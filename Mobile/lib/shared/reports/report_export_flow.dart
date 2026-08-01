import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/report_export_models.dart';
import 'providers/report_export_providers.dart';
import 'services/report_export_service.dart';
import 'widgets/export_dialog.dart';
import 'widgets/export_progress_dialog.dart';
import 'widgets/export_success_dialog.dart';

/// Runs the standard export dialog → progress → success flow.
///
/// Future report screens should call this instead of re-implementing UI.
Future<ReportExportResult?> runReportExportFlow(
  BuildContext context,
  WidgetRef ref, {
  required ReportExportRequest Function(ExportFormat format) buildRequest,
}) async {
  final choice = await ExportDialog.show(context);
  if (choice == null || !context.mounted) return null;

  final progress = ValueNotifier<double>(0);
  // ignore: unawaited_futures
  ExportProgressDialog.show(context, progress: progress);

  final service = ref.read(reportExportServiceProvider);
  final request = buildRequest(choice.format);

  try {
    final result = choice.share
        ? await service.exportAndShare(
            request: request,
            onProgress: (p) => progress.value = p,
          )
        : await service.exportAndDownload(
            request: request,
            onProgress: (p) => progress.value = p,
          );

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // progress
      await ExportSuccessDialog.show(
        context,
        result: result,
        shared: choice.share,
        onShareAgain: () {
          ref.read(fileShareServiceProvider).shareFile(
                filePath: result.filePath,
                subject: request.title,
              );
        },
      );
    }
    return result;
  } on ReportExportException catch (error) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export failed'),
          content: Text(error.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    return null;
  } catch (error) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export failed'),
          content: Text('$error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    return null;
  } finally {
    progress.dispose();
  }
}
