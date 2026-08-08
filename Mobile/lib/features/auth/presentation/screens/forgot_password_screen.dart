import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/forms/forms.dart';
import '../controllers/forgot_password_controller.dart';
import '../providers/auth_providers.dart';
import '../utils/validators.dart';
import '../widgets/auth_scaffold.dart';

/// Request a reset code, then set a new password with the OTP.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(forgotPasswordControllerProvider.notifier);
    final state = ref.read(forgotPasswordControllerProvider);

    if (state.step == ForgotPasswordStep.requestCode) {
      await controller.requestCode(phoneNumber: _phoneController.text.trim());
      return;
    }

    final ok = await controller.confirmReset(
      code: _codeController.text.trim(),
      newPassword: _passwordController.text,
      newPasswordConfirm: _confirmController.text,
    );
    if (!mounted || !ok) return;
    AppSnackbar.success(context, 'Password updated. Please sign in.');
    context.go(RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);
    final isResetStep = state.step == ForgotPasswordStep.resetPassword;

    ref.listen<ForgotPasswordState>(forgotPasswordControllerProvider,
        (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackbar.error(context, next.errorMessage!);
      }
      if (next.infoMessage != null &&
          next.infoMessage != previous?.infoMessage &&
          next.step == ForgotPasswordStep.resetPassword &&
          previous?.step == ForgotPasswordStep.requestCode) {
        AppSnackbar.info(context, next.infoMessage!);
      }
    });

    return AuthScaffold(
      showBackButton: true,
      title: isResetStep ? 'Enter reset code' : 'Reset password',
      child: AppForm(
        formKey: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      isResetStep
                          ? 'Enter the 6-digit code sent for this phone number, then choose a new password.'
                          : 'We will send a one-time reset code if this phone number has an account.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (!isResetStep)
              AppPhoneField(
                controller: _phoneController,
                validator: PhoneValidator.validate,
                enabled: !state.isLoading,
              )
            else ...[
              AppTextField(
                controller: _codeController,
                label: 'Reset code',
                hint: '6-digit code',
                keyboardType: TextInputType.number,
                enabled: !state.isLoading,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.length != 6 || int.tryParse(text) == null) {
                    return 'Enter the 6-digit reset code';
                  }
                  return null;
                },
              ),
              if (state.debugResetCode != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Debug code: ${state.debugResetCode}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                      ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              AppPasswordField(
                controller: _passwordController,
                label: 'New password',
                enabled: !state.isLoading,
                validator: PasswordValidator.validate,
              ),
              const SizedBox(height: AppSpacing.md),
              AppPasswordField(
                controller: _confirmController,
                label: 'Confirm new password',
                enabled: !state.isLoading,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return PasswordValidator.validate(value);
                },
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppSubmitButton(
              label: isResetStep ? 'Reset password' : 'Send reset code',
              isLoading: state.isLoading,
              formKey: _formKey,
              onSubmit: state.isLoading ? null : _submit,
            ),
            if (isResetStep) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: state.isLoading
                    ? null
                    : () {
                        _codeController.clear();
                        _passwordController.clear();
                        _confirmController.clear();
                        ref
                            .read(forgotPasswordControllerProvider.notifier)
                            .backToRequest();
                      },
                child: const Text('Use a different phone number'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
