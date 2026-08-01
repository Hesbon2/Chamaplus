import '../entities/report.dart';

/// Contract for chama reports & analytics.
abstract class ReportRepository {
  Future<MonthlyReport> getMonthlyReport({
    required String chamaId,
    required int year,
    required int month,
  });

  Future<List<MonthlyReport>> getMonthlyTrend({
    required String chamaId,
    int months = 6,
  });

  Future<ContributionTotals> getContributionsReport({
    required String chamaId,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? cycleId,
  });

  Future<LoanTotals> getLoansReport({
    required String chamaId,
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<RepaymentTotals> getRepaymentsReport({
    required String chamaId,
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<FinancialReport> getFinancialReport({
    required String chamaId,
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<MemberStatement> getMemberStatement({
    required String chamaId,
    required String memberId,
  });

  Future<ReportsHomeData> getReportsHome({
    required String chamaId,
  });
}
