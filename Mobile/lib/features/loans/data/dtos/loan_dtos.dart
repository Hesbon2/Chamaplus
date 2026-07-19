import '../../domain/entities/loan.dart';

double _asDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

DateTime? _asDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse('$value');
}

class LoanProductDto {
  const LoanProductDto({
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
  final String interestRate;
  final String minimumAmount;
  final String maximumAmount;
  final int maximumDuration;
  final int gracePeriodDays;
  final String processingFee;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  factory LoanProductDto.fromJson(Map<String, dynamic> json) {
    return LoanProductDto(
      id: '${json['id']}',
      chamaId: '${json['chama_id']}',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      interestRate: '${json['interest_rate'] ?? '0'}',
      minimumAmount: '${json['minimum_amount'] ?? '0'}',
      maximumAmount: '${json['maximum_amount'] ?? '0'}',
      maximumDuration: json['maximum_duration'] as int? ?? 0,
      gracePeriodDays: json['grace_period_days'] as int? ?? 0,
      processingFee: '${json['processing_fee'] ?? '0'}',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  LoanProduct toEntity() {
    return LoanProduct(
      id: id,
      chamaId: chamaId,
      name: name,
      description: description,
      interestRate: _asDouble(interestRate),
      minimumAmount: _asDouble(minimumAmount),
      maximumAmount: _asDouble(maximumAmount),
      maximumDuration: maximumDuration,
      gracePeriodDays: gracePeriodDays,
      processingFee: _asDouble(processingFee),
      isActive: isActive,
      createdAt: _asDate(createdAt),
      updatedAt: _asDate(updatedAt),
    );
  }
}

class LoanApplicationDto {
  const LoanApplicationDto({
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
  final String requestedAmount;
  final int requestedDuration;
  final String purpose;
  final String status;
  final String? appliedAt;
  final String? approvedAt;
  final String? rejectedAt;
  final String? approvedBy;
  final String? approvedAmount;
  final String? outstandingBalance;
  final String? remarks;
  final String? createdAt;
  final String? updatedAt;

  factory LoanApplicationDto.fromJson(Map<String, dynamic> json) {
    return LoanApplicationDto(
      id: '${json['id']}',
      applicantId: '${json['applicant_id']}',
      chamaId: '${json['chama_id']}',
      loanProductId: '${json['loan_product_id']}',
      requestedAmount: '${json['requested_amount'] ?? '0'}',
      requestedDuration: json['requested_duration'] as int? ?? 0,
      purpose: json['purpose'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      appliedAt: json['applied_at'] as String?,
      approvedAt: json['approved_at'] as String?,
      rejectedAt: json['rejected_at'] as String?,
      approvedBy: json['approved_by']?.toString(),
      approvedAmount: json['approved_amount']?.toString(),
      outstandingBalance: json['outstanding_balance']?.toString(),
      remarks: json['remarks'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  LoanApplication toEntity() {
    return LoanApplication(
      id: id,
      applicantId: applicantId,
      chamaId: chamaId,
      loanProductId: loanProductId,
      requestedAmount: _asDouble(requestedAmount),
      requestedDuration: requestedDuration,
      purpose: purpose,
      status: LoanApplicationStatus.fromApi(status),
      appliedAt: _asDate(appliedAt),
      approvedAt: _asDate(approvedAt),
      rejectedAt: _asDate(rejectedAt),
      approvedBy: approvedBy,
      approvedAmount:
          approvedAmount == null ? null : _asDouble(approvedAmount),
      outstandingBalance: outstandingBalance == null
          ? null
          : _asDouble(outstandingBalance),
      remarks: remarks,
      createdAt: _asDate(createdAt),
      updatedAt: _asDate(updatedAt),
    );
  }
}

class LoanApplicationsPageDto {
  const LoanApplicationsPageDto({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final List<LoanApplicationDto> results;
  final String? next;
  final String? previous;

  factory LoanApplicationsPageDto.fromJson(Map<String, dynamic> json) {
    final resultsJson = json['results'] as List<dynamic>? ?? [];
    return LoanApplicationsPageDto(
      count: json['count'] as int? ?? resultsJson.length,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: resultsJson
          .map((e) => LoanApplicationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CommitteeVoteDto {
  const CommitteeVoteDto({
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
  final String decision;
  final String? comment;
  final String? createdAt;

  factory CommitteeVoteDto.fromJson(Map<String, dynamic> json) {
    return CommitteeVoteDto(
      id: '${json['id']}',
      loanApplicationId: '${json['loan_application_id']}',
      voterId: '${json['voter_id'] ?? json['committee_member_id']}',
      decision: json['decision'] as String? ?? 'unknown',
      comment: json['comment'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  CommitteeVote toEntity() {
    return CommitteeVote(
      id: id,
      loanApplicationId: loanApplicationId,
      voterId: voterId,
      decision: VoteDecision.fromApi(decision),
      comment: comment,
      createdAt: _asDate(createdAt),
    );
  }
}

class LoanRepaymentDto {
  const LoanRepaymentDto({
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
  final String amount;
  final String currency;
  final String paymentMethod;
  final String reference;
  final String paymentDate;
  final String? recordedBy;
  final String? createdAt;

  factory LoanRepaymentDto.fromJson(Map<String, dynamic> json) {
    return LoanRepaymentDto(
      id: '${json['id']}',
      loanApplicationId: '${json['loan_application_id']}',
      amount: '${json['amount'] ?? '0'}',
      currency: json['currency'] as String? ?? 'KES',
      paymentMethod: json['payment_method'] as String? ?? 'unknown',
      reference: json['reference'] as String? ?? '',
      paymentDate: json['payment_date'] as String? ?? '',
      recordedBy: json['recorded_by']?.toString(),
      createdAt: json['created_at'] as String?,
    );
  }

  LoanRepayment toEntity() {
    return LoanRepayment(
      id: id,
      loanApplicationId: loanApplicationId,
      amount: _asDouble(amount),
      currency: currency,
      paymentMethod: LoanPaymentMethod.fromApi(paymentMethod),
      reference: reference,
      paymentDate: _asDate(paymentDate) ?? DateTime.now(),
      recordedBy: recordedBy,
      createdAt: _asDate(createdAt),
    );
  }
}

class LoanRepaymentsPageDto {
  const LoanRepaymentsPageDto({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final List<LoanRepaymentDto> results;
  final String? next;
  final String? previous;

  factory LoanRepaymentsPageDto.fromJson(Map<String, dynamic> json) {
    final resultsJson = json['results'] as List<dynamic>? ?? [];
    return LoanRepaymentsPageDto(
      count: json['count'] as int? ?? resultsJson.length,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: resultsJson
          .map((e) => LoanRepaymentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CreditScoreDto {
  const CreditScoreDto({
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
  final String? calculatedAt;

  factory CreditScoreDto.fromJson(Map<String, dynamic> json) {
    return CreditScoreDto(
      id: '${json['id']}',
      memberId: '${json['member_id']}',
      score: json['score'] as int? ?? 0,
      riskLevel: json['risk_level'] as String? ?? 'unknown',
      calculatedAt: json['calculated_at'] as String?,
    );
  }

  MemberCreditScore toEntity() {
    return MemberCreditScore(
      id: id,
      memberId: memberId,
      score: score,
      riskLevel: riskLevel,
      calculatedAt: _asDate(calculatedAt),
    );
  }
}
