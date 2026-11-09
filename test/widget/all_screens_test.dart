import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pg_manager/app/app.dart';
import 'package:pg_manager/core/database/app_database.dart';
import 'package:pg_manager/core/database/daos/billing_dao.dart';
import 'package:pg_manager/core/database/daos/reports_dao.dart';
import 'package:pg_manager/core/database/daos/tenants_dao.dart';
import 'package:pg_manager/core/database/enums.dart';
import 'package:pg_manager/core/services/auth_service.dart';
import 'package:pg_manager/core/services/providers.dart';

Future<void> settle(WidgetTester tester, [int n = 4]) async {
  for (var i = 0; i < n; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 60)));
    await tester.pump(const Duration(milliseconds: 250));
  }
}

/// Seeds a realistic PG and returns ids used for deep links.
Future<Map<String, int>> seed(AppDatabase db, AuthService auth) async {
  final now = DateTime.now();
  await db.settingsDao.saveProfile(
    name: 'Sunrise PG',
    address: '12 MG Road, Bengaluru',
    ownerName: 'Ravi Kumar',
    ownerPhone: '9876543210',
    upiId: 'ravi@okaxis',
  );
  await auth.setPin('2580');
  await db.roomsDao.addRoom(roomNumber: '101', floor: 1, rentPaise: 850000, bedCount: 3);
  await db.roomsDao.addRoom(roomNumber: '001', floor: 0, rentPaise: 750000, bedCount: 2);
  final beds = (await db.select(db.beds).get()).map((b) => b.id).toList();
  Future<int> tenant(String name, String phone, int bed, {int deposit = 1000000}) => db.tenantsDao.createTenant(
        TenantInput(
          fullName: name,
          phone: phone,
          gender: Gender.male,
          joiningDate: DateTime(now.year, now.month - 2, 10),
          monthlyRentPaise: 850000,
          rentDueDay: 5,
          securityDepositPaise: deposit,
          emergencyContactName: 'Suresh (father)',
          emergencyContactPhone: '9876500000',
          idProofType: 'Aadhaar',
        ),
        bedId: bed,
      );
  final a = await tenant('Arjun Mehta', '9876500001', beds[0]);
  final b = await tenant('Bala Subramanian', '9876500002', beds[1]);
  await db.billingDao.generateMonthlyInvoices(now.year, now.month - 1);
  await db.billingDao.generateMonthlyInvoices(now.year, now.month);
  final cash = await db.billingDao.recordPayment(
      PaymentInput(tenantId: a, amountPaise: 850000, method: PaymentMethod.cash, date: DateTime(now.year, now.month, 1)));
  await db.billingDao.recordPayment(PaymentInput(
      tenantId: b, amountPaise: 400000, method: PaymentMethod.upi, date: DateTime(now.year, now.month, 1), upiReference: '612345678901'));
  await db.tenantsDao.giveNotice(b, DateTime(now.year, now.month, 1), DateTime(now.year, now.month, 1).add(const Duration(days: 20)));
  await db.opsDao.addExpense(
      title: 'Electricity bill', category: ExpenseCategory.electricity, amountPaise: 1240000, date: DateTime(now.year, now.month, 2), method: PaymentMethod.upi);
  final complaint = await db.opsDao.addComplaint(
      tenantId: a, category: 'Plumbing', description: 'Bathroom tap leaking since morning', priority: ComplaintPriority.high);
  final notice = await db.opsDao.saveNotice(title: 'Water supply off Sunday', body: 'From 10 AM to 2 PM.', category: 'Water / power cut', publishDate: now);
  await db.opsDao.saveMenu(now, breakfast: 'Idli, sambar', lunch: 'Rice, dal, sabzi', dinner: 'Chapati, paneer');
  final invoice = (await db.select(db.rentInvoices).get()).first.id;
  return {'tenant': a, 'tenant2': b, 'payment': cash, 'invoice': invoice, 'complaint': complaint, 'notice': notice};
}

void main() {
  setUpAll(() => initializeDateFormatting('en_IN'));

  testWidgets('every screen renders with real data and no layout errors', (tester) async {
    // Print full diagnostics (including the widget that overflowed) for any error.
    final original = FlutterError.onError;
    FlutterError.onError = (d) {
      FlutterError.dumpErrorToConsole(d, forceReport: true);
      original?.call(d);
    };
    addTearDown(() => FlutterError.onError = original);
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final db = AppDatabase(NativeDatabase.memory());
    final auth = AuthService(store: MemorySecureStore(), iterations: 1000, hashInIsolate: false);
    final ids = (await tester.runAsync(() => seed(db, auth)))!;

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        authServiceProvider.overrideWithValue(auth),
      ],
      child: const PgManagerApp(),
    ));
    await settle(tester);
    for (final d in '2580'.split('')) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    await settle(tester);
    expect(find.text('Sunrise PG'), findsOneWidget);

    final routes = [
      '/tenants',
      '/tenants/${ids['tenant']}',
      '/tenants/${ids['tenant2']}',
      '/tenants/new',
      '/tenants/${ids['tenant']}/edit',
      '/tenants/${ids['tenant2']}/checkout',
      '/rooms',
      '/rooms/new',
      '/payments',
      '/payments/collect',
      '/payments/collect?tenant=${ids['tenant2']}',
      '/payments/${ids['payment']}',
      '/invoices/${ids['invoice']}',
      '/more',
      '/more/expenses',
      '/more/expenses/new',
      '/more/complaints',
      '/more/complaints/new',
      '/more/complaints/${ids['complaint']}',
      '/more/menu',
      '/more/notices',
      '/more/notices/new',
      '/more/notices/${ids['notice']}',
      '/more/reports',
      for (final r in ReportType.values)
        if (r != ReportType.tenantLedger) '/more/reports/${r.name}',
      '/more/reports/tenantLedger?tenant=${ids['tenant']}',
      '/more/backup',
      '/more/settings',
      '/more/settings/profile',
    ];
    for (final r in routes) {
      final ctx = tester.element(find.byType(Scaffold).first);
      GoRouter.of(ctx).go(r);
      await settle(tester);
      final err = tester.takeException();
      expect(err, isNull, reason: 'Screen $r threw');
      expect(find.byType(ErrorWidget), findsNothing, reason: 'Screen $r showed an error widget');
    }

    // Spot-check real values reached the UI.
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/tenants/${ids['tenant2']}');
    await settle(tester);
    expect(find.text('Bala Subramanian'), findsOneWidget);
    expect(find.text('Notice given'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.runAsync(() => db.close());
  });
}
