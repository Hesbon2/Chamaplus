export '../../../../core/models/paged_result.dart';

/// Lifecycle status of a loan application.
enum LoanApplicationStatus {
  draft,
  pending,
  approved,
  rejected,
  cancelled,
  disbursed,
  repaid,
  unknown;

  static LoanApplicationStatus fromApi(String? value) {
    switch (value) {
      case 'draft':
        return LoanApplicationStatus.draft;
      case 'pending':
        return LoanApplicationStatus.pending;
      case 'approved':
        return LoanApplicationStatus.approved;
      case 'rejected':
        return LoanApplicationStatus.rejected;
      case 'cancelled':
        return LoanApplicationStatus.cancelled;
      case 'disbursed':
        return LoanApplicationStatus.disbursed;
      case 'repaid':
        return LoanApplicationStatus.repaid;
      default:
        return LoanApplicationStatus.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case LoanApplicationStatus.draft:
        return 'draft';
      case LoanApplicationStatus.pending:
        return 'pending';
      case LoanApplicationStatus.approved:
        return 'approved';
      case LoanApplicationStatus.rejected:
        return 'rejected';
      case LoanApplicationStatus.cancelled:
        return 'cancelled';
      case LoanApplicationStatus.disbursed:
        return 'disbursed';
      case LoanApplicationStatus.repaid:
        return 'repaid';
      case LoanApplicationStatus.unknown:
        return 'unknown';
    }
  }

  String get label {
    switch (this) {
      case LoanApplicationStatus.draft:
        return 'Draft';
      case LoanApplicationStatus.pending:
        return 'Pending';
      case LoanApplicationStatus.approved:
        return 'Approved';
      case LoanApplicationStatus.rejected:
        return 'Rejected';
      case LoanApplicationStatus.cancelled:
        return 'Cancelled';
      case LoanApplicationStatus.disbursed:
        return 'Disbursed';
      case LoanApplicationStatus.repaid:
        return 'Repaid';
      case LoanApplicationStatus.unknown:
        return 'Unknown';
    }
  }

  bool get isActiveLoan =>
      this == LoanApplicationStatus.disbursed;

  bool get isTerminal =>
      this == LoanApplicationStatus.repaid ||
      this == LoanApplicationStatus.rejected ||
      this == LoanApplicationStatus.cancelled;
}

/// Committee vote decision.
enum VoteDecision {
  approve,
  reject,
  abstain,
  unknown;

  static VoteDecision fromApi(String? value) {
    switch (value) {
      case 'approve':
        return VoteDecision.approve;
      case 'reject':
        return VoteDecision.reject;
      case 'abstain':
        return VoteDecision.abstain;
      default:
        return VoteDecision.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case VoteDecision.approve:
        return 'approve';
      case VoteDecision.reject:
        return 'reject';
      case VoteDecision.abstain:
        return 'abstain';
      case VoteDecision.unknown:
        return 'unknown';
    }
  }

  String get label {
    switch (this) {
      case VoteDecision.approve:
        return 'Approve';
      case VoteDecision.reject:
        return 'Reject';
      case VoteDecision.abstain:
        return 'Abstain';
      case VoteDecision.unknown:
        return 'Unknown';
    }
  }
}

/// How a loan repayment was made.
enum LoanPaymentMethod {
  cash,
  mpesa,
  bank,
  unknown;

  static LoanPaymentMethod fromApi(String? value) {
    switch (value) {
      case 'cash':
        return LoanPaymentMethod.cash;
      case 'mpesa':
        return LoanPaymentMethod.mpesa;
      case 'bank':
        return LoanPaymentMethod.bank;
      default:
        return LoanPaymentMethod.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case LoanPaymentMethod.cash:
        return 'cash';
      case LoanPaymentMethod.mpesa:
        return 'mpesa';
      case LoanPaymentMethod.bank:
        return 'bank';
      case LoanPaymentMethod.unknown:
        return 'unknown';
    }
  }

  String get label {
    switch (this) {
      case LoanPaymentMethod.cash:
        return 'Cash';
      case LoanPaymentMethod.mpesa:
        return 'M-Pesa';
      case LoanPaymentMethod.bank:
        return 'Bank';
      case LoanPaymentMethod.unknown:
        return 'Unknown';
    }
  }
}

/// A loan product offered by a Chama.
class LoanProduct {
  const LoanProduct({
    required this.id,
    required this.chamaId,
    required this.name,
    this.description,
    required this.interestRate,
    required this.minimumAmount,
    required this.maximumAmount,
    required this.maximumDuration,
    required this.gracePeriodDays,
    required this.processingFee,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String chamaId;
  final String name;
  final String? description;
  final double interestRate;
  final double minimumAmount;
  final double maximumAmount;
  final int maximumDuration;
  final int gracePeriodDays;
  final double processingFee;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

/// A member's loan application.
class LoanApplication {
  const LoanApplication({
    required this.id,
    required this.applicantId,
    required this.chamaId,
    required this.loanProductId,
    required this.requestedAmount,
    required this.requestedDuration,
    required this.purpose,
    required this.status,
    this.appliedAt,
    this.approvedAt,
    this.rejectedAt,
    this.approvedBy,
    this.approvedAmount,
    this.outstandingBalance,
    this.remarks,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String applicantId;
  final String chamaId;
  final String loanProductId;
  final double requestedAmount;
  final int requestedDuration;
  final String purpose;
  final LoanApplicationStatus status;
  final DateTime? appliedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? approvedBy;
  final double? approvedAmount;
  final double? outstandingBalance;
  final String? remarks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  double get principalAmount => approvedAmount ?? requestedAmount;

  double get amountPaid {
    final outstanding = outstandingBalance;
    if (outstanding == null) return 0;
    final paid = principalAmount - outstanding;
    return paid < 0 ? 0 : paid;
  }

  double get repaymentProgressPercent {
    if (principalAmount <= 0) return 0;
    return ((amountPaid / principalAmount) * 100).clamp(0, 100);
  }
}

/// A committee vote on a loan application.
class CommitteeVote {
  const CommitteeVote({
    required this.id,
    required this.loanApplicationId,
    required this.voterId,
    required this.decision,
    this.comment,
    this.createdAt,
  });

  final String id;
  final String loanApplicationId;
  final String voterId;
  final VoteDecision decision;
  final String? comment;
  final DateTime? createdAt;
}

/// A recorded loan repayment.
class LoanRepayment {
  const LoanRepayment({
    required this.id,
    required this.loanApplicationId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.reference,
    required this.paymentDate,
    this.recordedBy,
    this.createdAt,
  });

  final String id;
  final String loanApplicationId;
  final double amount;
  final String currency;
  final LoanPaymentMethod paymentMethod;
  final String reference;
  final DateTime paymentDate;
  final String? recordedBy;
  final DateTime? createdAt;
}

/// Optional credit score snapshot for loan dashboards.
class MemberCreditScore {
  const MemberCreditScore({
    required this.id,
    required this.memberId,
    required this.score,
    required this.riskLevel,
    this.calculatedAt,
  });

  final String id;
  final String memberId;
  final int score;
  final String riskLevel;
  final DateTime? calculatedAt;
}

/// Composite loan dashboard for a chama member.
class LoanDashboard {
  const LoanDashboard({
    this.activeLoan,
    this.activeProduct,
    required this.loanLimit,
    required this.outstandingBalance,
    this.creditScore,
    required this.recentApplications,
    this.nextInstallmentEstimate,
    required this.currency,
  });

  final LoanApplication? activeLoan;
  final LoanProduct? activeProduct;
  final double loanLimit;
  final double outstandingBalance;
  final MemberCreditScore? creditScore;
  final List<LoanApplication> recentApplications;
  final double? nextInstallmentEstimate;
  final String currency;
}

/// Client-side loan repayment estimate (flat interest).
class LoanCalculation {
  const LoanCalculation({
    required this.principal,
    required this.durationMonths,
    required this.annualInterestRate,
    required this.monthlyRepayment,
    required this.totalInterest,
    required this.totalRepayment,
  });

  final double principal;
  final int durationMonths;
  final double annualInterestRate;
  final double monthlyRepayment;
  final double totalInterest;
  final double totalRepayment;

  /// Flat interest estimate used for calculator UX.
  factory LoanCalculation.flat({
    required double principal,
    required int durationMonths,
    required double annualInterestRate,
  }) {
    if (principal <= 0 || durationMonths <= 0) {
      return LoanCalculation(
        principal: principal,
        durationMonths: durationMonths,
        annualInterestRate: annualInterestRate,
        monthlyRepayment: 0,
        totalInterest: 0,
        totalRepayment: 0,
      );
    }
    final totalInterest =
        principal * (annualInterestRate / 100) * (durationMonths / 12);
    final totalRepayment = principal + totalInterest;
    return LoanCalculation(
      principal: principal,
      durationMonths: durationMonths,
      annualInterestRate: annualInterestRate,
      monthlyRepayment: totalRepayment / durationMonths,
      totalInterest: totalInterest,
      totalRepayment: totalRepayment,
    );
  }
}

/// Input for creating or updating a loan product (matches backend serializers).
class LoanProductInput {
  const LoanProductInput({
    required this.name,
    this.description,
    required this.interestRate,
    required this.minimumAmount,
    required this.maximumAmount,
    required this.maximumDuration,
    this.gracePeriodDays = 0,
    this.processingFee = 0,
    this.isActive = true,
  });

  final String name;
  final String? description;
  final double interestRate;
  final double minimumAmount;
  final double maximumAmount;
  final int maximumDuration;
  final int gracePeriodDays;
  final double processingFee;
  final bool isActive;

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'description': description?.trim() ?? '',
      'interest_rate': interestRate.toStringAsFixed(2),
      'minimum_amount': minimumAmount.toStringAsFixed(2),
      'maximum_amount': maximumAmount.toStringAsFixed(2),
      'maximum_duration': maximumDuration,
      'grace_period_days': gracePeriodDays,
      'processing_fee': processingFee.toStringAsFixed(2),
      'is_active': isActive,
    };
  }
}

/// Input for creating / submitting a loan application.
class ApplyLoanInput {
  const ApplyLoanInput({
    required this.loanProductId,
    required this.requestedAmount,
    required this.requestedDuration,
    required this.purpose,
    this.remarks,
    this.submit = true,
  });

  final String loanProductId;
  final double requestedAmount;
  final int requestedDuration;
  final String purpose;
  final String? remarks;
  final bool submit;
}

/// Input for casting a committee vote.
class CastVoteInput {
  const CastVoteInput({
    required this.decision,
    this.comment,
  });

  final VoteDecision decision;
  final String? comment;
}

/// Input for recording a repayment (treasurer).
class RecordRepaymentInput {
  const RecordRepaymentInput({
    required this.amount,
    required this.paymentMethod,
    required this.reference,
    this.paymentDate,
  });

  final double amount;
  final LoanPaymentMethod paymentMethod;
  final String reference;
  final DateTime? paymentDate;
}
