import 'package:flutter/material.dart';

/// Descriptor for a bottom-navigation destination.
class BottomNavItem {
  const BottomNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.badgeCount = 0,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int badgeCount;

  BottomNavItem copyWith({
    String? label,
    IconData? icon,
    IconData? selectedIcon,
    int? badgeCount,
  }) {
    return BottomNavItem(
      label: label ?? this.label,
      icon: icon ?? this.icon,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      badgeCount: badgeCount ?? this.badgeCount,
    );
  }
}
