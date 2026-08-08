import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cache/offline_cache_store.dart';
import '../config/env_config.dart';
import '../constants/api_constants.dart';
import '../errors/error_handler.dart';
import '../services/connectivity_service.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';
import 'connectivity_interceptor.dart';
import 'debug_logging_interceptor.dart';
import 'offline_cache_interceptor.dart';
import 'retry_interceptor.dart';
import 'session_expired_notifier.dart';
import 'timeout_interceptor.dart';
import 'token_refresh_service.dart';

typedef SessionExpiredCallback = void Function();

/// Global Dio HTTP client configured for the ChamaPlus API.
class ApiClient {
  ApiClient({
    required SecureStorageService secureStorage,
    required ConnectivityService connectivity,
    required OfflineCacheStore offlineCache,
    ErrorHandler? errorHandler,
    SessionExpiredCallback? onSessionExpired,
  })  : _errorHandler = errorHandler ?? const ErrorHandler(),
        _dio = Dio(
          BaseOptions(
            baseUrl: EnvConfig.apiBaseUrl,
            connectTimeout: Duration(milliseconds: EnvConfig.connectTimeoutMs),
            receiveTimeout: Duration(milliseconds: EnvConfig.receiveTimeoutMs),
            sendTimeout: Duration(milliseconds: EnvConfig.connectTimeoutMs),
            headers: {
              Headers.contentTypeHeader: ApiConstants.contentTypeJson,
              Headers.acceptHeader: ApiConstants.acceptJson,
            },
          ),
        ) {
    _tokenRefreshService = TokenRefreshService(
      dio: _dio,
      secureStorage: secureStorage,
    );

    _dio.interceptors.addAll([
      TimeoutInterceptor(),
      ConnectivityInterceptor(connectivity),
      OfflineCacheInterceptor(offlineCache),
      AuthInterceptor(
        dio: _dio,
        secureStorage: secureStorage,
        tokenRefreshService: _tokenRefreshService,
        onSessionExpired: onSessionExpired,
      ),
      RetryInterceptor(_dio),
      DebugLoggingInterceptor(),
    ]);
  }

  final Dio _dio;
  final ErrorHandler _errorHandler;
  late final TokenRefreshService _tokenRefreshService;

  Dio get dio => _dio;

  TokenRefreshService get tokenRefreshService => _tokenRefreshService;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _request(() => _dio.get<T>(
          path,
          queryParameters: queryParameters,
          options: options,
        ));
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _request(() => _dio.post<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        ));
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _request(() => _dio.put<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        ));
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _request(() => _dio.patch<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        ));
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _request(() => _dio.delete<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        ));
  }

  Future<Response<T>> _request<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } catch (error, stackTrace) {
      throw _errorHandler.handle(error, stackTrace);
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final sessionNotifier = ref.watch(sessionExpiredNotifierProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final offlineCache = ref.watch(offlineCacheStoreProvider);
  return ApiClient(
    secureStorage: secureStorage,
    connectivity: connectivity,
    offlineCache: offlineCache,
    onSessionExpired: sessionNotifier.notify,
  );
});

final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return const ErrorHandler();
});
