import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Login form submission state.
class LoginState {
  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
  });

  final bool isLoading;
  final String? errorMessage;
  final User? user;

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    User? user,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: clearUser ? null : (user ?? this.user),
    );
  }
}

/// Handles login form submission and validation errors.
class LoginController extends StateNotifier<LoginState> {
  LoginController(this._repository) : super(const LoginState());

  final AuthRepository _repository;

  Future<User?> login({
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.login(
        phoneNumber: phoneNumber,
        password: password,
      );
      state = state.copyWith(isLoading: false, user: user);
      return user;
    } on AppException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return null;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Login failed. Please try again.',
      );
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
