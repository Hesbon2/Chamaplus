import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../utils/logger.dart';

/// Debug-only request/response logger that redacts Authorization and secrets.
class DebugLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.debug(
        '→ ${options.method} ${options.uri} '
        'headers=${_safeHeaders(options.headers)}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      AppLogger.debug(
        '← ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.debug(
        '✖ ${err.response?.statusCode ?? err.type} '
        '${err.requestOptions.method} ${err.requestOptions.uri}',
      );
    }
    handler.next(err);
  }

  Map<String, dynamic> _safeHeaders(Map<String, dynamic> headers) {
    final copy = Map<String, dynamic>.from(headers);
    for (final key in copy.keys.toList()) {
      final lower = key.toLowerCase();
      if (lower == ApiConstants.authorizationHeader.toLowerCase() ||
          lower.contains('token') ||
          lower.contains('cookie') ||
          lower.contains('password')) {
        copy[key] = '***';
      }
    }
    return copy;
  }
}
