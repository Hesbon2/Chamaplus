import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Horizontal section title with an optional trailing action.
///
/// Use above lists, grids, or card groups to label a content region.
class SectionHeader extends StatelessWidget {
  /// Creates a section header row.
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.padding,
  });

  /// Primary section title.
  final String title;

  /// Optional secondary description under the title.
  final String? subtitle;

  /// Optional trailing action label (e.g. "See all").
  final String? actionLabel;

  /// Callback invoked when [actionLabel] is tapped.
  final VoidCallback? onAction;

  /// Outer padding. Defaults to vertical [AppSpacing.sm].
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}
