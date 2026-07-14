import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

/// Semantic tone used by [StatusChip].
enum StatusChipTone {
  /// Neutral / default state.
  neutral,

  /// Positive / completed state.
  success,

  /// Caution / pending state.
  warning,

  /// Negative / failed state.
  error,

  /// Informational state.
  info,
}

/// Compact colored label for statuses and tags.
///
/// Colors adapt slightly by theme brightness while remaining readable.
class StatusChip extends StatelessWidget {
  /// Creates a status chip.
  const StatusChip({
    super.key,
    required this.label,
    this.tone = StatusChipTone.neutral,
    this.icon,
    this.compact = false,
  });

  /// Chip text.
  final String label;

  /// Semantic color tone.
  final StatusChipTone tone;

  /// Optional leading icon.
  final IconData? icon;

  /// When true, uses tighter padding.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _colorsForTone(tone, isDark);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
        vertical: compact ? AppSpacing.xxs : 6,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: colors.foreground),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: TextStyle(
              color: colors.foreground,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  ({Color background, Color foreground}) _colorsForTone(
    StatusChipTone tone,
    bool isDark,
  ) {
    switch (tone) {
      case StatusChipTone.success:
        return (
          background: AppColors.success.withOpacity(isDark ? 0.25 : 0.12),
          foreground: isDark ? const Color(0xFF81C784) : AppColors.success,
        );
      case StatusChipTone.warning:
        return (
          background: AppColors.warning.withOpacity(isDark ? 0.25 : 0.12),
          foreground: isDark ? const Color(0xFFFFB74D) : AppColors.warning,
        );
      case StatusChipTone.error:
        return (
          background: AppColors.error.withOpacity(isDark ? 0.25 : 0.12),
          foreground: isDark ? const Color(0xFFEF9A9A) : AppColors.error,
        );
      case StatusChipTone.info:
        return (
          background: AppColors.info.withOpacity(isDark ? 0.25 : 0.12),
          foreground: isDark ? const Color(0xFF4FC3F7) : AppColors.info,
        );
      case StatusChipTone.neutral:
        return (
          background: isDark
              ? AppColors.borderDark.withOpacity(0.5)
              : AppColors.borderLight,
          foreground: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        );
    }
  }
}
