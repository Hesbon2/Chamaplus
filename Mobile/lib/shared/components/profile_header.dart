import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'app_card.dart';
import 'avatar_badge.dart';

/// Profile summary header for Settings / Profile / More.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.displayName,
    this.subtitle,
    this.initials,
    this.onTap,
    this.trailing,
  });

  final String displayName;
  final String? subtitle;
  final String? initials;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedInitials = (initials != null && initials!.isNotEmpty)
        ? initials!
        : (displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U');

    return Semantics(
      button: onTap != null,
      label: '$displayName. ${subtitle ?? ''}',
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            AvatarBadge(
              initials: resolvedInitials,
              size: 64,
              icon: Icons.person_outline,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: theme.textTheme.titleLarge),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
          ],
        ),
      ),
    );
  }
}
