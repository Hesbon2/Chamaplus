import '../../domain/entities/report.dart';

double _asDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

ContributionTotals _contributionTotals(Map<String, dynamic>? json) {
  final map = json ?? const {};
  return ContributionTotals(
    totalAmount: _asDouble(map['total_amount']),
    totalCount: _asInt(map['total_count']),
    currency: map['currency'] as String? ?? 'KES',
  );
}

LoanTotals _loanTotals(Map<String, dynamic>? json) {
  final map = json ?? const {};
  return LoanTotals(
    totalApplications: _asInt(map['total_applications']),
    pending: _asInt(map['pending']),
    approved: _asInt(map['approved']),
    disbursed: _asInt(map['disbursed']),
    repaid: _asInt(map['repaid']),
    outstandingBalance: _asDouble(map['outstanding_balance']),
  );
}

RepaymentTotals _repaymentTotals(Map<String, dynamic>? json) {
  final map = json ?? const {};
  return RepaymentTotals(
    totalAmount: _asDouble(map['total_amount']),
    totalCount: _asInt(map['total_count']),
    currency: map['currency'] as String? ?? 'KES',
  );
}

class MonthlyReportDto {
  const MonthlyReportDto(this.raw);
  final Map<String, dynamic> raw;

  factory MonthlyReportDto.fromJson(Map<String, dynamic> json) =>
      MonthlyReportDto(json);

  MonthlyReport toEntity() {
    return MonthlyReport(
      year: _asInt(raw['year']),
      month: _asInt(raw['month']),
      contributions: _contributionTotals(
        raw['contributions'] as Map<String, dynamic>?,
      ),
      loans: _loanTotals(raw['loans'] as Map<String, dynamic>?),
      repayments: _repaymentTotals(raw['repayments'] as Map<String, dynamic>?),
    );
  }
}

class FinancialReportDto {
  const FinancialReportDto(this.raw);
  final Map<String, dynamic> raw;

  factory FinancialReportDto.fromJson(Map<String, dynamic> json) =>
      FinancialReportDto(json);

  FinancialReport toEntity() {
    return FinancialReport(
      contributions: _contributionTotals(
        raw['contributions'] as Map<String, dynamic>?,
      ),
      loans: _loanTotals(raw['loans'] as Map<String, dynamic>?),
      repayments: _repaymentTotals(raw['repayments'] as Map<String, dynamic>?),
      memberCount: _asInt(raw['member_count']),
      activeCycles: _asInt(raw['active_cycles']),
    );
  }
}

class MemberStatementDto {
  const MemberStatementDto(this.raw);
  final Map<String, dynamic> raw;

  factory MemberStatementDto.fromJson(Map<String, dynamic> json) =>
      MemberStatementDto(json);

  MemberStatement toEntity({List<MemberStatementLine> lineItems = const []}) {
    return MemberStatement(
      memberId: '${raw['member_id'] ?? ''}',
      contributionsTotal: _asDouble(raw['contributions_total']),
      contributionsCount: _asInt(raw['contributions_count']),
      activeLoans: _asInt(raw['active_loans']),
      repaymentsTotal: _asDouble(raw['repayments_total']),
      creditScore: raw['credit_score'] == null
          ? null
          : _asInt(raw['credit_score']),
      creditRiskLevel: raw['credit_risk_level']?.toString(),
      lineItems: lineItems,
    );
  }
}

class ContributionTotalsDto {
  const ContributionTotalsDto(this.raw);
  final Map<String, dynamic> raw;

  factory ContributionTotalsDto.fromJson(Map<String, dynamic> json) =>
      ContributionTotalsDto(json);

  ContributionTotals toEntity() => _contributionTotals(raw);
}

class LoanTotalsDto {
  const LoanTotalsDto(this.raw);
  final Map<String, dynamic> raw;

  factory LoanTotalsDto.fromJson(Map<String, dynamic> json) =>
      LoanTotalsDto(json);

  LoanTotals toEntity() => _loanTotals(raw);
}

class RepaymentTotalsDto {
  const RepaymentTotalsDto(this.raw);
  final Map<String, dynamic> raw;

  factory RepaymentTotalsDto.fromJson(Map<String, dynamic> json) =>
      RepaymentTotalsDto(json);

  RepaymentTotals toEntity() => _repaymentTotals(raw);
}
