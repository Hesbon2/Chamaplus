import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_api.dart';

/// Concrete [ReportRepository] backed by [ReportRemoteDataSource].
class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(
    this._api, {
    Future<Map<String, int>> Function(String chamaId)? attendanceLoader,
    Future<List<MemberStatementLine>> Function(
      String chamaId,
      String memberId,
    )? statementLinesLoader,
    Future<int?> Function(String chamaId)? creditScoreLoader,
  })  : _attendanceLoader = attendanceLoader,
        _statementLinesLoader = statementLinesLoader,
        _creditScoreLoader = creditScoreLoader;

  final ReportRemoteDataSource _api;
  final Future<Map<String, int>> Function(String chamaId)? _attendanceLoader;
  final Future<List<MemberStatementLine>> Function(
    String chamaId,
    String memberId,
  )? _statementLinesLoader;
  final Future<int?> Function(String chamaId)? _creditScoreLoader;

  String? _date(DateTime? d) {
    if (d == null) return null;
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<MonthlyReport> getMonthlyReport({
    required String chamaId,
    required int year,
    required int month,
  }) async {
    final dto = await _api.getMonthlyReport(
      chamaId: chamaId,
      year: year,
      month: month,
    );
    return dto.toEntity();
  }

  @override
  Future<List<MonthlyReport>> getMonthlyTrend({
    required String chamaId,
    int months = 6,
  }) async {
    final now = DateTime.now();
    final results = <MonthlyReport>[];
    for (var i = months - 1; i >= 0; i--) {
      final cursor = DateTime(now.year, now.month - i, 1);
      try {
        results.add(
          await getMonthlyReport(
            chamaId: chamaId,
            year: cursor.year,
            month: cursor.month,
          ),
        );
      } catch (_) {
        results.add(
          MonthlyReport(
            year: cursor.year,
            month: cursor.month,
            contributions: const ContributionTotals(
              totalAmount: 0,
              totalCount: 0,
              currency: 'KES',
            ),
            loans: const LoanTotals(
              totalApplications: 0,
              pending: 0,
              approved: 0,
              disbursed: 0,
              repaid: 0,
              outstandingBalance: 0,
            ),
            repayments: const RepaymentTotals(
              totalAmount: 0,
              totalCount: 0,
              currency: 'KES',
            ),
          ),
        );
      }
    }
    return results;
  }

  @override
  Future<ContributionTotals> getContributionsReport({
    required String chamaId,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? cycleId,
  }) async {
    final dto = await _api.getContributionsReport(
      chamaId: chamaId,
      dateFrom: _date(dateFrom),
      dateTo: _date(dateTo),
      cycleId: cycleId,
    );
    return dto.toEntity();
  }

  @override
  Future<LoanTotals> getLoansReport({
    required String chamaId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final dto = await _api.getLoansReport(
      chamaId: chamaId,
      dateFrom: _date(dateFrom),
      dateTo: _date(dateTo),
    );
    return dto.toEntity();
  }

  @override
  Future<RepaymentTotals> getRepaymentsReport({
    required String chamaId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final dto = await _api.getRepaymentsReport(
      chamaId: chamaId,
      dateFrom: _date(dateFrom),
      dateTo: _date(dateTo),
    );
    return dto.toEntity();
  }

  @override
  Future<FinancialReport> getFinancialReport({
    required String chamaId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final dto = await _api.getFinancialReport(
      chamaId: chamaId,
      dateFrom: _date(dateFrom),
      dateTo: _date(dateTo),
    );
    return dto.toEntity();
  }

  @override
  Future<MemberStatement> getMemberStatement({
    required String chamaId,
    required String memberId,
  }) async {
    final dto = await _api.getMemberFinancialReport(
      chamaId: chamaId,
      memberId: memberId,
    );
    var lines = const <MemberStatementLine>[];
    if (_statementLinesLoader != null) {
      try {
        lines = await _statementLinesLoader(chamaId, memberId);
      } catch (_) {}
    }
    return dto.toEntity(lineItems: lines);
  }

  @override
  Future<DefaultersReport> getDefaultersReport({
    required String chamaId,
    String? cycleId,
    String type = 'all',
  }) async {
    final dto = await _api.getDefaultersReport(
      chamaId: chamaId,
      cycleId: cycleId,
      type: type,
    );
    return dto.toEntity();
  }

  @override
  Future<ReportsHomeData> getReportsHome({
    required String chamaId,
  }) async {
    final financial = await getFinancialReport(chamaId: chamaId);
    final monthly = await getMonthlyTrend(chamaId: chamaId, months: 6);
    var attendance = <String, int>{};
    if (_attendanceLoader != null) {
      try {
        attendance = await _attendanceLoader(chamaId);
      } catch (_) {}
    }
    int? creditScore;
    if (_creditScoreLoader != null) {
      try {
        creditScore = await _creditScoreLoader(chamaId);
      } catch (_) {}
    }
    return ReportsHomeData(
      financial: financial,
      latestMonth: monthly.isEmpty ? null : monthly.last,
      analytics: ReportsAnalytics(
        monthly: monthly,
        attendanceByStatus: attendance,
        creditScore: creditScore,
      ),
    );
  }
}
