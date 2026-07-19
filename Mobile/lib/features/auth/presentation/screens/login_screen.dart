import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../controllers/login_controller.dart';
import '../providers/auth_providers.dart';
import '../utils/validators.dart';
import '../widgets/auth_scaffold.dart';

/// Phone number and password login screen.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = await ref.read(loginControllerProvider.notifier).login(
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted || user == null) return;

    // Resolve gate before setAuthenticated — otherwise router sees
    // authenticated + unknown gate, redirects to splash, and disposes this
    // screen while resolveOnboardingGate is still running.
    await resolveOnboardingGate(ProviderScope.containerOf(context));
    if (!mounted) return;

    ref.read(authControllerProvider.notifier).setAuthenticated(user);
    // GoRouter redirect handles navigation (avoid a second context.go —
    // overlapping transitions trip Hero flight assertions).
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    final authState = ref.watch(authControllerProvider);

    ref.listen<LoginState>(loginControllerProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackbar.error(context, next.errorMessage!);
      }
    });

    final isLoading = loginState.isLoading || authState.isLoading;

    return AuthScaffold(
      title: 'Welcome back',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _phoneController,
              label: 'Phone number',
              hint: '0712345678',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.phone_outlined),
              validator: PhoneValidator.validate,
              enabled: !isLoading,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
              validator: PasswordValidator.validate,
              enabled: !isLoading,
              onChanged: (_) {
                if (loginState.errorMessage != null) {
                  ref.read(loginControllerProvider.notifier).clearError();
                }
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed:
                    isLoading ? null : () => context.push(RoutePaths.forgotPassword),
                child: const Text('Forgot password?'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Sign in',
              isLoading: isLoading,
              onPressed: isLoading ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed:
                  isLoading ? null : () => context.push(RoutePaths.register),
              child: const Text('New here? Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
