import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../dtos/login_request_dto.dart';
import '../dtos/profile_update_dto.dart';
import '../dtos/register_request_dto.dart';

/// Concrete [AuthRepository] backed by [AuthRemoteDataSource] and secure storage.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource authApi,
    required SecureStorageService secureStorage,
  })  : _authApi = authApi,
        _secureStorage = secureStorage;

  final AuthRemoteDataSource _authApi;
  final SecureStorageService _secureStorage;

  @override
  Future<User> register({
    required String phoneNumber,
    required String password,
    required String passwordConfirm,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    final userDto = await _authApi.register(
      RegisterRequestDto(
        phoneNumber: phoneNumber,
        password: password,
        passwordConfirm: passwordConfirm,
        firstName: firstName,
        lastName: lastName,
        email: email,
      ),
    );

    // Register returns profile only — exchange credentials for JWTs, then reuse
    // the register payload (avoids a second profile parse right after signup).
    final tokens = await _authApi.login(
      LoginRequestDto(phoneNumber: phoneNumber, password: password),
    );
    await _persistTokens(tokens.access, tokens.refresh);
    return userDto.toEntity();
  }

  @override
  Future<User> login({
    required String phoneNumber,
    required String password,
  }) async {
    final tokens = await _authApi.login(
      LoginRequestDto(phoneNumber: phoneNumber, password: password),
    );

    await _persistTokens(tokens.access, tokens.refresh);

    final userDto = await _authApi.getCurrentUser();
    return userDto.toEntity();
  }

  @override
  Future<User?> restoreSession() async {
    final accessToken = await _secureStorage.readAccessToken();
    final refreshToken = await _secureStorage.readRefreshToken();

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      return null;
    }

    try {
      final userDto = await _authApi.getCurrentUser();
      return userDto.toEntity();
    } catch (error) {
      // Access may be expired — attempt one refresh, then retry profile.
      AppLogger.debug('Session restore: access check failed, trying refresh');
      try {
        final tokens = await _authApi.refresh(refreshToken);
        await _persistTokens(tokens.access, tokens.refresh);
        final userDto = await _authApi.getCurrentUser();
        return userDto.toEntity();
      } catch (refreshError) {
        AppLogger.debug('Session restoration failed: $refreshError');
        // Keep tokens on transient network failures so auto-login can retry.
        final message = refreshError.toString().toLowerCase();
        final likelyNetwork = message.contains('network') ||
            message.contains('timeout') ||
            message.contains('connection') ||
            message.contains('socket');
        if (!likelyNetwork) {
          await _secureStorage.clearTokens();
        }
        return null;
      }
    }
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _secureStorage.readRefreshToken();

    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _authApi.logout(refreshToken);
      }
    } catch (error) {
      AppLogger.debug('Logout API call failed (tokens cleared locally): $error');
    } finally {
      await _secureStorage.clearTokens();
    }
  }

  @override
  Future<User> getCurrentUser() async {
    final userDto = await _authApi.getCurrentUser();
    return userDto.toEntity();
  }

  @override
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    final userDto = await _authApi.updateProfile(
      ProfileUpdateDto(
        firstName: firstName,
        lastName: lastName,
        email: email,
      ),
    );
    return userDto.toEntity();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) {
    return _authApi.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirm: newPasswordConfirm,
    );
  }

  @override
  Future<String?> requestPasswordReset({required String phoneNumber}) async {
    final data = await _authApi.requestPasswordReset(phoneNumber: phoneNumber);
    final debugCode = data['debug_reset_code'];
    if (debugCode is String && debugCode.isNotEmpty) {
      return debugCode;
    }
    return null;
  }

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
    required String newPasswordConfirm,
  }) {
    return _authApi.resetPassword(
      phoneNumber: phoneNumber,
      code: code,
      newPassword: newPassword,
      newPasswordConfirm: newPasswordConfirm,
    );
  }

  Future<void> _persistTokens(String access, String refresh) async {
    await _secureStorage.writeAccessToken(access);
    await _secureStorage.writeRefreshToken(refresh);
  }
}
