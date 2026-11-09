// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_dao.dart';

// ignore_for_file: type=lint
mixin _$DashboardDaoMixin on DatabaseAccessor<AppDatabase> {
  $RoomsTable get rooms => attachedDatabase.rooms;
  $BedsTable get beds => attachedDatabase.beds;
  $TenantsTable get tenants => attachedDatabase.tenants;
  $AllocationsTable get allocations => attachedDatabase.allocations;
  $RentInvoicesTable get rentInvoices => attachedDatabase.rentInvoices;
  $PaymentsTable get payments => attachedDatabase.payments;
  $ExpensesTable get expenses => attachedDatabase.expenses;
  DashboardDaoManager get managers => DashboardDaoManager(this);
}

class DashboardDaoManager {
  final _$DashboardDaoMixin _db;
  DashboardDaoManager(this._db);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db.attachedDatabase, _db.rooms);
  $$BedsTableTableManager get beds =>
      $$BedsTableTableManager(_db.attachedDatabase, _db.beds);
  $$TenantsTableTableManager get tenants =>
      $$TenantsTableTableManager(_db.attachedDatabase, _db.tenants);
  $$AllocationsTableTableManager get allocations =>
      $$AllocationsTableTableManager(_db.attachedDatabase, _db.allocations);
  $$RentInvoicesTableTableManager get rentInvoices =>
      $$RentInvoicesTableTableManager(_db.attachedDatabase, _db.rentInvoices);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db.attachedDatabase, _db.payments);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db.attachedDatabase, _db.expenses);
}
