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
}
