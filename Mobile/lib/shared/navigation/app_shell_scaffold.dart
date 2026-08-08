import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/offline_banner.dart';
import 'app_bottom_navigation.dart';
import 'navigation_provider.dart';
import 'quick_actions_sheet.dart';
import 'role_navigation_service.dart';

/// Scaffold that hosts the [StatefulNavigationShell] body, bottom nav, and FAB.
class AppShellScaffold extends ConsumerWidget {
  const AppShellScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  bool get _isHomeTab =>
      navigationShell.currentIndex == ShellTabIndex.home;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Future<void> _openQuickActions(BuildContext context, WidgetRef ref) async {
    final shellCtx = ref.read(shellNavigationContextProvider);
    final actions = RoleNavigationService.quickActionsFor(
      roleLabel: shellCtx.roleLabel,
      chamaId: shellCtx.chamaId,
    );
    final role = shellCtx.roleLabel;
    await QuickActionsSheet.show(
      context,
      actions: actions,
      title: 'Quick actions',
      subtitle: role == null || role.isEmpty
          ? 'Shortcuts for your chama'
          : 'Shortcuts for $role',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badges = ref.watch(navigationBadgesProvider);
    final items = defaultBottomNavItems(badges: badges);

    return Scaffold(
      body: OfflineAwareBody(child: navigationShell),
      bottomNavigationBar: AppBottomNavigation(
        items: items,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
      floatingActionButton: _isHomeTab
          ? FloatingActionButton.extended(
              onPressed: () => _openQuickActions(context, ref),
              icon: const Icon(Icons.bolt_outlined),
              label: const Text('Actions'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
