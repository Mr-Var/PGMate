import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/database/daos/dashboard_dao.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/state_views.dart';
import 'dashboard_providers.dart';
import 'period_picker.dart';

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
                    ownerName: profile?.ownerName,
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
      _CollectionHero(summary: s),
      if (s.pendingUpiCount > 0) ...[const SizedBox(height: Gap.md), _PendingUpiBanner(count: s.pendingUpiCount)],
      const SectionHeader(title: 'Quick actions'),
      const _QuickActions(),
      const _InvoicePrompt(),
      const SectionHeader(title: 'Occupancy'),
      _OccupancyCard(summary: s, onTap: () => context.go('/rooms')),
      SectionHeader(
        title: 'Finances',
        trailing: Text(s.range.label, style: _caption(context)),
      ),
      _FinanceGrid(summary: s),
      const SectionHeader(title: 'Collection trend'),
      const _TrendCard(),
      SectionHeader(title: 'Rent due today', count: s.dueToday.length),
      _DueList(items: s.dueToday, emptyText: 'No rent is due today.', overdue: false),
      SectionHeader(title: 'Overdue', count: s.overdue.length),
      _DueList(items: s.overdue, emptyText: 'No overdue rent. Great job!', overdue: true),
      SectionHeader(title: 'Upcoming checkouts', count: s.upcomingCheckouts.length),
      _CheckoutList(items: s.upcomingCheckouts),
      const SectionHeader(title: 'Recent transactions'),
      _RecentList(items: s.recent),
    ];
  }

  static TextStyle? _caption(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted);
}

class _Header extends StatelessWidget {
  const _Header({required this.ownerName, required this.pgName, required this.range, required this.onPickRange});

  final String? ownerName;
  final String? pgName;
  final DateRange range;
  final VoidCallback onPickRange;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final first = ownerName?.split(' ').first;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                first == null ? _greeting : '$_greeting, $first',
                style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(pgName ?? 'Dashboard', maxLines: 1, overflow: TextOverflow.ellipsis, style: t.headlineSmall),
            ],
          ),
        ),
        const SizedBox(width: Gap.md),
        ActionChip(
          avatar: const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
          label: Text(range.isSingleMonth ? Dates.monthYear(range.start) : 'Custom'),
          tooltip: 'Change period: ${range.label}',
          onPressed: onPickRange,
        ),
      ],
    );
  }
}

class _CollectionHero extends StatelessWidget {
  const _CollectionHero({required this.summary});
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = summary;
    final pct = (s.collectionRate * 100).round();
    final onDim = Colors.white.withValues(alpha: 0.72);

    return Semantics(
      container: true,
      label:
          'Collected ${Money.format(s.rentCollectedPaise)} in ${s.range.label}. '
          'Billed ${Money.format(s.rentBilledPaise)}. Outstanding ${Money.format(s.outstandingPaise)}.',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(Gap.xl),
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(Radii.xl)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Rent collected',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: t.labelLarge?.copyWith(color: onDim)),
                ),
                const SizedBox(width: Gap.sm),
                Flexible(
                  child: Text(s.range.label,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: t.labelMedium?.copyWith(color: onDim)),
                ),
              ],
            ),
            const SizedBox(height: Gap.sm),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                Money.format(s.rentCollectedPaise),
                style: t.displaySmall?.copyWith(color: Colors.white, fontFeatures: AppTheme.tabular),
              ),
            ),
            const SizedBox(height: Gap.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: s.collectionRate),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 8,
                  backgroundColor: AppColors.heroTrack,
                  valueColor: const AlwaysStoppedAnimation(AppColors.heroProgress),
                ),
              ),
            ),
            const SizedBox(height: Gap.sm),
            Text(
              s.rentBilledPaise == 0 ? 'No invoices billed in this period' : '$pct% of billed rent collected',
              style: t.bodySmall?.copyWith(color: onDim),
            ),
            const SizedBox(height: Gap.lg),
            Divider(color: Colors.white.withValues(alpha: 0.14)),
            const SizedBox(height: Gap.md),
            Row(
              children: [
                Expanded(
                  child: _HeroStat(label: 'Billed', value: Money.format(s.rentBilledPaise)),
                ),
                Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.14)),
                const SizedBox(width: Gap.lg),
                Expanded(
                  child: _HeroStat(label: 'Outstanding', value: Money.format(s.outstandingPaise)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: t.labelMedium?.copyWith(color: Colors.white.withValues(alpha: 0.72))),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: t.titleMedium?.copyWith(color: Colors.white, fontFeatures: AppTheme.tabular),
          ),
        ),
      ],
    );
  }
}

class _PendingUpiBanner extends StatelessWidget {
  const _PendingUpiBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/payments'),
      borderRadius: BorderRadius.circular(Radii.md),
      child: Container(
        padding: const EdgeInsets.all(Gap.md),
        decoration: BoxDecoration(
          color: AppColors.warningSoft,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.hourglass_top_rounded, color: AppColors.warning, size: 20),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Text(
                '$count UPI ${count == 1 ? 'payment needs' : 'payments need'} verification. '
                'They are not counted as collected until you confirm them.',
                style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w500, fontSize: 13),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.warning),
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
    final actions = [
      (Icons.person_add_alt_1_outlined, 'Add tenant', '/tenants/new'),
      (Icons.add_card_rounded, 'Collect rent', '/payments/collect'),
      (Icons.receipt_outlined, 'Add expense', '/more/expenses/new'),
      (Icons.report_problem_outlined, 'Complaint', '/more/complaints/new'),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final a in actions)
          Expanded(
            child: Semantics(
              button: true,
              label: a.$2,
              excludeSemantics: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(Radii.md),
                onTap: () => context.push(a.$3),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Gap.sm),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(Radii.lg),
                        ),
                        child: Icon(a.$1, color: AppColors.accentText, size: 26),
                      ),
                      const SizedBox(height: Gap.sm),
                      Text(
                        a.$2,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

final _unbilledNowProvider = StreamProvider<int>((ref) {
  final n = DateTime.now();
  return ref.watch(databaseProvider).billingDao.watchUnbilledCount(n.year, n.month);
});

/// Prompts to bill the current month when some tenants have no invoice yet.
class _InvoicePrompt extends ConsumerWidget {
  const _InvoicePrompt();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(_unbilledNowProvider).value ?? 0;
    if (count == 0) return const SizedBox.shrink();
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: Gap.md),
      child: AppCard(
        onTap: () => context.go('/payments'),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome_outlined, color: AppColors.primary),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bill ${Dates.monthYear(DateTime.now())} rent', style: t.titleSmall),
                  Text(
                    '$count ${count == 1 ? 'tenant has' : 'tenants have'} no invoice yet',
                    style: t.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

final _trendProvider = FutureProvider<List<(DateTime, int, int)>>((ref) {
  ref.watch(dashboardSummaryProvider); // refresh with the dashboard
  return ref.watch(databaseProvider).reportsDao.monthlyTrend(6);
});

/// Six-month billed vs collected bars, drawn to one scale.
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
          'Billed and collected rent for the last six months will appear here.',
          style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Legend(color: AppColors.primary.withValues(alpha: 0.22), label: 'Billed'),
              const SizedBox(width: Gap.lg),
              const _Legend(color: AppColors.primary, label: 'Collected'),
              const Spacer(),
              Text('Max ${Money.compact(maxV)}', style: t.labelSmall?.copyWith(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: Gap.lg),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final d in data)
                  Expanded(
                    child: Semantics(
                      label: '${Dates.monthYear(d.$1)}: billed ${Money.format(d.$2)}, collected ${Money.format(d.$3)}',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: _Bar(fraction: d.$2 / maxV, color: AppColors.primary.withValues(alpha: 0.22)),
                            ),
                            const SizedBox(width: 3),
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
          const SizedBox(height: Gap.sm),
          Row(
            children: [
              for (final d in data)
                Expanded(
                  child: Text(
                    DateFormat('MMM').format(d.$1),
                    textAlign: TextAlign.center,
                    style: t.labelSmall?.copyWith(color: AppColors.textMuted),
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
        height: v == 0 ? 2 : 120 * v,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
      ),
      const SizedBox(width: 6),
      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
    ],
  );
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
      ('Available', s.availableBeds, AppColors.bedAvailable),
      ('Reserved', s.reservedBeds, AppColors.bedReserved),
      ('Maintenance', s.maintenanceBeds, AppColors.bedMaintenance),
    ];

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Gap.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(s.occupancy * 100).round()}%',
                style: t.headlineMedium?.copyWith(fontFeatures: AppTheme.tabular),
              ),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('occupied',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: t.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${s.totalTenants}', style: t.titleLarge?.copyWith(fontFeatures: AppTheme.tabular)),
                  Text('tenants', style: t.bodySmall?.copyWith(color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(width: Gap.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${s.totalBeds}', style: t.titleLarge?.copyWith(fontFeatures: AppTheme.tabular)),
                  Text('beds', style: t.bodySmall?.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: Gap.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
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
          Wrap(
            spacing: Gap.lg,
            runSpacing: Gap.sm,
            children: [
              for (final seg in segments)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: seg.$3, borderRadius: BorderRadius.circular(3)),
                    ),
                    const SizedBox(width: 6),
                    Text('${seg.$1} ${seg.$2}', style: t.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinanceGrid extends StatelessWidget {
  const _FinanceGrid({required this.summary});
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final net = s.netCashFlowPaise;
    final tiles = [
      MetricTile(
        icon: Icons.receipt_long_outlined,
        label: 'Rent billed',
        value: Money.format(s.rentBilledPaise),
        caption: 'Invoices this period',
      ),
      MetricTile(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Collected',
        value: Money.format(s.rentCollectedPaise),
        caption: 'Confirmed payments',
        tone: AppColors.success,
      ),
      MetricTile(
        icon: Icons.pending_actions_outlined,
        label: 'Pending rent',
        value: Money.format(s.outstandingPaise),
        caption: 'All unpaid invoices',
        tone: AppColors.warning,
      ),
      MetricTile(
        icon: Icons.shopping_bag_outlined,
        label: 'Expenses',
        value: Money.format(s.expensesPaise),
        caption: 'Paid this period',
        tone: AppColors.danger,
      ),
    ];
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: tiles[0]),
            const SizedBox(width: Gap.md),
            Expanded(child: tiles[1]),
          ],
        ),
        const SizedBox(height: Gap.md),
        Row(
          children: [
            Expanded(child: tiles[2]),
            const SizedBox(width: Gap.md),
            Expanded(child: tiles[3]),
          ],
        ),
        const SizedBox(height: Gap.md),
        AppCard(
          child: Row(
            children: [
              Icon(
                net >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: net >= 0 ? AppColors.success : AppColors.danger,
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Net cash flow', style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      'Collected minus expenses',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Text(
                '${net > 0
                    ? '+'
                    : net < 0
                    ? '−'
                    : ''}${Money.format(net.abs())}',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontFeatures: AppTheme.tabular, color: net >= 0 ? AppColors.success : AppColors.danger),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.lg),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.color = AppColors.primary});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.take(2).map((p) => p.isEmpty ? '' : p[0].toUpperCase()).join();
    return CircleAvatar(
      radius: 20,
      backgroundColor: color.withValues(alpha: 0.10),
      child: Text(
        initials,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}

class _DueList extends StatelessWidget {
  const _DueList({required this.items, required this.emptyText, required this.overdue});

  final List<DueItem> items;
  final String emptyText;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _InlineEmpty(icon: Icons.task_alt_rounded, text: emptyText);
    final t = Theme.of(context).textTheme;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (i, d) in items.indexed) ...[
            if (i > 0) const Divider(indent: 68),
            ListTile(
              minTileHeight: 64,
              onTap: () => context.push('/tenants/${d.tenantId}'),
              leading: _Avatar(name: d.tenantName, color: overdue ? AppColors.danger : AppColors.primary),
              title: Text(d.tenantName, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                [
                  d.roomLabel,
                  overdue ? 'Due ${Dates.relativeDays(d.dueDate).toLowerCase()}' : null,
                ].whereType<String>().join(' · '),
                style: t.bodySmall?.copyWith(color: overdue ? AppColors.danger : AppColors.textMuted),
              ),
              trailing: Text(
                Money.format(d.balancePaise),
                style: t.titleSmall?.copyWith(fontFeatures: AppTheme.tabular),
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
    if (items.isEmpty) {
      return const _InlineEmpty(icon: Icons.event_available_outlined, text: 'No checkouts in the next 30 days.');
    }
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (i, c) in items.indexed) ...[
            if (i > 0) const Divider(indent: 68),
            ListTile(
              minTileHeight: 64,
              onTap: () => context.push('/tenants/${c.tenantId}/checkout'),
              leading: _Avatar(name: c.tenantName, color: AppColors.info),
              title: Text(c.tenantName, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: c.roomLabel == null ? null : Text(c.roomLabel!),
              trailing: StatusPill(
                label: Dates.relativeDays(c.date),
                color: AppColors.info,
                background: AppColors.infoSoft,
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
    if (items.isEmpty) {
      return const _InlineEmpty(
        icon: Icons.receipt_outlined,
        text: 'Payments and expenses you record will appear here.',
      );
    }
    final t = Theme.of(context).textTheme;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (i, r) in items.indexed) ...[
            if (i > 0) const Divider(indent: 68),
            ListTile(
              minTileHeight: 64,
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: (r.amountPaise >= 0 ? AppColors.success : AppColors.danger).withValues(alpha: 0.10),
                child: Icon(
                  switch (r.type) {
                    TransactionType.rentPayment => Icons.south_west_rounded,
                    TransactionType.reversal => Icons.undo_rounded,
                    TransactionType.expense => Icons.north_east_rounded,
                  },
                  size: 20,
                  color: r.amountPaise >= 0 ? AppColors.success : AppColors.danger,
                ),
              ),
              title: Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                '${r.subtitle} · ${Dates.dayMonth(r.date)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${r.amountPaise >= 0 ? '+' : '−'}${Money.format(r.amountPaise.abs())}',
                    style: t.titleSmall?.copyWith(
                      fontFeatures: AppTheme.tabular,
                      color: r.amountPaise >= 0 ? AppColors.success : AppColors.danger,
                    ),
                  ),
                  if (r.pendingVerification)
                    Text('Unverified', style: t.labelSmall?.copyWith(color: AppColors.warning)),
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
          const Icon(Icons.meeting_room_outlined, color: AppColors.primary, size: 32),
          const SizedBox(height: Gap.md),
          Text('Start by adding your rooms', style: t.titleMedium),
          const SizedBox(height: Gap.xs),
          Text(
            'Add each room with its floor, beds and rent. Occupancy and bed availability are calculated from them.',
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
          SkeletonBox(height: 200, radius: Radii.xl),
          SizedBox(height: Gap.xl),
          SkeletonBox(height: 20, width: 120),
          SizedBox(height: Gap.md),
          SkeletonBox(height: 120, radius: Radii.lg),
          SizedBox(height: Gap.xl),
          Row(
            children: [
              Expanded(child: SkeletonBox(height: 100, radius: Radii.lg)),
              SizedBox(width: Gap.md),
              Expanded(child: SkeletonBox(height: 100, radius: Radii.lg)),
            ],
          ),
        ],
      ),
    );
  }
}
