import 'package:chamaplus_mobile/features/auth/domain/entities/user.dart';
import 'package:chamaplus_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:chamaplus_mobile/features/auth/presentation/controllers/register_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<User> register({
    required String phoneNumber,
    required String password,
    required String passwordConfirm,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    return User(
      id: 'u1',
      phoneNumber: phoneNumber,
      firstName: firstName,
      lastName: lastName,
      email: email,
      isStaff: false,
      dateJoined: DateTime(2026, 1, 1),
    );
  }

  @override
  Future<User> login({
    required String phoneNumber,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<User?> restoreSession() => throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();

  @override
  Future<User> getCurrentUser() => throw UnimplementedError();

  @override
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) =>
      throw UnimplementedError();

  @override
  Future<String?> requestPasswordReset({required String phoneNumber}) =>
      throw UnimplementedError();

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
    required String newPasswordConfirm,
  }) =>
      throw UnimplementedError();
}

void main() {
  test('RegisterController registers and returns user', () async {
    final controller = RegisterController(_FakeAuthRepository());

    final user = await controller.register(
      phoneNumber: '0712345678',
      password: 'password1',
      passwordConfirm: 'password1',
      firstName: 'Ada',
    );

    expect(user?.firstName, 'Ada');
    expect(controller.state.isLoading, isFalse);
    expect(controller.state.errorMessage, isNull);
  });
}
