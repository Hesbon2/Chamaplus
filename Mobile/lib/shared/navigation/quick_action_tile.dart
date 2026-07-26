import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

/// A single quick-action row used in sheets and grids.
class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.label,
    required this.icon,
    this.subtitle,
    this.badgeCount = 0,
    this.onTap,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final String? subtitle;
  final int badgeCount;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return Material(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.45),
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: theme.textTheme.labelMedium,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListTile(
      onTap: onTap,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        child: Icon(icon),
      ),
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: badgeCount > 0
          ? Badge(label: Text('$badgeCount'))
          : const Icon(Icons.chevron_right),
    );
  }
}
