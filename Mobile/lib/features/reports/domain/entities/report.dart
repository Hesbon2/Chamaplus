export '../../../../core/models/paged_result.dart';

/// Contribution totals block shared across reports.
class ContributionTotals {
  const ContributionTotals({
    required this.totalAmount,
    required this.totalCount,
    required this.currency,
  });

  final double totalAmount;
  final int totalCount;
  final String currency;
}

/// Loan portfolio KPIs.
class LoanTotals {
  const LoanTotals({
    required this.totalApplications,
    required this.pending,
    required this.approved,
    required this.disbursed,
    required this.repaid,
    required this.outstandingBalance,
  });

  final int totalApplications;
  final int pending;
  final int approved;
  final int disbursed;
  final int repaid;
  final double outstandingBalance;
}

/// Repayment totals block.
class RepaymentTotals {
  const RepaymentTotals({
    required this.totalAmount,
    required this.totalCount,
    required this.currency,
  });

  final double totalAmount;
  final int totalCount;
  final String currency;
}

/// Single calendar-month aggregate.
class MonthlyReport {
  const MonthlyReport({
    required this.year,
    required this.month,
    required this.contributions,
    required this.loans,
    required this.repayments,
  });

  final int year;
  final int month;
  final ContributionTotals contributions;
  final LoanTotals loans;
  final RepaymentTotals repayments;

  String get periodLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final m = month.clamp(1, 12);
    return '${months[m - 1]} $year';
  }
}

/// Combined financial overview for a chama.
class FinancialReport {
  const FinancialReport({
    required this.contributions,
    required this.loans,
    required this.repayments,
    required this.memberCount,
    required this.activeCycles,
  });

  final ContributionTotals contributions;
  final LoanTotals loans;
  final RepaymentTotals repayments;
  final int memberCount;
  final int activeCycles;
}

/// Member-level financial snapshot (statement header).
class MemberStatement {
  const MemberStatement({
    required this.memberId,
    required this.contributionsTotal,
    required this.contributionsCount,
    required this.activeLoans,
    required this.repaymentsTotal,
    this.creditScore,
    this.creditRiskLevel,
    this.currency = 'KES',
    this.lineItems = const [],
  });

  final String memberId;
  final double contributionsTotal;
  final int contributionsCount;
  final int activeLoans;
  final double repaymentsTotal;
  final int? creditScore;
  final String? creditRiskLevel;
  final String currency;
  final List<MemberStatementLine> lineItems;
}

/// Optional ledger line for member statement UI / export.
class MemberStatementLine {
  const MemberStatementLine({
    required this.date,
    required this.label,
    required this.amount,
    required this.category,
  });

  final DateTime date;
  final String label;
  final double amount;
  final String category;
}

/// Trend series for analytics charts on the reports home.
class ReportsAnalytics {
  const ReportsAnalytics({
    required this.monthly,
    required this.attendanceByStatus,
    this.creditScore,
  });

  final List<MonthlyReport> monthly;
  final Map<String, int> attendanceByStatus;
  final int? creditScore;
}

/// Home composite for the reports section of a chama.
class ReportsHomeData {
  const ReportsHomeData({
    required this.financial,
    required this.analytics,
    this.latestMonth,
  });

  final FinancialReport financial;
  final ReportsAnalytics analytics;
  final MonthlyReport? latestMonth;
}

/// Type of financial default in the defaulters report.
enum DefaulterType {
  contribution,
  loan,
  unknown;

  static DefaulterType fromApi(String? value) {
    switch (value) {
      case 'contribution':
        return DefaulterType.contribution;
      case 'loan':
        return DefaulterType.loan;
      default:
        return DefaulterType.unknown;
    }
  }

  String get label {
    switch (this) {
      case DefaulterType.contribution:
        return 'Contribution';
      case DefaulterType.loan:
        return 'Loan';
      case DefaulterType.unknown:
        return 'Unknown';
    }
  }
}

/// One row in the defaulters report.
class DefaulterRecord {
  const DefaulterRecord({
    required this.memberId,
    required this.fullName,
    required this.phoneNumber,
    required this.type,
    this.membershipId,
    this.role,
    this.cycleId,
    this.cycleName,
    this.expectedAmount,
    this.penaltyAmount,
    this.loanId,
    this.outstandingBalance,
    this.dueDate,
  });

  final String memberId;
  final String? membershipId;
  final String fullName;
  final String phoneNumber;
  final String? role;
  final DefaulterType type;
  final String? cycleId;
  final String? cycleName;
  final double? expectedAmount;
  final double? penaltyAmount;
  final String? loanId;
  final double? outstandingBalance;
  final DateTime? dueDate;
}

/// Contribution and loan defaulters for a chama.
class DefaultersReport {
  const DefaultersReport({
    required this.currency,
    required this.contributionDefaultersCount,
    required this.loanDefaultersCount,
    required this.defaulters,
  });

  final String currency;
  final int contributionDefaultersCount;
  final int loanDefaultersCount;
  final List<DefaulterRecord> defaulters;

  int get totalCount =>
      contributionDefaultersCount + loanDefaultersCount;
}
