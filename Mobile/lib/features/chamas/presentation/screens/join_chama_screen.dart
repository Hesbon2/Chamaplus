import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/forms/forms.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../providers/chama_providers.dart';

/// Join an existing Chama using an invite code.
class JoinChamaScreen extends ConsumerStatefulWidget {
  const JoinChamaScreen({super.key});

  @override
  ConsumerState<JoinChamaScreen> createState() => _JoinChamaScreenState();
}

class _JoinChamaScreenState extends ConsumerState<JoinChamaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(chamaRepositoryProvider).joinChama(
            inviteCode: _codeController.text.trim(),
          );
      final chamas = await ref.read(chamaRepositoryProvider).listChamas();
      if (!mounted) return;
      markOnboardingReady(ref);
      AppSnackbar.success(context, 'Joined successfully!');
      if (chamas.isNotEmpty) {
        context.go(RoutePaths.chamaDetails(chamas.first.id));
      } else {
        context.go(RoutePaths.home);
      }
    } on AppException catch (error) {
      if (!mounted) return;
      AppSnackbar.error(context, error.message);
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Failed to join chama.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Chama')),
      body: SafeArea(
        child: AppForm(
          formKey: _formKey,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ListView(
            children: [
              FormSection(
                title: 'Invite code',
                subtitle:
                    'Ask your chairperson for the code, then enter it below.',
                children: [
                  AppTextField(
                    controller: _codeController,
                    label: 'Invite code',
                    hint: 'ABC123XY',
                    textCapitalization: TextCapitalization.characters,
                    prefixIcon: const Icon(Icons.qr_code_2_outlined),
                    validator: (v) =>
                        AppValidators.required(v, field: 'Invite code'),
                    enabled: !_submitting,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSubmitButton(
                label: 'Join Chama',
                formKey: _formKey,
                isLoading: _submitting,
                icon: Icons.login,
                onSubmit: _submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
