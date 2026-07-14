import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Circular avatar with optional badge overlay (count or status dot).
///
/// Displays initials when [imageUrl] is null, or an optional [icon].
/// Theme-aware background uses brand primary with adjusted opacity.
class AvatarBadge extends StatelessWidget {
  /// Creates an avatar with an optional notification badge.
  const AvatarBadge({
    super.key,
    this.initials,
    this.imageUrl,
    this.icon,
    this.size = 48,
    this.badgeCount,
    this.showDot = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Initials shown when no image or icon is provided (e.g. "JD").
  final String? initials;

  /// Optional remote image URL.
  final String? imageUrl;

  /// Optional icon when initials/image are not used.
  final IconData? icon;

  /// Avatar diameter.
  final double size;

  /// Optional numeric badge shown at the top-right.
  final int? badgeCount;

  /// When true and [badgeCount] is null, shows a status dot.
  final bool showDot;

  /// Override background color.
  final Color? backgroundColor;

  /// Override foreground (initials/icon) color.
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? AppColors.primary.withOpacity(0.15);
    final fg = foregroundColor ??
        (theme.brightness == Brightness.dark
            ? AppColors.primaryLight
            : AppColors.primary);

    return SizedBox(
      width: size + AppSpacing.xs,
      height: size + AppSpacing.xs,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: CircleAvatar(
              radius: size / 2,
              backgroundColor: bg,
              backgroundImage:
                  imageUrl != null ? NetworkImage(imageUrl!) : null,
              child: imageUrl != null
                  ? null
                  : icon != null
                      ? Icon(icon, color: fg, size: size * 0.45)
                      : Text(
                          _displayInitials,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w700,
                            fontSize: size * 0.32,
                          ),
                        ),
            ),
          ),
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              top: 0,
              right: 0,
              child: _Badge(
                label: badgeCount! > 99 ? '99+' : '$badgeCount',
              ),
            )
          else if (showDot)
            Positioned(
              top: AppSpacing.xxs,
              right: AppSpacing.xxs,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String get _displayInitials {
    final value = initials?.trim() ?? '';
    if (value.isEmpty) return '?';
    return value.length <= 2 ? value.toUpperCase() : value.substring(0, 2).toUpperCase();
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.surface),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
