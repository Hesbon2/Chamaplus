import 'dart:typed_data';

import 'package:chamaplus_mobile/shared/reports/models/report_export_models.dart';
import 'package:chamaplus_mobile/shared/reports/services/file_share_service.dart';
import 'package:chamaplus_mobile/shared/reports/services/report_export_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

class FakeFileShareService extends FileShareService {
  FakeFileShareService();

  Uint8List? lastBytes;
  String? lastName;
  String? lastDocumentsName;
  int shareCalls = 0;

  @override
  Future<String> writeTempFile({
    required String fileName,
    required Uint8List bytes,
  }) async {
    lastName = fileName;
    lastBytes = bytes;
    return '/tmp/$fileName';
  }

  @override
  Future<String> saveToDocuments({
    required String fileName,
    required Uint8List bytes,
  }) async {
    lastDocumentsName = fileName;
    lastBytes = bytes;
    return '/docs/exports/$fileName';
  }

  @override
  Future<ShareResult> shareFile({
    required String filePath,
    String? subject,
    String? text,
  }) async {
    shareCalls++;
    return ShareResult(filePath, ShareResultStatus.success);
  }
}

void main() {
  late FakeFileShareService files;
  late ReportExportService service;

  setUp(() {
    files = FakeFileShareService();
    service = ReportExportService(fileShareService: files);
  });

  ReportExportRequest _request(ExportFormat format) {
    return ReportExportRequest(
      title: 'Monthly contributions',
      subtitle: 'Umoja Chama',
      fileName: 'umoja_contributions',
      format: format,
      summary: const {'Members': '12', 'Total': 'KES 45,000'},
      columns: const [
        ReportColumn(key: 'member', label: 'Member'),
        ReportColumn(key: 'amount', label: 'Amount'),
      ],
      rows: const [
        {'member': 'Amina', 'amount': '2000'},
        {'member': 'John', 'amount': '1500'},
      ],
      generatedAt: DateTime(2026, 8, 1, 10, 30),
    );
  }

  test('export CSV writes UTF-8 table with headers', () async {
    final result = await service.export(
      request: _request(ExportFormat.csv),
      onProgress: (p) => expect(p, inInclusiveRange(0, 1)),
    );

    expect(result.format, ExportFormat.csv);
    expect(result.fileName, 'umoja_contributions.csv');
    expect(files.lastName, 'umoja_contributions.csv');

    final csv = String.fromCharCodes(result.bytes);
    expect(csv, contains('Monthly contributions'));
    expect(csv, contains('Member,Amount'));
    expect(csv, contains('Amina,2000'));
    expect(csv, contains('John,1500'));
  });

  test('export PDF produces non-empty bytes', () async {
    final result = await service.export(request: _request(ExportFormat.pdf));
    expect(result.format, ExportFormat.pdf);
    expect(result.bytes.length, greaterThan(100));
    expect(result.fileName, endsWith('.pdf'));
  });

  test('exportAndDownload saves under documents path', () async {
    final result = await service.exportAndDownload(
      request: _request(ExportFormat.csv),
    );
    expect(files.lastDocumentsName, 'umoja_contributions.csv');
    expect(result.filePath, contains('/docs/exports/'));
  });

  test('exportAndShare invokes share sheet', () async {
    await service.exportAndShare(request: _request(ExportFormat.csv));
    expect(files.shareCalls, 1);
  });

  test('CSV escapes commas and quotes', () async {
    final result = await service.export(
      request: ReportExportRequest(
        title: 'Escapes',
        fileName: 'escapes',
        format: ExportFormat.csv,
        columns: const [ReportColumn(key: 'n', label: 'Name')],
        rows: const [
          {'n': 'Amina, "Treasurer"'},
        ],
      ),
    );
    final csv = String.fromCharCodes(result.bytes);
    expect(csv, contains('"Amina, ""Treasurer"""'));
  });
}
