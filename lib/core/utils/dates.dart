import 'package:intl/intl.dart';

/// A half-open date range [start, end) at day granularity.
class DateRange {
  const DateRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  factory DateRange.month(int year, int month) => DateRange(DateTime(year, month), DateTime(year, month + 1));

  factory DateRange.currentMonth([DateTime? now]) {
    final n = now ?? DateTime.now();
    return DateRange.month(n.year, n.month);
  }

  /// Inclusive end date for display purposes.
  DateTime get lastDay => end.subtract(const Duration(days: 1));

  bool get isSingleMonth => start.day == 1 && end == DateTime(start.year, start.month + 1);

  String get label {
    if (isSingleMonth) return DateFormat('MMMM yyyy').format(start);
    return '${Dates.short(start)} – ${Dates.short(lastDay)}';
  }

  @override
  bool operator ==(Object other) => other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

abstract final class Dates {
  static DateTime today([DateTime? now]) {
    final n = now ?? DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static String short(DateTime d) => DateFormat('d MMM yyyy').format(d);
  static String dayMonth(DateTime d) => DateFormat('d MMM').format(d);
  static String monthYear(DateTime d) => DateFormat('MMM yyyy').format(d);

  static String relativeDays(DateTime date, [DateTime? now]) {
    final diff = DateTime(date.year, date.month, date.day).difference(today(now)).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff > 0) return 'In $diff days';
    return '${-diff} days ago';
  }

  static String floorLabel(int floor) {
    switch (floor) {
      case 0:
        return 'Ground Floor';
      case 1:
        return 'First Floor';
      case 2:
        return 'Second Floor';
      case 3:
        return 'Third Floor';
      default:
        if (floor < 0) return 'Basement ${-floor}';
        return 'Floor $floor';
    }
  }
}
