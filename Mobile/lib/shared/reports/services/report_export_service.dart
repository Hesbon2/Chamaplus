import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/report_export_models.dart';
import 'file_share_service.dart';

/// Generates PDF / CSV report files and optionally shares them.
///
/// Designed to be reused by every future report feature — pass a
/// [ReportExportRequest]; do not embed feature-specific logic here.
class ReportExportService {
  ReportExportService({
    FileShareService? fileShareService,
  }) : _files = fileShareService ?? const FileShareService();

  final FileShareService _files;

  /// Builds the export bytes, writes a temp file, and reports progress.
  Future<ReportExportResult> export({
    required ReportExportRequest request,
    ExportProgressCallback? onProgress,
  }) async {
    try {
      onProgress?.call(0.05);
      final bytes = switch (request.format) {
        ExportFormat.pdf => await _buildPdf(request, onProgress),
        ExportFormat.csv => _buildCsv(request, onProgress),
      };
      onProgress?.call(0.85);

      final fullName = '${request.fileName}.${request.format.extension}';
      final path = await _files.writeTempFile(
        fileName: fullName,
        bytes: bytes,
      );
      onProgress?.call(1.0);

      return ReportExportResult(
        filePath: path,
        format: request.format,
        bytes: bytes,
        fileName: fullName,
      );
    } catch (error, stack) {
      Error.throwWithStackTrace(
        ReportExportException('Export failed: $error'),
        stack,
      );
    }
  }

  /// Export then open the share sheet.
  Future<ReportExportResult> exportAndShare({
    required ReportExportRequest request,
    ExportProgressCallback? onProgress,
  }) async {
    final result = await export(request: request, onProgress: onProgress);
    await _files.shareFile(
      filePath: result.filePath,
      subject: request.title,
      text: request.subtitle,
    );
    return result;
  }

  /// Export then persist under app documents ("download").
  Future<ReportExportResult> exportAndDownload({
    required ReportExportRequest request,
    ExportProgressCallback? onProgress,
  }) async {
    final result = await export(request: request, onProgress: onProgress);
    final saved = await _files.saveToDocuments(
      fileName: result.fileName,
      bytes: result.bytes,
    );
    return ReportExportResult(
      filePath: saved,
      format: result.format,
      bytes: result.bytes,
      fileName: result.fileName,
    );
  }

  Uint8List _buildCsv(
    ReportExportRequest request,
    ExportProgressCallback? onProgress,
  ) {
    onProgress?.call(0.2);
    final buffer = StringBuffer();
    buffer.writeln('# ${request.title}');
    if (request.subtitle != null && request.subtitle!.isNotEmpty) {
      buffer.writeln('# ${request.subtitle}');
    }
    final stamp = request.generatedAt ?? DateTime.now();
    buffer.writeln(
      '# Generated: ${DateFormat.yMMMd().add_jm().format(stamp.toLocal())}',
    );

    if (request.summary.isNotEmpty) {
      buffer.writeln('# Summary');
      request.summary.forEach((key, value) {
        buffer.writeln('# $key,$value');
      });
    }

    if (request.columns.isNotEmpty) {
      buffer.writeln(request.columns.map((c) => _csvEscape(c.label)).join(','));
      onProgress?.call(0.45);
      for (var i = 0; i < request.rows.length; i++) {
        final row = request.rows[i];
        buffer.writeln(
          request.columns
              .map((c) => _csvEscape(row[c.key] ?? ''))
              .join(','),
        );
        if (i % 25 == 0) {
          final t = 0.45 + (0.35 * (i + 1) / request.rows.length);
          onProgress?.call(t.clamp(0.45, 0.8));
        }
      }
    }
    onProgress?.call(0.8);
    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

  Future<Uint8List> _buildPdf(
    ReportExportRequest request,
    ExportProgressCallback? onProgress,
  ) async {
    onProgress?.call(0.15);
    final doc = pw.Document();
    final stamp = request.generatedAt ?? DateTime.now();
    final stampLabel =
        DateFormat.yMMMd().add_jm().format(stamp.toLocal());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          onProgress?.call(0.4);
          return [
            pw.Text(
              request.title,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            if (request.subtitle != null && request.subtitle!.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                request.subtitle!,
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
            ],
            pw.SizedBox(height: 4),
            pw.Text(
              'Generated $stampLabel',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
            if (request.summary.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text(
                'Summary',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              ...request.summary.entries.map(
                (e) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(e.key),
                      pw.Text(e.value),
                    ],
                  ),
                ),
              ),
            ],
            if (request.columns.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: request.columns.map((c) => c.label).toList(),
                data: request.rows
                    .map(
                      (row) => request.columns
                          .map((c) => row[c.key] ?? '')
                          .toList(),
                    )
                    .toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.green800,
                ),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignment: pw.Alignment.centerLeft,
                headerAlignment: pw.Alignment.centerLeft,
              ),
            ],
          ];
        },
      ),
    );

    onProgress?.call(0.7);
    final bytes = await doc.save();
    onProgress?.call(0.8);
    return Uint8List.fromList(bytes);
  }

  String _csvEscape(String raw) {
    if (raw.contains(',') || raw.contains('"') || raw.contains('\n')) {
      return '"${raw.replaceAll('"', '""')}"';
    }
    return raw;
  }
}

/// Thrown when PDF/CSV generation or file IO fails.
class ReportExportException implements Exception {
  ReportExportException(this.message);
  final String message;

  @override
  String toString() => message;
}
