import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Manages global authentication state: session restore, login, logout.
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState.initial());

  final AuthRepository _repository;

  /// Restore session from secure storage on app launch.
  Future<void> restoreSession() async {
    state = const AuthState.loading();

    final user = await _repository.restoreSession();
    if (user != null) {
      state = AuthState.authenticated(user);
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  /// Mark user as authenticated after a successful login.
  void setAuthenticated(User user) {
    state = AuthState.authenticated(user);
  }

  /// Sign out locally and on the server.
  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState.unauthenticated();
  }

  /// Called when token refresh fails — clears session without API call.
  void onSessionExpired() {
    state = const AuthState.unauthenticated();
  }
}
