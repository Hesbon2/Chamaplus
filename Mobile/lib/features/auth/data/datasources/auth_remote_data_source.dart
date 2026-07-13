import '../dtos/login_request_dto.dart';
import '../dtos/token_response_dto.dart';
import '../dtos/user_dto.dart';

/// Contract for remote authentication operations.
abstract class AuthRemoteDataSource {
  Future<TokenResponseDto> login(LoginRequestDto request);
  Future<UserDto> getCurrentUser();
  Future<void> logout(String refreshToken);
}
