import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/enums.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/state_views.dart';

final _tenantSearchProvider = NotifierProvider<_Search, String>(_Search.new);

class _Search extends Notifier<String> {
  @override
  String build() => '';
  void set(String v) => state = v;
}

final tenantsListProvider = StreamProvider<List<Tenant>>((ref) {
  final db = ref.watch(databaseProvider);
  final q = ref.watch(_tenantSearchProvider).trim();
  final query = db.select(db.tenants)..orderBy([(t) => OrderingTerm.desc(t.joiningDate)]);
  if (q.isNotEmpty) {
    query.where((t) => t.fullName.like('%$q%') | t.phone.like('%$q%'));
  }
  return query.watch();
});

/// Tenant directory backed by the database. Registration, profiles and
/// checkout are delivered in Phase 2.
class TenantsScreen extends ConsumerWidget {
  const TenantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenants = ref.watch(tenantsListProvider);
    final query = ref.watch(_tenantSearchProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tenants')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.md),
            child: TextField(
              onChanged: ref.read(_tenantSearchProvider.notifier).set,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search by name or phone',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: tenants.when(
              loading: () => const LoadingList(),
              error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(tenantsListProvider)),
              data: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    icon: query.isEmpty ? Icons.people_outline_rounded : Icons.search_off_rounded,
                    title: query.isEmpty ? 'No tenants yet' : 'No matches',
                    message: query.isEmpty
                        ? 'Tenant registration, bed allocation and checkout are being added in the next update.'
                        : 'No tenant matches “$query”.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: Gap.sm),
                  itemBuilder: (_, i) => _TenantTile(tenant: list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TenantTile extends StatelessWidget {
  const _TenantTile({required this.tenant});
  final Tenant tenant;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final (color, bg) = switch (tenant.status) {
      TenantStatus.active => (AppColors.success, AppColors.successSoft),
      TenantStatus.noticeGiven => (AppColors.warning, AppColors.warningSoft),
      TenantStatus.newTenant => (AppColors.info, AppColors.infoSoft),
      _ => (AppColors.textSecondary, AppColors.neutralSoft),
    };
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(tenant.fullName[0].toUpperCase(),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tenant.fullName, style: t.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${tenant.phone} · Joined ${Dates.short(tenant.joiningDate)}',
                    style: t.bodySmall?.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusPill(label: tenant.status.label, color: color, background: bg),
              const SizedBox(height: 4),
              Text('${Money.format(tenant.monthlyRentPaise)}/mo',
                  style: t.bodySmall?.copyWith(fontFeatures: AppTheme.tabular)),
            ],
          ),
        ],
      ),
    );
  }
}
