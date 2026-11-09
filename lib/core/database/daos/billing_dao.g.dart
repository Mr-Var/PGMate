// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_dao.dart';

// ignore_for_file: type=lint
mixin _$BillingDaoMixin on DatabaseAccessor<AppDatabase> {
  $TenantsTable get tenants => attachedDatabase.tenants;
  $RoomsTable get rooms => attachedDatabase.rooms;
  $BedsTable get beds => attachedDatabase.beds;
  $AllocationsTable get allocations => attachedDatabase.allocations;
  $RentInvoicesTable get rentInvoices => attachedDatabase.rentInvoices;
  $PaymentsTable get payments => attachedDatabase.payments;
  $PaymentAllocationsTable get paymentAllocations =>
      attachedDatabase.paymentAllocations;
  $AuditLogsTable get auditLogs => attachedDatabase.auditLogs;
  $PgProfilesTable get pgProfiles => attachedDatabase.pgProfiles;
  BillingDaoManager get managers => BillingDaoManager(this);
}

class BillingDaoManager {
  final _$BillingDaoMixin _db;
  BillingDaoManager(this._db);
  $$TenantsTableTableManager get tenants =>
      $$TenantsTableTableManager(_db.attachedDatabase, _db.tenants);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db.attachedDatabase, _db.rooms);
  $$BedsTableTableManager get beds =>
      $$BedsTableTableManager(_db.attachedDatabase, _db.beds);
  $$AllocationsTableTableManager get allocations =>
      $$AllocationsTableTableManager(_db.attachedDatabase, _db.allocations);
  $$RentInvoicesTableTableManager get rentInvoices =>
      $$RentInvoicesTableTableManager(_db.attachedDatabase, _db.rentInvoices);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db.attachedDatabase, _db.payments);
  $$PaymentAllocationsTableTableManager get paymentAllocations =>
      $$PaymentAllocationsTableTableManager(
        _db.attachedDatabase,
        _db.paymentAllocations,
      );
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db.attachedDatabase, _db.auditLogs);
  $$PgProfilesTableTableManager get pgProfiles =>
      $$PgProfilesTableTableManager(_db.attachedDatabase, _db.pgProfiles);
}
