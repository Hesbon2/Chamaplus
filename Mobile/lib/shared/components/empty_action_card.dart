import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'action_button.dart';
import 'app_card.dart';

/// Card that guides the user from an empty module state into a primary action.
///
/// Prefer this over ad-hoc empty CTAs when a feature has no data yet.
class EmptyActionCard extends StatelessWidget {
  /// Creates an empty-state action card.
  const EmptyActionCard({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.icon = Icons.inbox_outlined,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.iconSize = 40,
  });

  /// Headline describing the empty state.
  final String title;

  /// Supporting copy that explains what to do next.
  final String message;

  /// Primary CTA label.
  final String actionLabel;

  /// Primary CTA callback.
  final VoidCallback onAction;

  /// Leading icon.
  final IconData icon;

  /// Optional secondary CTA label.
  final String? secondaryActionLabel;

  /// Optional secondary CTA callback.
  final VoidCallback? onSecondaryAction;

  /// Icon size in logical pixels.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ActionButton(
            label: actionLabel,
            onPressed: onAction,
            icon: Icons.arrow_forward,
          ),
          if (secondaryActionLabel != null && onSecondaryAction != null) ...[
            const SizedBox(height: AppSpacing.sm),
            ActionButton(
              label: secondaryActionLabel!,
              onPressed: onSecondaryAction,
              variant: ActionButtonVariant.secondary,
            ),
          ],
        ],
      ),
    );
  }
}
