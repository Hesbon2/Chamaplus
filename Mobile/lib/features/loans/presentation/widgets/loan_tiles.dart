import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/components/components.dart';
import '../../domain/entities/loan.dart';
import '../utils/loan_ui_mapper.dart';

/// List tile for a loan product.
class LoanProductTile extends StatelessWidget {
  const LoanProductTile({
    super.key,
    required this.product,
    this.onTap,
  });

  final LoanProduct product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          AvatarBadge(
            initials: product.name.isNotEmpty ? product.name[0] : 'L',
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: theme.textTheme.titleSmall),
                Text(
                  '${LoanFormatters.percent(product.interestRate)} · '
                  'up to ${LoanFormatters.money(product.maximumAmount)}',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  'Max ${product.maximumDuration} months',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          StatusChip(
            label: product.isActive ? 'Active' : 'Inactive',
            tone: product.isActive
                ? StatusChipTone.success
                : StatusChipTone.neutral,
            compact: true,
          ),
        ],
      ),
    );
  }
}

/// List tile for a loan application.
class LoanApplicationTile extends StatelessWidget {
  const LoanApplicationTile({
    super.key,
    required this.application,
    this.onTap,
    this.productName,
  });

  final LoanApplication application;
  final VoidCallback? onTap;
  final String? productName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          const AvatarBadge(
            initials: 'L',
            icon: Icons.request_quote_outlined,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LoanFormatters.money(application.requestedAmount),
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  productName ?? application.purpose,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  LoanFormatters.date(application.appliedAt ?? application.createdAt),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          StatusChip(
            label: application.status.label,
            tone: LoanUiMapper.toneForStatus(application.status),
            compact: true,
          ),
        ],
      ),
    );
  }
}

/// List tile for a repayment row.
class LoanRepaymentTile extends StatelessWidget {
  const LoanRepaymentTile({
    super.key,
    required this.repayment,
    this.remainingBalance,
  });

  final LoanRepayment repayment;
  final double? remainingBalance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        children: [
          AvatarBadge(
            initials: repayment.reference.isNotEmpty
                ? repayment.reference[0].toUpperCase()
                : 'R',
            icon: Icons.payments_outlined,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LoanFormatters.money(
                    repayment.amount,
                    currency: repayment.currency,
                  ),
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  repayment.reference,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  LoanFormatters.date(repayment.paymentDate),
                  style: theme.textTheme.bodySmall,
                ),
                if (remainingBalance != null)
                  Text(
                    'Remaining ${LoanFormatters.money(remainingBalance!)}',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          StatusChip(
            label: repayment.paymentMethod.label,
            tone: LoanUiMapper.toneForPayment(repayment.paymentMethod),
            compact: true,
          ),
        ],
      ),
    );
  }
}
