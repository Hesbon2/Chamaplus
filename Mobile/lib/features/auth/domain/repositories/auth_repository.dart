import '../entities/user.dart';

/// Contract for authentication operations.
abstract class AuthRepository {
  /// Authenticate with phone number and password.
  Future<User> login({
    required String phoneNumber,
    required String password,
  });

  /// Restore session from stored tokens and fetch the current user profile.
  /// Returns `null` when no valid session exists.
  Future<User?> restoreSession();

  /// Blacklist refresh token on the server and clear local storage.
  Future<void> logout();

  /// Fetch the authenticated user's profile.
  Future<User> getCurrentUser();
}
