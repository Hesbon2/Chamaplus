import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Modal progress indicator while a report export runs.
class ExportProgressDialog extends StatelessWidget {
  const ExportProgressDialog({
    super.key,
    required this.progress,
    this.title = 'Exporting…',
    this.message = 'Preparing your file',
  });

  /// 0.0 – 1.0
  final double progress;
  final String title;
  final String message;

  static Future<void> show(
    BuildContext context, {
    required ValueNotifier<double> progress,
    String title = 'Exporting…',
    String message = 'Preparing your file',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: ValueListenableBuilder<double>(
            valueListenable: progress,
            builder: (context, value, _) {
              return ExportProgressDialog(
                progress: value,
                title: title,
                message: message,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pct = (progress.clamp(0, 1) * 100).round();
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: AppSpacing.lg),
          LinearProgressIndicator(value: progress <= 0 ? null : progress),
          const SizedBox(height: AppSpacing.sm),
          Text('$pct%'),
        ],
      ),
    );
  }
}
