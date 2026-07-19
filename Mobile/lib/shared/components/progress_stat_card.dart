import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'app_card.dart';

/// Generic progress / percentage card for dashboards and detail screens.
///
/// Display any goal-style metric (loans, contributions, savings, attendance).
/// Pass either [percentage] directly, or [currentValue] + [targetValue] to
/// derive it. Contains no feature-specific business logic.
class ProgressStatCard extends StatelessWidget {
  /// Creates a progress statistic card.
  const ProgressStatCard({
    super.key,
    required this.title,
    this.subtitle,
    this.currentValue,
    this.targetValue,
    this.percentage,
    this.progressColor,
    this.icon,
    this.footer,
    this.onTap,
  }) : assert(
          percentage != null || (currentValue != null && targetValue != null),
          'Provide percentage, or both currentValue and targetValue.',
        );

  /// Primary label (e.g. "Outstanding Loan").
  final String title;

  /// Optional supporting text under the title.
  final String? subtitle;

  /// Optional formatted current value shown prominently (e.g. "KES 45,000").
  final String? currentValue;

  /// Optional formatted target / total value (e.g. "of KES 70,000").
  final String? targetValue;

  /// Progress from 0–100. When null, derived from numeric parsing of
  /// [currentValue] / [targetValue] if both look numeric; otherwise 0.
  final double? percentage;

  /// Bar / accent color. Defaults to brand primary.
  final Color? progressColor;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional footer widget below the progress bar.
  final Widget? footer;

  /// Optional tap handler.
  final VoidCallback? onTap;

  double get _resolvedPercentage {
    if (percentage != null) {
      return percentage!.clamp(0, 100);
    }
    final current = _parseNumber(currentValue);
    final target = _parseNumber(targetValue);
    if (current == null || target == null || target <= 0) {
      return 0;
    }
    return ((current / target) * 100).clamp(0, 100);
  }

  static double? _parseNumber(String? raw) {
    if (raw == null) return null;
    final cleaned = raw.replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(cleaned);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = progressColor ?? AppColors.primary;
    final pct = _resolvedPercentage;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '${pct.toStringAsFixed(pct == pct.roundToDouble() ? 0 : 1)}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ],
          ),
          if (currentValue != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              currentValue!,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (targetValue != null)
              Text(
                targetValue!,
                style: theme.textTheme.bodySmall,
              ),
          ],
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadius.smAll,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct / 100),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: accent.withOpacity(0.12),
                  color: accent,
                );
              },
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.sm),
            footer!,
          ],
        ],
      ),
    );
  }
}
