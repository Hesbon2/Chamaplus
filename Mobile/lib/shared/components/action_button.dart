import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Visual style variants for [ActionButton].
enum ActionButtonVariant {
  /// Filled elevated button (primary actions).
  primary,

  /// Outlined button (secondary actions).
  secondary,

  /// Text-only button (tertiary actions).
  text,
}

/// Configurable Material 3 action button with loading support.
///
/// Prefer this shared button over ad-hoc [ElevatedButton] usage in features.
class ActionButton extends StatelessWidget {
  /// Creates an action button.
  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ActionButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.expand = true,
    this.isDestructive = false,
  });

  /// Button label.
  final String label;

  /// Press callback. Ignored while [isLoading] is true.
  final VoidCallback? onPressed;

  /// Visual variant.
  final ActionButtonVariant variant;

  /// Shows a progress indicator and disables interaction.
  final bool isLoading;

  /// Optional leading icon.
  final IconData? icon;

  /// When true, expands to parent width.
  final bool expand;

  /// Uses error coloration for destructive confirmations.
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = isDestructive ? theme.colorScheme.error : null;

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == ActionButtonVariant.primary && !isDestructive
                  ? theme.colorScheme.onPrimary
                  : foreground ?? theme.colorScheme.primary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    final button = switch (variant) {
      ActionButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: isDestructive
              ? ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                )
              : null,
          child: child,
        ),
      ActionButtonVariant.secondary => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: foreground == null
              ? null
              : OutlinedButton.styleFrom(foregroundColor: foreground),
          child: child,
        ),
      ActionButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: foreground == null
              ? null
              : TextButton.styleFrom(foregroundColor: foreground),
          child: child,
        ),
    };

    if (!expand) return button;

    return SizedBox(width: double.infinity, child: button);
  }
}
