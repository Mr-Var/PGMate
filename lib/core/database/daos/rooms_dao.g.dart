// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rooms_dao.dart';

// ignore_for_file: type=lint
mixin _$RoomsDaoMixin on DatabaseAccessor<AppDatabase> {
  $RoomsTable get rooms => attachedDatabase.rooms;
  $BedsTable get beds => attachedDatabase.beds;
  $TenantsTable get tenants => attachedDatabase.tenants;
  $AllocationsTable get allocations => attachedDatabase.allocations;
  $AuditLogsTable get auditLogs => attachedDatabase.auditLogs;
  RoomsDaoManager get managers => RoomsDaoManager(this);
}

class RoomsDaoManager {
  final _$RoomsDaoMixin _db;
  RoomsDaoManager(this._db);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db.attachedDatabase, _db.rooms);
  $$BedsTableTableManager get beds =>
      $$BedsTableTableManager(_db.attachedDatabase, _db.beds);
  $$TenantsTableTableManager get tenants =>
      $$TenantsTableTableManager(_db.attachedDatabase, _db.tenants);
  $$AllocationsTableTableManager get allocations =>
      $$AllocationsTableTableManager(_db.attachedDatabase, _db.allocations);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db.attachedDatabase, _db.auditLogs);
}
