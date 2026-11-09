import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/auth_controller.dart';
import '../features/authentication/lock_screen.dart';
import '../features/authentication/onboarding_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/payments/payments_screen.dart';
import '../features/rooms/room_form_screen.dart';
import '../features/rooms/rooms_screen.dart';
import '../features/settings/more_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/tenants/tenants_screen.dart';
import 'shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Bridges Riverpod auth state into go_router's refresh mechanism.
  final authListenable = ValueNotifier<AuthStage>(ref.read(authControllerProvider));
  ref.listen(authControllerProvider, (_, next) => authListenable.value = next);
  ref.onDispose(authListenable.dispose);

  final router = GoRouter(
    initialLocation: '/home',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final stage = authListenable.value;
      final loc = state.matchedLocation;
      switch (stage) {
        case AuthStage.loading:
          return loc == '/splash' ? null : '/splash';
        case AuthStage.onboarding:
          return loc == '/onboarding' ? null : '/onboarding';
        case AuthStage.locked:
          return loc == '/lock' ? null : '/lock';
        case AuthStage.unlocked:
          if (loc == '/splash' || loc == '/onboarding' || loc == '/lock') return '/home';
          return null;
      }
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const _Splash()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/lock', builder: (_, _) => const LockScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const DashboardScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/tenants', builder: (_, _) => const TenantsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/rooms', builder: (_, _) => const RoomsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/payments', builder: (_, _) => const PaymentsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/more', builder: (_, _) => const MoreScreen())]),
        ],
      ),
      // Full-screen flows push above the bottom navigation.
      GoRoute(path: '/rooms/new', builder: (_, _) => const RoomFormScreen()),
      GoRoute(
        path: '/rooms/:id/edit',
        builder: (_, s) => RoomFormScreen(roomId: int.tryParse(s.pathParameters['id'] ?? '')),
      ),
      GoRoute(path: '/more/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/more/settings/profile', builder: (_, _) => const EditProfileScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}
