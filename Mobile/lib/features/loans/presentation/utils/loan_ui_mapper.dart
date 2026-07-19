import 'package:intl/intl.dart';

import '../../../../shared/components/components.dart';
import '../../domain/entities/loan.dart';

/// Maps loan domain values to design-system presentation helpers.
class LoanUiMapper {
  LoanUiMapper._();

  static StatusChipTone toneForStatus(LoanApplicationStatus status) {
    switch (status) {
      case LoanApplicationStatus.draft:
        return StatusChipTone.neutral;
      case LoanApplicationStatus.pending:
        return StatusChipTone.warning;
      case LoanApplicationStatus.approved:
        return StatusChipTone.info;
      case LoanApplicationStatus.rejected:
        return StatusChipTone.error;
      case LoanApplicationStatus.cancelled:
        return StatusChipTone.neutral;
      case LoanApplicationStatus.disbursed:
        return StatusChipTone.success;
      case LoanApplicationStatus.repaid:
        return StatusChipTone.success;
      case LoanApplicationStatus.unknown:
        return StatusChipTone.neutral;
    }
  }

  static StatusChipTone toneForVote(VoteDecision decision) {
    switch (decision) {
      case VoteDecision.approve:
        return StatusChipTone.success;
      case VoteDecision.reject:
        return StatusChipTone.error;
      case VoteDecision.abstain:
        return StatusChipTone.neutral;
      case VoteDecision.unknown:
        return StatusChipTone.neutral;
    }
  }

  static StatusChipTone toneForPayment(LoanPaymentMethod method) {
    switch (method) {
      case LoanPaymentMethod.mpesa:
      case LoanPaymentMethod.bank:
        return StatusChipTone.info;
      case LoanPaymentMethod.cash:
        return StatusChipTone.success;
      case LoanPaymentMethod.unknown:
        return StatusChipTone.neutral;
    }
  }
}

/// Shared money / date formatters for the loans feature.
class LoanFormatters {
  LoanFormatters._();

  static final _money = NumberFormat('#,##0.00');
  static final _date = DateFormat('d MMM yyyy');

  static String money(num amount, {String currency = 'KES'}) {
    return '$currency ${_money.format(amount)}';
  }

  static String date(DateTime? value) {
    if (value == null) return '—';
    return _date.format(value.toLocal());
  }

  static String percent(num rate) => '${rate.toStringAsFixed(2)}%';
}
