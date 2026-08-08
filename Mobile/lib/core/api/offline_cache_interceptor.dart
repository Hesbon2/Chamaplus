import 'package:dio/dio.dart';

import '../cache/offline_cache_store.dart';
import '../constants/api_constants.dart';
import '../utils/logger.dart';

/// Persists successful GET JSON payloads and serves them when offline / failed.
///
/// Covers dashboard, chamas, members, contributions, loans, meetings,
/// notifications, and reports without per-feature cache wiring.
class OfflineCacheInterceptor extends Interceptor {
  OfflineCacheInterceptor(this._cache);

  final OfflineCacheStore _cache;

  static const _cacheablePrefixes = [
    '/chamas/',
    '/notifications/',
    '/users/me/',
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final skip = options.extra[ApiConstants.skipCacheKey] == true;
    final forceNetwork = options.extra[ApiConstants.forceRefreshKey] == true;
    final method = options.method.toUpperCase();

    if (skip || forceNetwork || method != 'GET' || !_isCacheable(options.path)) {
      handler.next(options);
      return;
    }

    final online = options.extra['wasOnline'] != false;
    if (online) {
      handler.next(options);
      return;
    }

    final key = _keyFor(options);
    final cached = _cache.read(key, allowExpired: true);
    if (cached != null) {
      AppLogger.debug('Serving offline cache for ${options.path}');
      handler.resolve(
        Response<dynamic>(
          requestOptions: options,
          data: cached,
          statusCode: 200,
          statusMessage: 'OK (offline cache)',
          extra: {ApiConstants.fromCacheKey: true},
        ),
      );
      return;
    }

    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final options = response.requestOptions;
    final method = options.method.toUpperCase();
    final skip = options.extra[ApiConstants.skipCacheKey] == true;

    if (!skip &&
        method == 'GET' &&
        _isCacheable(options.path) &&
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300 &&
        response.data != null) {
      final key = _keyFor(options);
      await _cache.write(key: key, data: response.data);
    }

    if (!skip &&
        (method == 'POST' ||
            method == 'PUT' ||
            method == 'PATCH' ||
            method == 'DELETE')) {
      await _invalidateRelated(options.path);
    }

    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final skip = options.extra[ApiConstants.skipCacheKey] == true;
    final method = options.method.toUpperCase();

    if (!skip && method == 'GET' && _isCacheable(options.path)) {
      final key = _keyFor(options);
      final cached = _cache.read(key, allowExpired: true);
      if (cached != null) {
        AppLogger.debug('Network failed — using stale cache for ${options.path}');
        handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            data: cached,
            statusCode: 200,
            statusMessage: 'OK (stale cache)',
            extra: {
              ApiConstants.fromCacheKey: true,
              ApiConstants.staleCacheKey: true,
            },
          ),
        );
        return;
      }
    }

    handler.next(err);
  }

  bool _isCacheable(String path) {
    if (path.contains('/auth/')) return false;
    return _cacheablePrefixes.any(path.startsWith) || path.startsWith('/chamas');
  }

  String _keyFor(RequestOptions options) {
    return _cache.cacheKey(
      method: options.method,
      path: options.path,
      queryParameters: options.queryParameters,
    );
  }

  Future<void> _invalidateRelated(String path) async {
    // Invalidate the mutated resource path prefix (chama-scoped lists).
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.length >= 2) {
      final fragment = '/${segments.take(2).join('/')}/';
      await _cache.invalidatePathContaining(fragment);
    }
  }
}
