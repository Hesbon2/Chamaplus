import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/file_share_service.dart';
import '../services/report_export_service.dart';

final fileShareServiceProvider = Provider<FileShareService>((ref) {
  return const FileShareService();
});

final reportExportServiceProvider = Provider<ReportExportService>((ref) {
  return ReportExportService(
    fileShareService: ref.watch(fileShareServiceProvider),
  );
});
