import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/forms/forms.dart';
import '../../domain/entities/loan.dart';
import '../controllers/loan_controllers.dart';
import '../providers/loan_providers.dart';
import '../utils/loan_ui_mapper.dart';

/// Apply for a loan using the shared form framework.
class ApplyLoanScreen extends ConsumerStatefulWidget {
  const ApplyLoanScreen({
    super.key,
    required this.chamaId,
    this.initialProductId,
  });

  final String chamaId;
  final String? initialProductId;

  @override
  ConsumerState<ApplyLoanScreen> createState() => _ApplyLoanScreenState();
}

class _ApplyLoanScreenState extends ConsumerState<ApplyLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _durationController = TextEditingController();
  final _purposeController = TextEditingController();
  final _notesController = TextEditingController();
  LoanProduct? _product;
  bool _didSeedProduct = false;

  @override
  void dispose() {
    _amountController.dispose();
    _durationController.dispose();
    _purposeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final product = _product;
    if (product == null) {
      AppSnackbar.error(context, 'Select a loan product.');
      return;
    }

    final amount = double.parse(_amountController.text.trim());
    final duration = int.parse(_durationController.text.trim());

    try {
      final app = await ref.read(applyLoanControllerProvider.notifier).submit(
            chamaId: widget.chamaId,
            input: ApplyLoanInput(
              loanProductId: product.id,
              requestedAmount: amount,
              requestedDuration: duration,
              purpose: _purposeController.text.trim(),
              remarks: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
              submit: true,
            ),
          );

      if (!mounted) return;
      if (app == null) {
        final error = ref.read(applyLoanControllerProvider).errorMessage;
        AppSnackbar.error(
          context,
          (error == null || error.isEmpty)
              ? 'Could not submit application.'
              : error.replaceFirst(RegExp(r'^Exception:\s*'), ''),
        );
        return;
      }

      AppSnackbar.success(context, 'Loan application submitted.');
      context.go(RoutePaths.loanDetails(widget.chamaId, app.id));
    } on AppException catch (error) {
      if (!mounted) return;
      AppSnackbar.error(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync =
        ref.watch(activeLoanProductsProvider(widget.chamaId));
    final applyState = ref.watch(applyLoanControllerProvider);

    ref.listen<ApplyLoanState>(applyLoanControllerProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        AppSnackbar.error(
          context,
          next.errorMessage!.replaceFirst(RegExp(r'^Exception:\s*'), ''),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Apply for loan')),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(e is AppException ? e.message : e.toString()),
        ),
        data: (products) {
          if (!_didSeedProduct &&
              widget.initialProductId != null &&
              _product == null) {
            final match = products
                .where((p) => p.id == widget.initialProductId)
                .toList();
            if (match.isNotEmpty) {
              _didSeedProduct = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  _product = match.first;
                  _durationController.text =
                      '${match.first.maximumDuration}';
                });
              });
            }
          }

          return SafeArea(
            child: AppForm(
              formKey: _formKey,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ListView(
                children: [
                  FormSection(
                    title: 'Application details',
                    children: [
                      AppDropdown<LoanProduct>(
                        label: 'Loan product',
                        value: _product,
                        items: products
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.name),
                              ),
                            )
                            .toList(),
                        validator: (v) =>
                            v == null ? 'Select a product' : null,
                        onChanged: (value) {
                          setState(() {
                            _product = value;
                            if (value != null) {
                              _durationController.text =
                                  '${value.maximumDuration}';
                            }
                          });
                        },
                      ),
                      AppAmountField(
                        controller: _amountController,
                        label: 'Requested amount',
                        validator: (v) {
                          final base =
                              AppValidators.required(v, field: 'Amount');
                          if (base != null) return base;
                          final amount = double.tryParse(v!.trim());
                          if (amount == null || amount <= 0) {
                            return 'Enter a valid amount';
                          }
                          final product = _product;
                          if (product != null) {
                            if (amount < product.minimumAmount) {
                              return 'Minimum is ${LoanFormatters.money(product.minimumAmount)}';
                            }
                            if (amount > product.maximumAmount) {
                              return 'Maximum is ${LoanFormatters.money(product.maximumAmount)}';
                            }
                          }
                          return null;
                        },
                      ),
                      AppTextField(
                        controller: _durationController,
                        label: 'Duration (months)',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final base =
                              AppValidators.required(v, field: 'Duration');
                          if (base != null) return base;
                          final months = int.tryParse(v!.trim());
                          if (months == null || months <= 0) {
                            return 'Enter months';
                          }
                          final product = _product;
                          if (product != null &&
                              months > product.maximumDuration) {
                            return 'Max ${product.maximumDuration} months';
                          }
                          return null;
                        },
                      ),
                      AppTextField(
                        controller: _purposeController,
                        label: 'Purpose',
                        validator: (v) =>
                            AppValidators.required(v, field: 'Purpose'),
                      ),
                      AppMultilineField(
                        controller: _notesController,
                        label: 'Notes (optional)',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppSubmitButton(
                    label: 'Submit application',
                    formKey: _formKey,
                    isLoading: applyState.isSubmitting,
                    onSubmit: applyState.isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
