import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/forms/forms.dart';
import '../../domain/entities/contribution.dart';
import '../providers/contribution_providers.dart';

/// Form for treasurers to record a member contribution.
class RecordContributionScreen extends ConsumerStatefulWidget {
  const RecordContributionScreen({super.key, required this.chamaId});

  final String chamaId;

  @override
  ConsumerState<RecordContributionScreen> createState() =>
      _RecordContributionScreenState();
}

class _RecordContributionScreenState
    extends ConsumerState<RecordContributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();

  String? _cycleId;
  String? _memberId;
  PaymentMethod _paymentMethod = PaymentMethod.cash;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cycleId = _cycleId;
    final memberId = _memberId;
    if (cycleId == null || memberId == null) return;

    final recorded = await ref
        .read(recordContributionControllerProvider(widget.chamaId).notifier)
        .submit(
          RecordContributionInput(
            cycleId: cycleId,
            memberId: memberId,
            amount: _amountController.text.trim(),
            paymentMethod: _paymentMethod,
            reference: _referenceController.text.trim(),
          ),
        );

    if (!mounted) return;
    final state =
        ref.read(recordContributionControllerProvider(widget.chamaId));
    if (recorded != null) {
      AppSnackbar.success(context, 'Contribution recorded.');
      context.push(
        RoutePaths.contributionDetails(widget.chamaId, recorded.id),
      );
    } else if (state.errorMessage != null) {
      AppSnackbar.error(context, state.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cyclesAsync = ref.watch(openCyclesProvider(widget.chamaId));
    final membersAsync =
        ref.watch(activeMembersForContributionsProvider(widget.chamaId));
    final submitState =
        ref.watch(recordContributionControllerProvider(widget.chamaId));

    return Scaffold(
      appBar: AppBar(title: const Text('Record contribution')),
      body: SafeArea(
        child: AppForm(
          formKey: _formKey,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ListView(
            children: [
              FormSection(
                title: 'Payment details',
                children: [
                  cyclesAsync.when(
                    data: (cycles) {
                      if (cycles.isEmpty) {
                        return const EmptyState(
                          title: 'No open cycles',
                          message: 'Create and open a cycle before recording.',
                          icon: Icons.event_busy_outlined,
                        );
                      }
                      return AppDropdown<String>(
                        label: 'Cycle',
                        value: _cycleId,
                        hint: 'Select cycle',
                        items: cycles
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _cycleId = v),
                        validator: (v) =>
                            AppValidators.requiredSelection(v, field: 'Cycle'),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Failed to load cycles: $e'),
                  ),
                  membersAsync.when(
                    data: (members) {
                      return AppDropdown<String>(
                        label: 'Member',
                        value: _memberId,
                        hint: 'Select member',
                        items: members
                            .map(
                              (m) => DropdownMenuItem(
                                value: m.user.id,
                                child: Text(m.user.displayName),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _memberId = v),
                        validator: (v) => AppValidators.requiredSelection(
                          v,
                          field: 'Member',
                        ),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Failed to load members: $e'),
                  ),
                  AppAmountField(
                    controller: _amountController,
                    label: 'Amount',
                    currencyCode: 'KES',
                  ),
                  AppDropdown<PaymentMethod>(
                    label: 'Payment method',
                    value: _paymentMethod,
                    items: PaymentMethod.values
                        .where((m) => m != PaymentMethod.unknown)
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(m.label),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _paymentMethod = v);
                    },
                  ),
                  AppTextField(
                    controller: _referenceController,
                    label: 'Reference',
                    hint: 'CASH-001 / MPESA code',
                    validator: (v) =>
                        AppValidators.required(v, field: 'Reference'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSubmitButton(
                label: 'Record contribution',
                formKey: _formKey,
                isLoading: submitState.isSubmitting,
                icon: Icons.check,
                onSubmit: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
