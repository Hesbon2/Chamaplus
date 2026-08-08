import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/forms/forms.dart';
import '../../domain/entities/loan.dart';

/// Shared create/edit form fields for loan products (backend contract).
class LoanProductForm extends StatefulWidget {
  const LoanProductForm({
    super.key,
    required this.formKey,
    required this.isSubmitting,
    required this.submitLabel,
    required this.onSubmit,
    this.initial,
  });

  final GlobalKey<FormState> formKey;
  final bool isSubmitting;
  final String submitLabel;
  final Future<void> Function(LoanProductInput input) onSubmit;
  final LoanProduct? initial;

  @override
  State<LoanProductForm> createState() => LoanProductFormState();
}

class LoanProductFormState extends State<LoanProductForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _interestController;
  late final TextEditingController _minAmountController;
  late final TextEditingController _maxAmountController;
  late final TextEditingController _durationController;
  late final TextEditingController _graceController;
  late final TextEditingController _feeController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _descriptionController =
        TextEditingController(text: initial?.description ?? '');
    _interestController = TextEditingController(
      text: initial == null ? '' : _fmt(initial.interestRate),
    );
    _minAmountController = TextEditingController(
      text: initial == null ? '' : _fmt(initial.minimumAmount),
    );
    _maxAmountController = TextEditingController(
      text: initial == null ? '' : _fmt(initial.maximumAmount),
    );
    _durationController = TextEditingController(
      text: initial == null ? '' : '${initial.maximumDuration}',
    );
    _graceController = TextEditingController(
      text: initial == null ? '0' : '${initial.gracePeriodDays}',
    );
    _feeController = TextEditingController(
      text: initial == null ? '0' : _fmt(initial.processingFee),
    );
    _isActive = initial?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _interestController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _durationController.dispose();
    _graceController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  String _fmt(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  double? _parseAmount(String? raw) {
    if (raw == null) return null;
    return double.tryParse(raw.trim().replaceAll(',', ''));
  }

  Future<void> _handleSubmit() async {
    if (!widget.formKey.currentState!.validate()) return;

    final minAmount = _parseAmount(_minAmountController.text)!;
    final maxAmount = _parseAmount(_maxAmountController.text)!;
    final interest = _parseAmount(_interestController.text)!;
    final fee = _parseAmount(_feeController.text) ?? 0;
    final duration = int.parse(_durationController.text.trim());
    final grace = int.tryParse(_graceController.text.trim()) ?? 0;

    await widget.onSubmit(
      LoanProductInput(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        interestRate: interest,
        minimumAmount: minAmount,
        maximumAmount: maxAmount,
        maximumDuration: duration,
        gracePeriodDays: grace,
        processingFee: fee,
        isActive: _isActive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppForm(
      formKey: widget.formKey,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormSection(
              title: 'Product details',
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Name',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => AppValidators.required(v, field: 'Name'),
                ),
                AppMultilineField(
                  controller: _descriptionController,
                  label: 'Description (optional)',
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  subtitle: const Text('Members can apply when active'),
                  value: _isActive,
                  onChanged: widget.isSubmitting
                      ? null
                      : (value) => setState(() => _isActive = value),
                  secondary: StatusChip(
                    label: _isActive ? 'Active' : 'Inactive',
                    tone: _isActive
                        ? StatusChipTone.success
                        : StatusChipTone.neutral,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            FormSection(
              title: 'Amounts & rates',
              children: [
                AppAmountField(
                  controller: _minAmountController,
                  label: 'Minimum amount',
                  validator: (v) => AppValidators.amount(v),
                ),
                AppAmountField(
                  controller: _maxAmountController,
                  label: 'Maximum amount',
                  validator: (v) {
                    final base = AppValidators.amount(v);
                    if (base != null) return base;
                    final maxAmount = _parseAmount(v);
                    final minAmount = _parseAmount(_minAmountController.text);
                    if (minAmount != null &&
                        maxAmount != null &&
                        minAmount > maxAmount) {
                      return 'Must be greater than or equal to minimum amount';
                    }
                    return null;
                  },
                ),
                AppTextField(
                  controller: _interestController,
                  label: 'Interest rate',
                  hint: 'e.g. 12',
                  suffixText: '%',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  validator: (v) {
                    final required =
                        AppValidators.required(v, field: 'Interest rate');
                    if (required != null) return required;
                    final rate = _parseAmount(v);
                    if (rate == null) return 'Enter a valid rate';
                    if (rate < 0) return 'Rate cannot be negative';
                    if (rate > 100) return 'Rate cannot exceed 100%';
                    return null;
                  },
                ),
                AppAmountField(
                  controller: _feeController,
                  label: 'Processing fee',
                  isRequired: true,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Processing fee is required';
                    }
                    final fee = _parseAmount(v);
                    if (fee == null) return 'Enter a valid amount';
                    if (fee < 0) return 'Fee cannot be negative';
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            FormSection(
              title: 'Duration',
              children: [
                AppTextField(
                  controller: _durationController,
                  label: 'Maximum duration (months)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    final required =
                        AppValidators.required(v, field: 'Maximum duration');
                    if (required != null) return required;
                    final months = int.tryParse(v!.trim());
                    if (months == null || months < 1) {
                      return 'Enter at least 1 month';
                    }
                    return null;
                  },
                ),
                AppTextField(
                  controller: _graceController,
                  label: 'Grace period (days)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Grace period is required';
                    }
                    final days = int.tryParse(v.trim());
                    if (days == null || days < 0) {
                      return 'Enter zero or a positive number';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSubmitButton(
              label: widget.submitLabel,
              formKey: widget.formKey,
              isLoading: widget.isSubmitting,
              onSubmit: widget.isSubmitting ? null : _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
