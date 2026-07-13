import 'dart:async';

import 'package:dio/dio.dart';

import '../api/api_response.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import '../utils/logger.dart';

/// Handles JWT refresh with single-flight deduplication.
class TokenRefreshService {
  TokenRefreshService({
    required Dio dio,
    required SecureStorageService secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  final Dio _dio;
  final SecureStorageService _secureStorage;

  Completer<bool>? _refreshCompleter;

  Future<bool> refresh() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();
    try {
      final refreshToken = await _secureStorage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _refreshCompleter!.complete(false);
        return false;
      }

      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.authRefresh,
        data: {'refresh': refreshToken},
        options: Options(
          extra: {
            ApiConstants.skipAuthKey: true,
            ApiConstants.skipRefreshKey: true,
          },
        ),
      );

      final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data ?? {},
        (json) => Map<String, dynamic>.from(json as Map? ?? {}),
      );

      if (!envelope.success || envelope.data == null) {
        _refreshCompleter!.complete(false);
        return false;
      }

      final access = envelope.data!['access'] as String?;
      final refresh = envelope.data!['refresh'] as String?;

      if (access == null || refresh == null) {
        _refreshCompleter!.complete(false);
        return false;
      }

      await _secureStorage.writeAccessToken(access);
      await _secureStorage.writeRefreshToken(refresh);

      AppLogger.debug('Access token refreshed successfully.');
      _refreshCompleter!.complete(true);
      return true;
    } catch (error, stackTrace) {
      AppLogger.error('Token refresh failed', error, stackTrace);
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}
