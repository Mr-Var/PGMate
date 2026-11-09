import 'package:intl/intl.dart';

/// All money in the app is stored and computed as integer paise.
/// Floating point is used only for display formatting, never for storage.
abstract final class Money {
  static final _full = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  static final _whole = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  /// Formats paise as rupees, e.g. 1234550 → "₹12,345.50".
  /// Whole-rupee values drop the ".00" suffix for readability.
  static String format(int paise) {
    if (paise % 100 == 0) return _whole.format(paise ~/ 100);
    return _full.format(paise / 100);
  }

  /// Compact form for dashboard tiles, e.g. 12500000 → "₹1.25L".
  static String compact(int paise) {
    final negative = paise < 0;
    final rupees = paise.abs() / 100;
    String body;
    if (rupees >= 10000000) {
      body = '${_trim(rupees / 10000000)}Cr';
    } else if (rupees >= 100000) {
      body = '${_trim(rupees / 100000)}L';
    } else if (rupees >= 1000) {
      body = '${_trim(rupees / 1000)}K';
    } else {
      body = rupees.toStringAsFixed(0);
    }
    return '${negative ? '−' : ''}₹$body';
  }

  static String _trim(double v) {
    final s = v.toStringAsFixed(2);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  /// Parses user input in rupees ("12,345.5") into paise without
  /// floating-point rounding. Returns null for invalid input.
  static int? parseRupees(String input) {
    final cleaned = input.replaceAll(',', '').replaceAll('₹', '').trim();
    final match = RegExp(r'^(\d{1,9})(?:\.(\d{1,2}))?$').firstMatch(cleaned);
    if (match == null) return null;
    final rupees = int.parse(match.group(1)!);
    final fraction = (match.group(2) ?? '').padRight(2, '0');
    return rupees * 100 + int.parse(fraction);
  }

  /// Converts paise back into an editable rupee string.
  static String toInput(int paise) {
    final r = paise ~/ 100;
    final p = paise % 100;
    return p == 0 ? '$r' : '$r.${p.toString().padLeft(2, '0')}';
  }
}
