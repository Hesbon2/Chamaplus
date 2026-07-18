import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/forms/forms.dart';
import '../../domain/entities/contribution.dart';
import '../providers/contribution_providers.dart';

/// Form to create a new contribution cycle.
class CreateCycleScreen extends ConsumerStatefulWidget {
  const CreateCycleScreen({super.key, required this.chamaId});

  final String chamaId;

  @override
  ConsumerState<CreateCycleScreen> createState() => _CreateCycleScreenState();
}

class _CreateCycleScreenState extends ConsumerState<CreateCycleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _penaltyController = TextEditingController(text: '0.00');
  final _dueDayController = TextEditingController(text: '15');

  CycleFrequency _frequency = CycleFrequency.monthly;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _penaltyController.dispose();
    _dueDayController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final dueDay = int.tryParse(_dueDayController.text.trim()) ?? 0;
      await ref.read(contributionRepositoryProvider).createCycle(
            chamaId: widget.chamaId,
            input: CreateCycleInput(
              name: _nameController.text.trim(),
              frequency: _frequency,
              contributionAmount: _amountController.text.trim(),
              startDate: _startDate!,
              endDate: _endDate!,
              dueDay: dueDay,
              penaltyAmount: _penaltyController.text.trim().isEmpty
                  ? '0.00'
                  : _penaltyController.text.trim(),
            ),
          );
      if (!mounted) return;
      AppSnackbar.success(context, 'Cycle created.');
      context.pop();
    } on AppException catch (error) {
      if (!mounted) return;
      AppSnackbar.error(context, error.message);
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Failed to create cycle.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create cycle')),
      body: SafeArea(
        child: AppForm(
          formKey: _formKey,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ListView(
            children: [
              FormSection(
                title: 'Cycle details',
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: 'Name',
                    hint: 'July 2026 Cycle',
                    validator: (v) =>
                        AppValidators.required(v, field: 'Name'),
                  ),
                  AppDropdown<CycleFrequency>(
                    label: 'Frequency',
                    value: _frequency,
                    items: CycleFrequency.values
                        .where((f) => f != CycleFrequency.unknown)
                        .map(
                          (f) => DropdownMenuItem(
                            value: f,
                            child: Text(f.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _frequency = value);
                    },
                    validator: (v) =>
                        v == null ? 'Select a frequency' : null,
                  ),
                  AppAmountField(
                    controller: _amountController,
                    label: 'Contribution amount',
                    currencyCode: 'KES',
                  ),
                  AppAmountField(
                    controller: _penaltyController,
                    label: 'Penalty amount',
                    currencyCode: 'KES',
                    isRequired: false,
                    min: 0,
                  ),
                  AppTextField(
                    controller: _dueDayController,
                    label: 'Due day',
                    hint: _frequency == CycleFrequency.weekly
                        ? '1–7 (Mon–Sun)'
                        : '1–31',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final day = int.tryParse(v?.trim() ?? '');
                      if (day == null) return 'Enter a due day';
                      if (_frequency == CycleFrequency.weekly) {
                        if (day < 1 || day > 7) {
                          return 'Weekly due day must be 1–7';
                        }
                      } else if (day < 1 || day > 31) {
                        return 'Due day must be 1–31';
                      }
                      return null;
                    },
                  ),
                  AppDatePicker(
                    label: 'Start date',
                    initialValue: _startDate,
                    onChanged: (d) => setState(() => _startDate = d),
                    onSaved: (d) => _startDate = d,
                  ),
                  AppDatePicker(
                    label: 'End date',
                    initialValue: _endDate,
                    firstDate: _startDate,
                    onChanged: (d) => setState(() => _endDate = d),
                    onSaved: (d) => _endDate = d,
                    validator: (d) {
                      if (d == null) return 'Select an end date';
                      if (_startDate != null && d.isBefore(_startDate!)) {
                        return 'End date must be on or after start date';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSubmitButton(
                label: 'Create cycle',
                formKey: _formKey,
                isLoading: _submitting,
                onSubmit: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
