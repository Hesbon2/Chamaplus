import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'app_card.dart';

/// Compact metric display with a label, primary value, and optional subtitle.
///
/// Designed for dashboards and summary grids. Stretches to fill available
/// width so it works in responsive [Row] / [GridView] layouts.
class StatCard extends StatelessWidget {
  /// Creates a statistic card.
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
    this.accentColor,
    this.onTap,
  });

  /// Short metric title (e.g. "Balance").
  final String label;

  /// Primary numeric or textual value.
  final String value;

  /// Optional supporting text under the value.
  final String? subtitle;

  /// Optional leading icon.
  final IconData? icon;

  /// Accent color for the icon container. Defaults to brand primary.
  final Color? accentColor;

  /// Optional tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentColor ?? AppColors.primary;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: AppRadius.smAll,
                  ),
                  child: Icon(icon, size: 20, color: accent),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
