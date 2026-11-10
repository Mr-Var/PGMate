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
    // Tapping a notification opens the matching screen (after unlock).
    final reminders = ref.read(reminderServiceProvider);
    reminders.onOpen = (route) {
      if (ref.read(authControllerProvider) == AuthStage.unlocked) {
        ref.read(routerProvider).push(route);
      } else {
        reminders.pendingRoute = route;
      }
    };
    ref.listenManual(authControllerProvider, (prev, next) {
      if (next == AuthStage.unlocked && prev != AuthStage.unlocked) {
        _upkeep();
        final route = reminders.pendingRoute;
        if (route != null) {
          reminders.pendingRoute = null;
          WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(routerProvider).push(route));
        }
      }
    });
  }

  Future<void> _upkeep() async {
    try {
      final db = ref.read(databaseProvider);
      // Bill every month that is due (including this one) without asking.
      if ((await db.settingsDao.getSetting('auto_billing')) != 'false') {
        await db.billingDao.generateAllMissing();
      }
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
    final large = ref.watch(largeTextProvider).value ?? false;
    return MaterialApp.router(
      title: 'PG Manager',
      // Large text mode: 25% bigger on top of the phone's own font size.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final base = mq.textScaler.scale(1);
        final scale = (large ? base * 1.25 : base).clamp(1.0, 2.0);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: ref.watch(routerProvider),
      locale: const Locale('en', 'IN'),
      supportedLocales: const [Locale('en', 'IN'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
