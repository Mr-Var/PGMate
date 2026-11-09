// Field audit: each test reproduces a confirmed form/input bug.
// Expected to FAIL until the corresponding bug is fixed.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pg_manager/app/app.dart';
import 'package:pg_manager/features/authentication/auth_controller.dart';
import 'package:pg_manager/core/database/app_database.dart';
import 'package:pg_manager/core/services/auth_service.dart';
import 'package:pg_manager/core/services/providers.dart';
import 'package:pg_manager/core/utils/money.dart';
import 'package:pg_manager/shared/widgets/form_kit.dart';

import '../widget/all_screens_test.dart' show seed, settle;

Future<(AppDatabase, Map<String, int>)> boot(WidgetTester tester, {Future<void> Function(AppDatabase)? extra}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final db = AppDatabase(NativeDatabase.memory());
  final auth = AuthService(store: MemorySecureStore(), iterations: 1000, hashInIsolate: false);
  final ids = (await tester.runAsync(() async {
    final ids = await seed(db, auth);
    if (extra != null) await extra(db);
    return ids;
  }))!;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db), authServiceProvider.overrideWithValue(auth)],
      child: const PgManagerApp(),
    ),
  );
  await settle(tester);
  for (final d in '2580'.split('')) {
    await tester.tap(find.text(d).last);
    await tester.pump();
  }
  await settle(tester);
  return (db, ids);
}

Future<void> go(WidgetTester tester, String route) async {
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(route);
  await settle(tester);
}

Future<void> teardown(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await settle(tester);
  await tester.runAsync(() => db.close());
}

void main() {
  AuthController.splashMinimum = Duration.zero;
  setUpAll(() => initializeDateFormatting('en_IN'));

  test('money parsing used by every amount field', () {
    expect(Money.parseRupees('1,00,000'), 10000000);
    expect(Money.parseRupees('12.5'), 1250);
    expect(Money.parseRupees('0'), 0);
    expect(Money.parseRupees(''), isNull); // optional fields fall back to 0 via MoneyField.read
  });

  // BUG: new-tenant "Rent due day" shows Day 5 while the saved value is the
  // PG default loaded later (initialValue is read only once).
  testWidgets('new tenant due-day dropdown reflects the PG default', (tester) async {
    final (db, _) = await boot(
      tester,
      extra: (db) async {
        final p = (await db.settingsDao.getProfile())!;
        await db.settingsDao.saveProfile(
          name: p.name,
          address: p.address,
          ownerName: p.ownerName,
          ownerPhone: p.ownerPhone,
          defaultRentDueDay: 10,
        );
      },
    );
    await go(tester, '/tenants/new');
    await tester.scrollUntilVisible(find.text('Rent due day'), 300, scrollable: find.byType(Scrollable).first);
    await settle(tester, 2);
    expect(find.text('Day 10 of every month'), findsOneWidget, reason: 'UI shows Day 5 but saves 10');
    await teardown(tester, db);
  });

  // BUG: editing a complaint shows "Not tenant-specific" / "Common area" even
  // though the complaint has a tenant; initialValue is set before data loads.
  testWidgets('complaint edit form shows the saved tenant', (tester) async {
    final (db, ids) = await boot(tester);
    await go(tester, '/more/complaints/${ids['complaint']}/edit');
    await settle(tester, 3);
    expect(find.textContaining('Arjun Mehta'), findsWidgets);
    expect(find.text('Not tenant-specific'), findsNothing);
    await teardown(tester, db);
  });

  // BUG: "New invoice" for a checked-out tenant (button on every profile)
  // builds a dropdown whose value is not among the items → assertion.
  testWidgets('new invoice for a checked-out tenant does not crash', (tester) async {
    late int gone;
    final (db, _) = await boot(
      tester,
      extra: (db) async {
        final t = (await db.select(db.tenants).get()).last;
        gone = t.id;
        await db.billingDao.checkout(gone, DateTime.now());
      },
    );
    await go(tester, '/invoices/new?tenant=$gone');
    expect(tester.takeException(), isNull);
    await teardown(tester, db);
  });

  // BUG: checkout "Deductions" is not inside a Form, so "abc" or "1.234" is
  // silently treated as ₹0 with no error.
  testWidgets('checkout rejects an invalid deduction amount', (tester) async {
    final (db, ids) = await boot(tester);
    await go(tester, '/tenants/${ids['tenant']}/checkout');
    await tester.enterText(find.widgetWithText(TextFormField, 'Deductions (damages, cleaning…)'), '12.345');
    await settle(tester, 2);
    expect(find.text('Enter a valid amount (max 2 decimals)'), findsOneWidget);
    await teardown(tester, db);
  });

  // BUG: from a checked-out tenant's profile, "No complaints" opens the
  // complaint form with that tenant preselected, but only current tenants are
  // listed → same dropdown assertion.
  testWidgets('new complaint for a checked-out tenant does not crash', (tester) async {
    late int gone;
    final (db, _) = await boot(
      tester,
      extra: (db) async {
        final t = (await db.select(db.tenants).get()).last;
        gone = t.id;
        await db.billingDao.checkout(gone, DateTime.now());
      },
    );
    await go(tester, '/more/complaints/new?tenant=$gone');
    expect(tester.takeException(), isNull);
    await teardown(tester, db);
  });

  // BUG: DateField passes value as initialDate even when it is before `first`.
  // Reachable in the notice sheet: set "Notice given on" after "Expected
  // checkout", then tap "Expected checkout" → showDatePicker assertion.
  testWidgets('date field with value before first does not crash', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Builder(builder: (_) => _DateHost())),
      ),
    );
    await tester.tap(find.text('Expected checkout'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

class _DateHost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mirrors tenant_actions.dart notice sheet after notice date moved later.
    return DateField(
      label: 'Expected checkout',
      value: DateTime(2026, 12, 1),
      first: DateTime(2026, 12, 20),
      onChanged: (_) {},
    );
  }
}
