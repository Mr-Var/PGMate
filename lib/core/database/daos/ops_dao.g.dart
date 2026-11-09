// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_dao.dart';

// ignore_for_file: type=lint
mixin _$OpsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ExpensesTable get expenses => attachedDatabase.expenses;
  $TenantsTable get tenants => attachedDatabase.tenants;
  $RoomsTable get rooms => attachedDatabase.rooms;
  $ComplaintsTable get complaints => attachedDatabase.complaints;
  $NoticesTable get notices => attachedDatabase.notices;
  $MenusTable get menus => attachedDatabase.menus;
  $AuditLogsTable get auditLogs => attachedDatabase.auditLogs;
  OpsDaoManager get managers => OpsDaoManager(this);
}

class OpsDaoManager {
  final _$OpsDaoMixin _db;
  OpsDaoManager(this._db);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db.attachedDatabase, _db.expenses);
  $$TenantsTableTableManager get tenants =>
      $$TenantsTableTableManager(_db.attachedDatabase, _db.tenants);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db.attachedDatabase, _db.rooms);
  $$ComplaintsTableTableManager get complaints =>
      $$ComplaintsTableTableManager(_db.attachedDatabase, _db.complaints);
  $$NoticesTableTableManager get notices =>
      $$NoticesTableTableManager(_db.attachedDatabase, _db.notices);
  $$MenusTableTableManager get menus =>
      $$MenusTableTableManager(_db.attachedDatabase, _db.menus);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db.attachedDatabase, _db.auditLogs);
}
