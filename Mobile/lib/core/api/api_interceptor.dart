import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

/// Attaches auth headers and normalizes outgoing API requests.
class ApiInterceptor extends Interceptor {
  ApiInterceptor(this._secureStorage);

  final SecureStorageService _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.putIfAbsent(
      Headers.contentTypeHeader,
      () => ApiConstants.contentTypeJson,
    );
    options.headers.putIfAbsent(
      Headers.acceptHeader,
      () => ApiConstants.acceptJson,
    );

    final token = await _secureStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.authorizationHeader] =
          '${ApiConstants.bearerPrefix} $token';
    }

    handler.next(options);
  }
}
