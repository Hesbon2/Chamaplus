import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'app_card.dart';

/// A single step in a [TimelineCard].
class TimelineStep {
  /// Creates a timeline step.
  const TimelineStep({
    required this.title,
    this.subtitle,
    this.timestamp,
    this.icon,
    this.isCompleted = false,
    this.isActive = false,
    this.tone,
  });

  /// Primary step label.
  final String title;

  /// Optional supporting text.
  final String? subtitle;

  /// Optional time / date label shown on the trailing side.
  final String? timestamp;

  /// Optional leading icon (defaults by state).
  final IconData? icon;

  /// Whether this step is finished.
  final bool isCompleted;

  /// Whether this is the current step.
  final bool isActive;

  /// Optional accent override.
  final Color? tone;
}

/// Generic vertical timeline card for status / history sequences.
///
/// Reusable across meetings, loans, contributions, notifications, and audit.
/// Contains no feature-specific business logic.
class TimelineCard extends StatelessWidget {
  /// Creates a timeline card.
  const TimelineCard({
    super.key,
    required this.steps,
    this.title,
    this.subtitle,
    this.onTap,
    this.padding,
  });

  /// Ordered timeline steps (top → bottom).
  final List<TimelineStep> steps;

  /// Optional card header title.
  final String? title;

  /// Optional card header subtitle.
  final String? subtitle;

  /// Optional tap on the whole card.
  final VoidCallback? onTap;

  /// Inner padding. Defaults to [AppSpacing.md].
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(subtitle!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: AppSpacing.md),
          ],
          for (var i = 0; i < steps.length; i++) ...[
            _TimelineRow(
              step: steps[i],
              isLast: i == steps.length - 1,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.step,
    required this.isLast,
    required this.isDark,
  });

  final TimelineStep step;
  final bool isLast;
  final bool isDark;

  Color get _accent {
    if (step.tone != null) return step.tone!;
    if (step.isCompleted) return AppColors.success;
    if (step.isActive) return AppColors.primary;
    return isDark ? AppColors.borderDark : AppColors.borderLight;
  }

  IconData get _icon {
    if (step.icon != null) return step.icon!;
    if (step.isCompleted) return Icons.check_circle;
    if (step.isActive) return Icons.radio_button_checked;
    return Icons.radio_button_unchecked;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _accent;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.85, end: 1),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Icon(_icon, size: 22, color: accent),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(step.isCompleted ? 0.55 : 0.25),
                        borderRadius: AppRadius.smAll,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          step.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: step.isActive || step.isCompleted
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: step.isActive || step.isCompleted
                                ? null
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (step.timestamp != null)
                        Text(
                          step.timestamp!,
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                  if (step.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      step.subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
