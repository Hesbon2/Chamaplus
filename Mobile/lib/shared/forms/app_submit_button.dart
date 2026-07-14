import 'package:flutter/material.dart';

import '../components/action_button.dart';

/// Primary form submit control with loading and optional form validation.
///
/// When [formKey] is provided, taps validate the form first and only invoke
/// [onSubmit] when validation succeeds.
class AppSubmitButton extends StatelessWidget {
  /// Creates a submit button.
  const AppSubmitButton({
    super.key,
    required this.label,
    required this.onSubmit,
    this.formKey,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.expand = true,
    this.variant = ActionButtonVariant.primary,
  });

  /// Button label.
  final String label;

  /// Called after optional validation succeeds.
  final VoidCallback? onSubmit;

  /// When set, [FormState.validate] runs before [onSubmit].
  final GlobalKey<FormState>? formKey;

  /// Shows a progress indicator and blocks presses.
  final bool isLoading;

  /// When false, the button is disabled.
  final bool enabled;

  /// Optional leading icon.
  final IconData? icon;

  /// Stretch to parent width.
  final bool expand;

  /// Visual style forwarded to [ActionButton].
  final ActionButtonVariant variant;

  void _handlePress() {
    if (isLoading || !enabled || onSubmit == null) return;
    if (formKey != null) {
      final isValid = formKey!.currentState?.validate() ?? false;
      if (!isValid) return;
      formKey!.currentState?.save();
    }
    onSubmit!();
  }

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      label: label,
      icon: icon,
      variant: variant,
      isLoading: isLoading,
      expand: expand,
      onPressed: enabled && !isLoading ? _handlePress : null,
    );
  }
}
