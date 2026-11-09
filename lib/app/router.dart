import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/database/daos/reports_dao.dart';
import '../features/authentication/auth_controller.dart';
import '../features/authentication/lock_screen.dart';
import '../features/authentication/onboarding_screen.dart';
import '../features/backup/backup_screen.dart';
import '../features/complaints/complaints_screens.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/expenses/expenses_screens.dart';
import '../features/food_menu/food_menu_screen.dart';
import '../features/notices/notices_screens.dart';
import '../features/payments/collect_payment_screen.dart';
import '../features/payments/invoice_detail_screen.dart';
import '../features/payments/payment_detail_screen.dart';
import '../features/payments/payments_screen.dart';
import '../features/reports/reports_screens.dart';
import '../features/rooms/room_form_screen.dart';
import '../features/rooms/rooms_screen.dart';
import '../features/settings/more_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/tenants/checkout_screen.dart';
import '../features/tenants/tenant_detail_screen.dart';
import '../features/tenants/tenant_form_screen.dart';
import '../features/tenants/tenants_screen.dart';
import '../shared/widgets/document_viewer.dart';
import 'shell.dart';

int? _id(GoRouterState s, [String key = 'id']) => int.tryParse(s.pathParameters[key] ?? '');
int? _q(GoRouterState s, String key) => int.tryParse(s.uri.queryParameters[key] ?? '');

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
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (_, _) => const DashboardScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/tenants', builder: (_, _) => const TenantsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/rooms', builder: (_, _) => const RoomsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/payments', builder: (_, _) => const PaymentsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/more', builder: (_, _) => const MoreScreen())],
          ),
        ],
      ),
      // Full-screen flows push above the bottom navigation.
      GoRoute(path: '/rooms/new', builder: (_, _) => const RoomFormScreen()),
      GoRoute(
        path: '/rooms/:id/edit',
        builder: (_, s) => RoomFormScreen(roomId: _id(s)),
      ),

      GoRoute(path: '/tenants/new', builder: (_, _) => const TenantFormScreen()),
      GoRoute(
        path: '/tenants/:id',
        builder: (_, s) => TenantDetailScreen(tenantId: _id(s)!),
      ),
      GoRoute(
        path: '/tenants/:id/edit',
        builder: (_, s) => TenantFormScreen(tenantId: _id(s)),
      ),
      GoRoute(
        path: '/tenants/:id/checkout',
        builder: (_, s) => CheckoutScreen(tenantId: _id(s)!),
      ),

      GoRoute(
        path: '/payments/collect',
        builder: (_, s) => CollectPaymentScreen(tenantId: _q(s, 'tenant'), invoiceId: _q(s, 'invoice')),
      ),
      GoRoute(
        path: '/payments/:id',
        builder: (_, s) => PaymentDetailScreen(paymentId: _id(s)!),
      ),
      GoRoute(
        path: '/payments/:id/receipt',
        builder: (_, s) => ReceiptScreen(paymentId: _id(s)!),
      ),
      GoRoute(
        path: '/invoices/:id',
        builder: (_, s) => InvoiceDetailScreen(invoiceId: _id(s)!),
      ),

      GoRoute(path: '/more/expenses', builder: (_, _) => const ExpensesScreen()),
      GoRoute(path: '/more/expenses/new', builder: (_, _) => const ExpenseFormScreen()),
      GoRoute(path: '/more/complaints', builder: (_, _) => const ComplaintsScreen()),
      GoRoute(
        path: '/more/complaints/new',
        builder: (_, s) => ComplaintFormScreen(tenantId: _q(s, 'tenant')),
      ),
      GoRoute(
        path: '/more/complaints/:id',
        builder: (_, s) => ComplaintDetailScreen(complaintId: _id(s)!),
      ),
      GoRoute(path: '/more/menu', builder: (_, _) => const FoodMenuScreen()),
      GoRoute(path: '/more/notices', builder: (_, _) => const NoticesScreen()),
      GoRoute(path: '/more/notices/new', builder: (_, _) => const NoticeFormScreen()),
      GoRoute(
        path: '/more/notices/:id',
        builder: (_, s) => NoticeFormScreen(noticeId: _id(s)),
      ),
      GoRoute(path: '/more/reports', builder: (_, _) => const ReportsScreen()),
      GoRoute(
        path: '/more/reports/:type',
        builder: (_, s) {
          final type =
              ReportType.values.where((t) => t.name == s.pathParameters['type']).firstOrNull ??
              ReportType.financialSummary;
          return ReportViewScreen(type: type, tenantId: _q(s, 'tenant'));
        },
      ),
      GoRoute(path: '/more/backup', builder: (_, _) => const BackupScreen()),
      GoRoute(path: '/more/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/more/settings/profile', builder: (_, _) => const EditProfileScreen()),
      GoRoute(
        path: '/document',
        builder: (_, s) => DocumentViewerScreen(
          path: s.uri.queryParameters['path'] ?? '',
          title: s.uri.queryParameters['title'] ?? 'Document',
        ),
      ),
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
