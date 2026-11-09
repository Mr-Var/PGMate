import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/daos/dashboard_dao.dart';
import '../../core/services/providers.dart';
import '../../core/utils/dates.dart';

class DashboardRange extends Notifier<DateRange> {
  @override
  DateRange build() => DateRange.currentMonth();

  void set(DateRange range) => state = range;
}

final dashboardRangeProvider = NotifierProvider<DashboardRange, DateRange>(DashboardRange.new);

final dashboardSummaryProvider = StreamProvider<DashboardSummary>((ref) {
  final range = ref.watch(dashboardRangeProvider);
  return ref.watch(databaseProvider).dashboardDao.watchSummary(range);
});
