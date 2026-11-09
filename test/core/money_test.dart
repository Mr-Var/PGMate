import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pg_manager/core/utils/money.dart';
import 'package:pg_manager/core/services/export_service.dart';
import 'package:pg_manager/features/payments/reminders_screen.dart';

void main() {
  setUpAll(() => initializeDateFormatting('en_IN'));

  group('Money.parseRupees', () {
    test('parses whole rupees and paise without float rounding', () {
      expect(Money.parseRupees('8500'), 850000);
      expect(Money.parseRupees('12,345.5'), 1234550);
      expect(Money.parseRupees('0.1'), 10);
      expect(Money.parseRupees('0.29'), 29); // 0.29 * 100 is 28.999… in floating point
      expect(Money.parseRupees('₹ 1,00,000'), 10000000);
    });

    test('rejects invalid input', () {
      for (final bad in ['', 'abc', '1.234', '-5', '1e3', '12.']) {
        expect(Money.parseRupees(bad), isNull, reason: bad);
      }
    });
  });

  test('format uses Indian grouping and drops zero paise', () {
    expect(Money.format(1234550), '₹12,345.50');
    expect(Money.format(10000000), '₹1,00,000');
    expect(Money.format(0), '₹0');
  });

  test('compact', () {
    expect(Money.compact(12500000), '₹1.25L');
    expect(Money.compact(250000), '₹2.5K');
    expect(Money.compact(-250000), '−₹2.5K');
  });

  test('toInput round-trips', () {
    for (final p in [0, 5, 100, 850000, 1234550]) {
      expect(Money.parseRupees(Money.toInput(p)), p);
    }
  });

  test('reminder message fills placeholders', () {
    final m = fillReminder(
      defaultReminderTemplate,
      name: 'Arjun Mehta',
      amountPaise: 1445000,
      pg: 'Sunrise PG',
      upi: 'ravi@okaxis',
    );
    expect(m, contains('Hi Arjun,'));
    expect(m, contains('₹14,450'));
    expect(m, contains('Sunrise PG'));
    expect(m, contains('ravi@okaxis'));
    final noUpi = fillReminder(defaultReminderTemplate, name: 'Bala', amountPaise: 100, pg: 'X', upi: null);
    expect(noUpi, isNot(contains('UPI')));
    expect(noUpi, isNot(contains('  ')));
  });

  test('WhatsApp numbers get the India code once', () {
    expect(ExportService.waNumber('98765 43210'), '919876543210');
    expect(ExportService.waNumber('+91 98765-43210'), '919876543210');
  });
}
