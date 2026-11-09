import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/state_views.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const operations = [
      (Icons.shopping_bag_outlined, 'Expenses', 'Bills, salaries and utilities', '/more/expenses'),
      (Icons.report_problem_outlined, 'Complaints', 'Maintenance requests', '/more/complaints'),
      (Icons.restaurant_menu_rounded, 'Food menu', 'Daily breakfast, lunch, dinner', '/more/menu'),
      (Icons.campaign_outlined, 'Notices', 'Announcements for tenants', '/more/notices'),
    ];
    const admin = [
      (Icons.insert_chart_outlined_rounded, 'Reports', 'Collections, dues, occupancy', '/more/reports'),
      (Icons.cloud_sync_outlined, 'Backup & restore', 'Encrypted local backup', '/more/backup'),
      (Icons.settings_outlined, 'Settings', 'PG profile, PIN, biometrics', '/more/settings'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
        children: [
          const SectionHeader(title: 'Daily operations'),
          _Group(items: operations),
          const SectionHeader(title: 'Administration'),
          _Group(items: admin),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.items});
  final List<(IconData, String, String, String?)> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (i, item) in items.indexed) ...[
            if (i > 0) const Divider(indent: 72),
            ListTile(
              minTileHeight: 64,
              enabled: item.$4 != null,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: item.$4 != null ? 0.08 : 0.04),
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: Icon(item.$1, color: item.$4 != null ? AppColors.primary : AppColors.textMuted),
              ),
              title: Text(item.$2),
              subtitle: Text(item.$3),
              trailing: item.$4 != null
                  ? const Icon(Icons.chevron_right_rounded)
                  : const StatusPill(label: 'Coming soon', color: AppColors.textSecondary, background: AppColors.neutralSoft),
              onTap: item.$4 == null ? null : () => context.push(item.$4!),
            ),
          ],
        ],
      ),
    );
  }
}
