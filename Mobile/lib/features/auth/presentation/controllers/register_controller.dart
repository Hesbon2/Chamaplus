import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Registration form submission state.
class RegisterState {
  const RegisterState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
  });

  final bool isLoading;
  final String? errorMessage;
  final User? user;

  RegisterState copyWith({
    bool? isLoading,
    String? errorMessage,
    User? user,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: clearUser ? null : (user ?? this.user),
    );
  }
}

/// Handles registration + automatic login.
class RegisterController extends StateNotifier<RegisterState> {
  RegisterController(this._repository) : super(const RegisterState());

  final AuthRepository _repository;
  bool _inFlight = false;

  Future<User?> register({
    required String phoneNumber,
    required String password,
    required String passwordConfirm,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    if (_inFlight) return null;

    _inFlight = true;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.register(
        phoneNumber: phoneNumber,
        password: password,
        passwordConfirm: passwordConfirm,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
      state = state.copyWith(isLoading: false, user: user);
      return user;
    } on AppException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return null;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Registration failed. Please try again.',
      );
      return null;
    } finally {
      _inFlight = false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
