import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

/// Wrapper around [FlutterSecureStorage] for token persistence.
///
/// Uses encrypted shared preferences on Android and Keychain on iOS.
/// Never log token values.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() {
    return _read(AppConstants.accessTokenKey);
  }

  Future<String?> readRefreshToken() {
    return _read(AppConstants.refreshTokenKey);
  }

  Future<bool> hasTokens() async {
    final access = await readAccessToken();
    final refresh = await readRefreshToken();
    return access != null &&
        access.isNotEmpty &&
        refresh != null &&
        refresh.isNotEmpty;
  }

  Future<void> writeAccessToken(String token) {
    return _write(AppConstants.accessTokenKey, token);
  }

  Future<void> writeRefreshToken(String token) {
    return _write(AppConstants.refreshTokenKey, token);
  }

  Future<void> writeTokens({
    required String access,
    required String refresh,
  }) async {
    await writeAccessToken(access);
    await writeRefreshToken(refresh);
  }

  Future<void> clearTokens() async {
    await _delete(AppConstants.accessTokenKey);
    await _delete(AppConstants.refreshTokenKey);
  }

  /// Clears all app keys from secure storage (logout / wipe).
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (error) {
      throw StorageException(cause: error);
    }
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (error) {
      throw StorageException(cause: error);
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (error) {
      throw StorageException(cause: error);
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (error) {
      throw StorageException(cause: error);
    }
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
