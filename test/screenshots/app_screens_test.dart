// Renders real app screens to PNG for visual review.
// Run: flutter test test/screenshots --update-goldens
@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pg_manager/app/app.dart';
import 'package:pg_manager/features/authentication/auth_controller.dart';
import 'package:pg_manager/core/database/app_database.dart';
import 'package:pg_manager/core/services/auth_service.dart';
import 'package:pg_manager/core/services/providers.dart';

import '../widget/all_screens_test.dart' show seed, settle;

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    loader.addFont(Future.value(ByteData.view(Uint8List.fromList(File(p).readAsBytesSync()).buffer)));
  }
  await loader.load();
}

void main() {
  AuthController.splashMinimum = Duration.zero;
  setUpAll(() async {
    await initializeDateFormatting('en_IN');
    const f = 'assets/fonts/IBMPlexSans';
    await _font('IBMPlexSans', ['$f-Regular.ttf', '$f-Medium.ttf', '$f-SemiBold.ttf', '$f-Bold.ttf']);
    await _font('MaterialIcons', ['/opt/sdk/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
  });

  testWidgets('app screens', (tester) async {
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final db = AppDatabase(NativeDatabase.memory());
    final auth = AuthService(store: MemorySecureStore(), iterations: 1000, hashInIsolate: false);
    final ids = (await tester.runAsync(() => seed(db, auth)))!;

    Future<void> shot(String name, {double height = 780}) async {
      tester.view.physicalSize = Size(1080, height * 3);
      await settle(tester, 3);
      debugDisableShadows = false;
      for (final v in tester.binding.renderViews) {
        v.markNeedsPaint();
      }
      await tester.pump();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/$name.png'));
      debugDisableShadows = true;
    }

    tester.view.physicalSize = const Size(1080, 2340);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db), authServiceProvider.overrideWithValue(auth)],
        child: const PgManagerApp(),
      ),
    );
    await settle(tester);
    await shot('01_lock');
    for (final d in '2580'.split('')) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    await settle(tester);
    await shot('02_dashboard', height: 2300);

    final pages = [
      ('03_tenants', '/tenants', 780.0),
      ('04_tenant_profile', '/tenants/${ids['tenant2']}', 1300.0),
      ('05_tenant_form', '/tenants/new', 1700.0),
      ('06_checkout', '/tenants/${ids['tenant2']}/checkout', 1300.0),
      ('07_rooms', '/rooms', 780.0),
      ('08_payments', '/payments', 780.0),
      ('09_collect', '/payments/collect?tenant=${ids['tenant2']}', 1300.0),
      ('10_payment', '/payments/${ids['payment']}', 1100.0),
      ('11_invoice', '/invoices/${ids['invoice']}', 900.0),
      ('12_expenses', '/more/expenses', 900.0),
      ('13_complaint', '/more/complaints/${ids['complaint']}', 780.0),
      ('14_menu', '/more/menu', 1100.0),
      ('15_notices', '/more/notices', 780.0),
      ('16_reports', '/more/reports', 1100.0),
      ('17_report_summary', '/more/reports/financialSummary', 1100.0),
      ('18_backup', '/more/backup', 780.0),
      ('19_more', '/more', 780.0),
      ('20_settings', '/more/settings', 1000.0),
      ('22_reminders', '/payments/remind', 1100.0),
      ('21_new_invoice', '/invoices/new?tenant=${ids['tenant']}', 1200.0),
    ];
    for (final (name, route, h) in pages) {
      tester.view.physicalSize = Size(1080, h * 3);
      GoRouter.of(tester.element(find.byType(Scaffold).first)).go(route);
      await settle(tester);
      await shot(name, height: h);
    }

    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.runAsync(() => db.close());
  });
}
