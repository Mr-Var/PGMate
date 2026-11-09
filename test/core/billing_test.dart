import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pg_manager/core/database/app_database.dart';
import 'package:pg_manager/core/database/billing_math.dart';
import 'package:pg_manager/core/database/daos/billing_dao.dart';
import 'package:pg_manager/core/database/daos/reports_dao.dart';
import 'package:pg_manager/core/database/daos/tenants_dao.dart';
import 'package:pg_manager/core/database/enums.dart';
import 'package:pg_manager/core/database/rules.dart';
import 'package:pg_manager/core/utils/dates.dart';

void main() {
  setUpAll(() => initializeDateFormatting('en_IN'));

  late AppDatabase db;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.settingsDao.saveProfile(name: 'Test PG', address: 'Somewhere 1', ownerName: 'Owner', ownerPhone: '9876543210');
    await db.roomsDao.addRoom(roomNumber: '101', floor: 1, rentPaise: 900000, bedCount: 3);
  });
  tearDown(() => db.close());

  Future<List<int>> beds() async => (await db.select(db.beds).get()).map((b) => b.id).toList();

  Future<int> newTenant({
    String name = 'Arjun Mehta',
    String phone = '9876500001',
    DateTime? joining,
    int rent = 900000,
    int deposit = 0,
    int advance = 0,
    int? bed,
  }) async {
    final b = bed ?? (await beds()).first;
    return db.tenantsDao.createTenant(
      TenantInput(
        fullName: name,
        phone: phone,
        gender: Gender.male,
        joiningDate: joining ?? DateTime(2026, 11, 1),
        monthlyRentPaise: rent,
        rentDueDay: 5,
        securityDepositPaise: deposit,
        advancePaise: advance,
      ),
      bedId: b,
    );
  }

  Future<List<RentInvoice>> invoices(int tenantId) =>
      (db.select(db.rentInvoices)..where((i) => i.tenantId.equals(tenantId))..orderBy([(i) => OrderingTerm.asc(i.periodStart)])).get();

  group('BillingMath', () {
    test('prorates by days and rounds to paise', () {
      expect(BillingMath.joiningMonthRent(900000, DateTime(2026, 11, 1)), 900000);
      expect(BillingMath.joiningMonthRent(900000, DateTime(2026, 11, 16)), 450000); // 15 of 30 days
      expect(BillingMath.joiningMonthRent(1000000, DateTime(2026, 2, 15)), 500000); // 14 of 28 days
      expect(BillingMath.prorate(1000000, 1, 31), 32258);
    });

    test('due date never precedes joining', () {
      expect(BillingMath.dueDate(2026, 11, 5, DateTime(2026, 11, 20)), DateTime(2026, 11, 20));
      expect(BillingMath.dueDate(2026, 12, 5, DateTime(2026, 11, 20)), DateTime(2026, 12, 5));
    });
  });

  group('Registration', () {
    test('allocates the bed, marks it occupied and invoices the joining month prorated', () async {
      final id = await newTenant(joining: DateTime(2026, 11, 16));
      final t = await (db.select(db.tenants)..where((x) => x.id.equals(id))).getSingle();
      expect(t.status, TenantStatus.active);
      final firstBed = (await beds()).first;
      final bed = await (db.select(db.beds)..where((b) => b.id.equals(firstBed))).getSingle();
      expect(bed.status, BedStatus.occupied);
      final inv = (await invoices(id)).single;
      expect(inv.rentPaise, 450000);
      expect(inv.isProrated, isTrue);
      expect(inv.dueDate, DateTime(2026, 11, 16));
    });

    test('advance is recorded as a payment and settles the first invoice', () async {
      final id = await newTenant(advance: 1200000);
      final inv = (await invoices(id)).single;
      expect(inv.paidPaise, 900000);
      expect(inv.status, InvoiceStatus.paid);
      expect(await db.billingDao.tenantCredit(id), 300000);
    });

    test('a bed cannot be given to two tenants', () async {
      final b = (await beds()).first;
      await newTenant(bed: b);
      expect(() => newTenant(name: 'Bala', phone: '9876500002', bed: b), throwsA(isA<RuleException>()));
      // Nothing from the failed registration is left behind.
      expect(await db.select(db.tenants).get(), hasLength(1));
    });

    test('current tenants cannot share a phone number', () async {
      final ids = await beds();
      await newTenant(bed: ids[0]);
      expect(() => newTenant(name: 'Other', bed: ids[1]), throwsA(isA<RuleException>()));
    });
  });

  group('Monthly invoices', () {
    test('generation is idempotent and uses the rent at that time', () async {
      final id = await newTenant();
      final r1 = await db.billingDao.generateMonthlyInvoices(2026, 12);
      final r2 = await db.billingDao.generateMonthlyInvoices(2026, 12);
      expect(r1.created, 1);
      expect(r2.created, 0);
      expect(r2.skipped, 1);

      // A later rent change does not rewrite the December invoice.
      await (db.update(db.tenants)..where((t) => t.id.equals(id))).write(const TenantsCompanion(monthlyRentPaise: Value(1000000)));
      final dec = (await invoices(id)).last;
      expect(dec.rentPaise, 900000);
      await db.billingDao.generateMonthlyInvoices(2027, 1);
      expect((await invoices(id)).last.rentPaise, 1000000);
    });

    test('charges and discounts adjust the total but not below what is paid', () async {
      final id = await newTenant();
      final inv = (await invoices(id)).single;
      await db.billingDao.adjustInvoice(inv.id, additionalChargesPaise: 50000, discountPaise: 20000);
      expect((await invoices(id)).single.totalPaise, 930000);
      await db.billingDao.recordPayment(PaymentInput(tenantId: id, amountPaise: 900000, method: PaymentMethod.cash, date: DateTime(2026, 11, 3)));
      expect(
        () => db.billingDao.adjustInvoice(inv.id, additionalChargesPaise: 0, discountPaise: 100000),
        throwsA(isA<RuleException>()),
      );
    });

    test('invoices with payments cannot be cancelled', () async {
      final id = await newTenant();
      final inv = (await invoices(id)).single;
      await db.billingDao.recordPayment(PaymentInput(tenantId: id, amountPaise: 100, method: PaymentMethod.cash, date: DateTime(2026, 11, 3)));
      expect(() => db.billingDao.cancelInvoice(inv.id, 'mistake'), throwsA(isA<RuleException>()));
    });
  });

  group('Payments', () {
    test('partial payments, then overpayment becomes credit used by the next invoice', () async {
      final id = await newTenant();
      await db.billingDao.recordPayment(PaymentInput(tenantId: id, amountPaise: 400000, method: PaymentMethod.cash, date: DateTime(2026, 11, 3)));
      var inv = (await invoices(id)).single;
      // Partly paid; shown as overdue once the due date (5 Nov) has passed.
      expect(inv.status, isIn([InvoiceStatus.partiallyPaid, InvoiceStatus.overdue]));
      expect(inv.paidPaise, 400000);

      await db.billingDao.recordPayment(PaymentInput(tenantId: id, amountPaise: 700000, method: PaymentMethod.cash, date: DateTime(2026, 11, 10)));
      inv = (await invoices(id)).single;
      expect(inv.status, InvoiceStatus.paid);
      expect(await db.billingDao.tenantCredit(id), 200000);

      await db.billingDao.generateMonthlyInvoices(2026, 12);
      final dec = (await invoices(id)).last;
      expect(dec.paidPaise, 200000);
      expect(await db.billingDao.tenantCredit(id), 0);
      expect(await db.billingDao.tenantOutstanding(id), 700000);
    });

    test('unverified UPI is not allocated until the owner verifies it', () async {
      final id = await newTenant();
      final p = await db.billingDao.recordPayment(PaymentInput(
        tenantId: id,
        amountPaise: 900000,
        method: PaymentMethod.upi,
        date: DateTime(2026, 11, 3),
        upiReference: '612345678901',
      ));
      expect((await invoices(id)).single.paidPaise, 0);
      final summary1 = await db.dashboardDao.summary(DateRange.month(2026, 11));
      expect(summary1.rentCollectedPaise, 0);
      expect(summary1.pendingUpiCount, 1);

      await db.billingDao.verifyUpiPayment(p);
      expect((await invoices(id)).single.status, InvoiceStatus.paid);
      final summary2 = await db.dashboardDao.summary(DateRange.month(2026, 11));
      expect(summary2.rentCollectedPaise, 900000);
    });

    test('duplicate UTR is rejected with a clear message', () async {
      final id = await newTenant();
      final input = PaymentInput(tenantId: id, amountPaise: 1000, method: PaymentMethod.upi, date: DateTime(2026, 11, 3), upiReference: 'abc123456');
      await db.billingDao.recordPayment(input);
      expect(() => db.billingDao.recordPayment(input), throwsA(isA<RuleException>().having((e) => e.message, 'msg', contains('ABC123456'))));
    });

    test('rejected UPI never counts and cannot be reversed', () async {
      final id = await newTenant();
      final p = await db.billingDao.recordPayment(PaymentInput(
          tenantId: id, amountPaise: 5000, method: PaymentMethod.upi, date: DateTime(2026, 11, 3), upiReference: 'R0000001'));
      await db.billingDao.rejectUpiPayment(p, 'Not received');
      expect(() => db.billingDao.reversePayment(p, 'x'), throwsA(isA<RuleException>()));
      expect(await db.billingDao.tenantCredit(id), 0);
    });

    test('reversal restores the invoice balance and keeps the original record', () async {
      final id = await newTenant();
      final p = await db.billingDao.recordPayment(PaymentInput(tenantId: id, amountPaise: 900000, method: PaymentMethod.cash, date: DateTime(2026, 11, 3)));
      expect((await invoices(id)).single.status, InvoiceStatus.paid);

      await db.billingDao.reversePayment(p, 'Wrong tenant');
      final inv = (await invoices(id)).single;
      expect(inv.paidPaise, 0);
      expect(inv.status, isNot(InvoiceStatus.paid));
      final all = await db.select(db.payments).get();
      expect(all, hasLength(2));
      expect(all.map((x) => x.amountPaise), containsAll([900000, -900000]));
      expect(() => db.billingDao.reversePayment(p, 'again'), throwsA(isA<RuleException>()));
      // Net collected is zero.
      expect((await db.dashboardDao.summary(DateRange.month(2026, 11))).rentCollectedPaise, 0);
    });

    test('receipt numbers are sequential and unique', () async {
      final id = await newTenant();
      for (var i = 0; i < 3; i++) {
        await db.billingDao.recordPayment(PaymentInput(tenantId: id, amountPaise: 1000, method: PaymentMethod.cash, date: DateTime(2026, 11, 3)));
      }
      final nums = (await db.select(db.payments).get()).map((p) => p.receiptNumber).toList();
      expect(nums, ['RCPT-2026-0001', 'RCPT-2026-0002', 'RCPT-2026-0003']);
    });

    test('receipt data includes allocations and balance after payment', () async {
      final id = await newTenant();
      final p = await db.billingDao.recordPayment(PaymentInput(tenantId: id, amountPaise: 300000, method: PaymentMethod.cash, date: DateTime(2026, 11, 3)));
      final r = await db.billingDao.receiptData(p);
      expect(r.lines.single.amountPaise, 300000);
      expect(r.outstandingPaise, 600000);
      expect(r.roomLabel, 'Room 101 · Bed A');
    });
  });

  group('Checkout', () {
    test('prorates the final month, uses deposit for dues, refunds the rest, frees the bed', () async {
      final b = (await beds()).first;
      final id = await newTenant(deposit: 1500000, bed: b);
      await db.billingDao.generateMonthlyInvoices(2026, 12);
      // Nov paid, December unpaid. Leaves on 10 Dec: 10 of 31 days.
      await db.billingDao.recordPayment(PaymentInput(tenantId: id, amountPaise: 900000, method: PaymentMethod.cash, date: DateTime(2026, 11, 3)));

      final preview = await db.billingDao.previewCheckout(id, DateTime(2026, 12, 10), deductionsPaise: 50000);
      final dec10 = BillingMath.prorate(900000, 10, 31);
      expect(preview.finalMonthRentPaise, dec10);
      expect(preview.totalDuesPaise, dec10 + 50000);
      expect(preview.depositUsedPaise, dec10 + 50000);
      expect(preview.settlementPaise, 1500000 - dec10 - 50000);

      final result = await db.billingDao.checkout(id, DateTime(2026, 12, 10), deductionsPaise: 50000, deductionNote: 'Broken chair');
      expect(result.toCollectPaise, 0);
      expect(result.refundPaise, preview.settlementPaise);

      final t = await (db.select(db.tenants)..where((x) => x.id.equals(id))).getSingle();
      expect(t.status, TenantStatus.checkedOut);
      expect(t.depositAdjustedPaise, dec10 + 50000);
      expect(t.depositRefundedPaise, 1500000 - dec10 - 50000);
      final bed = await (db.select(db.beds)..where((x) => x.id.equals(b))).getSingle();
      expect(bed.status, BedStatus.available);
      expect(await db.select(db.allocations).get(), hasLength(1), reason: 'history kept');
      expect((await db.select(db.allocations).get()).single.isActive, isFalse);
      // Deposit adjustment is not counted as cash collected.
      expect((await db.dashboardDao.summary(DateRange.month(2026, 12))).rentCollectedPaise, 0);
      // The bed can now be given to someone else.
      await newTenant(name: 'Next Tenant', phone: '9876500009', bed: b, joining: DateTime(2026, 12, 11));
    });

    test('dues larger than the deposit remain to collect', () async {
      final id = await newTenant(deposit: 100000);
      final result = await db.billingDao.checkout(id, DateTime(2026, 11, 30));
      expect(result.refundPaise, 0);
      expect(result.toCollectPaise, 800000);
    });

    test('unused advance credit is refunded at checkout', () async {
      final id = await newTenant(advance: 1200000);
      final result = await db.billingDao.checkout(id, DateTime(2026, 11, 30));
      expect(result.refundPaise, 300000);
      expect(await db.billingDao.tenantCredit(id), 0);
    });
  });

  group('Tenant lifecycle', () {
    test('transfer keeps history and frees the old bed', () async {
      final ids = await beds();
      final id = await newTenant(bed: ids[0]);
      await db.tenantsDao.transfer(id, ids[1], DateTime(2026, 11, 20), newRentPaise: 950000);
      final allocs = await db.select(db.allocations).get();
      expect(allocs, hasLength(2));
      expect(allocs.where((a) => a.isActive).single.bedId, ids[1]);
      final old = await (db.select(db.beds)..where((b) => b.id.equals(ids[0]))).getSingle();
      expect(old.status, BedStatus.available);
      final t = await (db.select(db.tenants)..where((x) => x.id.equals(id))).getSingle();
      expect(t.monthlyRentPaise, 950000);
    });

    test('notice and archive rules', () async {
      final id = await newTenant();
      await db.tenantsDao.giveNotice(id, DateTime(2026, 11, 5), DateTime(2026, 12, 5));
      final s = await db.dashboardDao.summary(DateRange.month(2026, 11), now: DateTime(2026, 11, 10));
      expect(s.upcomingCheckouts.single.tenantName, 'Arjun Mehta');
      expect(() => db.tenantsDao.archive(id), throwsA(isA<RuleException>()));
    });
  });

  group('Reports', () {
    test('financial summary separates billed, collected, outstanding and expenses', () async {
      final id = await newTenant();
      await db.billingDao.recordPayment(PaymentInput(tenantId: id, amountPaise: 500000, method: PaymentMethod.cash, date: DateTime(2026, 11, 3)));
      await db.opsDao.addExpense(
          title: 'Power', category: ExpenseCategory.electricity, amountPaise: 200000, date: DateTime(2026, 11, 4), method: PaymentMethod.upi);
      final r = await db.reportsDao.build(ReportType.financialSummary, DateRange.month(2026, 11));
      final m = {for (final s in r.summary) s.$1: s.$2};
      expect(m['Rent billed'], '₹9,000');
      expect(m['Rent collected'], '₹5,000');
      expect(m['Outstanding receivables'], '₹4,000');
      expect(m['Expenses'], '₹2,000');
      expect(m['Net cash flow'], '₹3,000');
    });

    test('every report builds on real data', () async {
      final id = await newTenant(deposit: 500000);
      await db.billingDao.recordPayment(PaymentInput(tenantId: id, amountPaise: 300000, method: PaymentMethod.cash, date: DateTime(2026, 11, 3)));
      for (final type in ReportType.values) {
        final r = await db.reportsDao.build(type, DateRange.month(2026, 11), tenantId: id, today: DateTime(2026, 11, 20));
        expect(r.title, isNotEmpty, reason: type.name);
        for (final row in r.rows) {
          expect(row.length, r.columns.length, reason: '${type.name} row width');
        }
      }
      final ledger = await db.reportsDao.build(ReportType.tenantLedger, DateRange.month(2026, 11), tenantId: id);
      expect(ledger.rows.last.last, '₹6,000');
    });
  });
}
