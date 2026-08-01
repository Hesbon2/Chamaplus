import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Cross-platform file share / local save helpers for report exports.
class FileShareService {
  const FileShareService();

  /// Writes [bytes] under the temp directory and returns the absolute path.
  Future<String> writeTempFile({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final dir = await getTemporaryDirectory();
    final safeName = fileName.replaceAll(RegExp(r'[^\w.\-]+'), '_');
    final path = p.join(dir.path, safeName);
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Persists under app documents (acts as "download" on mobile).
  Future<String> saveToDocuments({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final exports = Directory(p.join(dir.path, 'exports'));
    if (!await exports.exists()) {
      await exports.create(recursive: true);
    }
    final safeName = fileName.replaceAll(RegExp(r'[^\w.\-]+'), '_');
    final path = p.join(exports.path, safeName);
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Opens the platform share sheet for [filePath].
  Future<ShareResult> shareFile({
    required String filePath,
    String? subject,
    String? text,
  }) {
    return Share.shareXFiles(
      [XFile(filePath)],
      subject: subject,
      text: text,
    );
  }

  /// Convenience: write temp + share.
  Future<ShareResult> shareBytes({
    required String fileName,
    required Uint8List bytes,
    String? subject,
    String? text,
  }) async {
    final path = await writeTempFile(fileName: fileName, bytes: bytes);
    return shareFile(filePath: path, subject: subject, text: text);
  }
}
