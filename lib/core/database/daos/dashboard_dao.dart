import 'package:drift/drift.dart';

import '../../utils/dates.dart';
import '../app_database.dart';
import '../enums.dart';
import '../tables/finance_tables.dart';
import '../tables/property_tables.dart';

part 'dashboard_dao.g.dart';

class DueItem {
  const DueItem({
    required this.tenantId,
    required this.tenantName,
    required this.roomLabel,
    required this.balancePaise,
    required this.dueDate,
  });

  final int tenantId;
  final String tenantName;
  final String? roomLabel;
  final int balancePaise;
  final DateTime dueDate;
}

class CheckoutItem {
  const CheckoutItem({required this.tenantId, required this.tenantName, required this.roomLabel, required this.date});

  final int tenantId;
  final String tenantName;
  final String? roomLabel;
  final DateTime date;
}

enum TransactionType { rentPayment, reversal, expense }

class RecentTransaction {
  const RecentTransaction({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amountPaise,
    required this.date,
    this.pendingVerification = false,
  });

  final TransactionType type;
  final String title;
  final String subtitle;

  /// Signed from the owner's perspective: money in is positive.
  final int amountPaise;
  final DateTime date;
  final bool pendingVerification;
}

class DashboardSummary {
  const DashboardSummary({
    required this.range,
    required this.totalTenants,
    required this.totalBeds,
    required this.occupiedBeds,
    required this.reservedBeds,
    required this.maintenanceBeds,
    required this.rentBilledPaise,
    required this.rentCollectedPaise,
    required this.outstandingPaise,
    required this.expensesPaise,
    required this.pendingUpiCount,
    required this.dueToday,
    required this.overdue,
    required this.upcomingCheckouts,
    required this.recent,
  });

  final DateRange range;
  final int totalTenants;
  final int totalBeds;
  final int occupiedBeds;
  final int reservedBeds;
  final int maintenanceBeds;
  final int rentBilledPaise;
  final int rentCollectedPaise;
  final int outstandingPaise;
  final int expensesPaise;
  final int pendingUpiCount;
  final List<DueItem> dueToday;
  final List<DueItem> overdue;
  final List<CheckoutItem> upcomingCheckouts;
  final List<RecentTransaction> recent;

  int get availableBeds => totalBeds - occupiedBeds - reservedBeds - maintenanceBeds;
  int get netCashFlowPaise => rentCollectedPaise - expensesPaise;
  double get occupancy => totalBeds == 0 ? 0 : occupiedBeds / totalBeds;

  /// Collection rate for invoices billed in the selected range.
  double get collectionRate => rentBilledPaise == 0 ? 0 : (rentCollectedPaise / rentBilledPaise).clamp(0, 1);
}

@DriftAccessor(tables: [Rooms, Beds, Tenants, Allocations, RentInvoices, Payments, Expenses])
class DashboardDao extends DatabaseAccessor<AppDatabase> with _$DashboardDaoMixin {
  DashboardDao(super.db);

  static const _roomLabelSql = '''
    (SELECT r.room_number || ' · ' || b.label FROM allocations a
       JOIN beds b ON b.id = a.bed_id JOIN rooms r ON r.id = b.room_id
      WHERE a.tenant_id = t.id AND a.is_active = 1)''';

  /// Re-computes the summary whenever any of the source tables change.
  Stream<DashboardSummary> watchSummary(DateRange range, {DateTime? now}) {
    return customSelect(
      'SELECT 1',
      readsFrom: {rooms, beds, tenants, allocations, rentInvoices, payments, expenses},
    ).watch().asyncMap((_) => summary(range, now: now));
  }

  Future<DashboardSummary> summary(DateRange range, {DateTime? now}) async {
    final today = Dates.today(now);
    final tomorrow = today.add(const Duration(days: 1));
    final start = Variable.withDateTime(range.start);
    final end = Variable.withDateTime(range.end);
    final cancelled = Variable.withString(InvoiceStatus.cancelled.name);

    Future<int> scalar(String sql, [List<Variable> vars = const []]) async {
      final row = await customSelect(sql, variables: vars).getSingle();
      return row.read<int?>('v') ?? 0;
    }

    final totalTenants = await scalar('SELECT COUNT(*) AS v FROM tenants WHERE status IN (?, ?, ?)', [
      Variable.withString(TenantStatus.newTenant.name),
      Variable.withString(TenantStatus.active.name),
      Variable.withString(TenantStatus.noticeGiven.name),
    ]);

    final bedRow = await customSelect('''
      SELECT
        COUNT(*) AS total,
        SUM(CASE WHEN a.id IS NOT NULL THEN 1 ELSE 0 END) AS occupied,
        SUM(CASE WHEN a.id IS NULL AND b.status = 'reserved' THEN 1 ELSE 0 END) AS reserved,
        SUM(CASE WHEN a.id IS NULL AND b.status = 'maintenance' THEN 1 ELSE 0 END) AS maintenance
      FROM beds b
      JOIN rooms r ON r.id = b.room_id AND r.is_active = 1
      LEFT JOIN allocations a ON a.bed_id = b.id AND a.is_active = 1
      WHERE b.is_active = 1
      ''').getSingle();

    final billed = await scalar(
      'SELECT SUM(total_paise) AS v FROM rent_invoices '
      'WHERE status <> ? AND period_start >= ? AND period_start < ?',
      [cancelled, start, end],
    );

    // Confirmed payments and reversals received in the range (cash basis).
    final collected = await scalar(
      "SELECT SUM(amount_paise) AS v FROM payments "
      "WHERE status = ? AND method <> 'deposit' AND payment_date >= ? AND payment_date < ?",
      [Variable.withString(PaymentStatus.confirmed.name), start, end],
    );

    // Everything still owed on invoices issued up to the end of the range.
    final outstanding = await scalar(
      'SELECT SUM(total_paise - paid_paise) AS v FROM rent_invoices '
      'WHERE status <> ? AND period_start < ? AND total_paise > paid_paise',
      [cancelled, end],
    );

    final expenseTotal = await scalar(
      'SELECT SUM(amount_paise) AS v FROM expenses '
      'WHERE is_voided = 0 AND expense_date >= ? AND expense_date < ?',
      [start, end],
    );

    final pendingUpi = await scalar('SELECT COUNT(*) AS v FROM payments WHERE status = ?', [
      Variable.withString(PaymentStatus.pendingVerification.name),
    ]);

    Future<List<DueItem>> dues(String dateCondition, List<Variable> vars) async {
      final rows = await customSelect(
        '''
        SELECT t.id AS tenant_id, t.full_name, $_roomLabelSql AS room_label,
               SUM(i.total_paise - i.paid_paise) AS balance, MIN(i.due_date) AS due
        FROM rent_invoices i JOIN tenants t ON t.id = i.tenant_id
        WHERE i.status <> ? AND i.total_paise > i.paid_paise AND $dateCondition
        GROUP BY t.id ORDER BY due ASC, balance DESC LIMIT 20
        ''',
        variables: [cancelled, ...vars],
        readsFrom: {rentInvoices, tenants},
      ).get();
      return rows
          .map(
            (r) => DueItem(
              tenantId: r.read<int>('tenant_id'),
              tenantName: r.read<String>('full_name'),
              roomLabel: r.read<String?>('room_label'),
              balancePaise: r.read<int>('balance'),
              dueDate: DateTime.fromMillisecondsSinceEpoch(r.read<int>('due') * 1000),
            ),
          )
          .toList();
    }

    final dueToday = await dues('i.due_date >= ? AND i.due_date < ?', [
      Variable.withDateTime(today),
      Variable.withDateTime(tomorrow),
    ]);
    final overdue = await dues('i.due_date < ?', [Variable.withDateTime(today)]);

    final checkoutRows = await customSelect(
      '''
      SELECT t.id, t.full_name, t.expected_checkout_date AS d, $_roomLabelSql AS room_label
      FROM tenants t
      WHERE t.status = ? AND t.expected_checkout_date IS NOT NULL AND t.expected_checkout_date < ?
      ORDER BY t.expected_checkout_date ASC LIMIT 10
      ''',
      variables: [
        Variable.withString(TenantStatus.noticeGiven.name),
        Variable.withDateTime(today.add(const Duration(days: 31))),
      ],
    ).get();

    final recentRows = await customSelect('''
      SELECT * FROM (
        SELECT 'payment' AS src, p.kind AS kind, p.method AS method, p.status AS status,
               t.full_name AS title, p.receipt_number AS ref, p.amount_paise AS amount,
               p.payment_date AS d, p.created_at AS c
        FROM payments p JOIN tenants t ON t.id = p.tenant_id
        WHERE p.status <> 'rejected' AND p.method <> 'deposit'
        UNION ALL
        SELECT 'expense', NULL, e.payment_method, NULL, e.title, e.category, -e.amount_paise,
               e.expense_date, e.created_at
        FROM expenses e WHERE e.is_voided = 0
      ) ORDER BY d DESC, c DESC LIMIT 8
      ''').get();

    return DashboardSummary(
      range: range,
      totalTenants: totalTenants,
      totalBeds: bedRow.read<int?>('total') ?? 0,
      occupiedBeds: bedRow.read<int?>('occupied') ?? 0,
      reservedBeds: bedRow.read<int?>('reserved') ?? 0,
      maintenanceBeds: bedRow.read<int?>('maintenance') ?? 0,
      rentBilledPaise: billed,
      rentCollectedPaise: collected,
      outstandingPaise: outstanding,
      expensesPaise: expenseTotal,
      pendingUpiCount: pendingUpi,
      dueToday: dueToday,
      overdue: overdue,
      upcomingCheckouts: checkoutRows
          .map(
            (r) => CheckoutItem(
              tenantId: r.read<int>('id'),
              tenantName: r.read<String>('full_name'),
              roomLabel: r.read<String?>('room_label'),
              date: DateTime.fromMillisecondsSinceEpoch(r.read<int>('d') * 1000),
            ),
          )
          .toList(),
      recent: recentRows.map(_toRecent).toList(),
    );
  }

  RecentTransaction _toRecent(QueryRow r) {
    final src = r.read<String>('src');
    final amount = r.read<int>('amount');
    final date = DateTime.fromMillisecondsSinceEpoch(r.read<int>('d') * 1000);
    if (src == 'expense') {
      final category = ExpenseCategory.values.byName(r.read<String>('ref'));
      return RecentTransaction(
        type: TransactionType.expense,
        title: r.read<String>('title'),
        subtitle: 'Expense · ${category.label}',
        amountPaise: amount,
        date: date,
      );
    }
    final method = PaymentMethod.values.byName(r.read<String>('method'));
    final isReversal = r.read<String>('kind') == PaymentKind.reversal.name;
    return RecentTransaction(
      type: isReversal ? TransactionType.reversal : TransactionType.rentPayment,
      title: r.read<String>('title'),
      subtitle: '${isReversal ? 'Reversal' : 'Rent'} · ${method.label}',
      amountPaise: amount,
      date: date,
      pendingVerification: r.read<String>('status') == PaymentStatus.pendingVerification.name,
    );
  }
}
