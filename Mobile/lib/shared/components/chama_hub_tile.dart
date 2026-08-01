import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'app_card.dart';
import 'avatar_badge.dart';

/// Shared chama picker tile used by Loans / Contributions / Meetings / Reports hubs.
class ChamaHubTile extends StatelessWidget {
  const ChamaHubTile({
    super.key,
    required this.name,
    required this.subtitle,
    required this.onTap,
    this.icon = Icons.groups_outlined,
  });

  final String name;
  final String subtitle;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: '$name. $subtitle',
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            AvatarBadge(
              initials: name.isNotEmpty ? name[0] : 'C',
              icon: icon,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleMedium),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
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
