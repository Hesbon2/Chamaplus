import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../utils/validators.dart';
import '../widgets/auth_scaffold.dart';

/// Forgot password UI — backend endpoint not yet available.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    AppSnackbar.info(
      context,
      'Password reset is not yet available. Please contact your chama admin.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      title: 'Reset password',
      child: Form(
        key: _formKey,
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
                  Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Online password reset is coming soon. '
                      'For now, contact your chama administrator.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _phoneController,
              label: 'Phone number',
              hint: '0712345678',
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined),
              validator: PhoneValidator.validate,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Request reset link',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
