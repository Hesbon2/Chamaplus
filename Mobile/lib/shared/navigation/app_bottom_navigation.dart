import 'package:flutter/material.dart';

import 'bottom_nav_item.dart';
import 'navigation_badge.dart';

/// Material 3 bottom navigation for the application shell.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<BottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 360;

    return NavigationBar(
      selectedIndex: selectedIndex.clamp(0, items.length - 1),
      onDestinationSelected: onDestinationSelected,
      labelBehavior: compact
          ? NavigationDestinationLabelBehavior.onlyShowSelected
          : NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        for (final item in items)
          NavigationDestination(
            icon: NavigationBadge(
              count: item.badgeCount,
              child: Icon(item.icon),
            ),
            selectedIcon: NavigationBadge(
              count: item.badgeCount,
              child: Icon(item.selectedIcon),
            ),
            label: item.label,
            tooltip: item.label,
          ),
      ],
    );
  }
}
