import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/daos/ops_dao.dart';
import '../../core/database/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dates.dart';
import '../../shared/widgets/state_views.dart';

const complaintCategories = [
  'Plumbing',
  'Electrical',
  'Furniture',
  'Cleaning',
  'Wi-Fi',
  'Food',
  'Appliance',
  'Pest control',
  'Noise',
  'Other',
];

(Color, Color) complaintStatusColors(ComplaintStatus s) => switch (s) {
  ComplaintStatus.open => (AppColors.danger, AppColors.dangerSoft),
  ComplaintStatus.inProgress => (AppColors.warning, AppColors.warningSoft),
  ComplaintStatus.resolved => (AppColors.success, AppColors.successSoft),
  ComplaintStatus.closed => (AppColors.textSecondary, AppColors.neutralSoft),
};

Color priorityColor(ComplaintPriority p) => switch (p) {
  ComplaintPriority.urgent => AppColors.danger,
  ComplaintPriority.high => AppColors.warning,
  ComplaintPriority.medium => AppColors.info,
  ComplaintPriority.low => AppColors.textMuted,
};

IconData complaintIcon(String category) => switch (category) {
  'Plumbing' => Icons.plumbing_rounded,
  'Electrical' => Icons.electrical_services_rounded,
  'Furniture' => Icons.chair_outlined,
  'Cleaning' => Icons.cleaning_services_outlined,
  'Wi-Fi' => Icons.wifi_rounded,
  'Food' => Icons.restaurant_outlined,
  'Appliance' => Icons.kitchen_outlined,
  'Pest control' => Icons.pest_control_outlined,
  'Noise' => Icons.volume_up_outlined,
  _ => Icons.report_problem_outlined,
};

class ComplaintTile extends StatelessWidget {
  const ComplaintTile({super.key, required this.view, this.showTenant = true});
  final ComplaintView view;
  final bool showTenant;

  @override
  Widget build(BuildContext context) {
    final c = view.complaint;
    final (color, bg) = complaintStatusColors(c.status);
    final t = Theme.of(context).textTheme;
    return ListTile(
      minTileHeight: 72,
      onTap: () => context.push('/more/complaints/${c.id}'),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: priorityColor(c.priority).withValues(alpha: 0.12),
        child: Icon(complaintIcon(c.category), size: 20, color: priorityColor(c.priority)),
      ),
      title: Text(c.description, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          c.category,
          if (showTenant && view.tenantName != null) view.tenantName!,
          if (view.roomNumber != null) 'Room ${view.roomNumber}',
          Dates.relativeDays(c.createdAt),
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: t.bodySmall?.copyWith(color: AppColors.textMuted),
      ),
      trailing: StatusPill(label: c.status.label, color: color, background: bg),
    );
  }
}
