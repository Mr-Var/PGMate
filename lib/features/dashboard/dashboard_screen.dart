import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/database/daos/billing_dao.dart';
import '../../core/database/daos/dashboard_dao.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/form_kit.dart';
import '../../shared/widgets/state_views.dart';
import '../payments/payments_providers.dart';
import 'dashboard_providers.dart';
import 'period_picker.dart';

final _missingInvoicesProvider = StreamProvider<int>(
  (ref) => ref.watch(databaseProvider).billingDao.watchMissingInvoiceCount(),
);

final _trendProvider = FutureProvider<List<(DateTime, int, int)>>((ref) {
  ref.watch(dashboardSummaryProvider); // refresh with the dashboard
  return ref.watch(databaseProvider).reportsDao.monthlyTrend(6);
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final range = ref.watch(dashboardRangeProvider);
    final profile = ref.watch(pgProfileProvider).value;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardSummaryProvider),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, 0),
                sliver: SliverToBoxAdapter(
                  child: _Header(
                    pgName: profile?.name,
                    range: range,
                    onPickRange: () async {
                      final picked = await showPeriodPicker(context, range);
                      if (picked != null) ref.read(dashboardRangeProvider.notifier).set(picked);
                    },
                  ),
                ),
              ),
              ...summary.when(
                skipLoadingOnReload: true,
                data: (s) => [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.xxl),
                    sliver: SliverList.list(children: _content(context, s)),
                  ),
                ],
                loading: () => [const SliverFillRemaining(hasScrollBody: false, child: _DashboardSkeleton())],
                error: (e, _) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorState(error: e, onRetry: () => ref.invalidate(dashboardSummaryProvider)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, DashboardSummary s) {
    return [
      if (s.totalBeds == 0) ...[
        _SetupCard(onAddRoom: () => context.push('/rooms/new')),
        const SizedBox(height: Gap.lg),
      ],
      _LedgerCard(summary: s),
      const SizedBox(height: Gap.md),
      const _QuickActions(),
      _Attention(summary: s),
      const SectionHeader(title: 'Occupancy'),
      _OccupancyCard(summary: s, onTap: () => context.go('/rooms')),
      const SectionHeader(title: 'Last 6 months'),
      const _TrendCard(),
      SectionHeader(title: 'Due today', count: s.dueToday.length),
      _PeopleList(items: s.dueToday, emptyText: 'No rent is due today.', overdue: false),
      SectionHeader(title: 'Overdue', count: s.overdue.length),
      _PeopleList(items: s.overdue, emptyText: 'Nobody is overdue.', overdue: true),
      SectionHeader(title: 'Leaving soon', count: s.upcomingCheckouts.length),
      _CheckoutList(items: s.upcomingCheckouts),
      const SectionHeader(title: 'Recent activity'),
      _RecentList(items: s.recent),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.pgName, required this.range, required this.onPickRange});

  final String? pgName;
  final DateRange range;
  final VoidCallback onPickRange;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(DateFormat('EEEE, d MMMM').format(DateTime.now())),
              const SizedBox(height: 4),
              Text(pgName ?? 'Dashboard', maxLines: 1, overflow: TextOverflow.ellipsis, style: t.headlineSmall),
            ],
          ),
        ),
        const SizedBox(width: Gap.md),
        Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
            side: const BorderSide(color: AppColors.borderStrong),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(Radii.md),
            onTap: onPickRange,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(range.isSingleMonth ? Dates.monthYear(range.start) : 'Custom range', style: t.labelLarge),
                  const SizedBox(width: 4),
                  const Icon(Icons.unfold_more_rounded, size: 18, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The one place money figures appear on the dashboard, read like a ledger.
class _LedgerCard extends StatelessWidget {
  const _LedgerCard({required this.summary});
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = summary;
    final pct = (s.collectionRate * 100).round();
    final net = s.netCashFlowPaise;
    final period = s.range.isSingleMonth ? DateFormat('MMMM').format(s.range.start) : 'this period';

    return Semantics(
      container: true,
      label:
          'Received ${Money.format(s.rentCollectedPaise)} in ${s.range.label}. '
          '${Money.format(s.billedPaidPaise)} of ${Money.format(s.rentBilledPaise)} billed is paid. '
          'Outstanding ${Money.format(s.outstandingPaise)}. Expenses ${Money.format(s.expensesPaise)}.',
      excludeSemantics: true,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gap.lg + 4, Gap.lg + 4, Gap.lg + 4, Gap.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow('Rent received in $period'),
                  const SizedBox(height: Gap.sm),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(Money.format(s.rentCollectedPaise), style: AppTheme.figure(36)),
                  ),
                  const SizedBox(height: Gap.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.rentBilledPaise == 0
                              ? 'No rent billed for $period yet'
                              : '${Money.format(s.billedPaidPaise)} of ${Money.format(s.rentBilledPaise)} billed is paid',
                          style: t.bodySmall?.copyWith(color: AppColors.textSecondary, fontFeatures: AppTheme.tabular),
                        ),
                      ),
                      if (s.rentBilledPaise > 0)
                        Text('$pct%', style: AppTheme.figure(13, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: Gap.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: s.collectionRate),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, _) => LinearProgressIndicator(
                        value: v,
                        minHeight: 6,
                        backgroundColor: AppColors.heroTrack,
                        valueColor: const AlwaysStoppedAnimation(AppColors.heroProgress),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            IntrinsicHeight(
              child: Row(
                children: [
                  _Figure(
                    label: 'Due',
                    value: s.outstandingPaise,
                    color: s.outstandingPaise > 0 ? AppColors.danger : null,
                  ),
                  const VerticalDivider(width: 1),
                  _Figure(label: 'Expenses', value: s.expensesPaise),
                  const VerticalDivider(width: 1),
                  _Figure(
                    label: 'Net cash',
                    value: net,
                    signed: true,
                    color: net < 0 ? AppColors.danger : (net > 0 ? AppColors.success : null),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value, this.color, this.signed = false});
  final String label;
  final int value;
  final Color? color;
  final bool signed;

  @override
  Widget build(BuildContext context) {
    final text = signed && value != 0 ? '${value > 0 ? '+' : '−'}${Money.format(value.abs())}' : Money.format(value);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.md, Gap.sm, Gap.md + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(label),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(text, style: AppTheme.figure(15.5, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    const actions = [
      (Icons.person_add_alt_outlined, 'Add tenant', '/tenants/new'),
      (Icons.payments_outlined, 'Collect', '/payments/collect'),
      (Icons.receipt_long_outlined, 'Expense', '/more/expenses/new'),
      (Icons.campaign_outlined, 'Remind', '/payments/remind'),
    ];
    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (final (i, a) in actions.indexed) ...[
              if (i > 0) const VerticalDivider(width: 1),
              Expanded(
                child: Semantics(
                  button: true,
                  label: a.$2,
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => context.push(a.$3),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Gap.md + 2),
                      child: Column(
                        children: [
                          Icon(a.$1, color: AppColors.primary, size: 22),
                          const SizedBox(height: 6),
                          Text(a.$2, style: Theme.of(context).textTheme.labelMedium, maxLines: 1),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Things the owner should act on, in one compact list. Hidden when clear.
class _Attention extends ConsumerWidget {
  const _Attention({required this.summary});
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = summary;
    final missing = ref.watch(_missingInvoicesProvider).value ?? 0;
    final overdueTotal = s.overdue.fold<int>(0, (a, d) => a + d.balancePaise);
    final rows = <(IconData, Color, String, String, VoidCallback)>[
      if (s.pendingUpiCount > 3)
        (
          Icons.hourglass_top_rounded,
          AppColors.warning,
          '${s.pendingUpiCount - 3} more UPI payments to verify',
          'Open the Verify tab in Payments',
          () => context.go('/payments'),
        ),
      if (missing > 0)
        (
          Icons.receipt_long_outlined,
          AppColors.primary,
          '$missing ${missing == 1 ? 'invoice' : 'invoices'} not created',
          'Months with a tenant in a bed but no bill',
          () => _billMissing(context, ref, missing),
        ),
      if (s.overdue.isNotEmpty)
        (
          Icons.error_outline_rounded,
          AppColors.danger,
          '${s.overdue.length} overdue · ${Money.format(overdueTotal)}',
          'Send WhatsApp reminders in one go',
          () => context.push('/payments/remind'),
        ),
    ];
    final pending = ref.watch(pendingUpiProvider).value ?? const <PaymentView>[];
    if (rows.isEmpty && pending.isEmpty) return const SizedBox.shrink();
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Needs attention'),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (i, v) in pending.take(3).indexed) ...[if (i > 0) const Divider(indent: 52), _UpiRow(view: v)],
              if (pending.isNotEmpty && rows.isNotEmpty) const Divider(indent: 52),
              for (final (i, r) in rows.indexed) ...[
                if (i > 0) const Divider(indent: 52),
                InkWell(
                  onTap: r.$5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
                    child: Row(
                      children: [
                        Icon(r.$1, size: 20, color: r.$2),
                        const SizedBox(width: Gap.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.$3, style: t.titleSmall?.copyWith(fontFeatures: AppTheme.tabular)),
                              Text(r.$4, style: t.bodySmall?.copyWith(color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _billMissing(BuildContext context, WidgetRef ref, int count) async {
    final ok = await confirmAction(
      context,
      title: 'Create $count ${count == 1 ? 'invoice' : 'invoices'}?',
      message:
          'Bills every month a tenant has had a bed but no invoice, up to this month. '
          'The first month is charged from the day the bed was assigned. Advance credit is applied.',
      confirmLabel: 'Create',
    );
    if (!ok || !context.mounted) return;
    await runGuarded(context, () async {
      final db = ref.read(databaseProvider);
      final n = await db.billingDao.generateAllMissing();
      await refreshReminders(db, ref.read(reminderServiceProvider));
      if (context.mounted) showAppSnack(context, '$n ${n == 1 ? 'invoice' : 'invoices'} created');
    });
  }
}

/// A UPI payment awaiting confirmation, confirmable in one tap.
class _UpiRow extends ConsumerWidget {
  const _UpiRow({required this.view});
  final PaymentView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = view.payment;
    final t = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => context.push('/payments/${p.id}'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.sm, Gap.sm),
        child: Row(
          children: [
            const Icon(Icons.hourglass_top_rounded, size: 20, color: AppColors.warning),
            const SizedBox(width: Gap.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${Money.format(p.amountPaise)} UPI · ${view.tenantName.split(' ').first}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleSmall?.copyWith(fontFeatures: AppTheme.tabular),
                  ),
                  Text(
                    'UTR ${p.upiReference ?? '—'} · check your bank app',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => runGuarded(context, () async {
                final db = ref.read(databaseProvider);
                await db.billingDao.verifyUpiPayment(p.id);
                await refreshReminders(db, ref.read(reminderServiceProvider));
              }, success: '${Money.format(p.amountPaise)} confirmed'),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Received'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OccupancyCard extends StatelessWidget {
  const _OccupancyCard({required this.summary, required this.onTap});
  final DashboardSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = summary;
    final segments = [
      ('Occupied', s.occupiedBeds, AppColors.bedOccupied),
      ('Free', s.availableBeds, AppColors.bedAvailable),
      ('Reserved', s.reservedBeds, AppColors.bedReserved),
      ('Repair', s.maintenanceBeds, AppColors.bedMaintenance),
    ];
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${(s.occupancy * 100).round()}%', style: AppTheme.figure(28)),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Text(
                  '${s.occupiedBeds} of ${s.totalBeds} beds · ${s.totalTenants} tenants',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 8,
              child: s.totalBeds == 0
                  ? Container(color: AppColors.surfaceMuted)
                  : Row(
                      children: [
                        for (final seg in segments)
                          if (seg.$2 > 0)
                            Expanded(
                              flex: seg.$2,
                              child: Container(color: seg.$3),
                            ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: Gap.md),
          Row(
            children: [
              for (final seg in segments)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: seg.$3, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(seg.$1, maxLines: 1, style: t.labelSmall?.copyWith(color: AppColors.textMuted)),
                          ),
                        ],
                      ),
                      Text('${seg.$2}', style: AppTheme.figure(15)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Six months of billed vs received, drawn to one scale with a baseline.
class _TrendCard extends ConsumerWidget {
  const _TrendCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_trendProvider).value;
    final t = Theme.of(context).textTheme;
    if (data == null) return const SkeletonBox(height: 190, radius: Radii.lg);
    final maxV = data.fold<int>(0, (a, d) => [a, d.$2, d.$3].reduce((x, y) => x > y ? x : y));
    if (maxV == 0) {
      return AppCard(
        child: Text(
          'Billed and received rent for the last six months will appear here.',
          style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    final last = data.last;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Legend(color: AppColors.borderStrong, label: 'Billed'),
              const SizedBox(width: Gap.lg),
              const _Legend(color: AppColors.primary, label: 'Received'),
              const Spacer(),
              Text('max ${Money.compact(maxV)}', style: t.labelSmall?.copyWith(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: Gap.md),
          SizedBox(
            height: 112,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderStrong)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final d in data)
                    Expanded(
                      child: Semantics(
                        label: '${Dates.monthYear(d.$1)}: billed ${Money.format(d.$2)}, received ${Money.format(d.$3)}',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: _Bar(fraction: d.$2 / maxV, color: AppColors.borderStrong),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: _Bar(fraction: d.$3 / maxV, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final d in data)
                Expanded(
                  child: Text(
                    DateFormat('MMM').format(d.$1),
                    textAlign: TextAlign.center,
                    style: t.labelSmall?.copyWith(
                      color: d == last ? AppColors.textPrimary : AppColors.textMuted,
                      fontWeight: d == last ? FontWeight.w600 : null,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.fraction, required this.color});
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraction.clamp(0, 1)),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Container(
        height: v == 0 ? 0 : (111 * v).clamp(2, 111),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      ),
      const SizedBox(width: 6),
      Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
    ],
  );
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gap.xs),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
    );
  }
}

class _PeopleList extends StatelessWidget {
  const _PeopleList({required this.items, required this.emptyText, required this.overdue});

  final List<DueItem> items;
  final String emptyText;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _InlineEmpty(text: emptyText);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (i, d) in items.indexed) ...[
            if (i > 0) const Divider(indent: 64),
            ListTile(
              minTileHeight: 60,
              onTap: () => context.push('/tenants/${d.tenantId}'),
              leading: PersonAvatar(name: d.tenantName),
              title: Text(d.tenantName, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: Money.format(d.balancePaise),
                      style: AppTheme.figure(12.5, color: overdue ? AppColors.danger : AppColors.textPrimary),
                    ),
                    TextSpan(
                      text:
                          ' · ${[d.roomLabel, overdue ? Dates.relativeDays(d.dueDate).toLowerCase() : null].whereType<String>().join(' · ')}',
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textMuted),
              ),
              trailing: FilledButton.tonal(
                onPressed: () => context.push('/payments/collect?tenant=${d.tenantId}'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  backgroundColor: AppColors.accentSoft,
                  foregroundColor: AppColors.primary,
                ),
                child: const Text('Collect'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckoutList extends StatelessWidget {
  const _CheckoutList({required this.items});
  final List<CheckoutItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _InlineEmpty(text: 'No checkouts in the next 30 days.');
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (i, c) in items.indexed) ...[
            if (i > 0) const Divider(indent: 64),
            ListTile(
              minTileHeight: 60,
              onTap: () => context.push('/tenants/${c.tenantId}/checkout'),
              leading: PersonAvatar(name: c.tenantName),
              title: Text(c.tenantName, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: c.roomLabel == null ? null : Text(c.roomLabel!),
              trailing: Text(
                Dates.relativeDays(c.date),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.info),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentList extends StatelessWidget {
  const _RecentList({required this.items});
  final List<RecentTransaction> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _InlineEmpty(text: 'Payments and expenses you record will appear here.');
    final t = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (i, r) in items.indexed) ...[
            if (i > 0) const Divider(indent: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${Dates.dayMonth(r.date)} · ${r.subtitle}${r.pendingVerification ? ' · unverified' : ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodySmall?.copyWith(
                            color: r.pendingVerification ? AppColors.warning : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Gap.md),
                  Text(
                    '${r.amountPaise >= 0 ? '+' : '−'}${Money.format(r.amountPaise.abs())}',
                    style: AppTheme.figure(14.5, color: r.amountPaise >= 0 ? AppColors.success : AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SetupCard extends StatelessWidget {
  const _SetupCard({required this.onAddRoom});
  final VoidCallback onAddRoom;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Getting started'),
          const SizedBox(height: Gap.sm),
          Text('Add your rooms and beds', style: t.titleMedium),
          const SizedBox(height: Gap.xs),
          Text(
            'Each room needs a floor, number of beds and rent. Occupancy, billing and the bed map all start from here.',
            style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: Gap.lg),
          FilledButton.icon(
            onPressed: onAddRoom,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add first room'),
          ),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(Gap.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 220, radius: Radii.lg),
          SizedBox(height: Gap.md),
          SkeletonBox(height: 72, radius: Radii.lg),
          SizedBox(height: Gap.xl),
          SkeletonBox(height: 120, radius: Radii.lg),
        ],
      ),
    );
  }
}
