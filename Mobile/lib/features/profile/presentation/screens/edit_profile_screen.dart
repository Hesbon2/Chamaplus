import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/forms/forms.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/profile_providers.dart';

/// Edit first name, last name, and email.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  bool _initialized = false;
  bool _submitting = false;

  @override
  void dispose() {
    if (_initialized) {
      _firstNameController.dispose();
      _lastNameController.dispose();
      _emailController.dispose();
    }
    super.dispose();
  }

  void _ensureControllers() {
    if (_initialized) return;
    final user = ref.read(authControllerProvider).user;
    _firstNameController =
        TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _initialized = true;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final user = await ref.read(authRepositoryProvider).updateProfile(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
          );
      ref.read(authControllerProvider.notifier).setAuthenticated(user);
      ref.invalidate(profileControllerProvider);
      if (!mounted) return;
      AppSnackbar.success(context, 'Profile updated.');
      context.pop();
    } on AppException catch (error) {
      if (!mounted) return;
      AppSnackbar.error(context, error.message);
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Failed to update profile.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureControllers();
    final phone = ref.watch(authControllerProvider).user?.phoneNumber ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: AppForm(
          formKey: _formKey,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ListView(
            children: [
              FormSection(
                title: 'Your details',
                subtitle: 'Phone number cannot be changed here.',
                children: [
                  AppTextField(
                    label: 'Phone number',
                    initialValue: phone,
                    readOnly: true,
                    enabled: false,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  AppTextField(
                    controller: _firstNameController,
                    label: 'First name',
                    prefixIcon: const Icon(Icons.person_outline),
                    enabled: !_submitting,
                  ),
                  AppTextField(
                    controller: _lastNameController,
                    label: 'Last name',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    enabled: !_submitting,
                  ),
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (v) =>
                        AppValidators.email(v, isRequired: false),
                    enabled: !_submitting,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSubmitButton(
                label: 'Save changes',
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
