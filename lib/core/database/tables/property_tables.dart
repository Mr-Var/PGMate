// Drift CHECK constraints reference their own column getter by design.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../enums.dart';

/// Single-row table holding the PG's own details (id is always 1).
@DataClassName('PgProfile')
class PgProfiles extends Table {
  @override
  String get tableName => 'pg_profile';

  IntColumn get id => integer().check(id.equals(1))();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get address => text().withLength(max: 500)();
  TextColumn get ownerName => text().withLength(min: 1, max: 120)();
  TextColumn get ownerPhone => text().withLength(min: 10, max: 15)();
  TextColumn get upiId => text().nullable()();
  IntColumn get defaultRentDueDay =>
      integer().withDefault(const Constant(5)).check(defaultRentDueDay.isBetweenValues(1, 28))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Room')
@TableIndex(name: 'idx_rooms_floor', columns: {#floor})
class Rooms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get roomNumber => text().withLength(min: 1, max: 20).unique()();
  IntColumn get floor => integer()();
  /// Default monthly rent per bed in this room, in paise.
  IntColumn get rentPaise => integer().check(rentPaise.isBiggerOrEqualValue(0))();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Bed')
@TableIndex(name: 'idx_beds_room', columns: {#roomId})
class Beds extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get roomId => integer().references(Rooms, #id, onDelete: KeyAction.restrict)();
  TextColumn get label => text().withLength(min: 1, max: 10)();
  TextColumn get status => textEnum<BedStatus>().withDefault(Constant(BedStatus.available.name))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {roomId, label},
      ];
}

@DataClassName('Tenant')
@TableIndex(name: 'idx_tenants_phone', columns: {#phone})
@TableIndex(name: 'idx_tenants_name', columns: {#fullName})
@TableIndex(name: 'idx_tenants_status', columns: {#status})
class Tenants extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fullName => text().withLength(min: 2, max: 120)();
  TextColumn get phone => text().withLength(min: 10, max: 15)();
  TextColumn get email => text().nullable()();
  TextColumn get gender => textEnum<Gender>()();
  /// Path relative to the app's private documents directory.
  TextColumn get photoPath => text().nullable()();
  TextColumn get idProofType => text().nullable()();
  TextColumn get idProofPath => text().nullable()();
  TextColumn get emergencyContactName => text().nullable()();
  TextColumn get emergencyContactPhone => text().nullable()();
  TextColumn get occupation => text().nullable()();
  DateTimeColumn get joiningDate => dateTime()();
  IntColumn get monthlyRentPaise => integer().check(monthlyRentPaise.isBiggerOrEqualValue(0))();
  IntColumn get securityDepositPaise =>
      integer().withDefault(const Constant(0)).check(securityDepositPaise.isBiggerOrEqualValue(0))();
  IntColumn get advancePaise =>
      integer().withDefault(const Constant(0)).check(advancePaise.isBiggerOrEqualValue(0))();
  IntColumn get rentDueDay => integer().check(rentDueDay.isBetweenValues(1, 28))();
  TextColumn get status => textEnum<TenantStatus>().withDefault(Constant(TenantStatus.newTenant.name))();
  DateTimeColumn get noticeDate => dateTime().nullable()();
  DateTimeColumn get expectedCheckoutDate => dateTime().nullable()();
  DateTimeColumn get checkoutDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Bed allocation history. A row with `isActive = true` means the tenant
/// currently occupies the bed. Partial unique indexes (created in the
/// migration) guarantee at most one active allocation per bed and per tenant.
@DataClassName('Allocation')
@TableIndex(name: 'idx_allocations_tenant', columns: {#tenantId})
@TableIndex(name: 'idx_allocations_bed', columns: {#bedId})
class Allocations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tenantId => integer().references(Tenants, #id, onDelete: KeyAction.restrict)();
  IntColumn get bedId => integer().references(Beds, #id, onDelete: KeyAction.restrict)();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get rentPaise => integer().check(rentPaise.isBiggerOrEqualValue(0))();
  TextColumn get endReason => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
