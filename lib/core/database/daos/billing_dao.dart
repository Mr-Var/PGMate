import 'dart:math';

import 'package:drift/drift.dart';

import '../../utils/dates.dart';
import '../../utils/money.dart';
import '../app_database.dart';
import '../billing_math.dart';
import '../enums.dart';
import '../rules.dart';
import '../tables/finance_tables.dart';
import '../tables/operations_tables.dart';
import '../tables/property_tables.dart';

part 'billing_dao.g.dart';

class PaymentInput {
  const PaymentInput({
    required this.tenantId,
    required this.amountPaise,
    required this.method,
    required this.date,
    this.invoiceId,
    this.upiReference,
    this.upiVerified = false,
    this.notes,
  });

  final int tenantId;
  final int amountPaise;
  final PaymentMethod method;
  final DateTime date;

  /// Invoice to settle first. Any remainder goes to the oldest dues, then
  /// stays as advance credit.
  final int? invoiceId;
  final String? upiReference;

  /// The owner confirmed the money arrived in their UPI/bank app.
  final bool upiVerified;
  final String? notes;
}

class GenerateResult {
  const GenerateResult(this.created, this.skipped);
  final int created;
  final int skipped;
}

class CheckoutPreview {
  const CheckoutPreview({
    required this.checkoutDate,
    required this.daysInFinalMonth,
    required this.monthlyRentPaise,
    required this.finalMonthRentPaise,
    required this.finalMonthInvoiced,
    required this.outstandingPaise,
    this.unbilledPaise = 0,
    required this.creditPaise,
    required this.depositPaise,
    required this.deductionsPaise,
    this.refundPaise,
    this.collectPaise,
  });

  final DateTime checkoutDate;
  final int daysInFinalMonth;
  final int monthlyRentPaise;

  /// Rent for the days stayed in the checkout month.
  final int finalMonthRentPaise;

  /// What the existing invoice for that month charges as rent (0 if none).
  final int finalMonthInvoiced;

  /// Unpaid balance on invoices up to the checkout month.
  final int outstandingPaise;

  /// Rent for earlier months that were never invoiced (billed at checkout).
  final int unbilledPaise;
  final int creditPaise;
  final int depositPaise;
  final int deductionsPaise;

  /// Exact settlement from a rolled-back dry run of the checkout.
  final int? refundPaise;
  final int? collectPaise;

  CheckoutPreview withSettlement({required int refundPaise, required int collectPaise}) => CheckoutPreview(
    checkoutDate: checkoutDate,
    daysInFinalMonth: daysInFinalMonth,
    monthlyRentPaise: monthlyRentPaise,
    finalMonthRentPaise: finalMonthRentPaise,
    finalMonthInvoiced: finalMonthInvoiced,
    outstandingPaise: outstandingPaise,
    unbilledPaise: unbilledPaise,
    creditPaise: creditPaise,
    depositPaise: depositPaise,
    deductionsPaise: deductionsPaise,
    refundPaise: refundPaise,
    collectPaise: collectPaise,
  );

  /// Change to the final month: a new invoice for the days stayed, or the
  /// reduction of an existing one (never an increase).
  int get finalMonthAdjustmentPaise =>
      finalMonthInvoiced == 0 ? finalMonthRentPaise : finalMonthRentPaise - finalMonthInvoiced;

  /// Net owed before credit and deposit; negative means money comes back.
  int get netDuesPaise => outstandingPaise + unbilledPaise + finalMonthAdjustmentPaise + deductionsPaise;

  int get totalDuesPaise => max(0, netDuesPaise);
  int get _credit => creditPaise + max(0, -netDuesPaise);
  int get _afterCredit => max(0, totalDuesPaise - _credit);
  int get creditLeftPaise => max(0, _credit - totalDuesPaise);
  int get depositUsedPaise => min(depositPaise, _afterCredit);
  int get depositRefundPaise => depositPaise - depositUsedPaise;

  /// Positive: owner refunds this. Negative: tenant must still pay this.
  int get settlementPaise => refundPaise != null && collectPaise != null
      ? refundPaise! - collectPaise!
      : depositRefundPaise + creditLeftPaise - (_afterCredit - depositUsedPaise);
}

class CheckoutResult {
  const CheckoutResult({required this.refundPaise, required this.toCollectPaise});
  final int refundPaise;
  final int toCollectPaise;
}

class _Rollback implements Exception {
  const _Rollback();
}

class InvoiceView {
  const InvoiceView(this.invoice, this.tenantName, this.roomLabel);
  final RentInvoice invoice;
  final String tenantName;
  final String? roomLabel;
  int get balancePaise => invoice.status == InvoiceStatus.cancelled ? 0 : invoice.totalPaise - invoice.paidPaise;
}

class PaymentView {
  const PaymentView(this.payment, this.tenantName, {this.isReversed = false});
  final Payment payment;
  final String tenantName;
  final bool isReversed;
}

class ReceiptLine {
  const ReceiptLine({required this.invoiceNumber, required this.period, required this.amountPaise});
  final String invoiceNumber;
  final DateTime period;
  final int amountPaise;
}

class ReceiptData {
  const ReceiptData({
    required this.profile,
    required this.tenant,
    required this.payment,
    required this.lines,
    required this.roomLabel,
    required this.outstandingPaise,
    required this.creditPaise,
  });

  final PgProfile profile;
  final Tenant tenant;
  final Payment payment;
  final List<ReceiptLine> lines;
  final String? roomLabel;
  final int outstandingPaise;
  final int creditPaise;
}

@DriftAccessor(
  tables: [Tenants, Allocations, Beds, Rooms, RentInvoices, Payments, PaymentAllocations, AuditLogs, PgProfiles],
)
class BillingDao extends DatabaseAccessor<AppDatabase> with _$BillingDaoMixin {
  BillingDao(super.db);

  static final _rnd = Random.secure();

  static const _current = [TenantStatus.newTenant, TenantStatus.active, TenantStatus.noticeGiven];

  // ---------------------------------------------------------------------------
  // Invoices
  // ---------------------------------------------------------------------------

  Future<String> _invoiceNumber(int year, int month) async {
    final n = await db.settingsDao.nextSequence('invoice_$year');
    return 'INV-$year${month.toString().padLeft(2, '0')}-${n.toString().padLeft(4, '0')}';
  }

  Future<RentInvoice?> invoiceFor(int tenantId, int year, int month) {
    return (select(rentInvoices)..where(
          (i) =>
              i.tenantId.equals(tenantId) &
              i.periodYear.equals(year) &
              i.periodMonth.equals(month) &
              i.status.equalsValue(InvoiceStatus.cancelled).not(),
        ))
        .getSingleOrNull();
  }

  /// Generates invoices for every current tenant with a bed for the month.
  /// Existing invoices are skipped, so running it twice is safe.
  /// The day rent starts: when the tenant first got a bed. Null if never.
  Future<DateTime?> billingStart(int tenantId) async {
    final row = await customSelect(
      'SELECT MIN(start_date) AS s FROM allocations WHERE tenant_id = ?',
      variables: [Variable.withInt(tenantId)],
    ).getSingle();
    final secs = row.read<int?>('s');
    return secs == null ? null : Dates.today(DateTime.fromMillisecondsSinceEpoch(secs * 1000));
  }

  /// Months from the billing start up to [upTo] that have no invoice yet.
  Future<List<DateTime>> missingMonths(int tenantId, DateTime upTo) async {
    final start = await billingStart(tenantId);
    if (start == null) return const [];
    final billed = await customSelect(
      "SELECT period_year AS y, period_month AS m FROM rent_invoices WHERE tenant_id = ? AND status <> 'cancelled'",
      variables: [Variable.withInt(tenantId)],
    ).get();
    final have = {for (final r in billed) r.read<int>('y') * 100 + r.read<int>('m')};
    return [
      for (final m in BillingMath.monthsBetween(start, upTo))
        if (!have.contains(m.year * 100 + m.month)) m,
    ];
  }

  /// Bills every missing month for one tenant up to [upTo] (inclusive).
  Future<int> generateMissingFor(int tenantId, DateTime upTo, {DateTime? today}) async {
    final t = await (select(tenants)..where((x) => x.id.equals(tenantId))).getSingle();
    final start = await billingStart(tenantId);
    if (start == null) return 0;
    final alloc = await (select(
      allocations,
    )..where((a) => a.tenantId.equals(tenantId) & a.isActive.equals(true))).getSingleOrNull();
    var n = 0;
    for (final m in await missingMonths(tenantId, upTo)) {
      final rent = BillingMath.rentForMonth(t.monthlyRentPaise, start, m.year, m.month);
      if (rent <= 0) continue;
      final startsHere = start.year == m.year && start.month == m.month;
      await _insertInvoice(
        tenantId: tenantId,
        allocationId: alloc?.id,
        year: m.year,
        month: m.month,
        rentPaise: rent,
        dueDate: BillingMath.dueDate(m.year, m.month, t.rentDueDay, start),
        prorated: startsHere && start.day > 1,
        today: today,
      );
      n++;
    }
    if (n > 0) await applyCredit(tenantId);
    return n;
  }

  /// Bills one month for every current tenant with a bed. Safe to repeat.
  Future<GenerateResult> generateMonthlyInvoices(int year, int month, {DateTime? today}) {
    return transaction(() async {
      final monthEnd = DateTime(year, month + 1);
      final rows = await (select(tenants).join([
        innerJoin(allocations, allocations.tenantId.equalsExp(tenants.id) & allocations.isActive.equals(true)),
      ])..where(tenants.status.isInValues(_current))).get();

      var created = 0;
      var skipped = 0;
      for (final row in rows) {
        final t = row.readTable(tenants);
        final a = row.readTable(allocations);
        final start = await billingStart(t.id);
        if (start == null || !start.isBefore(monthEnd)) continue;
        if (await invoiceFor(t.id, year, month) != null) {
          skipped++;
          continue;
        }
        final startsHere = start.year == year && start.month == month;
        await _insertInvoice(
          tenantId: t.id,
          allocationId: a.id,
          year: year,
          month: month,
          rentPaise: BillingMath.rentForMonth(t.monthlyRentPaise, start, year, month),
          dueDate: BillingMath.dueDate(year, month, t.rentDueDay, start),
          prorated: startsHere && start.day > 1,
          today: today,
        );
        await applyCredit(t.id);
        created++;
      }
      await db.settingsDao.log('invoice', null, 'generate', '$year-$month: $created created, $skipped skipped');
      return GenerateResult(created, skipped);
    });
  }

  /// Bills every month any current tenant is missing, up to this month.
  Future<int> generateAllMissing({DateTime? now}) {
    return transaction(() async {
      final upTo = now ?? DateTime.now();
      final ids = await customSelect(
        """SELECT DISTINCT t.id FROM tenants t JOIN allocations a ON a.tenant_id = t.id AND a.is_active = 1
           WHERE t.status IN ('newTenant','active','noticeGiven')""",
      ).get();
      var n = 0;
      for (final r in ids) {
        n += await generateMissingFor(r.read<int>('id'), upTo);
      }
      await db.settingsDao.log('invoice', null, 'generate_missing', '$n created');
      return n;
    });
  }

  /// Number of (tenant, month) invoices missing up to this month.
  Stream<int> watchMissingInvoiceCount() {
    return customSelect('SELECT 1', readsFrom: {tenants, allocations, rentInvoices}).watch().asyncMap((_) async {
      final ids = await customSelect(
        """SELECT DISTINCT t.id FROM tenants t JOIN allocations a ON a.tenant_id = t.id AND a.is_active = 1
           WHERE t.status IN ('newTenant','active','noticeGiven')""",
      ).get();
      var n = 0;
      for (final r in ids) {
        n += (await missingMonths(r.read<int>('id'), DateTime.now())).length;
      }
      return n;
    });
  }

  Future<int> createInvoice({
    required int tenantId,
    required int year,
    required int month,
    required int rentPaise,
    int additionalChargesPaise = 0,
    int discountPaise = 0,
    DateTime? dueDate,
    String? notes,
    bool prorated = false,
  }) {
    return transaction(() async {
      final tenant = await (select(tenants)..where((t) => t.id.equals(tenantId))).getSingle();
      if (await invoiceFor(tenantId, year, month) != null) {
        throw RuleException('${tenant.fullName} already has an invoice for ${Dates.monthYear(DateTime(year, month))}.');
      }
      if (rentPaise + additionalChargesPaise - discountPaise < 0) {
        throw RuleException('Discount cannot be more than the invoice amount.');
      }
      final alloc = await (select(
        allocations,
      )..where((a) => a.tenantId.equals(tenantId) & a.isActive.equals(true))).getSingleOrNull();
      final id = await _insertInvoice(
        tenantId: tenantId,
        allocationId: alloc?.id,
        year: year,
        month: month,
        rentPaise: rentPaise,
        additionalPaise: additionalChargesPaise,
        discountPaise: discountPaise,
        dueDate: dueDate ?? BillingMath.dueDate(year, month, tenant.rentDueDay, tenant.joiningDate),
        prorated: prorated,
        notes: notes,
      );
      await applyCredit(tenantId);
      return id;
    });
  }

  Future<int> _insertInvoice({
    required int tenantId,
    required int? allocationId,
    required int year,
    required int month,
    required int rentPaise,
    required DateTime dueDate,
    int additionalPaise = 0,
    int discountPaise = 0,
    bool prorated = false,
    String? notes,
    DateTime? today,
  }) async {
    final total = rentPaise + additionalPaise - discountPaise;
    final id = await into(rentInvoices).insert(
      RentInvoicesCompanion.insert(
        invoiceNumber: await _invoiceNumber(year, month),
        tenantId: tenantId,
        allocationId: Value(allocationId),
        periodYear: year,
        periodMonth: month,
        periodStart: DateTime(year, month),
        periodEnd: DateTime(year, month + 1),
        rentPaise: rentPaise,
        additionalChargesPaise: Value(additionalPaise),
        discountPaise: Value(discountPaise),
        totalPaise: total,
        dueDate: dueDate,
        isProrated: Value(prorated),
        notes: Value(notes),
        status: Value(_statusFor(total, 0, dueDate, today)),
      ),
    );
    await db.settingsDao.log('invoice', id, 'create', Money.format(total));
    return id;
  }

  static InvoiceStatus _statusFor(int total, int paid, DateTime due, [DateTime? today]) {
    if (paid >= total) return InvoiceStatus.paid;
    if (Dates.today(today).isAfter(due)) return InvoiceStatus.overdue;
    return paid > 0 ? InvoiceStatus.partiallyPaid : InvoiceStatus.unpaid;
  }

  /// Changes extra charges / discount on an open invoice. Rent stays frozen.
  Future<void> adjustInvoice(
    int invoiceId, {
    required int additionalChargesPaise,
    required int discountPaise,
    String? notes,
  }) {
    return transaction(() async {
      final inv = await (select(rentInvoices)..where((i) => i.id.equals(invoiceId))).getSingle();
      if (inv.status == InvoiceStatus.cancelled) throw RuleException('Cancelled invoices cannot be changed.');
      final total = inv.rentPaise + additionalChargesPaise - discountPaise;
      if (total < 0) throw RuleException('Discount cannot be more than the invoice amount.');
      if (total < inv.paidPaise) {
        throw RuleException(
          '${Money.format(inv.paidPaise)} is already paid on this invoice. '
          'The total cannot go below that; reverse a payment first.',
        );
      }
      await (update(rentInvoices)..where((i) => i.id.equals(invoiceId))).write(
        RentInvoicesCompanion(
          additionalChargesPaise: Value(additionalChargesPaise),
          discountPaise: Value(discountPaise),
          totalPaise: Value(total),
          notes: notes == null ? const Value.absent() : Value(notes),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _recompute(invoiceId);
      await applyCredit(inv.tenantId);
      await db.settingsDao.log('invoice', invoiceId, 'adjust', 'total ${Money.format(total)}');
    });
  }

  Future<void> cancelInvoice(int invoiceId, String reason) {
    return transaction(() async {
      final inv = await (select(rentInvoices)..where((i) => i.id.equals(invoiceId))).getSingle();
      if (inv.status == InvoiceStatus.cancelled) return;
      if (inv.paidPaise > 0) {
        throw RuleException('This invoice has payments. Reverse them before cancelling.');
      }
      await (update(rentInvoices)..where((i) => i.id.equals(invoiceId))).write(
        RentInvoicesCompanion(
          status: const Value(InvoiceStatus.cancelled),
          cancelledAt: Value(DateTime.now()),
          cancelReason: Value(reason),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await db.settingsDao.log('invoice', invoiceId, 'cancel', reason);
    });
  }

  /// Recalculates paid amount and status from the allocation ledger.
  Future<void> _recompute(int invoiceId, [DateTime? today]) async {
    final inv = await (select(rentInvoices)..where((i) => i.id.equals(invoiceId))).getSingle();
    final paidRow = await customSelect(
      'SELECT COALESCE(SUM(amount_paise), 0) AS v FROM payment_allocations WHERE invoice_id = ?',
      variables: [Variable.withInt(invoiceId)],
    ).getSingle();
    final paid = paidRow.read<int>('v');
    final status = inv.status == InvoiceStatus.cancelled
        ? InvoiceStatus.cancelled
        : _statusFor(inv.totalPaise, paid, inv.dueDate, today);
    await (update(rentInvoices)..where((i) => i.id.equals(invoiceId))).write(
      RentInvoicesCompanion(paidPaise: Value(paid), status: Value(status), updatedAt: Value(DateTime.now())),
    );
  }

  /// Moves unpaid invoices past their due date to overdue. Safe to call often.
  Future<int> refreshOverdue([DateTime? today]) {
    final t = Dates.today(today);
    return (update(rentInvoices)..where(
          (i) =>
              i.status.isInValues([InvoiceStatus.unpaid, InvoiceStatus.partiallyPaid]) &
              i.dueDate.isSmallerThanValue(t),
        ))
        .write(const RentInvoicesCompanion(status: Value(InvoiceStatus.overdue)));
  }

  // ---------------------------------------------------------------------------
  // Payments
  // ---------------------------------------------------------------------------

  static String _txnId() {
    final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(36).toUpperCase();
    final r = List.generate(6, (_) => _rnd.nextInt(36).toRadixString(36)).join().toUpperCase();
    return 'TXN-$ts-$r';
  }

  Future<String> _receiptNumber(DateTime date, {bool reversal = false}) async {
    final n = await db.settingsDao.nextSequence('${reversal ? 'reversal' : 'receipt'}_${date.year}');
    return '${reversal ? 'REV' : 'RCPT'}-${date.year}-${n.toString().padLeft(4, '0')}';
  }

  /// UTRs are compared without case, spaces or dashes.
  static String? normalizeUtr(String? raw) => raw?.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');

  /// Freezes the tenant's balance on a payment row once it counts, so a
  /// reprinted receipt always shows the balance of that day.
  Future<void> _freezeBalance(int paymentId, int tenantId) async {
    final int bal = await tenantOutstanding(tenantId) - max(0, await tenantCredit(tenantId));
    await customUpdate(
      'UPDATE payments SET balance_after_paise = ? WHERE id = ?',
      variables: [Variable.withInt(bal), Variable.withInt(paymentId)],
      updates: {payments},
    );
  }

  /// Records money received. Cash (and pre-verified UPI) is confirmed and
  /// allocated immediately; unverified UPI waits for the owner's confirmation.
  Future<int> recordPayment(PaymentInput input) {
    if (input.amountPaise <= 0) throw RuleException('Amount must be more than ₹0.');
    if (input.method == PaymentMethod.upi && (input.upiReference == null || input.upiReference!.trim().length < 6)) {
      throw RuleException('Enter the UPI transaction reference (UTR).');
    }
    return transaction(() async {
      final utr = normalizeUtr(input.upiReference);
      if (utr != null && utr.isNotEmpty) {
        final dup =
            await (select(payments)..where(
                  (p) =>
                      p.upiReference.equals(utr) &
                      p.kind.equalsValue(PaymentKind.payment) &
                      p.status.equalsValue(PaymentStatus.rejected).not(),
                ))
                .getSingleOrNull();
        if (dup != null) {
          throw RuleException('UTR $utr is already recorded on receipt ${dup.receiptNumber}.');
        }
      }
      final confirmed = input.method != PaymentMethod.upi || input.upiVerified;
      final id = await into(payments).insert(
        PaymentsCompanion.insert(
          transactionId: _txnId(),
          receiptNumber: await _receiptNumber(input.date),
          tenantId: input.tenantId,
          amountPaise: input.amountPaise,
          method: input.method,
          upiReference: Value(utr == null || utr.isEmpty ? null : utr),
          paymentDate: input.date,
          status: confirmed ? PaymentStatus.confirmed : PaymentStatus.pendingVerification,
          notes: Value(input.notes?.trim().isEmpty ?? true ? null : input.notes!.trim()),
          verifiedAt: Value(confirmed && input.method == PaymentMethod.upi ? DateTime.now() : null),
        ),
      );
      if (confirmed) {
        await _allocate(id, input.tenantId, preferredInvoiceId: input.invoiceId);
        await _freezeBalance(id, input.tenantId);
      }
      await db.settingsDao.log('payment', id, 'create', '${input.method.name} ${Money.format(input.amountPaise)}');
      return id;
    });
  }

  /// Possible duplicate: same tenant, method and amount on the same day.
  Future<Payment?> findSimilarPayment(int tenantId, int amountPaise, DateTime date) {
    final day = Dates.today(date);
    return (select(payments)..where(
          (p) =>
              p.tenantId.equals(tenantId) &
              p.amountPaise.equals(amountPaise) &
              p.kind.equalsValue(PaymentKind.payment) &
              p.status.equalsValue(PaymentStatus.rejected).not() &
              p.paymentDate.isBiggerOrEqualValue(day) &
              p.paymentDate.isSmallerThanValue(day.add(const Duration(days: 1))),
        ))
        .get()
        .then((l) => l.firstOrNull);
  }

  Future<void> verifyUpiPayment(int paymentId) {
    return transaction(() async {
      final p = await (select(payments)..where((x) => x.id.equals(paymentId))).getSingle();
      if (p.status != PaymentStatus.pendingVerification) return;
      await (update(payments)..where((x) => x.id.equals(paymentId))).write(
        PaymentsCompanion(status: const Value(PaymentStatus.confirmed), verifiedAt: Value(DateTime.now())),
      );
      await _allocate(paymentId, p.tenantId);
      await _freezeBalance(paymentId, p.tenantId);
      await db.settingsDao.log('payment', paymentId, 'verify');
    });
  }

  Future<void> rejectUpiPayment(int paymentId, String reason) {
    return transaction(() async {
      final p = await (select(payments)..where((x) => x.id.equals(paymentId))).getSingle();
      if (p.status != PaymentStatus.pendingVerification) {
        throw RuleException('Only payments awaiting verification can be rejected.');
      }
      await (update(payments)..where((x) => x.id.equals(paymentId))).write(
        PaymentsCompanion(
          status: const Value(PaymentStatus.rejected),
          notes: Value([p.notes, 'Rejected: $reason'].whereType<String>().join('\n')),
        ),
      );
      await db.settingsDao.log('payment', paymentId, 'reject', reason);
    });
  }

  Future<bool> isReversed(int paymentId) async =>
      (await (select(payments)..where((p) => p.reversesPaymentId.equals(paymentId))).get()).isNotEmpty;

  /// Reverses a confirmed payment with a negative entry and undoes its
  /// invoice allocations. The original record is kept unchanged.
  Future<int> reversePayment(int paymentId, String reason, {DateTime? date}) {
    return transaction(() async {
      final p = await (select(payments)..where((x) => x.id.equals(paymentId))).getSingle();
      if (p.kind != PaymentKind.payment || p.status != PaymentStatus.confirmed) {
        throw RuleException('Only confirmed payments can be reversed.');
      }
      if (await isReversed(paymentId)) throw RuleException('This payment is already reversed.');
      final when = date ?? DateTime.now();
      final revId = await into(payments).insert(
        PaymentsCompanion.insert(
          transactionId: _txnId(),
          receiptNumber: await _receiptNumber(when, reversal: true),
          tenantId: p.tenantId,
          amountPaise: -p.amountPaise,
          method: p.method,
          paymentDate: when,
          status: PaymentStatus.confirmed,
          kind: const Value(PaymentKind.reversal),
          reversesPaymentId: Value(paymentId),
          notes: Value('Reversal of ${p.receiptNumber}: $reason'),
        ),
      );
      final allocs = await customSelect(
        'SELECT invoice_id, SUM(amount_paise) AS a FROM payment_allocations WHERE payment_id = ? GROUP BY invoice_id',
        variables: [Variable.withInt(paymentId)],
      ).get();
      for (final a in allocs) {
        final amount = a.read<int>('a');
        if (amount == 0) continue;
        final invoiceId = a.read<int>('invoice_id');
        await into(paymentAllocations)
            .insert(PaymentAllocationsCompanion.insert(paymentId: revId, invoiceId: invoiceId, amountPaise: -amount));
        await _recompute(invoiceId);
      }
      await applyCredit(p.tenantId);
      await _freezeBalance(revId, p.tenantId);
      await db.settingsDao.log('payment', paymentId, 'reverse', reason);
      return revId;
    });
  }

  Future<int> _unallocated(int paymentId) async {
    final row = await customSelect(
      'SELECT p.amount_paise - COALESCE((SELECT SUM(amount_paise) FROM payment_allocations WHERE payment_id = p.id), 0) AS v '
      'FROM payments p WHERE p.id = ?',
      variables: [Variable.withInt(paymentId)],
    ).getSingle();
    return row.read<int>('v');
  }

  /// Spreads a payment over the preferred invoice, then the oldest dues.
  Future<void> _allocate(int paymentId, int tenantId, {int? preferredInvoiceId, int? limit}) async {
    var remaining = await _unallocated(paymentId);
    if (limit != null) remaining = min(remaining, limit);
    if (remaining <= 0) return;
    final open =
        await (select(rentInvoices)
              ..where(
                (i) =>
                    i.tenantId.equals(tenantId) &
                    i.status.equalsValue(InvoiceStatus.cancelled).not() &
                    i.totalPaise.isBiggerThan(i.paidPaise),
              )
              ..orderBy([(i) => OrderingTerm.asc(i.periodStart), (i) => OrderingTerm.asc(i.id)]))
            .get();
    if (preferredInvoiceId != null) {
      final i = open.indexWhere((x) => x.id == preferredInvoiceId);
      if (i > 0) open.insert(0, open.removeAt(i));
    }
    for (final inv in open) {
      if (remaining <= 0) break;
      final take = min(remaining, inv.totalPaise - inv.paidPaise);
      await into(paymentAllocations)
          .insert(PaymentAllocationsCompanion.insert(paymentId: paymentId, invoiceId: inv.id, amountPaise: take));
      await _recompute(inv.id);
      remaining -= take;
    }
  }

  /// Advance/credit = confirmed money in (and out) minus what is allocated.
  Future<int> tenantCredit(int tenantId) async {
    final row = await customSelect(
      '''SELECT
           COALESCE((SELECT SUM(amount_paise) FROM payments WHERE tenant_id = ?1 AND status = 'confirmed'), 0)
         - COALESCE((SELECT SUM(pa.amount_paise) FROM payment_allocations pa
                       JOIN payments p ON p.id = pa.payment_id WHERE p.tenant_id = ?1), 0) AS v''',
      variables: [Variable.withInt(tenantId)],
    ).getSingle();
    return row.read<int>('v');
  }

  Future<int> tenantOutstanding(int tenantId) async {
    final row = await customSelect(
      "SELECT COALESCE(SUM(total_paise - paid_paise), 0) AS v FROM rent_invoices WHERE tenant_id = ? AND status <> 'cancelled'",
      variables: [Variable.withInt(tenantId)],
    ).getSingle();
    return row.read<int>('v');
  }

  /// Uses any advance credit to pay open invoices, oldest first.
  Future<void> applyCredit(int tenantId) async {
    var credit = await tenantCredit(tenantId);
    if (credit <= 0) return;
    final sources = await customSelect(
      '''SELECT p.id FROM payments p
         WHERE p.tenant_id = ? AND p.status = 'confirmed' AND p.kind = 'payment'
           AND NOT EXISTS (SELECT 1 FROM payments r WHERE r.reverses_payment_id = p.id)
         ORDER BY p.payment_date, p.id''',
      variables: [Variable.withInt(tenantId)],
    ).get();
    for (final s in sources) {
      if (credit <= 0) break;
      final id = s.read<int>('id');
      final before = await _unallocated(id);
      if (before <= 0) continue;
      await _allocate(id, tenantId, limit: credit);
      credit -= before - await _unallocated(id);
    }
  }

  // ---------------------------------------------------------------------------
  // Checkout
  // ---------------------------------------------------------------------------

  /// Breakdown for the checkout screen. The settlement figures come from a
  /// dry run of [checkout] that is rolled back, so the preview always equals
  /// what the real checkout will do.
  Future<CheckoutPreview> previewCheckout(int tenantId, DateTime checkoutDate, {int deductionsPaise = 0}) async {
    final info = await _checkoutInfo(tenantId, checkoutDate, deductionsPaise: deductionsPaise);
    final t = await (select(tenants)..where((x) => x.id.equals(tenantId))).getSingle();
    if (!_current.contains(t.status)) return info;
    CheckoutResult? dry;
    try {
      await transaction(() async {
        dry = await checkout(tenantId, checkoutDate, deductionsPaise: deductionsPaise);
        throw const _Rollback();
      });
    } on _Rollback {
      // Expected: nothing from the dry run is kept.
    }
    return info.withSettlement(refundPaise: dry!.refundPaise, collectPaise: dry!.toCollectPaise);
  }

  Future<CheckoutPreview> _checkoutInfo(int tenantId, DateTime checkoutDate, {int deductionsPaise = 0}) async {
    final t = await (select(tenants)..where((x) => x.id.equals(tenantId))).getSingle();
    final date = Dates.today(checkoutDate);
    if (date.isBefore(Dates.today(t.joiningDate))) {
      throw RuleException('Checkout date cannot be before the joining date (${Dates.short(t.joiningDate)}).');
    }
    final start = await billingStart(tenantId);
    final dim = BillingMath.daysInMonth(date.year, date.month);
    var days = 0;
    var finalRent = 0;
    var unbilled = 0;
    if (start != null && !start.isAfter(date)) {
      final startsThisMonth = start.year == date.year && start.month == date.month;
      days = date.day - (startsThisMonth ? start.day : 1) + 1;
      finalRent = BillingMath.prorate(t.monthlyRentPaise, days, dim);
      final lastFull = DateTime(date.year, date.month - 1);
      for (final m in await missingMonths(tenantId, lastFull)) {
        unbilled += BillingMath.rentForMonth(t.monthlyRentPaise, start, m.year, m.month);
      }
    }
    final existing = await invoiceFor(tenantId, date.year, date.month);
    // Checkout only ever lowers an existing final-month invoice.
    if (existing != null) finalRent = min(finalRent, existing.rentPaise);
    final later = await customSelect(
      """SELECT COALESCE(SUM(total_paise - paid_paise), 0) AS bal, COALESCE(SUM(paid_paise), 0) AS paid
         FROM rent_invoices WHERE tenant_id = ? AND status <> 'cancelled' AND period_start >= ?""",
      variables: [Variable.withInt(tenantId), Variable.withDateTime(DateTime(date.year, date.month + 1))],
    ).getSingle();
    return CheckoutPreview(
      checkoutDate: date,
      daysInFinalMonth: days,
      monthlyRentPaise: t.monthlyRentPaise,
      finalMonthRentPaise: finalRent,
      finalMonthInvoiced: existing?.rentPaise ?? 0,
      outstandingPaise: await tenantOutstanding(tenantId) - later.read<int>('bal'),
      unbilledPaise: unbilled,
      creditPaise: max(0, await tenantCredit(tenantId)) + later.read<int>('paid'),
      depositPaise: t.securityDepositPaise,
      deductionsPaise: deductionsPaise,
    );
  }

  /// Final settlement: bills any missing months, sets the last month to the
  /// days stayed, cancels later invoices, adds deductions, uses credit then
  /// the deposit against dues, refunds the rest and frees the bed.
  Future<CheckoutResult> checkout(
    int tenantId,
    DateTime checkoutDate, {
    int deductionsPaise = 0,
    String? deductionNote,
    PaymentMethod refundMethod = PaymentMethod.cash,
    String? notes,
  }) {
    return transaction(() async {
      final t = await (select(tenants)..where((x) => x.id.equals(tenantId))).getSingle();
      if (!_current.contains(t.status)) throw RuleException('${t.fullName} is already checked out.');
      final date = Dates.today(checkoutDate);
      final preview = await _checkoutInfo(tenantId, date, deductionsPaise: deductionsPaise);

      // 1. Bill months before the checkout month that were never invoiced.
      await generateMissingFor(tenantId, DateTime(date.year, date.month - 1));

      // 2. Cancel invoices for months after checkout, returning paid money to credit.
      final later =
          await (select(rentInvoices)..where(
                (i) =>
                    i.tenantId.equals(tenantId) &
                    i.status.equalsValue(InvoiceStatus.cancelled).not() &
                    i.periodStart.isBiggerOrEqualValue(DateTime(date.year, date.month + 1)),
              ))
              .get();
      for (final inv in later) {
        if (inv.paidPaise > 0) {
          await _releaseFromInvoice(inv.id, inv.paidPaise);
          await _recompute(inv.id);
        }
        await (update(rentInvoices)..where((i) => i.id.equals(inv.id))).write(
          RentInvoicesCompanion(
            status: const Value(InvoiceStatus.cancelled),
            cancelledAt: Value(DateTime.now()),
            cancelReason: Value('Tenant checked out on ${Dates.short(date)}'),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      // 3. Final month: correct the existing invoice or create one for the days stayed.
      final existing = await invoiceFor(tenantId, date.year, date.month);
      final alloc = await (select(
        allocations,
      )..where((a) => a.tenantId.equals(tenantId) & a.isActive.equals(true))).getSingleOrNull();
      int? finalInvoiceId = existing?.id;
      final dayNote = preview.daysInFinalMonth > 0 ? 'Final month: ${preview.daysInFinalMonth} days' : null;
      if (existing != null) {
        final reduceBy = max(0, existing.rentPaise - preview.finalMonthRentPaise);
        final newDiscount = existing.discountPaise + reduceBy;
        final newAdditional = existing.additionalChargesPaise + deductionsPaise;
        final newTotal = max(0, existing.rentPaise + newAdditional - newDiscount);
        if (newTotal < existing.paidPaise) {
          await _releaseFromInvoice(existing.id, existing.paidPaise - newTotal);
        }
        await (update(rentInvoices)..where((i) => i.id.equals(existing.id))).write(
          RentInvoicesCompanion(
            discountPaise: Value(min(newDiscount, existing.rentPaise + newAdditional)),
            additionalChargesPaise: Value(newAdditional),
            totalPaise: Value(newTotal),
            notes: Value([existing.notes, dayNote, deductionNote].whereType<String>().join('\n')),
            updatedAt: Value(DateTime.now()),
          ),
        );
        await _recompute(existing.id);
      } else if (preview.finalMonthRentPaise > 0 || deductionsPaise > 0) {
        finalInvoiceId = await _insertInvoice(
          tenantId: tenantId,
          allocationId: alloc?.id,
          year: date.year,
          month: date.month,
          rentPaise: preview.finalMonthRentPaise,
          additionalPaise: deductionsPaise,
          dueDate: date,
          prorated: preview.daysInFinalMonth < BillingMath.daysInMonth(date.year, date.month),
          notes: [dayNote, deductionNote].whereType<String>().join('\n'),
        );
      }

      // 4. Use advance credit, then the deposit.
      await applyCredit(tenantId);
      final dues = await tenantOutstanding(tenantId);
      final depositUsed = min(t.securityDepositPaise, dues);
      if (depositUsed > 0) {
        final id = await into(payments).insert(
          PaymentsCompanion.insert(
            transactionId: _txnId(),
            receiptNumber: await _receiptNumber(date),
            tenantId: tenantId,
            amountPaise: depositUsed,
            method: PaymentMethod.deposit,
            paymentDate: date,
            status: PaymentStatus.confirmed,
            notes: const Value('Adjusted from security deposit at checkout'),
          ),
        );
        await _allocate(id, tenantId, preferredInvoiceId: finalInvoiceId);
        await _freezeBalance(id, tenantId);
      }
      final depositRefund = t.securityDepositPaise - depositUsed;

      // 5. Refund unused advance credit as a negative entry.
      final creditLeft = await tenantCredit(tenantId);
      if (creditLeft > 0) {
        final refundId = await into(payments).insert(
          PaymentsCompanion.insert(
            transactionId: _txnId(),
            receiptNumber: await _receiptNumber(date, reversal: true),
            tenantId: tenantId,
            amountPaise: -creditLeft,
            method: refundMethod,
            paymentDate: date,
            status: PaymentStatus.confirmed,
            kind: const Value(PaymentKind.reversal),
            notes: const Value('Refund of unused advance at checkout'),
          ),
        );
        await _freezeBalance(refundId, tenantId);
      }

      // 6. Close the allocation and free the bed.
      if (alloc != null) {
        await (update(allocations)..where((a) => a.id.equals(alloc.id))).write(
          AllocationsCompanion(isActive: const Value(false), endDate: Value(date), endReason: const Value('checkout')),
        );
        await (update(beds)..where((b) => b.id.equals(alloc.bedId))).write(
          BedsCompanion(status: const Value(BedStatus.available), updatedAt: Value(DateTime.now())),
        );
      }
      final toCollect = await tenantOutstanding(tenantId);
      await (update(tenants)..where((x) => x.id.equals(tenantId))).write(
        TenantsCompanion(
          status: const Value(TenantStatus.checkedOut),
          checkoutDate: Value(date),
          depositAdjustedPaise: Value(depositUsed),
          depositRefundedPaise: Value(depositRefund),
          checkoutNotes: Value(notes),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final int refund = depositRefund + max(0, creditLeft);
      await db.settingsDao.log(
        'tenant',
        tenantId,
        'checkout',
        'deposit used ${Money.format(depositUsed)}, refunded ${Money.format(refund)}, due ${Money.format(toCollect)}',
      );
      return CheckoutResult(refundPaise: refund, toCollectPaise: toCollect);
    });
  }

  /// Pays back a tenant's unused advance credit (e.g. a UPI payment that was
  /// verified after checkout). Recorded as a negative entry, never deleted.
  Future<int> refundCredit(int tenantId, PaymentMethod method, {DateTime? date}) {
    return transaction(() async {
      final credit = await tenantCredit(tenantId);
      if (credit <= 0) throw RuleException('There is no advance credit to refund.');
      final when = Dates.today(date);
      final id = await into(payments).insert(
        PaymentsCompanion.insert(
          transactionId: _txnId(),
          receiptNumber: await _receiptNumber(when, reversal: true),
          tenantId: tenantId,
          amountPaise: -credit,
          method: method,
          paymentDate: when,
          status: PaymentStatus.confirmed,
          kind: const Value(PaymentKind.reversal),
          notes: const Value('Refund of advance credit'),
        ),
      );
      await _freezeBalance(id, tenantId);
      await db.settingsDao.log('payment', id, 'refund_credit', Money.format(credit));
      return id;
    });
  }

  /// Moves [amount] of allocated money on an invoice back to credit by adding
  /// negative allocations against the most recent contributing payments.
  Future<void> _releaseFromInvoice(int invoiceId, int amount) async {
    var left = amount;
    final rows = await customSelect(
      'SELECT payment_id, SUM(amount_paise) AS a FROM payment_allocations WHERE invoice_id = ? '
      'GROUP BY payment_id HAVING a > 0 ORDER BY payment_id DESC',
      variables: [Variable.withInt(invoiceId)],
    ).get();
    for (final r in rows) {
      if (left <= 0) break;
      final take = min(left, r.read<int>('a'));
      await into(paymentAllocations).insert(
        PaymentAllocationsCompanion.insert(
          paymentId: r.read<int>('payment_id'),
          invoiceId: invoiceId,
          amountPaise: -take,
        ),
      );
      left -= take;
    }
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  static const _roomLabelSql = '''
    (SELECT 'Room ' || r.room_number || ' · Bed ' || b.label FROM allocations a
       JOIN beds b ON b.id = a.bed_id JOIN rooms r ON r.id = b.room_id
      WHERE a.tenant_id = t.id ORDER BY a.is_active DESC, a.id DESC LIMIT 1)''';

  Stream<List<InvoiceView>> watchInvoices({int? year, int? month, int? tenantId, bool openOnly = false}) {
    final where = <String>[];
    final vars = <Variable>[];
    if (year != null && month != null) {
      where.add('i.period_year = ? AND i.period_month = ?');
      vars.addAll([Variable.withInt(year), Variable.withInt(month)]);
    }
    if (tenantId != null) {
      where.add('i.tenant_id = ?');
      vars.add(Variable.withInt(tenantId));
    }
    if (openOnly) where.add("i.status <> 'cancelled' AND i.total_paise > i.paid_paise");
    return customSelect(
      '''SELECT i.*, t.full_name AS tenant_name, $_roomLabelSql AS room_label
         FROM rent_invoices i JOIN tenants t ON t.id = i.tenant_id
         ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
         ORDER BY i.period_start DESC, t.full_name''',
      variables: vars,
      readsFrom: {rentInvoices, tenants, allocations},
    ).watch().asyncMap(
      (rows) async => [
        for (final r in rows)
          InvoiceView(await rentInvoices.mapFromRow(r), r.read<String>('tenant_name'), r.read<String?>('room_label')),
      ],
    );
  }

  Stream<List<PaymentView>> watchPayments({DateRange? range, int? tenantId, PaymentStatus? status}) {
    final where = <String>[];
    final vars = <Variable>[];
    if (range != null) {
      where.add('p.payment_date >= ? AND p.payment_date < ?');
      vars.addAll([Variable.withDateTime(range.start), Variable.withDateTime(range.end)]);
    }
    if (tenantId != null) {
      where.add('p.tenant_id = ?');
      vars.add(Variable.withInt(tenantId));
    }
    if (status != null) {
      where.add('p.status = ?');
      vars.add(Variable.withString(status.name));
    }
    return customSelect(
      '''SELECT p.*, t.full_name AS tenant_name,
           EXISTS (SELECT 1 FROM payments r WHERE r.reverses_payment_id = p.id) AS reversed
         FROM payments p JOIN tenants t ON t.id = p.tenant_id
         ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
         ORDER BY p.payment_date DESC, p.id DESC LIMIT 500''',
      variables: vars,
      readsFrom: {payments, tenants},
    ).watch().asyncMap(
      (rows) async => [
        for (final r in rows)
          PaymentView(
            await payments.mapFromRow(r),
            r.read<String>('tenant_name'),
            isReversed: r.read<bool>('reversed'),
          ),
      ],
    );
  }

  /// One invoice with the payments applied to it.
  Stream<(InvoiceView, List<(Payment, int)>)?> watchInvoice(int id) {
    return customSelect('SELECT 1', readsFrom: {rentInvoices, paymentAllocations, payments, tenants}).watch().asyncMap((
      _,
    ) async {
      final r = await customSelect(
        '''SELECT i.*, t.full_name AS tenant_name, $_roomLabelSql AS room_label
           FROM rent_invoices i JOIN tenants t ON t.id = i.tenant_id WHERE i.id = ?''',
        variables: [Variable.withInt(id)],
      ).getSingleOrNull();
      if (r == null) return null;
      final view = InvoiceView(
        await rentInvoices.mapFromRow(r),
        r.read<String>('tenant_name'),
        r.read<String?>('room_label'),
      );
      final allocs = await customSelect(
        '''SELECT p.*, SUM(pa.amount_paise) AS applied FROM payment_allocations pa
           JOIN payments p ON p.id = pa.payment_id WHERE pa.invoice_id = ?
           GROUP BY p.id ORDER BY p.payment_date, p.id''',
        variables: [Variable.withInt(id)],
      ).get();
      return (view, [for (final a in allocs) (await payments.mapFromRow(a), a.read<int>('applied'))]);
    });
  }

  /// Whether invoices exist for the month (to prompt generation).
  Stream<int> watchInvoiceCount(int year, int month) => customSelect(
    "SELECT COUNT(*) AS c FROM rent_invoices WHERE period_year = ? AND period_month = ? AND status <> 'cancelled'",
    variables: [Variable.withInt(year), Variable.withInt(month)],
    readsFrom: {rentInvoices},
  ).watchSingle().map((r) => r.read<int>('c'));

  /// Current tenants with a bed but no invoice for the month yet.
  Stream<int> watchUnbilledCount(int year, int month) => customSelect(
    '''SELECT COUNT(*) AS c FROM tenants t
           JOIN allocations a ON a.tenant_id = t.id AND a.is_active = 1
           WHERE t.status IN ('newTenant','active','noticeGiven') AND t.joining_date < ?
             AND NOT EXISTS (SELECT 1 FROM rent_invoices i WHERE i.tenant_id = t.id AND i.period_year = ?
                               AND i.period_month = ? AND i.status <> 'cancelled')''',
    variables: [Variable.withDateTime(DateTime(year, month + 1)), Variable.withInt(year), Variable.withInt(month)],
    readsFrom: {tenants, allocations, rentInvoices},
  ).watchSingle().map((r) => r.read<int>('c'));

  Stream<PaymentView?> watchPayment(int id) {
    return customSelect(
      '''SELECT p.*, t.full_name AS tenant_name,
           EXISTS (SELECT 1 FROM payments r WHERE r.reverses_payment_id = p.id) AS reversed
         FROM payments p JOIN tenants t ON t.id = p.tenant_id WHERE p.id = ?''',
      variables: [Variable.withInt(id)],
      readsFrom: {payments, tenants},
    ).watchSingleOrNull().asyncMap(
      (r) async => r == null
          ? null
          : PaymentView(
              await payments.mapFromRow(r),
              r.read<String>('tenant_name'),
              isReversed: r.read<bool>('reversed'),
            ),
    );
  }

  Future<ReceiptData> receiptData(int paymentId) async {
    final p = await (select(payments)..where((x) => x.id.equals(paymentId))).getSingle();
    final t = await (select(tenants)..where((x) => x.id.equals(p.tenantId))).getSingle();
    final profile = await db.settingsDao.getProfile();
    if (profile == null) throw RuleException('Set up the PG profile first.');
    final lines = await customSelect(
      '''SELECT i.invoice_number, i.period_start, SUM(pa.amount_paise) AS a
         FROM payment_allocations pa JOIN rent_invoices i ON i.id = pa.invoice_id
         WHERE pa.payment_id = ? GROUP BY i.id ORDER BY i.period_start''',
      variables: [Variable.withInt(paymentId)],
    ).get();
    final room = await customSelect(
      'SELECT $_roomLabelSql AS l FROM tenants t WHERE t.id = ?',
      variables: [Variable.withInt(t.id)],
    ).getSingle();
    final asOf = p.balanceAfterPaise ?? await _balanceAsOf(p);
    return ReceiptData(
      profile: profile,
      tenant: t,
      payment: p,
      roomLabel: room.read<String?>('l'),
      lines: [
        for (final l in lines)
          if (l.read<int>('a') != 0)
            ReceiptLine(
              invoiceNumber: l.read<String>('invoice_number'),
              period: DateTime.fromMillisecondsSinceEpoch(l.read<int>('period_start') * 1000),
              amountPaise: l.read<int>('a'),
            ),
      ],
      outstandingPaise: max(0, asOf),
      creditPaise: max(0, -asOf),
    );
  }

  /// Balance as it stood right after [p] was recorded: everything billed up
  /// to then minus every confirmed payment up to and including this one.
  /// Reprinted receipts therefore keep showing the balance of that day.
  Future<int> _balanceAsOf(Payment p) async {
    final row = await customSelect(
      '''SELECT
           COALESCE((SELECT SUM(total_paise) FROM rent_invoices
                      WHERE tenant_id = ?1 AND status <> 'cancelled' AND created_at <= ?2), 0)
         - COALESCE((SELECT SUM(amount_paise) FROM payments
                      WHERE tenant_id = ?1 AND status = 'confirmed' AND id <= ?3), 0) AS v''',
      variables: [Variable.withInt(p.tenantId), Variable.withDateTime(p.createdAt), Variable.withInt(p.id)],
    ).getSingle();
    return row.read<int>('v');
  }
}
