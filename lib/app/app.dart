import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/providers.dart';
import '../core/theme/app_theme.dart';
import '../features/authentication/auth_controller.dart';
import 'router.dart';

class PgManagerApp extends ConsumerStatefulWidget {
  const PgManagerApp({super.key});

  @override
  ConsumerState<PgManagerApp> createState() => _PgManagerAppState();
}

class _PgManagerAppState extends ConsumerState<PgManagerApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Re-lock after the app has been in the background for a while.
    _lifecycle = AppLifecycleListener(
      onHide: () => ref.read(authControllerProvider.notifier).onBackground(),
      onShow: () => ref.read(authControllerProvider.notifier).onForeground(),
    );
    // Daily upkeep each time the owner unlocks: mark overdue invoices and
    // refresh local rent reminders. Failures never block the app.
    ref.listenManual(authControllerProvider, (prev, next) {
      if (next == AuthStage.unlocked && prev != AuthStage.unlocked) _upkeep();
    });
  }

  Future<void> _upkeep() async {
    try {
      final db = ref.read(databaseProvider);
      await db.billingDao.refreshOverdue();
      await refreshReminders(db, ref.read(reminderServiceProvider));
    } catch (e) {
      debugPrint('Upkeep skipped: $e');
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PG Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: ref.watch(routerProvider),
      locale: const Locale('en', 'IN'),
      supportedLocales: const [Locale('en', 'IN'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
