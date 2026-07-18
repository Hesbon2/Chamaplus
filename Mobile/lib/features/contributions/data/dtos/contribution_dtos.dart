import '../../domain/entities/contribution.dart';

class ContributionCycleDto {
  const ContributionCycleDto({
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
  final String frequency;
  final String contributionAmount;
  final String startDate;
  final String endDate;
  final int dueDay;
  final String penaltyAmount;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  factory ContributionCycleDto.fromJson(Map<String, dynamic> json) {
    return ContributionCycleDto(
      id: json['id'] as String,
      chamaId: json['chama_id'] as String? ?? '',
      name: json['name'] as String,
      frequency: json['frequency'] as String? ?? 'monthly',
      contributionAmount: '${json['contribution_amount'] ?? '0.00'}',
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      dueDay: json['due_day'] as int? ?? 1,
      penaltyAmount: '${json['penalty_amount'] ?? '0.00'}',
      status: json['status'] as String? ?? 'open',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  ContributionCycle toEntity() {
    return ContributionCycle(
      id: id,
      chamaId: chamaId,
      name: name,
      frequency: CycleFrequency.fromApi(frequency),
      contributionAmount: contributionAmount,
      startDate: DateTime.parse(startDate),
      endDate: DateTime.parse(endDate),
      dueDay: dueDay,
      penaltyAmount: penaltyAmount,
      status: CycleStatus.fromApi(status),
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }
}

class ContributionDto {
  const ContributionDto({
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
  final String paymentMethod;
  final String reference;
  final String recordedBy;
  final String recordedAt;
  final String? createdAt;

  factory ContributionDto.fromJson(Map<String, dynamic> json) {
    return ContributionDto(
      id: json['id'] as String,
      memberId: json['member_id'] as String,
      cycleId: json['cycle_id'] as String,
      amount: '${json['amount'] ?? '0.00'}',
      currency: json['currency'] as String? ?? 'KES',
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      reference: json['reference'] as String? ?? '',
      recordedBy: json['recorded_by'] as String? ?? '',
      recordedAt: json['recorded_at'] as String,
      createdAt: json['created_at'] as String?,
    );
  }

  Contribution toEntity() {
    return Contribution(
      id: id,
      memberId: memberId,
      cycleId: cycleId,
      amount: amount,
      currency: currency,
      paymentMethod: PaymentMethod.fromApi(paymentMethod),
      reference: reference,
      recordedBy: recordedBy,
      recordedAt: DateTime.parse(recordedAt),
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    );
  }
}

class ContributionsPageDto {
  const ContributionsPageDto({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<ContributionDto> results;

  factory ContributionsPageDto.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>? ?? [];
    return ContributionsPageDto(
      count: json['count'] as int? ?? results.length,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: results
          .map((e) => ContributionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ContributionSummaryDto {
  const ContributionSummaryDto({
    required this.totalAmount,
    required this.totalCount,
    required this.currency,
  });

  final String totalAmount;
  final int totalCount;
  final String currency;

  factory ContributionSummaryDto.fromJson(Map<String, dynamic> json) {
    return ContributionSummaryDto(
      totalAmount: '${json['total_amount'] ?? '0.00'}',
      totalCount: json['total_count'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'KES',
    );
  }

  ContributionSummary toEntity() {
    return ContributionSummary(
      totalAmount: totalAmount,
      totalCount: totalCount,
      currency: currency,
    );
  }
}

class MemberContributionSummaryDto {
  const MemberContributionSummaryDto({
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

  factory MemberContributionSummaryDto.fromJson(Map<String, dynamic> json) {
    return MemberContributionSummaryDto(
      memberId: json['member_id'] as String? ?? '',
      contributionsTotal: '${json['contributions_total'] ?? '0.00'}',
      contributionsCount: json['contributions_count'] as int? ?? 0,
      activeLoans: json['active_loans'] as int? ?? 0,
      repaymentsTotal: json['repayments_total']?.toString(),
      creditScore: json['credit_score'] as int?,
      creditRiskLevel: json['credit_risk_level'] as String?,
    );
  }

  MemberContributionSummary toEntity() {
    return MemberContributionSummary(
      memberId: memberId,
      contributionsTotal: contributionsTotal,
      contributionsCount: contributionsCount,
      activeLoans: activeLoans,
      repaymentsTotal: repaymentsTotal,
      creditScore: creditScore,
      creditRiskLevel: creditRiskLevel,
    );
  }
}
