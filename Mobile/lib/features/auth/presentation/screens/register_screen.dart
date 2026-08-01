import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/forms/forms.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../controllers/register_controller.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_scaffold.dart';

/// New user registration with automatic login.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = await ref.read(registerControllerProvider.notifier).register(
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text,
          passwordConfirm: _confirmController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
        );

    if (!mounted || user == null) return;

    // Resolve gate before setAuthenticated to avoid disposing this screen
    // (router redirects authenticated + unknown → splash).
    await resolveOnboardingGate(ProviderScope.containerOf(context));
    if (!mounted) return;

    AppSnackbar.success(context, 'Welcome to ChamaPlus!');
    ref.read(authControllerProvider.notifier).setAuthenticated(user);
    // GoRouter redirect handles navigation — do not also call context.go.
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerControllerProvider);
    final isLoading = registerState.isLoading;

    ref.listen<RegisterState>(registerControllerProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackbar.error(context, next.errorMessage!);
      }
    });

    return AuthScaffold(
      title: 'Create account',
      showBackButton: true,
      child: AppForm(
        formKey: _formKey,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPhoneField(
              controller: _phoneController,
              enabled: !isLoading,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _firstNameController,
              label: 'First name',
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.person_outline),
              enabled: !isLoading,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _lastNameController,
              label: 'Last name',
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.badge_outlined),
              enabled: !isLoading,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _emailController,
              label: 'Email (optional)',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.email_outlined),
              validator: (v) => AppValidators.email(v, isRequired: false),
              enabled: !isLoading,
            ),
            const SizedBox(height: AppSpacing.md),
            AppPasswordField(
              controller: _passwordController,
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
            ),
            const SizedBox(height: AppSpacing.md),
            AppPasswordField(
              controller: _confirmController,
              label: 'Confirm password',
              autofillHints: const [AutofillHints.newPassword],
              enabled: !isLoading,
              validator: (v) {
                if (v != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return AppValidators.minLength(
                  v,
                  length: 8,
                  field: 'Confirm password',
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSubmitButton(
              label: 'Create account',
              formKey: _formKey,
              isLoading: isLoading,
              onSubmit: isLoading ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed:
                  isLoading ? null : () => context.go(RoutePaths.login),
              child: const Text('Already have an account? Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
