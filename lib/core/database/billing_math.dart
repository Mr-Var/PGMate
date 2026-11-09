/// Pure billing calculations. Everything is integer paise.
abstract final class BillingMath {
  static int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  /// Rent for [days] out of a [daysInMonth]-day month, rounded to the nearest paisa.
  static int prorate(int monthlyRentPaise, int days, int daysInMonth) {
    if (days <= 0) return 0;
    if (days >= daysInMonth) return monthlyRentPaise;
    return (monthlyRentPaise * days + daysInMonth ~/ 2) ~/ daysInMonth;
  }

  /// Rent for the joining month: from the joining day to month end, inclusive.
  static int joiningMonthRent(int monthlyRentPaise, DateTime joining) {
    final dim = daysInMonth(joining.year, joining.month);
    return prorate(monthlyRentPaise, dim - joining.day + 1, dim);
  }

  /// Days occupied in the month of [checkout], counting the checkout day,
  /// starting from the 1st or the joining date if the tenant joined that month.
  static int daysStayedInCheckoutMonth(DateTime joining, DateTime checkout) {
    final sameMonth = joining.year == checkout.year && joining.month == checkout.month;
    final start = sameMonth ? joining.day : 1;
    return checkout.day - start + 1;
  }

  /// Due date for an invoice: the tenant's due day, but never before joining.
  static DateTime dueDate(int year, int month, int dueDay, DateTime joining) {
    final due = DateTime(year, month, dueDay.clamp(1, daysInMonth(year, month)));
    final joinDay = DateTime(joining.year, joining.month, joining.day);
    return due.isBefore(joinDay) ? joinDay : due;
  }

  /// Rent for one calendar month when rent started on [start]: full rent for
  /// months after the start month, prorated in the start month, zero before.
  static int rentForMonth(int monthlyRentPaise, DateTime start, int year, int month) {
    final first = DateTime(year, month);
    final next = DateTime(year, month + 1);
    final s = DateTime(start.year, start.month, start.day);
    if (!s.isBefore(next)) return 0;
    if (s.isBefore(first)) return monthlyRentPaise;
    return joiningMonthRent(monthlyRentPaise, s);
  }

  /// Every month (first day) from [start]'s month up to and including [upTo]'s month.
  static List<DateTime> monthsBetween(DateTime start, DateTime upTo) {
    final out = <DateTime>[];
    var m = DateTime(start.year, start.month);
    final last = DateTime(upTo.year, upTo.month);
    while (!m.isAfter(last)) {
      out.add(m);
      m = DateTime(m.year, m.month + 1);
    }
    return out;
  }
}
