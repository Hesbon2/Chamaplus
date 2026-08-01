import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../components/app_card.dart';
import '../../components/status_chip.dart';

/// Summary tile for a report type on future Reports screens.
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.assessment_outlined,
    this.badgeLabel,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String? badgeLabel;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            child: Icon(icon),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (badgeLabel != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  StatusChip(
                    label: badgeLabel!,
                    tone: StatusChipTone.info,
                    compact: true,
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
    );
  }
}
