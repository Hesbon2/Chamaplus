import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/forms/forms.dart';
import '../../domain/entities/loan.dart';
import '../providers/loan_providers.dart';
import '../utils/loan_ui_mapper.dart';

/// Client-side loan repayment calculator (flat interest estimate).
class LoanCalculatorScreen extends ConsumerStatefulWidget {
  const LoanCalculatorScreen({super.key, required this.chamaId});

  final String chamaId;

  @override
  ConsumerState<LoanCalculatorScreen> createState() =>
      _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends ConsumerState<LoanCalculatorScreen> {
  LoanProduct? _product;
  final _amountController = TextEditingController();
  final _durationController = TextEditingController();
  LoanCalculation? _result;

  @override
  void dispose() {
    _amountController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _recalculate() {
    final product = _product;
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final duration = int.tryParse(_durationController.text.trim()) ?? 0;
    if (product == null || amount <= 0 || duration <= 0) {
      setState(() => _result = null);
      return;
    }
    setState(() {
      _result = LoanCalculation.flat(
        principal: amount,
        durationMonths: duration,
        annualInterestRate: product.interestRate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync =
        ref.watch(activeLoanProductsProvider(widget.chamaId));

    return Scaffold(
      appBar: AppBar(title: const Text('Loan calculator')),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          title: 'Could not load products',
          message: e.toString(),
          icon: Icons.error_outline,
          actionLabel: 'Retry',
          onAction: () =>
              ref.invalidate(activeLoanProductsProvider(widget.chamaId)),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const EmptyState(
              title: 'No active products',
              message: 'Create a loan product before using the calculator.',
              icon: Icons.inventory_2_outlined,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      onChanged: (value) {
                        setState(() {
                          _product = value;
                          if (value != null &&
                              _durationController.text.isEmpty) {
                            _durationController.text =
                                '${value.maximumDuration}';
                          }
                        });
                        _recalculate();
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppAmountField(
                      controller: _amountController,
                      label: 'Amount',
                      onChanged: (_) => _recalculate(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _durationController,
                      label: 'Duration (months)',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _recalculate(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_result != null) ...[
                StatCard(
                  label: 'Monthly repayment',
                  value: LoanFormatters.money(_result!.monthlyRepayment),
                  icon: Icons.calendar_month_outlined,
                ),
                const SizedBox(height: AppSpacing.sm),
                StatCard(
                  label: 'Total interest',
                  value: LoanFormatters.money(_result!.totalInterest),
                  icon: Icons.percent,
                ),
                const SizedBox(height: AppSpacing.sm),
                ProgressStatCard(
                  title: 'Total repayment',
                  currentValue: LoanFormatters.money(_result!.totalRepayment),
                  targetValue:
                      'Principal ${LoanFormatters.money(_result!.principal)}',
                  percentage: _result!.totalRepayment <= 0
                      ? 0
                      : (_result!.principal / _result!.totalRepayment) * 100,
                  icon: Icons.payments_outlined,
                  footer: Text(
                    'Flat interest estimate at '
                    '${LoanFormatters.percent(_result!.annualInterestRate)} p.a.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ] else
                const EmptyState(
                  title: 'Enter details',
                  message:
                      'Select a product, amount, and duration to estimate repayments.',
                  icon: Icons.calculate_outlined,
                ),
            ],
          );
        },
      ),
    );
  }
}
