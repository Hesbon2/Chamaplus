import 'dart:math';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../utils/logger.dart';

/// Retries transient failures for safe (idempotent) requests.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this._dio, {
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 400),
  });

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;
  final _random = Random();

  static const _retryableStatuses = {408, 425, 429, 500, 502, 503, 504};

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra[ApiConstants.retryAttemptKey] as int?) ?? 0;
    final skipRetry = options.extra[ApiConstants.skipRetryKey] == true;

    if (skipRetry || attempt >= maxRetries || !_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final nextAttempt = attempt + 1;
    options.extra[ApiConstants.retryAttemptKey] = nextAttempt;

    final delay = baseDelay * (1 << (nextAttempt - 1)) +
        Duration(milliseconds: _random.nextInt(120));
    AppLogger.debug(
      'Retry $nextAttempt/$maxRetries ${options.method} ${options.path} '
      'after ${delay.inMilliseconds}ms',
    );
    await Future<void>.delayed(delay);

    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    final method = err.requestOptions.method.toUpperCase();
    if (method != 'GET' && method != 'HEAD' && method != 'OPTIONS') {
      return false;
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final code = err.response?.statusCode;
        return code != null && _retryableStatuses.contains(code);
      default:
        return false;
    }
  }
}
