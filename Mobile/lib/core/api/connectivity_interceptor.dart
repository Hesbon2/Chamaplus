import 'package:dio/dio.dart';

import '../errors/app_exception.dart';
import '../services/connectivity_service.dart';

/// Fails fast with [NetworkException] when the device reports no connectivity.
///
/// Offline GET fallback is handled by [OfflineCacheInterceptor].
class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor(this._connectivity);

  final ConnectivityService _connectivity;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final online = await _connectivity.hasConnection();
    options.extra['wasOnline'] = online;
    if (!online) {
      // Let the offline cache interceptor resolve GETs; block writes early.
      final method = options.method.toUpperCase();
      if (method != 'GET' && method != 'HEAD') {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: const NetworkException(),
            message: 'No internet connection. Please check your network.',
          ),
        );
        return;
      }
    }
    handler.next(options);
  }
}
