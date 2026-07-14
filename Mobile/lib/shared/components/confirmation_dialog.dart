import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import 'action_button.dart';

/// Material 3 confirmation alert with cancel and confirm actions.
///
/// Returns `true` when confirm is pressed and `false` when cancelled.
class ConfirmationDialog extends StatelessWidget {
  /// Creates a confirmation dialog.
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
  });

  /// Dialog title.
  final String title;

  /// Body message.
  final String message;

  /// Confirm button label.
  final String confirmLabel;

  /// Cancel button label.
  final String cancelLabel;

  /// When true, confirm uses error styling.
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      title: Text(title),
      content: Text(message),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        ActionButton(
          label: cancelLabel,
          variant: ActionButtonVariant.text,
          expand: false,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ActionButton(
          label: confirmLabel,
          variant: ActionButtonVariant.primary,
          expand: false,
          isDestructive: isDestructive,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

/// Shows a [ConfirmationDialog] and returns the user's choice.
///
/// Returns `false` if the dialog is dismissed without a selection.
Future<bool> showAppConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => ConfirmationDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDestructive: isDestructive,
    ),
  );

  return result ?? false;
}
