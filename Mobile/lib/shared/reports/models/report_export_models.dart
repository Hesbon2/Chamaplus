import 'dart:typed_data';

/// Supported export formats for analytics / reports.
enum ExportFormat {
  pdf,
  csv;

  String get label {
    switch (this) {
      case ExportFormat.pdf:
        return 'PDF';
      case ExportFormat.csv:
        return 'CSV';
    }
  }

  String get extension {
    switch (this) {
      case ExportFormat.pdf:
        return 'pdf';
      case ExportFormat.csv:
        return 'csv';
    }
  }

  String get mimeType {
    switch (this) {
      case ExportFormat.pdf:
        return 'application/pdf';
      case ExportFormat.csv:
        return 'text/csv';
    }
  }
}

/// A single table column definition for tabular exports.
class ReportColumn {
  const ReportColumn({
    required this.key,
    required this.label,
  });

  final String key;
  final String label;
}

/// Generic export payload reusable by every future report module.
class ReportExportRequest {
  const ReportExportRequest({
    required this.title,
    required this.fileName,
    required this.format,
    this.subtitle,
    this.columns = const [],
    this.rows = const [],
    this.summary = const {},
    this.generatedAt,
  });

  /// Document / share title.
  final String title;

  /// Base file name without extension.
  final String fileName;

  final ExportFormat format;
  final String? subtitle;

  /// Ordered columns for CSV / PDF tables.
  final List<ReportColumn> columns;

  /// Each row maps column [ReportColumn.key] → display value.
  final List<Map<String, String>> rows;

  /// Optional key/value summary block (PDF header / CSV preamble).
  final Map<String, String> summary;

  final DateTime? generatedAt;
}

/// Result of a successful export write.
class ReportExportResult {
  const ReportExportResult({
    required this.filePath,
    required this.format,
    required this.bytes,
    required this.fileName,
  });

  final String filePath;
  final ExportFormat format;
  final Uint8List bytes;
  final String fileName;
}

/// Progress callback: 0.0 → 1.0.
typedef ExportProgressCallback = void Function(double progress);
