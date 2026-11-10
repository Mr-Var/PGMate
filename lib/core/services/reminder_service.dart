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

  /// Opens a screen when a notification is tapped (set by the app).
  void Function(String route)? onOpen;

  /// A screen to open once the owner unlocks the app.
  String? pendingRoute;

  void _open(String? route) {
    if (route == null || route.isEmpty) return;
    if (onOpen != null) {
      onOpen!(route);
    } else {
      pendingRoute = route;
    }
  }

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
        settings: const InitializationSettings(android: AndroidInitializationSettings('@drawable/ic_stat_notify')),
        onDidReceiveNotificationResponse: (r) => _open(r.payload),
      );
      // App started by tapping a notification: open that screen after unlock.
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) pendingRoute = launch!.notificationResponse?.payload;
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
  /// Replaces all scheduled notifications. One notification per due day
  /// ("3 tenants owe ₹25,500 today") that opens the reminders screen, plus a
  /// backup nudge when the last backup is a week old.
  Future<int> reschedule(AppDatabase db, {bool enabled = true, int hour = 9}) async {
    if (!await _init()) return 0;
    await _plugin.cancelAll();
    if (!enabled) return 0;
    final today = Dates.today();
    final rows = await db
        .customSelect(
          '''SELECT i.due_date AS d, COUNT(DISTINCT i.tenant_id) AS n, SUM(i.total_paise - i.paid_paise) AS bal
             FROM rent_invoices i
             WHERE i.status <> 'cancelled' AND i.total_paise > i.paid_paise
               AND i.due_date >= ? AND i.due_date < ?
             GROUP BY i.due_date ORDER BY i.due_date LIMIT 40''',
          variables: [Variable.withDateTime(today), Variable.withDateTime(today.add(const Duration(days: 31)))],
        )
        .get();
    var count = 0;
    final now = tz.TZDateTime.now(tz.local);
    for (final r in rows) {
      final due = DateTime.fromMillisecondsSinceEpoch(r.read<int>('d') * 1000);
      final at = tz.TZDateTime(tz.local, due.year, due.month, due.day, hour);
      if (at.isBefore(now)) continue;
      final n = r.read<int>('n');
      await _plugin.zonedSchedule(
        id: due.year * 10000 + due.month * 100 + due.day,
        title: 'Rent due today',
        body:
            '$n ${n == 1 ? 'tenant owes' : 'tenants owe'} ${Money.format(r.read<int>('bal'))}. Tap to send reminders.',
        scheduledDate: at,
        notificationDetails: const NotificationDetails(android: _channel),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: '/payments/remind',
      );
      count++;
    }
    // Backup nudge seven days after the last backup (or tomorrow if never).
    final last = DateTime.tryParse(await db.settingsDao.getSetting('last_backup_at') ?? '');
    final nudgeDay = last == null ? today.add(const Duration(days: 1)) : Dates.today(last).add(const Duration(days: 7));
    var nudge = tz.TZDateTime(tz.local, nudgeDay.year, nudgeDay.month, nudgeDay.day, 10);
    if (nudge.isBefore(now)) nudge = tz.TZDateTime(tz.local, today.year, today.month, today.day + 1, 10);
    await _plugin.zonedSchedule(
      id: 1,
      title: 'Back up your PG data',
      body: 'Keep a copy in Google Drive so nothing is lost if the phone is. Tap to back up.',
      scheduledDate: nudge,
      notificationDetails: const NotificationDetails(android: _channel),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: '/more/backup',
    );
    return count + 1;
  }
}
