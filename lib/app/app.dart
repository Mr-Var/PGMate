import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
