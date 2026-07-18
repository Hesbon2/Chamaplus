import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/forms/forms.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../domain/entities/chama.dart';
import '../providers/chama_providers.dart';

/// Form to create a new Chama (caller becomes chairperson).
class CreateChamaScreen extends ConsumerStatefulWidget {
  const CreateChamaScreen({super.key});

  @override
  ConsumerState<CreateChamaScreen> createState() => _CreateChamaScreenState();
}

class _CreateChamaScreenState extends ConsumerState<CreateChamaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _currency = 'KES';
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final chama = await ref.read(chamaRepositoryProvider).createChama(
            CreateChamaInput(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              location: _locationController.text.trim().isEmpty
                  ? null
                  : _locationController.text.trim(),
              currency: _currency,
            ),
          );
      if (!mounted) return;
      markOnboardingReady(ref);
      AppSnackbar.success(context, 'Chama created. Share your invite code!');
      context.go(RoutePaths.chamaDetails(chama.id));
    } on AppException catch (error) {
      if (!mounted) return;
      AppSnackbar.error(context, error.message);
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Failed to create chama.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Chama')),
      body: SafeArea(
        child: AppForm(
          formKey: _formKey,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ListView(
            children: [
              FormSection(
                title: 'Chama details',
                subtitle: 'You will be assigned as chairperson.',
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: 'Name',
                    hint: 'Umoja Savings',
                    prefixIcon: const Icon(Icons.groups_outlined),
                    validator: (v) =>
                        AppValidators.required(v, field: 'Name'),
                    enabled: !_submitting,
                  ),
                  AppMultilineField(
                    controller: _descriptionController,
                    label: 'Description (optional)',
                    maxLines: 3,
                    enabled: !_submitting,
                  ),
                  AppTextField(
                    controller: _locationController,
                    label: 'Location (optional)',
                    hint: 'Nairobi',
                    prefixIcon: const Icon(Icons.place_outlined),
                    enabled: !_submitting,
                  ),
                  AppCurrencyField(
                    value: _currency,
                    onChanged: (value) {
                      if (value != null) setState(() => _currency = value);
                    },
                    enabled: !_submitting,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSubmitButton(
                label: 'Create Chama',
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
