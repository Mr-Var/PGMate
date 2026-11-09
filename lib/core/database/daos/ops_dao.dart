import 'dart:convert';

import 'package:drift/drift.dart';

import '../../utils/dates.dart';
import '../../utils/money.dart';
import '../app_database.dart';
import '../enums.dart';
import '../rules.dart';
import '../tables/finance_tables.dart';
import '../tables/operations_tables.dart';
import '../tables/property_tables.dart';

part 'ops_dao.g.dart';

class ComplaintView {
  const ComplaintView(this.complaint, this.tenantName, this.roomNumber, this.expense);
  final Complaint complaint;
  final String? tenantName;
  final String? roomNumber;
  final Expense? expense;

  List<String> get images => (jsonDecode(complaint.imagePaths) as List).cast<String>();
}

class CategoryTotal {
  const CategoryTotal(this.category, this.totalPaise, this.count);
  final ExpenseCategory category;
  final int totalPaise;
  final int count;
}

@DriftAccessor(tables: [Expenses, Complaints, Notices, Menus, Tenants, Rooms, AuditLogs])
class OpsDao extends DatabaseAccessor<AppDatabase> with _$OpsDaoMixin {
  OpsDao(super.db);

  // ---------------------------------------------------------------- Expenses

  Future<int> addExpense({
    required String title,
    required ExpenseCategory category,
    required int amountPaise,
    required DateTime date,
    required PaymentMethod method,
    String? vendor,
    String? billPath,
    String? notes,
  }) {
    if (amountPaise <= 0) throw RuleException('Amount must be more than ₹0.');
    return transaction(() async {
      final id = await into(expenses).insert(
        ExpensesCompanion.insert(
          title: title.trim(),
          category: category,
          amountPaise: amountPaise,
          expenseDate: Dates.today(date),
          paymentMethod: method,
          vendor: Value(_n(vendor)),
          billPath: Value(billPath),
          notes: Value(_n(notes)),
        ),
      );
      await db.settingsDao.log('expense', id, 'create', '${category.name} ${Money.format(amountPaise)}');
      return id;
    });
  }

  /// Expenses are never deleted; a voided expense is excluded from totals.
  Future<void> voidExpense(int id, String reason) {
    return transaction(() async {
      await (update(expenses)..where((e) => e.id.equals(id))).write(
        ExpensesCompanion(isVoided: const Value(true), voidReason: Value(reason)),
      );
      await db.settingsDao.log('expense', id, 'void', reason);
    });
  }

  Stream<List<Expense>> watchExpenses(DateRange range, {ExpenseCategory? category, bool includeVoided = true}) {
    final q = select(expenses)
      ..where((e) => e.expenseDate.isBiggerOrEqualValue(range.start) & e.expenseDate.isSmallerThanValue(range.end))
      ..orderBy([(e) => OrderingTerm.desc(e.expenseDate), (e) => OrderingTerm.desc(e.id)]);
    if (category != null) q.where((e) => e.category.equalsValue(category));
    if (!includeVoided) q.where((e) => e.isVoided.equals(false));
    return q.watch();
  }

  Stream<List<CategoryTotal>> watchCategoryTotals(DateRange range) {
    return customSelect(
      '''SELECT category, SUM(amount_paise) AS total, COUNT(*) AS n FROM expenses
         WHERE is_voided = 0 AND expense_date >= ? AND expense_date < ?
         GROUP BY category ORDER BY total DESC''',
      variables: [Variable.withDateTime(range.start), Variable.withDateTime(range.end)],
      readsFrom: {expenses},
    ).watch().map(
      (rows) => [
        for (final r in rows)
          CategoryTotal(
            ExpenseCategory.values.byName(r.read<String>('category')),
            r.read<int>('total'),
            r.read<int>('n'),
          ),
      ],
    );
  }

  // -------------------------------------------------------------- Complaints

  Future<int> addComplaint({
    int? tenantId,
    int? roomId,
    required String category,
    required String description,
    required ComplaintPriority priority,
    List<String> images = const [],
  }) {
    return transaction(() async {
      final id = await into(complaints).insert(
        ComplaintsCompanion.insert(
          tenantId: Value(tenantId),
          roomId: Value(roomId),
          category: category,
          description: description.trim(),
          priority: priority,
          imagePaths: Value(jsonEncode(images)),
        ),
      );
      await db.settingsDao.log('complaint', id, 'create', category);
      return id;
    });
  }

  /// Moves a complaint along Open → In progress → Resolved → Closed.
  /// A repair cost is recorded as a linked Repairs expense.
  Future<void> updateComplaintStatus(
    int id,
    ComplaintStatus status, {
    String? resolutionNotes,
    int? repairCostPaise,
    PaymentMethod repairMethod = PaymentMethod.cash,
  }) {
    return transaction(() async {
      final c = await (select(complaints)..where((x) => x.id.equals(id))).getSingle();
      if (status.index < c.status.index) {
        throw RuleException('A complaint cannot move back to ${status.label.toLowerCase()}.');
      }
      int? expenseId = c.expenseId;
      if (repairCostPaise != null && repairCostPaise > 0) {
        if (expenseId != null) throw RuleException('A repair expense is already recorded for this complaint.');
        expenseId = await addExpense(
          title: 'Repair: ${c.category}',
          category: ExpenseCategory.repairs,
          amountPaise: repairCostPaise,
          date: DateTime.now(),
          method: repairMethod,
          notes: 'Complaint #$id',
        );
      }
      final now = DateTime.now();
      await (update(complaints)..where((x) => x.id.equals(id))).write(
        ComplaintsCompanion(
          status: Value(status),
          resolutionNotes: resolutionNotes == null ? const Value.absent() : Value(_n(resolutionNotes)),
          expenseId: Value(expenseId),
          resolvedAt: status == ComplaintStatus.resolved && c.resolvedAt == null ? Value(now) : const Value.absent(),
          closedAt: status == ComplaintStatus.closed ? Value(now) : const Value.absent(),
          updatedAt: Value(now),
        ),
      );
      await db.settingsDao.log('complaint', id, 'status', status.name);
    });
  }

  Future<void> addComplaintImages(int id, List<String> paths) {
    return transaction(() async {
      final c = await (select(complaints)..where((x) => x.id.equals(id))).getSingle();
      final all = [...(jsonDecode(c.imagePaths) as List).cast<String>(), ...paths];
      await (update(complaints)..where((x) => x.id.equals(id))).write(
        ComplaintsCompanion(imagePaths: Value(jsonEncode(all)), updatedAt: Value(DateTime.now())),
      );
    });
  }

  Stream<List<ComplaintView>> watchComplaints({ComplaintStatus? status, int? tenantId}) {
    final q = select(complaints).join([
      leftOuterJoin(tenants, tenants.id.equalsExp(complaints.tenantId)),
      leftOuterJoin(rooms, rooms.id.equalsExp(complaints.roomId)),
      leftOuterJoin(expenses, expenses.id.equalsExp(complaints.expenseId)),
    ])..orderBy([OrderingTerm.desc(complaints.createdAt)]);
    if (status != null) q.where(complaints.status.equalsValue(status));
    if (tenantId != null) q.where(complaints.tenantId.equals(tenantId));
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          ComplaintView(
            r.readTable(complaints),
            r.readTableOrNull(tenants)?.fullName,
            r.readTableOrNull(rooms)?.roomNumber,
            r.readTableOrNull(expenses),
          ),
      ],
    );
  }

  // ----------------------------------------------------------------- Notices

  Future<int> saveNotice({
    int? id,
    required String title,
    required String body,
    required String category,
    required DateTime publishDate,
  }) {
    return transaction(() async {
      final c = NoticesCompanion(
        title: Value(title.trim()),
        body: Value(body.trim()),
        category: Value(category),
        publishDate: Value(Dates.today(publishDate)),
      );
      if (id == null) {
        final newId = await into(notices).insert(c);
        await db.settingsDao.log('notice', newId, 'create', title);
        return newId;
      }
      await (update(notices)..where((n) => n.id.equals(id))).write(c);
      await db.settingsDao.log('notice', id, 'update', title);
      return id;
    });
  }

  Future<void> deleteNotice(int id) => transaction(() async {
    await (delete(notices)..where((n) => n.id.equals(id))).go();
    await db.settingsDao.log('notice', id, 'delete');
  });

  Stream<List<Notice>> watchNotices() =>
      (select(notices)..orderBy([(n) => OrderingTerm.desc(n.publishDate), (n) => OrderingTerm.desc(n.id)])).watch();

  // ------------------------------------------------------------------- Menus

  Future<void> saveMenu(DateTime date, {required String breakfast, required String lunch, required String dinner}) {
    final day = Dates.today(date);
    return into(menus).insert(
      MenusCompanion.insert(
        menuDate: day,
        breakfast: Value(breakfast.trim()),
        lunch: Value(lunch.trim()),
        dinner: Value(dinner.trim()),
        updatedAt: Value(DateTime.now()),
      ),
      onConflict: DoUpdate(
        (_) => MenusCompanion(
          breakfast: Value(breakfast.trim()),
          lunch: Value(lunch.trim()),
          dinner: Value(dinner.trim()),
          updatedAt: Value(DateTime.now()),
        ),
        target: [menus.menuDate],
      ),
    );
  }

  /// Copies every menu from the 7 days before [weekStart] onto this week.
  Future<int> copyPreviousWeek(DateTime weekStart) {
    return transaction(() async {
      final start = Dates.today(weekStart);
      final prev =
          await (select(menus)..where(
                (m) =>
                    m.menuDate.isBiggerOrEqualValue(start.subtract(const Duration(days: 7))) &
                    m.menuDate.isSmallerThanValue(start),
              ))
              .get();
      for (final m in prev) {
        await saveMenu(
          m.menuDate.add(const Duration(days: 7)),
          breakfast: m.breakfast,
          lunch: m.lunch,
          dinner: m.dinner,
        );
      }
      return prev.length;
    });
  }

  Stream<List<Menu>> watchMenus(DateTime from, DateTime to) =>
      (select(menus)
            ..where(
              (m) =>
                  m.menuDate.isBiggerOrEqualValue(Dates.today(from)) & m.menuDate.isSmallerThanValue(Dates.today(to)),
            )
            ..orderBy([(m) => OrderingTerm.asc(m.menuDate)]))
          .watch();

  static String? _n(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}
