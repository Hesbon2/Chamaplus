import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../components/action_button.dart';
import '../models/report_export_models.dart';

/// Lets the user pick PDF / CSV and share vs download.
class ExportDialog extends StatefulWidget {
  const ExportDialog({
    super.key,
    this.initialFormat = ExportFormat.pdf,
    this.title = 'Export report',
    this.message = 'Choose a format and how you want to save the file.',
  });

  final ExportFormat initialFormat;
  final String title;
  final String message;

  /// Shows the dialog and returns the user choice, or null if cancelled.
  static Future<ExportDialogResult?> show(
    BuildContext context, {
    ExportFormat initialFormat = ExportFormat.pdf,
    String title = 'Export report',
    String message = 'Choose a format and how you want to save the file.',
  }) {
    return showDialog<ExportDialogResult>(
      context: context,
      builder: (context) => ExportDialog(
        initialFormat: initialFormat,
        title: title,
        message: message,
      ),
    );
  }

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class ExportDialogResult {
  const ExportDialogResult({
    required this.format,
    required this.share,
  });

  final ExportFormat format;

  /// When true, share sheet; when false, save to documents.
  final bool share;
}

class _ExportDialogState extends State<ExportDialog> {
  late ExportFormat _format;
  bool _share = true;

  @override
  void initState() {
    super.initState();
    _format = widget.initialFormat;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.message),
          const SizedBox(height: AppSpacing.md),
          Text('Format', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<ExportFormat>(
            segments: const [
              ButtonSegment(
                value: ExportFormat.pdf,
                label: Text('PDF'),
                icon: Icon(Icons.picture_as_pdf_outlined),
              ),
              ButtonSegment(
                value: ExportFormat.csv,
                label: Text('CSV'),
                icon: Icon(Icons.table_chart_outlined),
              ),
            ],
            selected: {_format},
            onSelectionChanged: (values) {
              setState(() => _format = values.first);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Share after export'),
            subtitle: Text(
              _share
                  ? 'Open the system share sheet'
                  : 'Save into app documents',
            ),
            value: _share,
            onChanged: (value) => setState(() => _share = value),
          ),
        ],
      ),
      actions: [
        ActionButton(
          label: 'Cancel',
          variant: ActionButtonVariant.text,
          expand: false,
          onPressed: () => Navigator.of(context).pop(),
        ),
        ActionButton(
          label: 'Continue',
          expand: false,
          onPressed: () {
            Navigator.of(context).pop(
              ExportDialogResult(format: _format, share: _share),
            );
          },
        ),
      ],
    );
  }
}
