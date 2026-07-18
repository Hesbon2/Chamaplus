import 'package:chamaplus_mobile/features/auth/data/dtos/login_request_dto.dart';
import 'package:chamaplus_mobile/features/auth/data/dtos/profile_update_dto.dart';
import 'package:chamaplus_mobile/features/auth/data/dtos/register_request_dto.dart';
import 'package:chamaplus_mobile/features/auth/data/dtos/token_response_dto.dart';
import 'package:chamaplus_mobile/features/auth/data/dtos/user_dto.dart';
import 'package:chamaplus_mobile/features/auth/data/datasources/auth_remote_data_source.dart';

/// Test double for [AuthRemoteDataSource].
class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  TokenResponseDto? loginResponse;
  UserDto? userResponse;
  Object? loginError;
  Object? getCurrentUserError;
  bool logoutCalled = false;

  @override
  Future<UserDto> register(RegisterRequestDto request) async {
    return userResponse!;
  }

  @override
  Future<TokenResponseDto> login(LoginRequestDto request) async {
    if (loginError != null) throw loginError!;
    return loginResponse!;
  }

  @override
  Future<UserDto> getCurrentUser() async {
    if (getCurrentUserError != null) throw getCurrentUserError!;
    return userResponse!;
  }

  @override
  Future<UserDto> updateProfile(ProfileUpdateDto request) async {
    return userResponse!;
  }

  @override
  Future<void> logout(String refreshToken) async {
    logoutCalled = true;
  }
}
