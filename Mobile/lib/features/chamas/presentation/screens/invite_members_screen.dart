import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/forms/forms.dart';
import '../../domain/entities/chama.dart';
import '../providers/chama_providers.dart';

/// Invite a registered user to this Chama by phone number.
class InviteMembersScreen extends ConsumerStatefulWidget {
  const InviteMembersScreen({super.key, required this.chamaId});

  final String chamaId;

  @override
  ConsumerState<InviteMembersScreen> createState() =>
      _InviteMembersScreenState();
}

class _InviteMembersScreenState extends ConsumerState<InviteMembersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _role = 'member';
  bool _submitting = false;

  static const _roles = ChamaAssignableRoles.options;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final membership = await ref.read(chamaRepositoryProvider).inviteMember(
            chamaId: widget.chamaId,
            input: InviteMemberInput(
              phoneNumber: _phoneController.text.trim(),
              role: _role,
            ),
          );
      if (!mounted) return;
      AppSnackbar.success(
        context,
        '${membership.user.displayName} invited. They are pending approval.',
      );
      context.pop();
    } on AppException catch (error) {
      if (!mounted) return;
      AppSnackbar.error(context, error.message);
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Failed to invite member.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invite members')),
      body: SafeArea(
        child: AppForm(
          formKey: _formKey,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ListView(
            children: [
              FormSection(
                title: 'Member details',
                subtitle:
                    'The person must already have a ChamaPlus account. They stay pending until you approve them under Join requests.',
                children: [
                  AppPhoneField(
                    controller: _phoneController,
                    enabled: !_submitting,
                  ),
                  AppDropdown<String>(
                    label: 'Role',
                    value: _role,
                    items: _roles
                        .map(
                          (r) => DropdownMenuItem(
                            value: r.$1,
                            child: Text(r.$2),
                          ),
                        )
                        .toList(),
                    onChanged: _submitting
                        ? null
                        : (value) {
                            if (value != null) setState(() => _role = value);
                          },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSubmitButton(
                label: 'Send invite',
                formKey: _formKey,
                isLoading: _submitting,
                icon: Icons.person_add_alt_1_outlined,
                onSubmit: _submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
