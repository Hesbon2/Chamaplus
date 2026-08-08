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
  Future<TokenResponseDto> refresh(String refreshToken) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.authRefresh,
      data: {'refresh': refreshToken},
      options: Options(
        extra: {
          ApiConstants.skipAuthKey: true,
          ApiConstants.skipRefreshKey: true,
          ApiConstants.skipRetryKey: true,
          ApiConstants.skipCacheKey: true,
        },
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

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.authChangePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirm': newPasswordConfirm,
      },
    );
    final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? {},
      (data) => Map<String, dynamic>.from(data as Map? ?? {}),
    );
    if (!envelope.success) {
      throw ServerException(message: envelope.message);
    }
  }

  @override
  Future<Map<String, dynamic>> requestPasswordReset({
    required String phoneNumber,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.authForgotPassword,
      data: {'phone_number': phoneNumber},
      options: Options(
        extra: {ApiConstants.skipAuthKey: true},
      ),
    );
    return _unwrapMap(response.data);
  }

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.authResetPassword,
      data: {
        'phone_number': phoneNumber,
        'code': code,
        'new_password': newPassword,
        'new_password_confirm': newPasswordConfirm,
      },
      options: Options(
        extra: {ApiConstants.skipAuthKey: true},
      ),
    );
    final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? {},
      (data) => Map<String, dynamic>.from(data as Map? ?? {}),
    );
    if (!envelope.success) {
      throw ServerException(message: envelope.message);
    }
  }

  Map<String, dynamic> _unwrapMap(Map<String, dynamic>? json) {
    final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
      json ?? {},
      (data) => Map<String, dynamic>.from(data as Map? ?? {}),
    );
    if (!envelope.success || envelope.data == null) {
      throw ServerException(message: envelope.message);
    }
    return envelope.data!;
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
