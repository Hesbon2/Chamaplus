import 'package:flutter/services.dart';

/// Clipboard helpers that avoid silently copying secrets.
class SafeClipboard {
  SafeClipboard._();

  /// Copies [text] when it does not look like a credential.
  static Future<bool> copyPublicText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    final lower = trimmed.toLowerCase();
    if (lower.startsWith('eyj') || // JWT
        lower.contains('bearer ') ||
        lower.contains('password') ||
        (trimmed.length > 80 && !trimmed.contains(' '))) {
      return false;
    }
    await Clipboard.setData(ClipboardData(text: trimmed));
    return true;
  }
}
