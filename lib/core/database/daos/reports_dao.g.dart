// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_dao.dart';

// ignore_for_file: type=lint
mixin _$ReportsDaoMixin on DatabaseAccessor<AppDatabase> {
  $TenantsTable get tenants => attachedDatabase.tenants;
  $RoomsTable get rooms => attachedDatabase.rooms;
  $BedsTable get beds => attachedDatabase.beds;
  $AllocationsTable get allocations => attachedDatabase.allocations;
  $RentInvoicesTable get rentInvoices => attachedDatabase.rentInvoices;
  $PaymentsTable get payments => attachedDatabase.payments;
  $ExpensesTable get expenses => attachedDatabase.expenses;
  ReportsDaoManager get managers => ReportsDaoManager(this);
}

class ReportsDaoManager {
  final _$ReportsDaoMixin _db;
  ReportsDaoManager(this._db);
  $$TenantsTableTableManager get tenants => $$TenantsTableTableManager(_db.attachedDatabase, _db.tenants);
  $$RoomsTableTableManager get rooms => $$RoomsTableTableManager(_db.attachedDatabase, _db.rooms);
  $$BedsTableTableManager get beds => $$BedsTableTableManager(_db.attachedDatabase, _db.beds);
  $$AllocationsTableTableManager get allocations =>
      $$AllocationsTableTableManager(_db.attachedDatabase, _db.allocations);
  $$RentInvoicesTableTableManager get rentInvoices =>
      $$RentInvoicesTableTableManager(_db.attachedDatabase, _db.rentInvoices);
  $$PaymentsTableTableManager get payments => $$PaymentsTableTableManager(_db.attachedDatabase, _db.payments);
  $$ExpensesTableTableManager get expenses => $$ExpensesTableTableManager(_db.attachedDatabase, _db.expenses);
}
