import '../dtos/login_request_dto.dart';
import '../dtos/profile_update_dto.dart';
import '../dtos/register_request_dto.dart';
import '../dtos/token_response_dto.dart';
import '../dtos/user_dto.dart';

/// Contract for remote authentication operations.
abstract class AuthRemoteDataSource {
  Future<UserDto> register(RegisterRequestDto request);

  Future<TokenResponseDto> login(LoginRequestDto request);

  Future<UserDto> getCurrentUser();

  Future<UserDto> updateProfile(ProfileUpdateDto request);

  Future<void> logout(String refreshToken);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  });
}
