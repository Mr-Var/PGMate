// Drift CHECK constraints reference their own column getter by design.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../enums.dart';
import 'finance_tables.dart';
import 'property_tables.dart';

@DataClassName('Complaint')
@TableIndex(name: 'idx_complaints_status', columns: {#status})
class Complaints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tenantId => integer().nullable().references(Tenants, #id, onDelete: KeyAction.restrict)();
  IntColumn get roomId => integer().nullable().references(Rooms, #id, onDelete: KeyAction.restrict)();
  TextColumn get category => text().withLength(min: 1, max: 60)();
  TextColumn get description => text().withLength(min: 1, max: 2000)();
  TextColumn get priority => textEnum<ComplaintPriority>()();
  TextColumn get status => textEnum<ComplaintStatus>().withDefault(Constant(ComplaintStatus.open.name))();
  /// JSON array of private-storage relative paths.
  TextColumn get imagePaths => text().withDefault(const Constant('[]'))();
  TextColumn get resolutionNotes => text().nullable()();
  IntColumn get expenseId => integer().nullable().references(Expenses, #id, onDelete: KeyAction.restrict)();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Notice')
@TableIndex(name: 'idx_notices_publish', columns: {#publishDate})
class Notices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 160)();
  TextColumn get body => text().withLength(min: 1, max: 4000)();
  TextColumn get category => text().withLength(min: 1, max: 60)();
  DateTimeColumn get publishDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Menu')
class Menus extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get menuDate => dateTime().unique()();
  TextColumn get breakfast => text().withDefault(const Constant(''))();
  TextColumn get lunch => text().withDefault(const Constant(''))();
  TextColumn get dinner => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('AuditLog')
@TableIndex(name: 'idx_audit_entity', columns: {#entity, #entityId})
class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entity => text()();
  IntColumn get entityId => integer().nullable()();
  TextColumn get action => text()();
  TextColumn get details => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('AppSetting')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}
