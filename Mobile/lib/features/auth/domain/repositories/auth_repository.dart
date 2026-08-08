import '../entities/user.dart';

/// Contract for authentication operations.
abstract class AuthRepository {
  /// Register a new user, then log them in (backend register returns profile only).
  Future<User> register({
    required String phoneNumber,
    required String password,
    required String passwordConfirm,
    String? firstName,
    String? lastName,
    String? email,
  });

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

  /// Update profile fields (`first_name`, `last_name`, `email`).
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  });

  /// Change password for the authenticated user.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  });

  /// Request a password-reset code for [phoneNumber] (anti-enumeration).
  ///
  /// Returns an optional debug code when the backend is in DEBUG mode.
  Future<String?> requestPasswordReset({required String phoneNumber});

  /// Confirm password reset with the OTP code from [requestPasswordReset].
  Future<void> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
    required String newPasswordConfirm,
  });
}
