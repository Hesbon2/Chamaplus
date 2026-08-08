import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/repositories/auth_repository.dart';

enum ForgotPasswordStep { requestCode, resetPassword }

class ForgotPasswordState {
  const ForgotPasswordState({
    this.step = ForgotPasswordStep.requestCode,
    this.isLoading = false,
    this.errorMessage,
    this.infoMessage,
    this.phoneNumber,
    this.debugResetCode,
    this.resetSucceeded = false,
  });

  final ForgotPasswordStep step;
  final bool isLoading;
  final String? errorMessage;
  final String? infoMessage;
  final String? phoneNumber;
  final String? debugResetCode;
  final bool resetSucceeded;

  ForgotPasswordState copyWith({
    ForgotPasswordStep? step,
    bool? isLoading,
    String? errorMessage,
    String? infoMessage,
    String? phoneNumber,
    String? debugResetCode,
    bool? resetSucceeded,
    bool clearError = false,
    bool clearInfo = false,
    bool clearDebugCode = false,
  }) {
    return ForgotPasswordState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      phoneNumber: phoneNumber ?? this.phoneNumber,
      debugResetCode:
          clearDebugCode ? null : (debugResetCode ?? this.debugResetCode),
      resetSucceeded: resetSucceeded ?? this.resetSucceeded,
    );
  }
}

class ForgotPasswordController extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordController(this._repository)
      : super(const ForgotPasswordState());

  final AuthRepository _repository;

  Future<bool> requestCode({required String phoneNumber}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearInfo: true,
      phoneNumber: phoneNumber,
    );
    try {
      final debugCode =
          await _repository.requestPasswordReset(phoneNumber: phoneNumber);
      state = state.copyWith(
        isLoading: false,
        step: ForgotPasswordStep.resetPassword,
        infoMessage:
            'If an account exists for that phone number, a reset code has been sent.',
        debugResetCode: debugCode,
        clearDebugCode: debugCode == null,
      );
      return true;
    } on AppException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not request a reset code. Please try again.',
      );
      return false;
    }
  }

  Future<bool> confirmReset({
    required String code,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    final phone = state.phoneNumber;
    if (phone == null || phone.isEmpty) {
      state = state.copyWith(errorMessage: 'Enter your phone number first.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.resetPassword(
        phoneNumber: phone,
        code: code,
        newPassword: newPassword,
        newPasswordConfirm: newPasswordConfirm,
      );
      state = state.copyWith(
        isLoading: false,
        resetSucceeded: true,
        infoMessage: 'Password reset successfully. You can sign in now.',
        clearDebugCode: true,
      );
      return true;
    } on AppException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not reset password. Please try again.',
      );
      return false;
    }
  }

  void backToRequest() {
    state = state.copyWith(
      step: ForgotPasswordStep.requestCode,
      clearError: true,
      clearInfo: true,
      clearDebugCode: true,
      resetSucceeded: false,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
