import 'package:drift/drift.dart';

import '../../utils/dates.dart';
import '../../utils/money.dart';
import '../app_database.dart';
import '../enums.dart';
import '../tables/finance_tables.dart';
import '../tables/property_tables.dart';

part 'reports_dao.g.dart';

enum ReportType {
  financialSummary('Monthly financial summary', 'Billed vs collected vs expenses', true),
  collection('Collection report', 'All rent received', true),
  cashCollection('Cash collection', 'Rent received in cash', true),
  upiCollection('UPI collection', 'Rent received through UPI', true),
  pendingRent('Pending rent', 'Every unpaid invoice', false),
  overdueRent('Overdue rent', 'Unpaid invoices past due date', false),
  expenses('Expense report', 'Expenses by date and category', true),
  occupancy('Occupancy report', 'Beds and who is in them', false),
  tenantLedger('Tenant ledger', 'Invoices and payments for one tenant', false),
  admissions('Admission report', 'Tenants who joined', true),
  checkouts('Checkout report', 'Tenants who left, with settlement', true),
  deposits('Deposit report', 'Deposits held, adjusted and refunded', false);

  const ReportType(this.title, this.subtitle, this.usesRange);
  final String title;
  final String subtitle;
  final bool usesRange;
}

enum ColumnAlign { left, right }

class ReportColumn {
  const ReportColumn(this.label, {this.align = ColumnAlign.left, this.flex = 2});
  final String label;
  final ColumnAlign align;
  final int flex;
}

/// A generic tabular report, rendered on screen and exported to PDF/CSV.
class ReportTable {
  const ReportTable({
    required this.title,
    required this.subtitle,
    required this.columns,
    required this.rows,
    this.summary = const [],
    this.footer,
  });

  final String title;
  final String subtitle;
  final List<ReportColumn> columns;
  final List<List<String>> rows;

  /// Headline figures shown above the table, e.g. ("Collected", "₹1,20,000").
  final List<(String, String)> summary;
  final List<String>? footer;
}

@DriftAccessor(tables: [Tenants, Rooms, Beds, Allocations, RentInvoices, Payments, Expenses])
class ReportsDao extends DatabaseAccessor<AppDatabase> with _$ReportsDaoMixin {
  ReportsDao(super.db);

  static DateTime _d(int secs) => DateTime.fromMillisecondsSinceEpoch(secs * 1000);
  static String _m(int p) => Money.format(p);

  static const _room = '''
    (SELECT r.room_number || '-' || b.label FROM allocations a
       JOIN beds b ON b.id = a.bed_id JOIN rooms r ON r.id = b.room_id
      WHERE a.tenant_id = t.id ORDER BY a.is_active DESC, a.id DESC LIMIT 1)''';

  Future<ReportTable> build(ReportType type, DateRange range, {int? tenantId, DateTime? today}) {
    return switch (type) {
      ReportType.financialSummary => _summary(range),
      ReportType.collection => _collection(range, null),
      ReportType.cashCollection => _collection(range, PaymentMethod.cash),
      ReportType.upiCollection => _collection(range, PaymentMethod.upi),
      ReportType.pendingRent => _dues(range, overdueOnly: false, today: today),
      ReportType.overdueRent => _dues(range, overdueOnly: true, today: today),
      ReportType.expenses => _expenses(range),
      ReportType.occupancy => _occupancy(),
      ReportType.tenantLedger => _ledger(tenantId),
      ReportType.admissions => _admissions(range),
      ReportType.checkouts => _checkouts(range),
      ReportType.deposits => _deposits(),
    };
  }

  Future<int> _scalar(String sql, List<Variable> vars) async =>
      (await customSelect(sql, variables: vars).getSingle()).read<int?>('v') ?? 0;

  Future<ReportTable> _summary(DateRange r) async {
    final s = Variable.withDateTime(r.start), e = Variable.withDateTime(r.end);
    final billed = await _scalar(
      "SELECT SUM(total_paise) AS v FROM rent_invoices WHERE status <> 'cancelled' AND period_end > ? AND period_start < ?",
      [s, e],
    );
    Future<int> coll(String method) => _scalar(
      "SELECT SUM(amount_paise) AS v FROM payments WHERE status = 'confirmed' AND method = ? AND payment_date >= ? AND payment_date < ?",
      [Variable.withString(method), s, e],
    );
    final cash = await coll('cash');
    final upi = await coll('upi');
    final bank = await coll('bank');
    final deposit = await coll('deposit');
    final outstanding = await _scalar(
      "SELECT SUM(total_paise - paid_paise) AS v FROM rent_invoices WHERE status <> 'cancelled' AND period_start < ? AND total_paise > paid_paise",
      [e],
    );
    final pendingUpi = await _scalar(
      "SELECT SUM(amount_paise) AS v FROM payments WHERE status = 'pendingVerification' AND payment_date >= ? AND payment_date < ?",
      [s, e],
    );
    final cats = await customSelect(
      'SELECT category, SUM(amount_paise) AS t FROM expenses WHERE is_voided = 0 AND expense_date >= ? AND expense_date < ? GROUP BY category ORDER BY t DESC',
      variables: [s, e],
    ).get();
    final expenseTotal = cats.fold<int>(0, (a, c) => a + c.read<int>('t'));
    final collected = cash + upi + bank;
    return ReportTable(
      title: ReportType.financialSummary.title,
      subtitle: r.label,
      summary: [
        ('Rent billed', _m(billed)),
        ('Rent collected', _m(collected)),
        ('Outstanding receivables', _m(outstanding)),
        ('Expenses', _m(expenseTotal)),
        ('Net cash flow', _m(collected - expenseTotal)),
      ],
      columns: const [
        ReportColumn('Line item', flex: 4),
        ReportColumn('Amount', align: ColumnAlign.right),
      ],
      rows: [
        ['Rent billed (invoices for the period)', _m(billed)],
        ['Collected in cash', _m(cash)],
        ['Collected by UPI (verified)', _m(upi)],
        if (bank != 0) ['Collected by bank transfer', _m(bank)],
        ['Total rent collected', _m(collected)],
        ['Settled from deposits (not cash)', _m(deposit)],
        ['UPI awaiting verification (not counted)', _m(pendingUpi)],
        ['Outstanding receivables (all unpaid invoices)', _m(outstanding)],
        for (final c in cats)
          ['Expense · ${ExpenseCategory.values.byName(c.read<String>('category')).label}', _m(c.read<int>('t'))],
        ['Total expenses', _m(expenseTotal)],
        ['Net cash flow (collected − expenses)', _m(collected - expenseTotal)],
      ],
    );
  }

  Future<ReportTable> _collection(DateRange r, PaymentMethod? method) async {
    final rows = await customSelect(
      '''SELECT p.payment_date, p.receipt_number, t.full_name, p.method, p.upi_reference, p.amount_paise, p.status, p.kind
         FROM payments p JOIN tenants t ON t.id = p.tenant_id
         WHERE p.payment_date >= ? AND p.payment_date < ? AND p.status <> 'rejected' AND p.method <> 'deposit'
           ${method == null ? '' : 'AND p.method = ?'}
         ORDER BY p.payment_date, p.id''',
      variables: [
        Variable.withDateTime(r.start),
        Variable.withDateTime(r.end),
        if (method != null) Variable.withString(method.name),
      ],
    ).get();
    var confirmed = 0, pending = 0;
    for (final x in rows) {
      final a = x.read<int>('amount_paise');
      x.read<String>('status') == 'confirmed' ? confirmed += a : pending += a;
    }
    final type = switch (method) {
      PaymentMethod.cash => ReportType.cashCollection,
      PaymentMethod.upi => ReportType.upiCollection,
      _ => ReportType.collection,
    };
    return ReportTable(
      title: type.title,
      subtitle: r.label,
      summary: [
        ('Confirmed', _m(confirmed)),
        if (pending != 0) ('Awaiting verification', _m(pending)),
        ('Entries', '${rows.length}'),
      ],
      columns: const [
        ReportColumn('Date'),
        ReportColumn('Receipt'),
        ReportColumn('Tenant', flex: 3),
        ReportColumn('Method'),
        ReportColumn('Reference'),
        ReportColumn('Amount', align: ColumnAlign.right),
      ],
      rows: [
        for (final x in rows)
          [
            Dates.short(_d(x.read<int>('payment_date'))),
            x.read<String>('receipt_number'),
            x.read<String>('full_name') + (x.read<String>('status') == 'pendingVerification' ? ' (unverified)' : ''),
            PaymentMethod.values.byName(x.read<String>('method')).label,
            x.read<String?>('upi_reference') ?? '',
            _m(x.read<int>('amount_paise')),
          ],
      ],
    );
  }

  Future<ReportTable> _dues(DateRange r, {required bool overdueOnly, DateTime? today}) async {
    final t0 = Dates.today(today);
    final rows = await customSelect(
      '''SELECT i.invoice_number, i.period_start, i.due_date, i.total_paise, i.paid_paise, t.full_name, t.phone, $_room AS room
         FROM rent_invoices i JOIN tenants t ON t.id = i.tenant_id
         WHERE i.status <> 'cancelled' AND i.total_paise > i.paid_paise
           ${overdueOnly ? 'AND i.due_date < ?' : 'AND i.period_start < ?'}
         ORDER BY i.due_date, t.full_name''',
      variables: [Variable.withDateTime(overdueOnly ? t0 : r.end)],
    ).get();
    final total = rows.fold<int>(0, (a, x) => a + x.read<int>('total_paise') - x.read<int>('paid_paise'));
    final tenantsCount = rows.map((x) => x.read<String>('full_name')).toSet().length;
    return ReportTable(
      title: overdueOnly ? ReportType.overdueRent.title : ReportType.pendingRent.title,
      subtitle: overdueOnly ? 'As of ${Dates.short(t0)}' : 'Invoices up to ${Dates.short(r.lastDay)}',
      summary: [('Total due', _m(total)), ('Tenants', '$tenantsCount'), ('Invoices', '${rows.length}')],
      columns: const [
        ReportColumn('Tenant', flex: 3),
        ReportColumn('Room'),
        ReportColumn('Phone'),
        ReportColumn('Month'),
        ReportColumn('Due date'),
        ReportColumn('Days late', align: ColumnAlign.right, flex: 1),
        ReportColumn('Balance', align: ColumnAlign.right),
      ],
      rows: [
        for (final x in rows)
          [
            x.read<String>('full_name'),
            x.read<String?>('room') ?? '—',
            x.read<String>('phone'),
            Dates.monthYear(_d(x.read<int>('period_start'))),
            Dates.short(_d(x.read<int>('due_date'))),
            '${t0.difference(_d(x.read<int>('due_date'))).inDays.clamp(0, 9999)}',
            _m(x.read<int>('total_paise') - x.read<int>('paid_paise')),
          ],
      ],
    );
  }

  Future<ReportTable> _expenses(DateRange r) async {
    final rows =
        await (select(expenses)
              ..where(
                (e) =>
                    e.isVoided.equals(false) &
                    e.expenseDate.isBiggerOrEqualValue(r.start) &
                    e.expenseDate.isSmallerThanValue(r.end),
              )
              ..orderBy([(e) => OrderingTerm.asc(e.expenseDate)]))
            .get();
    final byCat = <ExpenseCategory, int>{};
    for (final e in rows) {
      byCat[e.category] = (byCat[e.category] ?? 0) + e.amountPaise;
    }
    final total = rows.fold<int>(0, (a, e) => a + e.amountPaise);
    final sorted = byCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return ReportTable(
      title: ReportType.expenses.title,
      subtitle: r.label,
      summary: [('Total expenses', _m(total)), for (final c in sorted.take(3)) (c.key.label, _m(c.value))],
      columns: const [
        ReportColumn('Date'),
        ReportColumn('Title', flex: 3),
        ReportColumn('Category'),
        ReportColumn('Vendor'),
        ReportColumn('Paid by'),
        ReportColumn('Amount', align: ColumnAlign.right),
      ],
      rows: [
        for (final e in rows)
          [
            Dates.short(e.expenseDate),
            e.title,
            e.category.label,
            e.vendor ?? '',
            e.paymentMethod.label,
            _m(e.amountPaise),
          ],
      ],
      footer: ['Category totals: ${sorted.map((c) => '${c.key.label} ${_m(c.value)}').join(' · ')}'],
    );
  }

  Future<ReportTable> _occupancy() async {
    final rows = await customSelect(
      '''SELECT r.floor, r.room_number, b.label, b.status, r.rent_paise, t.full_name, t.phone, a.start_date
         FROM beds b JOIN rooms r ON r.id = b.room_id
         LEFT JOIN allocations a ON a.bed_id = b.id AND a.is_active = 1
         LEFT JOIN tenants t ON t.id = a.tenant_id
         WHERE b.is_active = 1 AND r.is_active = 1
         ORDER BY r.floor, r.room_number, b.label''',
    ).get();
    final occupied = rows.where((x) => x.read<String?>('full_name') != null).length;
    String status(QueryRow x) {
      if (x.read<String?>('full_name') != null) return 'Occupied';
      final s = BedStatus.values.byName(x.read<String>('status'));
      return s == BedStatus.occupied ? 'Available' : s.label;
    }

    return ReportTable(
      title: ReportType.occupancy.title,
      subtitle: 'As of ${Dates.short(DateTime.now())}',
      summary: [
        ('Beds', '${rows.length}'),
        ('Occupied', '$occupied'),
        ('Occupancy', rows.isEmpty ? '0%' : '${(occupied * 100 / rows.length).round()}%'),
      ],
      columns: const [
        ReportColumn('Floor'),
        ReportColumn('Room', flex: 1),
        ReportColumn('Bed', flex: 1),
        ReportColumn('Status'),
        ReportColumn('Tenant', flex: 3),
        ReportColumn('Since'),
        ReportColumn('Rent/bed', align: ColumnAlign.right),
      ],
      rows: [
        for (final x in rows)
          [
            Dates.floorLabel(x.read<int>('floor')),
            x.read<String>('room_number'),
            x.read<String>('label'),
            status(x),
            x.read<String?>('full_name') ?? '',
            x.read<int?>('start_date') == null ? '' : Dates.short(_d(x.read<int>('start_date'))),
            _m(x.read<int>('rent_paise')),
          ],
      ],
    );
  }

  Future<ReportTable> _ledger(int? tenantId) async {
    if (tenantId == null) {
      return const ReportTable(title: 'Tenant ledger', subtitle: 'Choose a tenant', columns: [], rows: []);
    }
    final t = await (select(tenants)..where((x) => x.id.equals(tenantId))).getSingle();
    final entries = await customSelect(
      '''SELECT * FROM (
           SELECT i.created_at AS c, i.period_start AS d, 'Invoice ' || i.invoice_number AS what,
                  i.total_paise AS debit, 0 AS credit, i.status AS note
           FROM rent_invoices i WHERE i.tenant_id = ?1 AND i.status <> 'cancelled'
           UNION ALL
           SELECT p.created_at, p.payment_date, p.receipt_number || ' · ' ||
                  CASE p.method WHEN 'cash' THEN 'Cash' WHEN 'upi' THEN 'UPI' WHEN 'bank' THEN 'Bank'
                                ELSE 'Deposit adjustment' END,
                  CASE WHEN p.amount_paise < 0 THEN -p.amount_paise ELSE 0 END,
                  CASE WHEN p.amount_paise > 0 THEN p.amount_paise ELSE 0 END,
                  COALESCE(p.notes, '')
           FROM payments p WHERE p.tenant_id = ?1 AND p.status = 'confirmed'
         ) ORDER BY d, c''',
      variables: [Variable.withInt(tenantId)],
    ).get();
    var balance = 0;
    final rows = <List<String>>[];
    var billed = 0, paid = 0;
    for (final e in entries) {
      final debit = e.read<int>('debit'), credit = e.read<int>('credit');
      billed += debit;
      paid += credit;
      balance += debit - credit;
      rows.add([
        Dates.short(_d(e.read<int>('d'))),
        e.read<String>('what'),
        debit == 0 ? '' : _m(debit),
        credit == 0 ? '' : _m(credit),
        balance < 0 ? '${_m(-balance)} CR' : _m(balance),
      ]);
    }
    return ReportTable(
      title: 'Ledger · ${t.fullName}',
      subtitle: '${t.phone} · joined ${Dates.short(t.joiningDate)} · ${t.status.label}',
      summary: [
        ('Billed', _m(billed)),
        ('Paid', _m(paid)),
        (balance >= 0 ? 'Balance due' : 'Advance credit', _m(balance.abs())),
        ('Deposit', _m(t.securityDepositPaise)),
      ],
      columns: const [
        ReportColumn('Date'),
        ReportColumn('Entry', flex: 4),
        ReportColumn('Charge', align: ColumnAlign.right),
        ReportColumn('Payment', align: ColumnAlign.right),
        ReportColumn('Balance', align: ColumnAlign.right),
      ],
      rows: rows,
    );
  }

  Future<ReportTable> _admissions(DateRange r) async {
    final rows = await customSelect(
      '''SELECT t.*, $_room AS room FROM tenants t
         WHERE t.joining_date >= ? AND t.joining_date < ? ORDER BY t.joining_date''',
      variables: [Variable.withDateTime(r.start), Variable.withDateTime(r.end)],
    ).get();
    return ReportTable(
      title: ReportType.admissions.title,
      subtitle: r.label,
      summary: [('New tenants', '${rows.length}')],
      columns: const [
        ReportColumn('Joined'),
        ReportColumn('Tenant', flex: 3),
        ReportColumn('Phone'),
        ReportColumn('Room'),
        ReportColumn('Rent', align: ColumnAlign.right),
        ReportColumn('Deposit', align: ColumnAlign.right),
      ],
      rows: [
        for (final x in rows)
          [
            Dates.short(_d(x.read<int>('joining_date'))),
            x.read<String>('full_name'),
            x.read<String>('phone'),
            x.read<String?>('room') ?? '—',
            _m(x.read<int>('monthly_rent_paise')),
            _m(x.read<int>('security_deposit_paise')),
          ],
      ],
    );
  }

  Future<ReportTable> _checkouts(DateRange r) async {
    final rows = await customSelect(
      '''SELECT t.*, $_room AS room,
           COALESCE((SELECT SUM(i.total_paise - i.paid_paise) FROM rent_invoices i
                     WHERE i.tenant_id = t.id AND i.status <> 'cancelled'), 0) AS dues
         FROM tenants t WHERE t.checkout_date >= ? AND t.checkout_date < ? ORDER BY t.checkout_date''',
      variables: [Variable.withDateTime(r.start), Variable.withDateTime(r.end)],
    ).get();
    return ReportTable(
      title: ReportType.checkouts.title,
      subtitle: r.label,
      summary: [('Checkouts', '${rows.length}')],
      columns: const [
        ReportColumn('Left on'),
        ReportColumn('Tenant', flex: 3),
        ReportColumn('Room'),
        ReportColumn('Deposit', align: ColumnAlign.right),
        ReportColumn('Adjusted', align: ColumnAlign.right),
        ReportColumn('Refunded', align: ColumnAlign.right),
        ReportColumn('Still due', align: ColumnAlign.right),
      ],
      rows: [
        for (final x in rows)
          [
            Dates.short(_d(x.read<int>('checkout_date'))),
            x.read<String>('full_name'),
            x.read<String?>('room') ?? '—',
            _m(x.read<int>('security_deposit_paise')),
            _m(x.read<int>('deposit_adjusted_paise')),
            _m(x.read<int>('deposit_refunded_paise')),
            _m(x.read<int>('dues')),
          ],
      ],
    );
  }

  Future<ReportTable> _deposits() async {
    final rows = await customSelect('''SELECT t.*, $_room AS room FROM tenants t WHERE t.security_deposit_paise > 0
         ORDER BY CASE WHEN t.status IN ('checkedOut','archived') THEN 1 ELSE 0 END, t.full_name''').get();
    var held = 0, adjusted = 0, refunded = 0;
    for (final x in rows) {
      final d = x.read<int>('security_deposit_paise');
      final a = x.read<int>('deposit_adjusted_paise');
      final f = x.read<int>('deposit_refunded_paise');
      final out = ['checkedOut', 'archived'].contains(x.read<String>('status'));
      if (!out) held += d;
      adjusted += a;
      refunded += f;
    }
    return ReportTable(
      title: ReportType.deposits.title,
      subtitle: 'As of ${Dates.short(DateTime.now())}',
      summary: [('Currently held', _m(held)), ('Adjusted against dues', _m(adjusted)), ('Refunded', _m(refunded))],
      columns: const [
        ReportColumn('Tenant', flex: 3),
        ReportColumn('Room'),
        ReportColumn('Status'),
        ReportColumn('Deposit', align: ColumnAlign.right),
        ReportColumn('Adjusted', align: ColumnAlign.right),
        ReportColumn('Refunded', align: ColumnAlign.right),
      ],
      rows: [
        for (final x in rows)
          [
            x.read<String>('full_name'),
            x.read<String?>('room') ?? '—',
            TenantStatus.values.byName(x.read<String>('status')).label,
            _m(x.read<int>('security_deposit_paise')),
            _m(x.read<int>('deposit_adjusted_paise')),
            _m(x.read<int>('deposit_refunded_paise')),
          ],
      ],
    );
  }

  /// Billed vs collected for the last [months] months, oldest first.
  Future<List<(DateTime, int, int)>> monthlyTrend(int months, {DateTime? now}) async {
    final n = now ?? DateTime.now();
    final out = <(DateTime, int, int)>[];
    for (var i = months - 1; i >= 0; i--) {
      final r = DateRange.month(n.year, n.month - i);
      final s = Variable.withDateTime(r.start), e = Variable.withDateTime(r.end);
      final billed = await _scalar(
        "SELECT SUM(total_paise) AS v FROM rent_invoices WHERE status <> 'cancelled' AND period_end > ? AND period_start < ?",
        [s, e],
      );
      final collected = await _scalar(
        "SELECT SUM(amount_paise) AS v FROM payments WHERE status = 'confirmed' AND method <> 'deposit' AND payment_date >= ? AND payment_date < ?",
        [s, e],
      );
      out.add((r.start, billed, collected));
    }
    return out;
  }
}
