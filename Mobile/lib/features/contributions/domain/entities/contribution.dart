export '../../../../core/models/paged_result.dart';

/// Lifecycle status of a contribution cycle.
enum CycleStatus {
  open,
  closed,
  unknown;

  static CycleStatus fromApi(String? value) {
    switch (value) {
      case 'open':
        return CycleStatus.open;
      case 'closed':
        return CycleStatus.closed;
      default:
        return CycleStatus.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case CycleStatus.open:
        return 'open';
      case CycleStatus.closed:
        return 'closed';
      case CycleStatus.unknown:
        return 'unknown';
    }
  }

  String get label {
    switch (this) {
      case CycleStatus.open:
        return 'Open';
      case CycleStatus.closed:
        return 'Closed';
      case CycleStatus.unknown:
        return 'Unknown';
    }
  }
}

/// How often contributions are expected in a cycle.
enum CycleFrequency {
  weekly,
  monthly,
  quarterly,
  annually,
  unknown;

  static CycleFrequency fromApi(String? value) {
    switch (value) {
      case 'weekly':
        return CycleFrequency.weekly;
      case 'monthly':
        return CycleFrequency.monthly;
      case 'quarterly':
        return CycleFrequency.quarterly;
      case 'annually':
        return CycleFrequency.annually;
      default:
        return CycleFrequency.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case CycleFrequency.weekly:
        return 'weekly';
      case CycleFrequency.monthly:
        return 'monthly';
      case CycleFrequency.quarterly:
        return 'quarterly';
      case CycleFrequency.annually:
        return 'annually';
      case CycleFrequency.unknown:
        return 'unknown';
    }
  }

  String get label {
    switch (this) {
      case CycleFrequency.weekly:
        return 'Weekly';
      case CycleFrequency.monthly:
        return 'Monthly';
      case CycleFrequency.quarterly:
        return 'Quarterly';
      case CycleFrequency.annually:
        return 'Annually';
      case CycleFrequency.unknown:
        return 'Unknown';
    }
  }
}

/// How a contribution payment was made.
enum PaymentMethod {
  cash,
  mpesa,
  bank,
  unknown;

  static PaymentMethod fromApi(String? value) {
    switch (value) {
      case 'cash':
        return PaymentMethod.cash;
      case 'mpesa':
        return PaymentMethod.mpesa;
      case 'bank':
        return PaymentMethod.bank;
      default:
        return PaymentMethod.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.mpesa:
        return 'mpesa';
      case PaymentMethod.bank:
        return 'bank';
      case PaymentMethod.unknown:
        return 'unknown';
    }
  }

  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.mpesa:
        return 'M-Pesa';
      case PaymentMethod.bank:
        return 'Bank';
      case PaymentMethod.unknown:
        return 'Unknown';
    }
  }
}

/// A scheduled contribution period for a Chama.
class ContributionCycle {
  const ContributionCycle({
    required this.id,
    required this.chamaId,
    required this.name,
    required this.frequency,
    required this.contributionAmount,
    required this.startDate,
    required this.endDate,
    required this.dueDay,
    required this.penaltyAmount,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String chamaId;
  final String name;
  final CycleFrequency frequency;
  final String contributionAmount;
  final DateTime startDate;
  final DateTime endDate;
  final int dueDay;
  final String penaltyAmount;
  final CycleStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isOpen => status == CycleStatus.open;
}

/// An immutable recorded contribution payment.
class Contribution {
  const Contribution({
    required this.id,
    required this.memberId,
    required this.cycleId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.reference,
    required this.recordedBy,
    required this.recordedAt,
    this.createdAt,
  });

  final String id;
  final String memberId;
  final String cycleId;
  final String amount;
  final String currency;
  final PaymentMethod paymentMethod;
  final String reference;
  final String recordedBy;
  final DateTime recordedAt;
  final DateTime? createdAt;
}

/// Aggregate totals for a Chama's contributions.
class ContributionSummary {
  const ContributionSummary({
    required this.totalAmount,
    required this.totalCount,
    required this.currency,
  });

  final String totalAmount;
  final int totalCount;
  final String currency;
}

/// Dashboard payload for the contributions module.
class ContributionDashboard {
  const ContributionDashboard({
    required this.summary,
    required this.openCycles,
    required this.recentContributions,
  });

  final ContributionSummary summary;
  final List<ContributionCycle> openCycles;
  final List<Contribution> recentContributions;

  bool get hasOpenCycle => openCycles.isNotEmpty;
}

/// Per-member contribution (and related finance) summary.
class MemberContributionSummary {
  const MemberContributionSummary({
    required this.memberId,
    required this.contributionsTotal,
    required this.contributionsCount,
    this.activeLoans = 0,
    this.repaymentsTotal,
    this.creditScore,
    this.creditRiskLevel,
  });

  final String memberId;
  final String contributionsTotal;
  final int contributionsCount;
  final int activeLoans;
  final String? repaymentsTotal;
  final int? creditScore;
  final String? creditRiskLevel;
}

/// Input for creating a contribution cycle.
class CreateCycleInput {
  const CreateCycleInput({
    required this.name,
    required this.frequency,
    required this.contributionAmount,
    required this.startDate,
    required this.endDate,
    required this.dueDay,
    this.penaltyAmount = '0.00',
  });

  final String name;
  final CycleFrequency frequency;
  final String contributionAmount;
  final DateTime startDate;
  final DateTime endDate;
  final int dueDay;
  final String penaltyAmount;
}

/// Input for recording a contribution.
class RecordContributionInput {
  const RecordContributionInput({
    required this.cycleId,
    required this.memberId,
    required this.amount,
    required this.paymentMethod,
    required this.reference,
    this.recordedAt,
    this.idempotencyKey,
  });

  final String cycleId;
  final String memberId;
  final String amount;
  final PaymentMethod paymentMethod;
  final String reference;
  final DateTime? recordedAt;
  final String? idempotencyKey;
}
