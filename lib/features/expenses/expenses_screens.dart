import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/daos/ops_dao.dart';
import '../../core/database/enums.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/form_kit.dart';
import '../../shared/widgets/owner_pin.dart';
import '../../shared/widgets/state_views.dart';
import '../../shared/widgets/validators.dart';
import '../payments/payment_widgets.dart';

IconData expenseIcon(ExpenseCategory c) => switch (c) {
  ExpenseCategory.electricity => Icons.bolt_rounded,
  ExpenseCategory.water => Icons.water_drop_outlined,
  ExpenseCategory.food => Icons.restaurant_outlined,
  ExpenseCategory.staffSalaries => Icons.badge_outlined,
  ExpenseCategory.internet => Icons.wifi_rounded,
  ExpenseCategory.maintenance => Icons.build_outlined,
  ExpenseCategory.cleaning => Icons.cleaning_services_outlined,
  ExpenseCategory.repairs => Icons.handyman_outlined,
  ExpenseCategory.miscellaneous => Icons.more_horiz_rounded,
};

class _Month extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime(DateTime.now().year, DateTime.now().month);
  void shift(int n) => state = DateTime(state.year, state.month + n);
}

final _monthProvider = NotifierProvider<_Month, DateTime>(_Month.new);

final _expensesProvider = StreamProvider<List<Expense>>((ref) {
  final m = ref.watch(_monthProvider);
  return ref.watch(databaseProvider).opsDao.watchExpenses(DateRange.month(m.year, m.month));
});

final _totalsProvider = StreamProvider<List<CategoryTotal>>((ref) {
  final m = ref.watch(_monthProvider);
  return ref.watch(databaseProvider).opsDao.watchCategoryTotals(DateRange.month(m.year, m.month));
});

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(_monthProvider);
    final list = ref.watch(_expensesProvider);
    final totals = ref.watch(_totalsProvider).value ?? const <CategoryTotal>[];
    final total = totals.fold<int>(0, (a, c) => a + c.totalPaise);
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.push('/more/expenses/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add expense'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, 96),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: () => ref.read(_monthProvider.notifier).shift(-1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(Dates.monthYear(m), textAlign: TextAlign.center, style: t.titleMedium),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: () => ref.read(_monthProvider.notifier).shift(1),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Spent in ${Dates.monthYear(m)}', style: t.labelLarge?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(Money.format(total), style: t.headlineMedium?.copyWith(fontFeatures: AppTheme.tabular)),
                if (totals.isNotEmpty) ...[
                  const SizedBox(height: Gap.lg),
                  for (final c in totals.take(6))
                    Padding(
                      padding: const EdgeInsets.only(bottom: Gap.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(expenseIcon(c.category), size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Expanded(child: Text(c.category.label, style: t.bodySmall)),
                              Text(
                                Money.format(c.totalPaise),
                                style: t.bodySmall?.copyWith(
                                  fontFeatures: AppTheme.tabular,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0 : c.totalPaise / total,
                              minHeight: 6,
                              backgroundColor: AppColors.surfaceMuted,
                              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SectionHeader(title: 'Entries'),
          list.when(
            skipLoadingOnReload: true,
            loading: () => const SkeletonBox(height: 200, radius: Radii.lg),
            error: (e, _) => ErrorState(error: e),
            data: (l) => l.isEmpty
                ? const AppCard(
                    child: Text('No expenses recorded this month.', style: TextStyle(color: AppColors.textSecondary)),
                  )
                : TileGroup(indent: 68, children: [for (final e in l) _ExpenseTile(expense: e)]),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends ConsumerWidget {
  const _ExpenseTile({required this.expense});
  final Expense expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = expense;
    final t = Theme.of(context).textTheme;
    return ListTile(
      minTileHeight: 68,
      onTap: () => _details(context, ref),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primary.withValues(alpha: 0.08),
        child: Icon(expenseIcon(e.category), size: 20, color: e.isVoided ? AppColors.textMuted : AppColors.primary),
      ),
      title: Text(e.title, style: TextStyle(decoration: e.isVoided ? TextDecoration.lineThrough : null)),
      subtitle: Text(
        [e.category.label, if (e.vendor != null) e.vendor!, Dates.dayMonth(e.expenseDate)].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: t.bodySmall?.copyWith(color: AppColors.textMuted),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            Money.format(e.amountPaise),
            style: t.titleSmall?.copyWith(
              fontFeatures: AppTheme.tabular,
              color: e.isVoided ? AppColors.textMuted : null,
            ),
          ),
          if (e.isVoided)
            const StatusPill(label: 'Voided', color: AppColors.textSecondary, background: AppColors.neutralSoft)
          else if (e.billPath != null)
            const Icon(Icons.attach_file_rounded, size: 16, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Future<void> _details(BuildContext context, WidgetRef ref) async {
    final e = expense;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final t = Theme.of(ctx).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(e.title, style: t.titleLarge),
                const SizedBox(height: Gap.xs),
                Text(
                  '${Money.format(e.amountPaise)} · ${e.category.label} · ${e.paymentMethod.label} · ${Dates.short(e.expenseDate)}'
                  '${e.vendor == null ? '' : '\nVendor: ${e.vendor}'}${e.notes == null ? '' : '\n${e.notes}'}'
                  '${e.voidReason == null ? '' : '\nVoided: ${e.voidReason}'}',
                  style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: Gap.xl),
                if (e.billPath != null) ...[
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push(
                        Uri(path: '/document', queryParameters: {'path': e.billPath!, 'title': e.title}).toString(),
                      );
                    },
                    icon: const Icon(Icons.receipt_outlined),
                    label: const Text('View bill'),
                  ),
                  const SizedBox(height: Gap.md),
                ],
                if (!e.isVoided) ...[
                  AsyncButton(
                    label: 'Correct this expense',
                    icon: Icons.edit_outlined,
                    outlined: true,
                    onPressed: () async {
                      // Expenses are never edited in place: the corrected copy
                      // replaces this one when it is saved, and this one is voided then.
                      final pinOk = await requireOwnerPin(
                        ctx,
                        ref,
                        message: 'You will enter the corrected expense. This one is voided only when you save it.',
                      );
                      if (!pinOk || !ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (context.mounted) context.push('/more/expenses/new?from=${e.id}');
                    },
                  ),
                  const SizedBox(height: Gap.md),
                  AsyncButton(
                    label: 'Void this expense',
                    outlined: true,
                    danger: true,
                    onPressed: () async {
                      final reason = await askReason(ctx, title: 'Void expense?', hint: 'Reason', confirmLabel: 'Void');
                      if (reason == null || !ctx.mounted) return;
                      final pinOk = await requireOwnerPin(
                        ctx,
                        ref,
                        message: 'Voiding removes this expense from totals.',
                      );
                      if (!pinOk || !ctx.mounted) return;
                      final ok = await runGuarded(
                        ctx,
                        () => ref.read(databaseProvider).opsDao.voidExpense(e.id, reason),
                        success: 'Expense voided',
                      );
                      if (ok && ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key, this.copyFromId});

  /// Pre-fills the form from a voided expense being corrected.
  final int? copyFromId;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _vendor = TextEditingController();
  final _notes = TextEditingController();
  ExpenseCategory? _category;
  PaymentMethod _method = PaymentMethod.cash;
  DateTime _date = Dates.today();
  (Uint8List, String)? _bill;
  String? _existingBill;

  @override
  void initState() {
    super.initState();
    final from = widget.copyFromId;
    if (from != null) {
      final db = ref.read(databaseProvider);
      (db.select(db.expenses)..where((x) => x.id.equals(from))).getSingleOrNull().then((e) {
        if (e == null || !mounted) return;
        setState(() {
          _title.text = e.title;
          _amount.text = Money.toInput(e.amountPaise);
          _vendor.text = e.vendor ?? '';
          _notes.text = e.notes ?? '';
          _category = e.category;
          _method = e.paymentMethod;
          _date = e.expenseDate;
          _existingBill = e.billPath;
        });
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_title, _amount, _vendor, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final path = _bill == null
        ? _existingBill
        : await ref.read(fileStoreProvider).save(_bill!.$1, folder: 'bills', extension: _bill!.$2);
    if (!mounted) return;
    final ops = ref.read(databaseProvider).opsDao;
    final from = widget.copyFromId;
    int? savedId;
    final ok = await runGuarded(
      context,
      () async => savedId = await (from == null
          ? ops.addExpense(
              title: _title.text,
              category: _category!,
              amountPaise: MoneyField.read(_amount),
              date: _date,
              method: _method,
              vendor: _vendor.text,
              billPath: path,
              notes: _notes.text,
            )
          : ops.correctExpense(
              from,
              title: _title.text,
              category: _category!,
              amountPaise: MoneyField.read(_amount),
              date: _date,
              method: _method,
              vendor: _vendor.text,
              billPath: path,
              notes: _notes.text,
            )),
    );
    if (!ok || !mounted) return;
    final amount = Money.format(MoneyField.read(_amount));
    showAppSnack(
      context,
      from == null ? '$amount expense saved' : 'Expense corrected',
      actionLabel: 'Undo',
      onAction: savedId == null ? null : () => ops.voidExpense(savedId!, 'Undone right after saving'),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.copyFromId == null ? 'Add expense' : 'Corrected expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
          children: [
            FormSection(
              title: 'Category',
              children: [
                Wrap(
                  spacing: Gap.sm,
                  runSpacing: Gap.sm,
                  children: [
                    for (final c in ExpenseCategory.values)
                      ChoiceChip(
                        avatar: Icon(expenseIcon(c), size: 18),
                        label: Text(c.label),
                        selected: _category == c,
                        showCheckmark: false,
                        onSelected: (_) => setState(() {
                          _category = c;
                          if (_title.text.trim().isEmpty) _title.text = c.label;
                        }),
                      ),
                  ],
                ),
                FormField<ExpenseCategory>(
                  validator: (_) => _category == null ? 'Choose a category' : null,
                  builder: (s) => s.hasError
                      ? Text(s.errorText!, style: const TextStyle(color: AppColors.danger, fontSize: 12))
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            FormSection(
              title: 'Details',
              children: [
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. November electricity bill'),
                  validator: (v) => Validators.required(v, 'Title', max: 120),
                ),
                MoneyField(controller: _amount, label: 'Amount'),
                DateField(
                  label: 'Date',
                  value: _date,
                  last: Dates.today(),
                  onChanged: (d) => setState(() => _date = d),
                ),
                SegmentedButton<PaymentMethod>(
                  segments: const [
                    ButtonSegment(value: PaymentMethod.cash, label: Text('Cash')),
                    ButtonSegment(value: PaymentMethod.upi, label: Text('UPI')),
                    ButtonSegment(value: PaymentMethod.bank, label: Text('Bank')),
                  ],
                  selected: {_method},
                  onSelectionChanged: (s) => setState(() => _method = s.first),
                ),
                TextFormField(
                  controller: _vendor,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Vendor (optional)', hintText: 'e.g. BESCOM'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final d = await pickDocument(context, title: 'Bill');
                    if (d != null) setState(() => _bill = d);
                  },
                  icon: Icon(
                    _bill == null ? Icons.attach_file_rounded : Icons.check_circle_rounded,
                    color: _bill == null ? null : AppColors.success,
                  ),
                  label: Text(
                    _bill != null || _existingBill != null
                        ? 'Bill attached · tap to change'
                        : 'Attach bill (photo or PDF)',
                  ),
                ),
                TextFormField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                ),
              ],
            ),
            AsyncButton(label: 'Save expense', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
