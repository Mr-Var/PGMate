// Renders real screens to PNG for visual review.
// Run: flutter test test/screenshots --update-goldens
@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pg_manager/core/database/app_database.dart';
import 'package:pg_manager/core/database/enums.dart';
import 'package:pg_manager/core/services/auth_service.dart';
import 'package:pg_manager/core/services/providers.dart';
import 'package:pg_manager/core/theme/app_theme.dart';
import 'package:pg_manager/features/authentication/lock_screen.dart';
import 'package:pg_manager/features/authentication/onboarding_screen.dart';
import 'package:pg_manager/features/dashboard/dashboard_screen.dart';
import 'package:pg_manager/features/payments/payments_screen.dart';
import 'package:pg_manager/features/rooms/room_form_screen.dart';
import 'package:pg_manager/features/rooms/rooms_screen.dart';
import 'package:pg_manager/features/settings/more_screen.dart';
import 'package:pg_manager/features/settings/settings_screen.dart';
import 'package:pg_manager/features/tenants/tenants_screen.dart';

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    final bytes = File(p).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)));
  }
  await loader.load();
}

Future<void> settle(WidgetTester tester, [int rounds = 6]) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 60)));
    await tester.pump(const Duration(milliseconds: 400));
  }
}

Future<void> seedProfile(AppDatabase db) => db.settingsDao.saveProfile(
      name: 'Sunrise PG',
      address: '12, 4th Cross, Koramangala, Bengaluru 560034',
      ownerName: 'Ravi Kumar',
      ownerPhone: '9876543210',
      upiId: 'ravi@okaxis',
    );

Future<void> seedFull(AppDatabase db) async {
  await seedProfile(db);
  final rooms = db.roomsDao;
  await rooms.addRoom(roomNumber: '001', floor: 0, rentPaise: 750000, bedCount: 3, notes: 'Near entrance');
  await rooms.addRoom(roomNumber: '002', floor: 0, rentPaise: 900000, bedCount: 2);
  await rooms.addRoom(roomNumber: '101', floor: 1, rentPaise: 850000, bedCount: 3);
  await rooms.addRoom(roomNumber: '102', floor: 1, rentPaise: 1200000, bedCount: 1, notes: 'AC single');
  await rooms.addRoom(roomNumber: '201', floor: 2, rentPaise: 800000, bedCount: 4);

  final beds = await (db.select(db.beds)..orderBy([(b) => OrderingTerm.asc(b.id)])).get();
  final names = [
    ('Arjun Mehta', '9845012345', 0),
    ('Bala Subramanian', '9845012346', 1),
    ('Chetan Rao', '9845012347', 3),
    ('Deepak Nair', '9845012348', 5),
    ('Farhan Ali', '9845012349', 6),
    ('Gaurav Singh', '9845012350', 8),
    ('Harish Reddy', '9845012351', 9),
    ('Imran Khan', '9845012352', 10),
  ];
  final tenantIds = <int>[];
  for (final (i, n) in names.indexed) {
    final status = i == 5 ? TenantStatus.noticeGiven : TenantStatus.active;
    final id = await db.into(db.tenants).insert(TenantsCompanion.insert(
          fullName: n.$1,
          phone: n.$2,
          gender: Gender.male,
          joiningDate: DateTime(2026, 3 + i % 6, 1 + i),
          monthlyRentPaise: 850000,
          rentDueDay: 5,
          status: Value(status),
          expectedCheckoutDate: Value(status == TenantStatus.noticeGiven ? DateTime(2026, 11, 25) : null),
        ));
    tenantIds.add(id);
    await db.into(db.allocations).insert(AllocationsCompanion.insert(
          tenantId: id,
          bedId: beds[n.$3].id,
          startDate: DateTime(2026, 3, 1),
          rentPaise: 850000,
        ));
  }
  await rooms.setBedStatus(beds[2].id, BedStatus.reserved);
  await rooms.setBedStatus(beds[7].id, BedStatus.maintenance);

  var inv = 0;
  Future<void> invoice(int t, int month, int paid, InvoiceStatus s, DateTime due) =>
      db.into(db.rentInvoices).insert(RentInvoicesCompanion.insert(
            invoiceNumber: 'INV-2026-${(++inv).toString().padLeft(4, '0')}',
            tenantId: t,
            periodYear: 2026,
            periodMonth: month,
            periodStart: DateTime(2026, month),
            periodEnd: DateTime(2026, month + 1),
            rentPaise: 850000,
            totalPaise: 850000,
            paidPaise: Value(paid),
            status: Value(s),
            dueDate: due,
          ));
  for (final (i, t) in tenantIds.indexed) {
    if (i < 4) {
      await invoice(t, 11, 850000, InvoiceStatus.paid, DateTime(2026, 11, 5));
    } else if (i == 4) {
      await invoice(t, 11, 400000, InvoiceStatus.partiallyPaid, DateTime(2026, 11, 5));
    } else if (i == 5) {
      await invoice(t, 11, 0, InvoiceStatus.unpaid, DateTime(2026, 11, 9));
    } else {
      await invoice(t, 11, 0, InvoiceStatus.overdue, DateTime(2026, 11, 5));
    }
  }
  await invoice(tenantIds[7], 10, 0, InvoiceStatus.overdue, DateTime(2026, 10, 5));

  var p = 0;
  Future<void> pay(int t, int amount, DateTime d, PaymentMethod m,
          {PaymentStatus s = PaymentStatus.confirmed, String? utr}) =>
      db.into(db.payments).insert(PaymentsCompanion.insert(
            transactionId: 'TXN-${++p}',
            receiptNumber: 'RCPT-2026-${p.toString().padLeft(4, '0')}',
            tenantId: t,
            amountPaise: amount,
            method: m,
            upiReference: Value(utr),
            paymentDate: d,
            status: s,
          ));
  await pay(tenantIds[0], 850000, DateTime(2026, 11, 2), PaymentMethod.cash);
  await pay(tenantIds[1], 850000, DateTime(2026, 11, 3), PaymentMethod.upi, utr: '431298765401');
  await pay(tenantIds[2], 850000, DateTime(2026, 11, 4), PaymentMethod.upi, utr: '431298765402');
  await pay(tenantIds[3], 850000, DateTime(2026, 11, 5), PaymentMethod.cash);
  await pay(tenantIds[4], 400000, DateTime(2026, 11, 6), PaymentMethod.cash);
  await pay(tenantIds[6], 850000, DateTime(2026, 11, 8), PaymentMethod.upi,
      s: PaymentStatus.pendingVerification, utr: '431298765409');

  await db.into(db.expenses).insert(ExpensesCompanion.insert(
        title: 'BESCOM electricity bill',
        category: ExpenseCategory.electricity,
        amountPaise: 1845000,
        expenseDate: DateTime(2026, 11, 3),
        paymentMethod: PaymentMethod.upi,
      ));
  await db.into(db.expenses).insert(ExpensesCompanion.insert(
        title: 'Vegetables & groceries',
        category: ExpenseCategory.food,
        amountPaise: 1260000,
        expenseDate: DateTime(2026, 11, 7),
        paymentMethod: PaymentMethod.cash,
      ));
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en_IN');
    const f = 'assets/fonts/IBMPlexSans';
    await _loadFont('IBMPlexSans', ['$f-Regular.ttf', '$f-Medium.ttf', '$f-SemiBold.ttf', '$f-Bold.ttf']);
    await _loadFont('MaterialIcons', ['/opt/sdk/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
  });

  Future<AppDatabase> shoot(
    WidgetTester tester,
    String name,
    Widget screen, {
    Future<void> Function(AppDatabase db)? seed,
    double height = 780,
    Future<void> Function()? before,
    AppDatabase? reuse,
  }) async {
    tester.view.physicalSize = Size(1080, height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final db = reuse ?? AppDatabase(NativeDatabase.memory());
    final store = MemorySecureStore();
    final auth = AuthService(store: store, iterations: 1000);
    await tester.runAsync(() async {
      if (seed != null) await seed(db);
      await auth.setPin('2580');
    });

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        secureStoreProvider.overrideWithValue(store),
        authServiceProvider.overrideWithValue(auth),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        locale: const Locale('en', 'IN'),
        supportedLocales: const [Locale('en', 'IN'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: screen,
      ),
    ));
    await settle(tester);
    if (before != null) {
      await before();
      await settle(tester);
    }
    // Render real shadows (tests default to solid outlines), then restore
    // the flag because the test harness checks it is unchanged.
    debugDisableShadows = false;
    for (final v in tester.binding.renderViews) {
      v.markNeedsPaint();
    }
    await tester.pump();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/$name.png'));
    debugDisableShadows = true;

    await tester.pumpWidget(const SizedBox());
    await settle(tester, 2);
    await tester.runAsync(() => db.close());
    return db;
  }

  testWidgets('01 onboarding', (t) => shoot(t, '01_onboarding', const OnboardingScreen()));
  testWidgets('02 lock', (t) => shoot(t, '02_lock', const LockScreen(), seed: seedProfile));
  testWidgets('03 dashboard', (t) => shoot(t, '03_dashboard', const DashboardScreen(), seed: seedFull));
  testWidgets('04 dashboard full', (t) => shoot(t, '04_dashboard_full', const DashboardScreen(), seed: seedFull, height: 2300));
  testWidgets('05 dashboard empty', (t) => shoot(t, '05_dashboard_empty', const DashboardScreen(), seed: seedProfile, height: 1300));
  testWidgets('06 rooms', (t) => shoot(t, '06_rooms', const RoomsScreen(), seed: seedFull, height: 1500));
  testWidgets('07 add room', (t) => shoot(t, '07_add_room', const RoomFormScreen(), seed: seedProfile));
  testWidgets('08 bed sheet', (t) => shoot(t, '08_bed_sheet', const RoomsScreen(), seed: seedFull, before: () async {
        await t.tap(find.text('Bed C').first);
      }));
  testWidgets('09 tenants', (t) => shoot(t, '09_tenants', const TenantsScreen(), seed: seedFull));
  testWidgets('10 payments', (t) => shoot(t, '10_payments', const PaymentsScreen(), seed: seedFull));
  testWidgets('11 more', (t) => shoot(t, '11_more', const MoreScreen()));
  testWidgets('12 settings', (t) => shoot(t, '12_settings', const SettingsScreen(), seed: seedProfile));
}
