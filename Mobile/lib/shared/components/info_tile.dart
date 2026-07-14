import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// A list-style row with leading, title, subtitle, and optional trailing.
///
/// Suitable for settings rows, profile fields, and generic detail lines.
/// Theme text styles keep light/dark modes consistent.
class InfoTile extends StatelessWidget {
  /// Creates an informational list tile.
  const InfoTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.dense = false,
    this.contentPadding,
  });

  /// Primary line of text.
  final String title;

  /// Optional secondary line of text.
  final String? subtitle;

  /// Optional leading widget (icon, avatar, etc.).
  final Widget? leading;

  /// Optional trailing widget (chevron, switch, value).
  final Widget? trailing;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Compact vertical density.
  final bool dense;

  /// Override content padding.
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: dense,
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
      leading: leading,
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: theme.textTheme.bodyMedium),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
