import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pg_manager/app/app.dart';
import 'package:pg_manager/features/authentication/auth_controller.dart';
import 'package:pg_manager/core/database/app_database.dart';
import 'package:pg_manager/core/services/auth_service.dart';
import 'package:pg_manager/core/services/providers.dart';

Future<void> enterPin(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(find.text(d).last);
    await tester.pump();
  }
}

/// Lets real async work (isolates, SQLite) finish, then settles frames.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  AuthController.splashMinimum = Duration.zero;
  setUpAll(() => initializeDateFormatting('en_IN'));

  late AppDatabase db;
  late MemorySecureStore store;
  late AuthService auth;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    store = MemorySecureStore();
    auth = AuthService(store: store, iterations: 1000, hashInIsolate: false);
  });

  Widget app() => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      secureStoreProvider.overrideWithValue(store),
      authServiceProvider.overrideWithValue(auth),
    ],
    child: const PgManagerApp(),
  );

  testWidgets('first launch shows PG setup', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await settle(tester);
    expect(find.text('Set up your PG'), findsOneWidget);

    // Validation blocks an empty form.
    await tester.ensureVisible(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('PG name is required'), findsOneWidget);

    // Unmount first so no live query keeps the database busy while closing.
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.runAsync(() => db.close());
  });

  testWidgets('unlock with PIN, then dashboard shows database figures', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.runAsync(() async {
      await db.settingsDao.saveProfile(
        name: 'Sunrise PG',
        address: '12 MG Road, Bengaluru',
        ownerName: 'Ravi Kumar',
        ownerPhone: '9876543210',
      );
      await auth.setPin('2580');
      await db.roomsDao.addRoom(roomNumber: '101', floor: 1, rentPaise: 850000, bedCount: 3);
    });

    await tester.pumpWidget(app());
    await settle(tester);
    expect(find.text('Enter your PIN to unlock'), findsOneWidget);

    await enterPin(tester, '1357');
    await settle(tester);
    expect(find.textContaining('Incorrect PIN'), findsOneWidget);

    await enterPin(tester, '2580');
    await settle(tester);

    expect(find.text('Sunrise PG'), findsOneWidget);
    expect(find.textContaining('RENT RECEIVED'), findsOneWidget);
    expect(find.text('DUE'), findsOneWidget);
    // 3 beds from the database, 0 occupied.
    // Occupancy sits under "Show more" on the simplified home screen.
    await tester.scrollUntilVisible(find.textContaining('Show more'), 300, scrollable: find.byType(Scrollable).first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.textContaining('Show more'));
    await settle(tester);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('3'), findsWidgets);

    // Navigate to Rooms tab and see the bed map.
    await tester.tap(find.text('Rooms').last);
    await settle(tester);
    expect(find.text('Room 101'), findsOneWidget);
    expect(find.text('Bed A'), findsOneWidget);

    // Unmount first so no live query keeps the database busy while closing.
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.runAsync(() => db.close());
  });
}
