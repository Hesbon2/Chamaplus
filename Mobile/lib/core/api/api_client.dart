import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env_config.dart';
import '../constants/api_constants.dart';
import '../errors/error_handler.dart';
import 'api_interceptor.dart';
import '../storage/secure_storage_service.dart';

/// Global Dio HTTP client configured for the ChamaPlus API.
class ApiClient {
  ApiClient({
    required SecureStorageService secureStorage,
    ErrorHandler? errorHandler,
  })  : _errorHandler = errorHandler ?? const ErrorHandler(),
        _dio = Dio(
          BaseOptions(
            baseUrl: EnvConfig.apiBaseUrl,
            connectTimeout: Duration(milliseconds: EnvConfig.connectTimeoutMs),
            receiveTimeout: Duration(milliseconds: EnvConfig.receiveTimeoutMs),
            headers: {
              Headers.contentTypeHeader: ApiConstants.contentTypeJson,
              Headers.acceptHeader: ApiConstants.acceptJson,
            },
          ),
        ) {
    _dio.interceptors.add(ApiInterceptor(secureStorage));
  }

  final Dio _dio;
  final ErrorHandler _errorHandler;

  Dio get dio => _dio;

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
  return ApiClient(secureStorage: secureStorage);
});

final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return const ErrorHandler();
});
