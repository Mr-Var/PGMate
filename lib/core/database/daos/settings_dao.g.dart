// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_dao.dart';

// ignore_for_file: type=lint
mixin _$SettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PgProfilesTable get pgProfiles => attachedDatabase.pgProfiles;
  $AppSettingsTable get appSettings => attachedDatabase.appSettings;
  $AuditLogsTable get auditLogs => attachedDatabase.auditLogs;
  SettingsDaoManager get managers => SettingsDaoManager(this);
}

class SettingsDaoManager {
  final _$SettingsDaoMixin _db;
  SettingsDaoManager(this._db);
  $$PgProfilesTableTableManager get pgProfiles =>
      $$PgProfilesTableTableManager(_db.attachedDatabase, _db.pgProfiles);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db.attachedDatabase, _db.appSettings);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db.attachedDatabase, _db.auditLogs);
}
