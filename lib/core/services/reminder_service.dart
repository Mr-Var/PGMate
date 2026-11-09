import 'package:drift/drift.dart' show Variable;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../database/app_database.dart';
import '../utils/dates.dart';
import '../utils/money.dart';

/// Local rent-due reminders. No server, no internet: notifications are
/// scheduled on the phone for each unpaid invoice due in the next 30 days.
class ReminderService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channel = AndroidNotificationDetails(
    'rent_due',
    'Rent reminders',
    channelDescription: 'Reminders when a tenant\'s rent is due',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  Future<bool> _init() async {
    if (_ready) return true;
    try {
      tzdata.initializeTimeZones();
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
      await _plugin.initialize(
        settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      );
      _ready = true;
    } catch (e) {
      debugPrint('Reminders unavailable: $e');
    }
    return _ready;
  }

  Future<bool> requestPermission() async {
    if (!await _init()) return false;
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  /// Replaces all scheduled reminders. Call after billing changes.
  Future<int> reschedule(AppDatabase db, {bool enabled = true, int hour = 9}) async {
    if (!await _init()) return 0;
    await _plugin.cancelAll();
    if (!enabled) return 0;
    final today = Dates.today();
    final rows = await db.customSelect(
      '''SELECT i.id, i.due_date, i.total_paise - i.paid_paise AS bal, t.full_name
         FROM rent_invoices i JOIN tenants t ON t.id = i.tenant_id
         WHERE i.status <> 'cancelled' AND i.total_paise > i.paid_paise
           AND i.due_date >= ? AND i.due_date < ?
         ORDER BY i.due_date LIMIT 60''',
      variables: [Variable.withDateTime(today), Variable.withDateTime(today.add(const Duration(days: 31)))],
    ).get();
    var n = 0;
    for (final r in rows) {
      final due = DateTime.fromMillisecondsSinceEpoch(r.read<int>('due_date') * 1000);
      final at = tz.TZDateTime(tz.local, due.year, due.month, due.day, hour);
      if (at.isBefore(tz.TZDateTime.now(tz.local))) continue;
      await _plugin.zonedSchedule(
        id: r.read<int>('id'),
        title: 'Rent due today',
        body: '${r.read<String>('full_name')} · ${Money.format(r.read<int>('bal'))}',
        scheduledDate: at,
        notificationDetails: const NotificationDetails(android: _channel),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      n++;
    }
    return n;
  }
}
