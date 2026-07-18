import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../dtos/login_request_dto.dart';
import '../dtos/profile_update_dto.dart';
import '../dtos/register_request_dto.dart';
import '../dtos/token_response_dto.dart';
import '../dtos/user_dto.dart';
import 'auth_remote_data_source.dart';

/// Remote authentication API client.
class AuthApi implements AuthRemoteDataSource {
  AuthApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<UserDto> register(RegisterRequestDto request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.authRegister,
      data: request.toJson(),
      options: Options(
        extra: {ApiConstants.skipAuthKey: true},
      ),
    );

    return _parseUserResponse(response.data);
  }

  @override
  Future<TokenResponseDto> login(LoginRequestDto request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.authLogin,
      data: request.toJson(),
      options: Options(
        extra: {ApiConstants.skipAuthKey: true},
      ),
    );

    return _parseTokenResponse(response.data);
  }

  @override
  Future<UserDto> getCurrentUser() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.usersMe,
    );

    return _parseUserResponse(response.data);
  }

  @override
  Future<UserDto> updateProfile(ProfileUpdateDto request) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiConstants.usersMe,
      data: request.toJson(),
    );

    return _parseUserResponse(response.data);
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.authLogout,
      data: {'refresh': refreshToken},
    );
  }

  TokenResponseDto _parseTokenResponse(Map<String, dynamic>? json) {
    final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
      json ?? {},
      (data) => Map<String, dynamic>.from(data as Map? ?? {}),
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(message: envelope.message);
    }

    return TokenResponseDto.fromJson(envelope.data!);
  }

  UserDto _parseUserResponse(Map<String, dynamic>? json) {
    final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
      json ?? {},
      (data) => Map<String, dynamic>.from(data as Map? ?? {}),
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(message: envelope.message);
    }

    return UserDto.fromJson(envelope.data!);
  }
}
