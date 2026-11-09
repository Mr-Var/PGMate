import '../../core/utils/money.dart';

/// Form validators with specific, human messages.
abstract final class Validators {
  static String? required(String? v, String field, {int min = 1, int max = 500}) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return '$field is required';
    if (s.length < min) return '$field must be at least $min characters';
    if (s.length > max) return '$field must be under $max characters';
    return null;
  }

  static String? indianPhone(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(s)) return 'Enter a valid 10-digit mobile number';
    return null;
  }

  static String? optionalUpi(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null;
    if (!RegExp(r'^[\w.\-]{2,256}@[a-zA-Z][a-zA-Z0-9]{1,64}$').hasMatch(s)) {
      return 'Enter a valid UPI ID, e.g. name@okaxis';
    }
    return null;
  }

  static String? amount(String? v, {bool allowZero = false, String field = 'Amount'}) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return '$field is required';
    final paise = Money.parseRupees(s);
    if (paise == null) return 'Enter a valid amount (max 2 decimals)';
    if (!allowZero && paise == 0) return '$field must be more than ₹0';
    return null;
  }
}
