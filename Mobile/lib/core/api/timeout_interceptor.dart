import 'package:dio/dio.dart';

import '../config/env_config.dart';

/// Ensures connect/receive/send timeouts are present on every request.
///
/// Primary timeouts come from [BaseOptions]; this interceptor fills gaps when
/// a caller overrides [Options] without timeouts.
class TimeoutInterceptor extends Interceptor {
  TimeoutInterceptor({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  })  : _connectTimeout =
            connectTimeout ?? Duration(milliseconds: EnvConfig.connectTimeoutMs),
        _receiveTimeout =
            receiveTimeout ?? Duration(milliseconds: EnvConfig.receiveTimeoutMs),
        _sendTimeout =
            sendTimeout ?? Duration(milliseconds: EnvConfig.connectTimeoutMs);

  final Duration _connectTimeout;
  final Duration _receiveTimeout;
  final Duration _sendTimeout;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.connectTimeout ??= _connectTimeout;
    options.receiveTimeout ??= _receiveTimeout;
    options.sendTimeout ??= _sendTimeout;
    handler.next(options);
  }
}
