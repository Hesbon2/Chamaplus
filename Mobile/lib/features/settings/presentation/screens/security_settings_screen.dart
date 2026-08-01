import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/forms/forms.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Change password using the backend auth API.
class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      await ref.read(authRepositoryProvider).changePassword(
            currentPassword: _currentController.text,
            newPassword: _newController.text,
            newPasswordConfirm: _confirmController.text,
          );
      if (!mounted) return;
      AppSnackbar.success(context, 'Password updated.');
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
    } on AppException catch (error) {
      if (!mounted) return;
      AppSnackbar.error(context, error.message);
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Could not change password.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: SafeArea(
        child: AppForm(
          formKey: _formKey,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ListView(
            children: [
              AppPasswordField(
                controller: _currentController,
                label: 'Current password',
                textInputAction: TextInputAction.next,
                enabled: !_submitting,
              ),
              const SizedBox(height: AppSpacing.md),
              AppPasswordField(
                controller: _newController,
                label: 'New password',
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                enabled: !_submitting,
              ),
              const SizedBox(height: AppSpacing.md),
              AppPasswordField(
                controller: _confirmController,
                label: 'Confirm new password',
                autofillHints: const [AutofillHints.newPassword],
                enabled: !_submitting,
                validator: (value) {
                  if (value != _newController.text) {
                    return 'Passwords do not match';
                  }
                  return AppValidators.minLength(
                    value,
                    length: 8,
                    field: 'Confirm new password',
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSubmitButton(
                label: 'Update password',
                formKey: _formKey,
                isLoading: _submitting,
                onSubmit: _submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
