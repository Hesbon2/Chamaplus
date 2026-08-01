import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'app_card.dart';

/// Direction of a KPI trend arrow.
enum MetricTrend {
  up,
  down,
  flat,
}

/// Generic summary KPI tile for dashboards and reports.
///
/// Reusable across features — pass display values only; no domain logic.
class SummaryMetricTile extends StatelessWidget {
  const SummaryMetricTile({
    super.key,
    required this.title,
    required this.value,
    this.trend,
    this.percentage,
    this.icon,
    this.footer,
    this.accentColor,
    this.onTap,
    this.subtitle,
  });

  final String title;
  final String value;

  /// Optional trend indicator (up / down / flat).
  final MetricTrend? trend;

  /// Optional percentage shown beside the trend (0–100 or delta).
  final double? percentage;

  final IconData? icon;
  final Widget? footer;
  final Color? accentColor;
  final VoidCallback? onTap;

  /// Optional secondary line under the value (legacy subtitle support).
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentColor ?? AppColors.primary;

    return Semantics(
      label: '$title, $value',
      child: AppCard(
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
                    title,
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
            ),
            if (trend != null || percentage != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  if (trend != null) ...[
                    Icon(
                      switch (trend!) {
                        MetricTrend.up => Icons.trending_up,
                        MetricTrend.down => Icons.trending_down,
                        MetricTrend.flat => Icons.trending_flat,
                      },
                      size: 18,
                      color: switch (trend!) {
                        MetricTrend.up => AppColors.success,
                        MetricTrend.down => AppColors.error,
                        MetricTrend.flat => theme.colorScheme.onSurfaceVariant,
                      },
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                  ],
                  if (percentage != null)
                    Text(
                      '${percentage! >= 0 ? '+' : ''}${percentage!.toStringAsFixed(1)}%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(subtitle!, style: theme.textTheme.bodySmall),
            ],
            if (footer != null) ...[
              const SizedBox(height: AppSpacing.sm),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
