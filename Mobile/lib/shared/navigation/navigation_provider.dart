import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/domain/entities/dashboard.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';
import 'bottom_nav_item.dart';

/// Shell tab indices for [StatefulShellRoute.indexedStack].
abstract final class ShellTabIndex {
  static const int home = 0;
  static const int chamas = 1;
  static const int loans = 2;
  static const int alerts = 3;
  static const int more = 4;
}

/// Badge counts surfaced on bottom navigation destinations.
@immutable
class NavigationBadgeState {
  const NavigationBadgeState({
    this.alerts = 0,
    this.loans = 0,
    this.chamas = 0,
  });

  final int alerts;
  final int loans;
  final int chamas;

  NavigationBadgeState copyWith({
    int? alerts,
    int? loans,
    int? chamas,
  }) {
    return NavigationBadgeState(
      alerts: alerts ?? this.alerts,
      loans: loans ?? this.loans,
      chamas: chamas ?? this.chamas,
    );
  }
}

/// Derives nav badges from live notification unread count + dashboard loans.
final navigationBadgesProvider = Provider<NavigationBadgeState>((ref) {
  final unread = ref.watch(notificationUnreadCountProvider);
  final dashState = ref.watch(dashboardProvider);
  final Dashboard? data = dashState.data;
  return NavigationBadgeState(
    alerts: unread,
    loans: data?.loanSummary.pendingApplications ?? 0,
  );
});

/// Context for role-aware FAB actions (active chama + role label).
@immutable
class ShellNavigationContext {
  const ShellNavigationContext({
    this.chamaId,
    this.roleLabel,
  });

  final String? chamaId;
  final String? roleLabel;
}

final shellNavigationContextProvider = Provider<ShellNavigationContext>((ref) {
  final data = ref.watch(dashboardProvider).data;
  if (data == null || !data.hasChama) {
    return const ShellNavigationContext();
  }
  return ShellNavigationContext(
    chamaId: data.chamaId,
    roleLabel: data.userRole,
  );
});

/// Default bottom-nav items; badge counts are applied at build time.
List<BottomNavItem> defaultBottomNavItems({
  NavigationBadgeState badges = const NavigationBadgeState(),
}) {
  return [
    const BottomNavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    BottomNavItem(
      label: 'Chamas',
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups,
      badgeCount: badges.chamas,
    ),
    BottomNavItem(
      label: 'Loans',
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
      badgeCount: badges.loans,
    ),
    BottomNavItem(
      label: 'Alerts',
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications,
      badgeCount: badges.alerts,
    ),
    const BottomNavItem(
      label: 'More',
      icon: Icons.menu_outlined,
      selectedIcon: Icons.menu,
    ),
  ];
}
