import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/daos/tenants_dao.dart';
import '../../core/database/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/form_kit.dart';
import '../../shared/widgets/state_views.dart';
import 'tenants_providers.dart';

class TenantsScreen extends ConsumerStatefulWidget {
  const TenantsScreen({super.key});

  @override
  ConsumerState<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends ConsumerState<TenantsScreen> {
  late final _search = TextEditingController(text: ref.read(tenantQueryProvider).search);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = ref.watch(tenantQueryProvider);
    final list = ref.watch(tenantListProvider);
    final notifier = ref.read(tenantQueryProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenants'),
        actions: [
          PopupMenuButton<TenantSort>(
            tooltip: 'Sort',
            icon: const Icon(Icons.sort_rounded),
            initialValue: q.sort,
            onSelected: (s) => notifier.update(q.copyWith(sort: s)),
            itemBuilder: (_) => const [
              PopupMenuItem(value: TenantSort.joiningNewest, child: Text('Newest joined first')),
              PopupMenuItem(value: TenantSort.joiningOldest, child: Text('Oldest joined first')),
              PopupMenuItem(value: TenantSort.name, child: Text('Name A–Z')),
              PopupMenuItem(value: TenantSort.dues, child: Text('Highest dues first')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.push('/tenants/new'),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add tenant'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.sm),
            child: TextField(
              controller: _search,
              onChanged: (v) => notifier.update(q.copyWith(search: v)),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search name or phone',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: q.search.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _search.clear();
                          notifier.update(q.copyWith(search: ''));
                        },
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
              children: [
                for (final f in const [
                  (TenantFilter.current, 'Current'),
                  (TenantFilter.active, 'Active'),
                  (TenantFilter.notice, 'Notice given'),
                  (TenantFilter.checkedOut, 'Checked out'),
                  (TenantFilter.all, 'All'),
                ]) ...[
                  ChoiceChip(
                    label: Text(f.$2),
                    selected: q.filter == f.$1,
                    showCheckmark: false,
                    onSelected: (_) => notifier.update(q.copyWith(filter: f.$1)),
                  ),
                  const SizedBox(width: Gap.sm),
                ],
              ],
            ),
          ),
          Expanded(
            child: list.when(
              skipLoadingOnReload: true,
              loading: () => const LoadingList(),
              error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(tenantListProvider)),
              data: (items) {
                if (items.isEmpty) {
                  final searching = q.search.trim().isNotEmpty;
                  return EmptyState(
                    icon: searching ? Icons.search_off_rounded : Icons.people_outline_rounded,
                    title: searching ? 'No matches' : 'No tenants here',
                    message: searching
                        ? 'No tenant matches “${q.search.trim()}”. Check the spelling or the filter.'
                        : q.filter == TenantFilter.current
                        ? 'Register your first tenant to assign a bed, bill rent and record payments.'
                        : 'Nobody matches this filter yet.',
                    actionLabel: searching || q.filter != TenantFilter.current ? null : 'Add tenant',
                    onAction: () => context.push('/tenants/new'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, 96),
                  itemCount: items.length + 1,
                  separatorBuilder: (_, i) => SizedBox(height: i == 0 ? Gap.md : Gap.sm),
                  itemBuilder: (context, i) {
                    if (i == 0) return _Summary(items: items);
                    return TenantTile(item: items[i - 1]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.items});
  final List<TenantListItem> items;

  @override
  Widget build(BuildContext context) {
    final dues = items.fold<int>(0, (a, i) => a + (i.duesPaise > 0 ? i.duesPaise : 0));
    final overdue = items.where((i) => i.overdue).length;
    final t = Theme.of(context).textTheme;
    return Text(
      '${items.length} ${items.length == 1 ? 'tenant' : 'tenants'}'
      '${dues > 0 ? ' · ${Money.format(dues)} due' : ''}'
      '${overdue > 0 ? ' · $overdue overdue' : ''}',
      style: t.bodySmall?.copyWith(color: AppColors.textMuted),
    );
  }
}

class TenantTile extends StatelessWidget {
  const TenantTile({super.key, required this.item});
  final TenantListItem item;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final tenant = item.tenant;
    final (color, bg) = statusColors(tenant.status);
    return AppCard(
      onTap: () => context.push('/tenants/${tenant.id}'),
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
      child: Row(
        children: [
          PersonAvatar(name: tenant.fullName, photoPath: tenant.photoPath),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tenant.fullName, style: t.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  [item.roomLabel ?? 'No bed assigned', tenant.phone].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: Gap.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (item.duesPaise > 0)
                Text(
                  Money.format(item.duesPaise),
                  style: t.titleSmall?.copyWith(
                    fontFeatures: AppTheme.tabular,
                    color: item.overdue ? AppColors.danger : AppColors.textPrimary,
                  ),
                )
              else
                Text('Paid up', style: t.labelMedium?.copyWith(color: AppColors.success)),
              const SizedBox(height: 4),
              StatusPill(
                label: item.overdue ? 'Overdue' : tenant.status.label,
                color: item.overdue ? AppColors.danger : color,
                background: item.overdue ? AppColors.dangerSoft : bg,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

(Color, Color) statusColors(TenantStatus s) => switch (s) {
  TenantStatus.active => (AppColors.success, AppColors.successSoft),
  TenantStatus.noticeGiven => (AppColors.warning, AppColors.warningSoft),
  TenantStatus.newTenant => (AppColors.info, AppColors.infoSoft),
  _ => (AppColors.textSecondary, AppColors.neutralSoft),
};
