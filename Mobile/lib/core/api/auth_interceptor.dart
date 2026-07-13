import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import '../utils/logger.dart';
import 'token_refresh_service.dart';

/// Attaches Bearer tokens, refreshes on 401, and retries failed requests.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required Dio dio,
    required SecureStorageService secureStorage,
    required TokenRefreshService tokenRefreshService,
    void Function()? onSessionExpired,
  })  : _dio = dio,
        _secureStorage = secureStorage,
        _tokenRefreshService = tokenRefreshService,
        _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final SecureStorageService _secureStorage;
  final TokenRefreshService _tokenRefreshService;
  final void Function()? _onSessionExpired;

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

    final skipAuth = options.extra[ApiConstants.skipAuthKey] == true;
    if (!skipAuth) {
      final token = await _secureStorage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers[ApiConstants.authorizationHeader] =
            '${ApiConstants.bearerPrefix} $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final skipRefresh = err.requestOptions.extra[ApiConstants.skipRefreshKey];
    final isUnauthorized = err.response?.statusCode == 401;

    if (!isUnauthorized || skipRefresh == true) {
      handler.next(err);
      return;
    }

    final refreshed = await _tokenRefreshService.refresh();
    if (!refreshed) {
      AppLogger.debug('Session expired — clearing tokens.');
      await _secureStorage.clearTokens();
      _onSessionExpired?.call();
      handler.next(err);
      return;
    }

    try {
      final accessToken = await _secureStorage.readAccessToken();
      final requestOptions = err.requestOptions;
      requestOptions.headers[ApiConstants.authorizationHeader] =
          '${ApiConstants.bearerPrefix} $accessToken';

      final response = await _dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } catch (error) {
      handler.next(err);
    }
  }
}
