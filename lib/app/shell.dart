import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard_rounded), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.people_outline_rounded), selectedIcon: Icon(Icons.people_rounded), label: 'Tenants'),
    NavigationDestination(icon: Icon(Icons.bed_outlined), selectedIcon: Icon(Icons.bed_rounded), label: 'Rooms'),
    NavigationDestination(
        icon: Icon(Icons.account_balance_wallet_outlined),
        selectedIcon: Icon(Icons.account_balance_wallet_rounded),
        label: 'Payments'),
    NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          destinations: _destinations,
          // Re-tapping the current tab returns to its root.
          onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        ),
      ),
    );
  }
}
