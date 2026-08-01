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
    await _authApi.register(
      RegisterRequestDto(
        phoneNumber: phoneNumber,
        password: password,
        passwordConfirm: passwordConfirm,
        firstName: firstName,
        lastName: lastName,
        email: email,
      ),
    );

    // Register returns the user profile without tokens — log in immediately.
    return login(phoneNumber: phoneNumber, password: password);
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
      AppLogger.debug('Session restoration failed: $error');
      await _secureStorage.clearTokens();
      return null;
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

  Future<void> _persistTokens(String access, String refresh) async {
    await _secureStorage.writeAccessToken(access);
    await _secureStorage.writeRefreshToken(refresh);
  }
}
