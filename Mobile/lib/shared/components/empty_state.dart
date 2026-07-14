import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'action_button.dart';

/// Placeholder shown when a list or screen has no data.
///
/// Centered layout with optional icon, message, and call-to-action.
/// Prefer this shared component over feature-specific empty views.
class EmptyState extends StatelessWidget {
  /// Creates an empty-state placeholder.
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.iconSize = 56,
  });

  /// Primary empty-state headline.
  final String title;

  /// Optional supporting explanation.
  final String? message;

  /// Leading icon.
  final IconData icon;

  /// Optional CTA label.
  final String? actionLabel;

  /// CTA callback. Required when [actionLabel] is set for the button to show.
  final VoidCallback? onAction;

  /// Icon size in logical pixels.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message!,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.lg),
                ActionButton(
                  label: actionLabel!,
                  onPressed: onAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
