import 'package:flutter/foundation.dart';

/// Lightweight logger that never prints secrets outside debug builds.
class AppLogger {
  AppLogger._();

  static final _secretPattern = RegExp(
    r'(Bearer\s+)\S+|(access|refresh|password|token)["\s:=]+[^\s,"}]+',
    caseSensitive: false,
  );

  static String _redact(String message) {
    return message.replaceAllMapped(_secretPattern, (match) {
      if (match.group(1) != null) {
        return '${match.group(1)}***';
      }
      return '***';
    });
  }

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('[ChamaPlus] ${_redact(message)}');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ChamaPlus][ERROR] ${_redact(message)}');
      if (error != null) {
        debugPrint(_redact(error.toString()));
      }
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }
}
