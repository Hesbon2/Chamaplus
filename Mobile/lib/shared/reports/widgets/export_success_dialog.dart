import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../components/action_button.dart';
import '../models/report_export_models.dart';

/// Shown after a successful export / download / share.
class ExportSuccessDialog extends StatelessWidget {
  const ExportSuccessDialog({
    super.key,
    required this.result,
    this.shared = false,
    this.onShareAgain,
    this.onOpenLocation,
  });

  final ReportExportResult result;
  final bool shared;
  final VoidCallback? onShareAgain;
  final VoidCallback? onOpenLocation;

  static Future<void> show(
    BuildContext context, {
    required ReportExportResult result,
    bool shared = false,
    VoidCallback? onShareAgain,
    VoidCallback? onOpenLocation,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => ExportSuccessDialog(
        result: result,
        shared: shared,
        onShareAgain: onShareAgain,
        onOpenLocation: onOpenLocation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      icon: Icon(
        Icons.check_circle_outline,
        color: theme.colorScheme.primary,
        size: 40,
      ),
      title: Text(shared ? 'Shared' : 'Export ready'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.fileName,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            result.filePath,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        if (onShareAgain != null)
          ActionButton(
            label: 'Share',
            icon: Icons.share_outlined,
            variant: ActionButtonVariant.secondary,
            expand: false,
            onPressed: () {
              Navigator.of(context).pop();
              onShareAgain!();
            },
          ),
        ActionButton(
          label: 'Done',
          expand: false,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
