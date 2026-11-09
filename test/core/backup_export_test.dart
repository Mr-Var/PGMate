import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:pg_manager/core/database/app_database.dart';
import 'package:pg_manager/core/database/daos/billing_dao.dart';
import 'package:pg_manager/core/database/daos/reports_dao.dart';
import 'package:pg_manager/core/database/daos/tenants_dao.dart';
import 'package:pg_manager/core/database/enums.dart';
import 'package:pg_manager/core/database/rules.dart';
import 'package:pg_manager/core/services/backup_service.dart';
import 'package:pg_manager/core/services/export_service.dart';
import 'package:pg_manager/core/services/file_store.dart';
import 'package:pg_manager/core/utils/dates.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakePaths extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  FakePaths(this.root);
  final Directory root;

  @override
  Future<String?> getTemporaryPath() async => (await Directory(p.join(root.path, 'tmp')).create(recursive: true)).path;

  @override
  Future<String?> getApplicationSupportPath() async => (await Directory(p.join(root.path, 'support')).create(recursive: true)).path;

  @override
  Future<String?> getApplicationDocumentsPath() async => (await Directory(p.join(root.path, 'docs')).create(recursive: true)).path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;

  setUpAll(() => initializeDateFormatting('en_IN'));
  setUp(() async {
    root = await Directory.systemTemp.createTemp('pgm_test');
    PathProviderPlatform.instance = FakePaths(root);
  });
  tearDown(() => root.delete(recursive: true));

  Future<AppDatabase> openLive() async {
    final file = await AppDatabase.databaseFile();
    return AppDatabase(NativeDatabase(file));
  }

  Future<(int, int)> seed(AppDatabase db) async {
    await db.settingsDao.saveProfile(name: 'Sunrise PG', address: '12 MG Road', ownerName: 'Ravi', ownerPhone: '9876543210');
    await db.roomsDao.addRoom(roomNumber: '101', floor: 1, rentPaise: 900000, bedCount: 2);
    final bed = (await db.select(db.beds).get()).first.id;
    final t = await db.tenantsDao.createTenant(
      TenantInput(
        fullName: 'Arjun Mehta',
        phone: '9876500001',
        gender: Gender.male,
        joiningDate: DateTime(2026, 11, 1),
        monthlyRentPaise: 900000,
        rentDueDay: 5,
        securityDepositPaise: 500000,
      ),
      bedId: bed,
    );
    final pay = await db.billingDao.recordPayment(
        PaymentInput(tenantId: t, amountPaise: 400000, method: PaymentMethod.cash, date: DateTime(2026, 11, 3)));
    return (t, pay);
  }

  test('backup → wipe → restore brings back data and files; wrong password and tampering are rejected', () async {
    final files = FileStore();
    final backups = BackupService(files: files);
    var db = await openLive();
    final (_, _) = await seed(db);
    final photo = await files.save(Uint8List.fromList(List.generate(2000, (i) => i % 256)), folder: 'tenants', extension: 'jpg');

    final (bytes, manifest) = await backups.create(db, 'correct horse');
    expect(manifest.tenants, 1);
    expect(manifest.payments, 1);
    expect(manifest.files, 1);
    // The file is encrypted: no readable tenant names inside.
    expect(String.fromCharCodes(bytes).contains('Arjun'), isFalse);

    // Wrong password and a flipped byte are both refused before anything changes.
    await expectLater(backups.validate(bytes, 'wrong pass', currentSchemaVersion: db.schemaVersion), throwsA(isA<RuleException>()));
    final tampered = Uint8List.fromList(bytes)..[bytes.length - 10] ^= 0xFF;
    await expectLater(backups.validate(tampered, 'correct horse', currentSchemaVersion: db.schemaVersion), throwsA(isA<RuleException>()));
    await expectLater(backups.validate(Uint8List.fromList([1, 2, 3]), 'x', currentSchemaVersion: 1), throwsA(isA<RuleException>()));

    // Change data after the backup, then restore.
    await db.opsDao.addExpense(
        title: 'After backup', category: ExpenseCategory.food, amountPaise: 100, date: DateTime(2026, 11, 5), method: PaymentMethod.cash);
    final valid = await backups.validate(bytes, 'correct horse', currentSchemaVersion: db.schemaVersion);
    await db.close();
    await (await files.resolve(photo)).delete();
    await backups.apply(valid);

    db = await openLive();
    expect((await db.select(db.tenants).get()).single.fullName, 'Arjun Mehta');
    expect((await db.select(db.payments).get()).single.amountPaise, 400000);
    expect(await db.select(db.expenses).get(), isEmpty, reason: 'post-backup change is gone');
    expect(await (await files.resolve(photo)).exists(), isTrue, reason: 'photo restored');
    // Integrity rules survive the restore.
    expect(() => (db.delete(db.payments)).go(), throwsA(isA<SqliteException>()));
    // A safety copy of the replaced data was kept.
    final support = Directory(p.join(root.path, 'support'));
    expect(support.listSync().whereType<Directory>().any((d) => p.basename(d.path).startsWith('pre_restore_')), isTrue);
    await db.close();
  });

  test('receipt and report PDFs, and CSV export', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final (_, pay) = await seed(db);
    final export = ExportService();

    final receipt = await export.receiptPdf(await db.billingDao.receiptData(pay));
    expect(String.fromCharCodes(receipt.take(5)), '%PDF-');
    expect(receipt.length, greaterThan(2000));

    for (final type in ReportType.values) {
      final t = await db.reportsDao.build(type, DateRange.month(2026, 11), tenantId: 1);
      final pdf = await export.reportPdf(t, pgName: 'Sunrise PG');
      expect(String.fromCharCodes(pdf.take(5)), '%PDF-', reason: type.name);
    }

    final csv = ExportService.toCsv(await db.reportsDao.build(ReportType.collection, DateRange.month(2026, 11)));
    expect(csv.startsWith('﻿'), isTrue);
    expect(csv, contains('Receipt,Tenant'));
    expect(csv, contains('Arjun Mehta'));
    expect(csv, contains('"₹4,000"'), reason: 'amounts with commas are quoted');
    await db.close();
  });
}
