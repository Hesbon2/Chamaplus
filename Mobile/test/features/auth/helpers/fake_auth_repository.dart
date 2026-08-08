import 'package:chamaplus_mobile/features/auth/domain/entities/user.dart';
import 'package:chamaplus_mobile/features/auth/domain/repositories/auth_repository.dart';

/// Test double for [AuthRepository].
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.restoreResult,
    this.loginResult,
    this.loginError,
    this.logoutCalled = false,
  });

  User? restoreResult;
  User? loginResult;
  Object? loginError;
  bool logoutCalled;

  @override
  Future<User> register({
    required String phoneNumber,
    required String password,
    required String passwordConfirm,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    if (loginError != null) throw loginError!;
    return loginResult ?? restoreResult!;
  }

  @override
  Future<User> getCurrentUser() async {
    if (restoreResult != null) return restoreResult!;
    if (loginResult != null) return loginResult!;
    throw UnimplementedError();
  }

  @override
  Future<User> login({
    required String phoneNumber,
    required String password,
  }) async {
    if (loginError != null) throw loginError!;
    return loginResult!;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  Future<User?> restoreSession() async => restoreResult;

  @override
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    final base = loginResult ?? restoreResult ?? testUser();
    return User(
      id: base.id,
      phoneNumber: base.phoneNumber,
      firstName: firstName ?? base.firstName,
      lastName: lastName ?? base.lastName,
      email: email ?? base.email,
      isStaff: base.isStaff,
      dateJoined: base.dateJoined,
      lastLogin: base.lastLogin,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {}

  @override
  Future<String?> requestPasswordReset({required String phoneNumber}) async {
    return '123456';
  }

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {}
}

/// Sample user for tests.
User testUser() {
  return User(
    id: 'user-1',
    phoneNumber: '+254712345678',
    firstName: 'Jane',
    lastName: 'Doe',
    isStaff: false,
    dateJoined: DateTime.parse('2026-07-12T10:00:00+03:00'),
  );
}
