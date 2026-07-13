import 'package:chamaplus_mobile/core/constants/app_constants.dart';
import 'package:chamaplus_mobile/core/storage/secure_storage_service.dart';

/// In-memory secure storage for unit tests.
class FakeSecureStorage extends SecureStorageService {
  FakeSecureStorage();

  final Map<String, String> _data = {};

  @override
  Future<String?> readAccessToken() async => _data[AppConstants.accessTokenKey];

  @override
  Future<String?> readRefreshToken() async =>
      _data[AppConstants.refreshTokenKey];

  @override
  Future<void> writeAccessToken(String token) async {
    _data[AppConstants.accessTokenKey] = token;
  }

  @override
  Future<void> writeRefreshToken(String token) async {
    _data[AppConstants.refreshTokenKey] = token;
  }

  @override
  Future<void> clearTokens() async {
    _data.remove(AppConstants.accessTokenKey);
    _data.remove(AppConstants.refreshTokenKey);
  }
}
