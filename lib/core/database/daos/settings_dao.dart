import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/operations_tables.dart';
import '../tables/property_tables.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [PgProfiles, AppSettings, AuditLogs])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Stream<PgProfile?> watchProfile() => (select(pgProfiles)..where((p) => p.id.equals(1))).watchSingleOrNull();

  Future<PgProfile?> getProfile() => (select(pgProfiles)..where((p) => p.id.equals(1))).getSingleOrNull();

  Future<void> saveProfile({
    required String name,
    required String address,
    required String ownerName,
    required String ownerPhone,
    String? upiId,
    int? defaultRentDueDay,
  }) {
    return transaction(() async {
      final existing = await getProfile();
      await into(pgProfiles).insertOnConflictUpdate(
        PgProfilesCompanion(
          id: const Value(1),
          name: Value(name),
          address: Value(address),
          ownerName: Value(ownerName),
          ownerPhone: Value(ownerPhone),
          upiId: Value(upiId),
          defaultRentDueDay: defaultRentDueDay == null ? const Value.absent() : Value(defaultRentDueDay),
          createdAt: existing == null ? Value(DateTime.now()) : Value(existing.createdAt),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await log('pg_profile', 1, existing == null ? 'create' : 'update');
    });
  }

  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watchSetting(String key) =>
      (select(appSettings)..where((s) => s.key.equals(key))).watchSingleOrNull().map((r) => r?.value);

  Future<void> setSetting(String key, String value) => into(appSettings)
      .insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value, updatedAt: Value(DateTime.now())));

  /// Next value of a named, gap-free counter (e.g. receipt numbers per year).
  /// Must be called inside the caller's transaction.
  Future<int> nextSequence(String name) async {
    final key = 'seq_$name';
    final current = int.tryParse(await getSetting(key) ?? '') ?? 0;
    final next = current + 1;
    await setSetting(key, '$next');
    return next;
  }

  Future<void> log(String entity, int? entityId, String action, [String? details]) => into(auditLogs).insert(
    AuditLogsCompanion.insert(entity: entity, entityId: Value(entityId), action: action, details: Value(details)),
  );
}
