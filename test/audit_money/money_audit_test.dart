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
import 'package:pg_manager/core/services/export_service.dart';
import 'package:pg_manager/core/utils/dates.dart';
import 'package:pg_manager/core/utils/money.dart';

void main() {
  setUpAll(() => initializeDateFormatting('en_IN'));

  late AppDatabase db;
  var phone = 9876500000;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.settingsDao.saveProfile(
      name: 'Audit PG',
      address: 'Somewhere 1',
      ownerName: 'Owner',
      ownerPhone: '9876543210',
    );
    await db.roomsDao.addRoom(roomNumber: '101', floor: 1, rentPaise: 900000, bedCount: 4);
    await db.roomsDao.addRoom(roomNumber: '201', floor: 2, rentPaise: 1200000, bedCount: 2);
  });
  tearDown(() => db.close());

  Future<List<int>> beds() async =>
      (await (db.select(db.beds)..orderBy([(b) => OrderingTerm.asc(b.id)])).get()).map((b) => b.id).toList();

  Future<int> tenant({
    String name = 'Arjun Mehta',
    DateTime? joining,
    int rent = 900000,
    int deposit = 0,
    int advance = 0,
    int bedIndex = 0,
    DateTime? now,
  }) async {
    phone++;
    return db.tenantsDao.createTenant(
      TenantInput(
        fullName: name,
        phone: '$phone',
        gender: Gender.male,
        joiningDate: joining ?? DateTime(2026, 11, 1),
        monthlyRentPaise: rent,
        rentDueDay: 5,
        securityDepositPaise: deposit,
        advancePaise: advance,
      ),
      bedId: (await beds())[bedIndex],
      now: now ?? DateTime(2026, 11, 20),
    );
  }

  Future<int> pay(
    int t,
    int amount,
    DateTime d, {
    PaymentMethod m = PaymentMethod.cash,
    String? utr,
    bool verified = true,
    int? invoiceId,
  }) => db.billingDao.recordPayment(
    PaymentInput(
      tenantId: t,
      amountPaise: amount,
      method: m,
      date: d,
      upiReference: utr,
      upiVerified: verified,
      invoiceId: invoiceId,
    ),
  );

  Future<List<RentInvoice>> invoices(int t) =>
      (db.select(db.rentInvoices)
            ..where((i) => i.tenantId.equals(t))
            ..orderBy([(i) => OrderingTerm.asc(i.periodStart), (i) => OrderingTerm.asc(i.id)]))
          .get();

  /// Core ledger invariants that must hold after every operation.
  Future<void> invariants(String step) async {
    final inv = await db.select(db.rentInvoices).get();
    for (final i in inv) {
      final row = await db
          .customSelect(
            'SELECT COALESCE(SUM(amount_paise),0) AS s FROM payment_allocations WHERE invoice_id = ?',
            variables: [Variable.withInt(i.id)],
          )
          .getSingle();
      expect(i.paidPaise, row.read<int>('s'), reason: '$step: invoice ${i.invoiceNumber} paid != allocations');
      if (i.status == InvoiceStatus.cancelled) {
        expect(i.paidPaise, 0, reason: '$step: cancelled ${i.invoiceNumber} still holds money');
      } else {
        expect(i.paidPaise, inInclusiveRange(0, i.totalPaise), reason: '$step: ${i.invoiceNumber} paid out of range');
        expect(
          i.totalPaise,
          i.rentPaise + i.additionalChargesPaise - i.discountPaise,
          reason: '$step: ${i.invoiceNumber} total != rent + extra - discount',
        );
      }
      final expected = i.status == InvoiceStatus.cancelled
          ? InvoiceStatus.cancelled
          : i.paidPaise >= i.totalPaise
          ? InvoiceStatus.paid
          : null;
      if (expected != null) expect(i.status, expected, reason: '$step: ${i.invoiceNumber} status');
    }
    for (final t in await db.select(db.tenants).get()) {
      final c = await db.billingDao.tenantCredit(t.id);
      expect(c, greaterThanOrEqualTo(0), reason: '$step: ${t.fullName} credit negative ($c)');
      // Never both money owed and unused credit for a current tenant.
      if ([TenantStatus.active, TenantStatus.noticeGiven, TenantStatus.newTenant].contains(t.status)) {
        final due = await db.billingDao.tenantOutstanding(t.id);
        expect(due > 0 && c > 0, isFalse, reason: '$step: ${t.fullName} has dues $due AND credit $c');
      }
      // Payment allocations never exceed what the payment brought in.
      final over = await db
          .customSelect(
            '''SELECT p.receipt_number AS r FROM payments p
           WHERE p.tenant_id = ? AND p.kind = 'payment' AND p.amount_paise <
             COALESCE((SELECT SUM(amount_paise) FROM payment_allocations WHERE payment_id = p.id), 0)''',
            variables: [Variable.withInt(t.id)],
          )
          .get();
      expect(over, isEmpty, reason: '$step: over-allocated payments ${over.map((r) => r.read<String>('r'))}');
    }
    // Unverified / rejected payments never carry allocations.
    final bad = await db
        .customSelect(
          "SELECT COUNT(*) AS c FROM payment_allocations pa JOIN payments p ON p.id = pa.payment_id WHERE p.status <> 'confirmed'",
        )
        .getSingle();
    expect(bad.read<int>('c'), 0, reason: '$step: unconfirmed payment allocated');
  }

  /// Dashboard, financial summary report and Payments-tab figures must agree.
  Future<void> crossScreen(DateRange r, String step) async {
    final s = await db.dashboardDao.summary(r, now: DateTime(2026, 12, 20));
    final rep = await db.reportsDao.build(ReportType.financialSummary, r);
    final m = {for (final x in rep.summary) x.$1: x.$2};
    expect(m['Rent billed'], Money.format(s.rentBilledPaise), reason: '$step billed');
    expect(m['Rent collected'], Money.format(s.rentCollectedPaise), reason: '$step collected');
    expect(m['Outstanding receivables'], Money.format(s.outstandingPaise), reason: '$step outstanding');
    expect(m['Expenses'], Money.format(s.expensesPaise), reason: '$step expenses');
    expect(m['Net cash flow'], Money.format(s.netCashFlowPaise), reason: '$step net');

    // Payments tab: invoices of the month.
    if (r.isSingleMonth) {
      final views = await db.billingDao.watchInvoices(year: r.start.year, month: r.start.month).first;
      final billed = views
          .where((v) => v.invoice.status != InvoiceStatus.cancelled)
          .fold<int>(0, (a, v) => a + v.invoice.totalPaise);
      expect(billed, s.rentBilledPaise, reason: '$step Payments-tab billed');
      final pays = await db.billingDao.watchPayments(range: r).first;
      final received = pays
          .where((v) => v.payment.status == PaymentStatus.confirmed && v.payment.method != PaymentMethod.deposit)
          .fold<int>(0, (a, v) => a + v.payment.amountPaise);
      expect(received, s.rentCollectedPaise, reason: '$step Payments-tab received');
      // Collection report "Confirmed" equals dashboard collected.
      final coll = await db.reportsDao.build(ReportType.collection, r);
      expect(
        {for (final x in coll.summary) x.$1: x.$2}['Confirmed'],
        Money.format(s.rentCollectedPaise),
        reason: '$step collection report',
      );
    }

    // Tenant list dues == detail outstanding == ledger balance (minus credit).
    final list = await db.tenantsDao.watchTenants(filter: TenantFilter.all).first;
    for (final it in list) {
      final d = (await db.tenantsDao.tenantDetail(it.tenant.id))!;
      expect(it.duesPaise, d.outstandingPaise, reason: '$step ${it.tenant.fullName} list vs detail');
      final ledger = await db.reportsDao.build(ReportType.tenantLedger, r, tenantId: it.tenant.id);
      final expectedBal = d.outstandingPaise - d.creditPaise;
      final last = ledger.rows.isEmpty ? Money.format(0) : ledger.rows.last.last;
      final shown = expectedBal < 0 ? '${Money.format(-expectedBal)} CR' : Money.format(expectedBal);
      expect(last, shown, reason: '$step ${it.tenant.fullName} ledger balance');
    }

    // Occupancy: dashboard vs rooms screen vs occupancy report.
    final rooms = await db.roomsDao.watchRooms().first;
    final occRooms = rooms.fold<int>(0, (a, x) => a + x.count(BedStatus.occupied));
    final bedsTotal = rooms.fold<int>(0, (a, x) => a + x.capacity);
    expect(s.occupiedBeds, occRooms, reason: '$step occupied');
    expect(s.totalBeds, bedsTotal, reason: '$step beds');
    expect(s.availableBeds, rooms.fold<int>(0, (a, x) => a + x.count(BedStatus.available)), reason: '$step available');
    final occ = await db.reportsDao.build(ReportType.occupancy, r);
    expect({for (final x in occ.summary) x.$1: x.$2}['Occupied'], '$occRooms', reason: '$step occupancy report');

    // CSV carries the same summary figures as the screen.
    final csv = ExportService.toCsv(rep);
    for (final x in rep.summary) {
      expect(csv, contains(x.$2.contains(',') ? '"${x.$2}"' : x.$2), reason: '$step CSV ${x.$1}');
    }
  }

  group('Lifecycle with invariants and cross-screen checks', () {
    test('multi-month: partial, over, advance, UPI states, reversal, transfer, notice, checkout, archive', () async {
      final a = await tenant(name: 'Arjun Mehta', deposit: 1000000, advance: 300000, bedIndex: 0);
      await invariants('register A');
      final b = await tenant(name: 'Bala Kumar', joining: DateTime(2026, 11, 16), bedIndex: 1);
      await invariants('register B');
      expect((await invoices(b)).single.rentPaise, 450000);

      await pay(a, 400000, DateTime(2026, 11, 3)); // advance 3000 + 4000 = 7000 of 9000
      await invariants('partial A');
      expect(await db.billingDao.tenantOutstanding(a), 200000);

      final upiPending = await pay(
        b,
        450000,
        DateTime(2026, 11, 18),
        m: PaymentMethod.upi,
        utr: 'UTR0001',
        verified: false,
      );
      await invariants('B pending UPI');
      await crossScreen(DateRange.month(2026, 11), 'Nov pending UPI');
      await db.billingDao.verifyUpiPayment(upiPending);
      await invariants('B UPI verified');

      final wrong = await pay(b, 50000, DateTime(2026, 11, 19), m: PaymentMethod.upi, utr: 'utr0002 ', verified: false);
      await db.billingDao.rejectUpiPayment(wrong, 'Not received');
      await invariants('B UPI rejected');

      await db.opsDao.addExpense(
        title: 'Power',
        category: ExpenseCategory.electricity,
        amountPaise: 230000,
        date: DateTime(2026, 11, 30),
        method: PaymentMethod.upi,
      );
      await crossScreen(DateRange.month(2026, 11), 'Nov end');

      await db.billingDao.generateMonthlyInvoices(2026, 12);
      await invariants('Dec generated');
      final over = await pay(a, 1500000, DateTime(2026, 12, 2)); // clears 2000 Nov + 9000 Dec + 4000 credit
      await invariants('A overpaid');
      expect(await db.billingDao.tenantCredit(a), 400000);

      await db.billingDao.reversePayment(over, 'Typed wrong amount');
      await invariants('A reversed');
      expect(await db.billingDao.tenantOutstanding(a), 1100000);
      expect(await db.billingDao.tenantCredit(a), 0);
      await pay(a, 1100000, DateTime(2026, 12, 3));
      await invariants('A paid correctly');

      // Transfer B mid-December to the costlier room.
      final bedIds = await beds();
      await db.tenantsDao.transfer(b, bedIds[4], DateTime(2026, 12, 10), newRentPaise: 1200000);
      await invariants('B transfer');
      await crossScreen(DateRange.month(2026, 12), 'Dec after transfer');

      await db.tenantsDao.giveNotice(a, DateTime(2026, 12, 5), DateTime(2027, 1, 4));
      final pv = await db.billingDao.previewCheckout(a, DateTime(2027, 1, 4), deductionsPaise: 50000);
      final res = await db.billingDao.checkout(
        a,
        DateTime(2027, 1, 4),
        deductionsPaise: 50000,
        deductionNote: 'Key lost',
      );
      await invariants('A checkout');
      expect(res.refundPaise - res.toCollectPaise, pv.settlementPaise, reason: 'preview == settlement');
      final ta = await (db.select(db.tenants)..where((x) => x.id.equals(a))).getSingle();
      expect(ta.depositAdjustedPaise + ta.depositRefundedPaise, 1000000, reason: 'deposit fully accounted');
      final dep = await db.reportsDao.build(ReportType.deposits, DateRange.month(2027, 1));
      final dm = {for (final x in dep.summary) x.$1: x.$2};
      expect(dm['Adjusted against dues'], Money.format(ta.depositAdjustedPaise));
      expect(dm['Refunded'], Money.format(ta.depositRefundedPaise));
      if (res.toCollectPaise == 0) {
        await db.tenantsDao.archive(a);
        await invariants('A archived');
      }
      await crossScreen(DateRange.month(2027, 1), 'Jan');
      await crossScreen(DateRange(DateTime(2026, 11, 1), DateTime(2027, 2, 1)), 'custom 3 months');
    });
  });

  group('Checkout edge cases (preview must equal settlement)', () {
    Future<void> check(int t, DateTime d, {int deductions = 0, int? expectRefund, int? expectCollect}) async {
      final p = await db.billingDao.previewCheckout(t, d, deductionsPaise: deductions);
      final r = await db.billingDao.checkout(t, d, deductionsPaise: deductions);
      await invariants('checkout $d');
      expect(r.refundPaise - r.toCollectPaise, p.settlementPaise, reason: 'preview vs settlement at $d');
      if (expectRefund != null) expect(r.refundPaise, expectRefund, reason: 'refund at $d');
      if (expectCollect != null) expect(r.toCollectPaise, expectCollect, reason: 'collect at $d');
    }

    test('leaves mid-month after paying the full month: unused days refunded', () async {
      final t = await tenant(deposit: 0);
      await pay(t, 900000, DateTime(2026, 11, 2));
      await check(
        t,
        DateTime(2026, 11, 10),
        expectRefund: 900000 - BillingMath.prorate(900000, 10, 30),
        expectCollect: 0,
      );
    });

    test('leaves on the 1st of the next month (unbilled)', () async {
      final t = await tenant(deposit: 500000);
      await pay(t, 900000, DateTime(2026, 11, 2));
      await check(
        t,
        DateTime(2026, 12, 1),
        expectRefund: 500000 - BillingMath.prorate(900000, 1, 31),
        expectCollect: 0,
      );
    });

    test('leaves on the last day: full month, no proration', () async {
      final t = await tenant(deposit: 500000);
      await check(t, DateTime(2026, 11, 30), expectRefund: 0, expectCollect: 400000);
    });

    test('joins and leaves in the same month', () async {
      final t = await tenant(joining: DateTime(2026, 11, 11), deposit: 1000000);
      await check(
        t,
        DateTime(2026, 11, 20),
        expectRefund: 1000000 - BillingMath.prorate(900000, 10, 30),
        expectCollect: 0,
      );
    });

    test('future-dated checkout next month', () async {
      final t = await tenant(deposit: 2000000);
      await check(t, DateTime(2026, 12, 15), expectRefund: 2000000 - 900000 - BillingMath.prorate(900000, 15, 31));
    });

    test('backdated checkout after later months were paid', () async {
      final t = await tenant(deposit: 0);
      await db.billingDao.generateMonthlyInvoices(2026, 12);
      await pay(t, 1800000, DateTime(2026, 12, 1));
      await check(
        t,
        DateTime(2026, 11, 15),
        expectRefund: 1800000 - BillingMath.prorate(900000, 15, 30),
        expectCollect: 0,
      );
    });

    test('deductions larger than deposit', () async {
      final t = await tenant(deposit: 100000);
      await pay(t, 900000, DateTime(2026, 11, 2));
      await check(t, DateTime(2026, 11, 30), deductions: 300000, expectRefund: 0, expectCollect: 200000);
    });

    test('rent increased by a transfer earlier in the final month', () async {
      final t = await tenant(deposit: 2000000);
      await db.tenantsDao.transfer(t, (await beds())[4], DateTime(2026, 11, 5), newRentPaise: 1200000);
      // November was invoiced at 9,000 before the transfer; tenant leaves 30 Nov.
      await check(t, DateTime(2026, 11, 30), expectRefund: 2000000 - 900000, expectCollect: 0);
    });
  });

  group('Calendar and numbering', () {
    test('leap-year February proration', () async {
      expect(BillingMath.daysInMonth(2028, 2), 29);
      expect(BillingMath.joiningMonthRent(2900000, DateTime(2028, 2, 15)), 1500000);
      final t = await tenant(joining: DateTime(2028, 2, 15), rent: 2900000, now: DateTime(2028, 2, 20));
      expect((await invoices(t)).single.rentPaise, 1500000);
    });

    test('invoice and receipt numbering roll over by year and stay unique across reversals', () async {
      final t = await tenant(joining: DateTime(2026, 12, 1), now: DateTime(2027, 1, 10));
      final inv = await invoices(t);
      expect(inv.map((i) => i.invoiceNumber), ['INV-202612-0001', 'INV-202701-0001']);
      final p1 = await pay(t, 100000, DateTime(2026, 12, 31));
      await db.billingDao.reversePayment(p1, 'test', date: DateTime(2027, 1, 1));
      final p2 = await pay(t, 100000, DateTime(2027, 1, 1));
      final all = await db.select(db.payments).get();
      expect(all.map((p) => p.receiptNumber).toSet().length, all.length);
      expect(all.firstWhere((p) => p.id == p2).receiptNumber, 'RCPT-2027-0001');
    });

    test('payment on the last day of the month counts in that month only', () async {
      final t = await tenant();
      await pay(t, 100000, DateTime(2026, 11, 30, 23, 59));
      expect((await db.dashboardDao.summary(DateRange.month(2026, 11))).rentCollectedPaise, 100000);
      expect((await db.dashboardDao.summary(DateRange.month(2026, 12))).rentCollectedPaise, 0);
    });
  });

  group('UTR handling', () {
    test('UTR duplicates are caught regardless of case and spaces', () async {
      final t = await tenant();
      await pay(t, 1000, DateTime(2026, 11, 3), m: PaymentMethod.upi, utr: '6123 4567 8901');
      expect(
        () => pay(t, 1000, DateTime(2026, 11, 3), m: PaymentMethod.upi, utr: '612345678901'),
        throwsA(isA<RuleException>()),
      );
    });

    test('a UTR from a rejected entry can be recorded again correctly', () async {
      final t = await tenant();
      final p = await pay(t, 90000, DateTime(2026, 11, 3), m: PaymentMethod.upi, utr: 'UTR777777', verified: false);
      await db.billingDao.rejectUpiPayment(p, 'Wrong amount typed');
      await pay(t, 900000, DateTime(2026, 11, 3), m: PaymentMethod.upi, utr: 'UTR777777');
      expect(await db.billingDao.tenantOutstanding(t), 0);
    });

    test('UPI verified after checkout is not silently stranded', () async {
      final t = await tenant(deposit: 900000);
      final p = await pay(t, 900000, DateTime(2026, 11, 28), m: PaymentMethod.upi, utr: 'LATE00001', verified: false);
      await db.billingDao.checkout(t, DateTime(2026, 11, 30));
      await db.billingDao.verifyUpiPayment(p);
      final credit = await db.billingDao.tenantCredit(t);
      final d = (await db.tenantsDao.tenantDetail(t))!;
      // Money exists as credit on a checked-out tenant; it must be visible somewhere.
      final list = await db.tenantsDao.watchTenants(filter: TenantFilter.checkedOut).first;
      expect(credit, 900000);
      expect(d.creditPaise, credit);
      expect(list.single.duesPaise, 0);
    });
  });

  group('Allocation order', () {
    test('a payment targeted at one invoice spills over oldest-first even with many open invoices', () async {
      final t = await tenant(joining: DateTime(2023, 1, 1), now: DateTime(2026, 11, 20)); // 47 open invoices
      final inv = await invoices(t);
      expect(inv.length, greaterThan(40));
      final target = inv[20];
      await pay(t, target.totalPaise + 2 * 900000, DateTime(2026, 11, 20), invoiceId: target.id);
      final after = await invoices(t);
      final paid = after.where((i) => i.paidPaise > 0).map((i) => i.periodStart).toList();
      expect(paid, [
        inv[0].periodStart,
        inv[1].periodStart,
        inv[20].periodStart,
      ], reason: 'spill-over must go to the oldest invoices');
    });
  });

  group('Receipts', () {
    test('receipt balance as of the payment, including invoices adjusted later', () async {
      final t = await tenant();
      final p1 = await pay(t, 300000, DateTime(2026, 11, 3));
      final inv = (await invoices(t)).single;
      await db.billingDao.adjustInvoice(inv.id, additionalChargesPaise: 100000, discountPaise: 0);
      final r = await db.billingDao.receiptData(p1);
      expect(r.outstandingPaise, 600000, reason: 'balance on the day of payment, before the later charge');
    });
  });
}
