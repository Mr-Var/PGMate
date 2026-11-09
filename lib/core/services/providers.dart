import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'auth_service.dart';
import 'backup_service.dart';
import 'export_service.dart';
import 'file_store.dart';
import 'reminder_service.dart';

/// Overridden in tests. Invalidated after a restore to reopen the new data.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  // A restore closes the database itself before swapping files.
  ref.onDispose(() => unawaited(db.close().catchError((Object _) {})));
  return db;
});

final secureStoreProvider = Provider<SecureStore>((ref) => const PlatformSecureStore());

final authServiceProvider = Provider<AuthService>((ref) => AuthService(store: ref.watch(secureStoreProvider)));

final fileStoreProvider = Provider<FileStore>((ref) => FileStore());

final exportServiceProvider = Provider<ExportService>((ref) => ExportService());

final backupServiceProvider = Provider<BackupService>((ref) => BackupService(files: ref.watch(fileStoreProvider)));

final reminderServiceProvider = Provider<ReminderService>((ref) => ReminderService());

final pgProfileProvider = StreamProvider<PgProfile?>((ref) => ref.watch(databaseProvider).settingsDao.watchProfile());

/// Whether rent reminders are on (stored in app settings, default on).
final remindersEnabledProvider = StreamProvider<bool>(
  (ref) => ref.watch(databaseProvider).settingsDao.watchSetting('reminders_enabled').map((v) => v != 'false'),
);

/// Re-schedules local reminders from current invoices. Safe to call often.
Future<void> refreshReminders(AppDatabase db, ReminderService reminders) async {
  final enabled = (await db.settingsDao.getSetting('reminders_enabled')) != 'false';
  await reminders.reschedule(db, enabled: enabled);
}
