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
