import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';

/// Bottom sheet to pick a month (last 12) or a custom date range.
Future<DateRange?> showPeriodPicker(BuildContext context, DateRange current) {
  return showModalBottomSheet<DateRange>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      final now = DateTime.now();
      final months = List.generate(12, (i) => DateRange.month(now.year, now.month - i));
      final t = Theme.of(ctx).textTheme;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.75),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.md),
                child: Text('Select period', style: t.titleLarge),
              ),
              ListTile(
                leading: const Icon(Icons.date_range_rounded, color: AppColors.primary),
                title: const Text('Custom date range'),
                subtitle: current.isSingleMonth ? null : Text(current.label),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: ctx,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(now.year + 1, 12, 31),
                    initialDateRange: DateTimeRange(start: current.start, end: current.lastDay),
                  );
                  if (picked != null && ctx.mounted) {
                    Navigator.pop(
                      ctx,
                      DateRange(Dates.today(picked.start), Dates.today(picked.end).add(const Duration(days: 1))),
                    );
                  }
                },
              ),
              const Divider(),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final m in months)
                      ListTile(
                        title: Text(m.label),
                        trailing: m == current ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                        selected: m == current,
                        onTap: () => Navigator.pop(ctx, m),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
