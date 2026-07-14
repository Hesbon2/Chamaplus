import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

/// A theme-aware surface container for grouping related content.
///
/// Supports optional padding, border, elevation, and tap handling.
/// Adapts border and background colors for light and dark themes.
class AppCard extends StatelessWidget {
  /// Creates a rounded Material 3 card.
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
    this.showBorder = true,
    this.elevation = 0,
    this.color,
  });

  /// Content rendered inside the card.
  final Widget child;

  /// Inner padding. Defaults to [AppSpacing.md].
  final EdgeInsetsGeometry? padding;

  /// Outer margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Optional tap callback; when set the card becomes interactive.
  final VoidCallback? onTap;

  /// Corner radius. Defaults to [AppRadius.lgAll].
  final BorderRadius? borderRadius;

  /// Whether to draw a subtle outline border.
  final bool showBorder;

  /// Material elevation. Prefer `0` with an outline for Material 3.
  final double elevation;

  /// Override surface color. When null, uses theme surface.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = borderRadius ?? AppRadius.lgAll;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: child,
    );

    final card = Material(
      color: color ?? theme.colorScheme.surface,
      elevation: elevation,
      shadowColor: Colors.black.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: showBorder
            ? BorderSide(color: borderColor)
            : BorderSide.none,
      ),
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: content,
            ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: card);
    }
    return card;
  }
}
