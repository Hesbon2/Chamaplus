import 'package:chamaplus_mobile/core/errors/app_exception.dart';
import 'package:chamaplus_mobile/features/reports/data/datasources/report_api.dart';
import 'package:chamaplus_mobile/features/reports/data/dtos/report_dtos.dart';
import 'package:chamaplus_mobile/features/reports/data/repositories/report_repository_impl.dart';
import 'package:chamaplus_mobile/features/reports/domain/entities/report.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeReportApi implements ReportRemoteDataSource {
  MonthlyReportDto? monthly;
  FinancialReportDto? financial;
  MemberStatementDto? member;
  ContributionTotalsDto? contributions;
  LoanTotalsDto? loans;
  RepaymentTotalsDto? repayments;
  Object? error;
  int monthlyCalls = 0;

  @override
  Future<ContributionTotalsDto> getContributionsReport({
    required String chamaId,
    String? dateFrom,
    String? dateTo,
    String? cycleId,
  }) async {
    if (error != null) throw error!;
    return contributions ??
        ContributionTotalsDto(const {
          'total_amount': 1000,
          'total_count': 2,
          'currency': 'KES',
        });
  }

  @override
  Future<FinancialReportDto> getFinancialReport({
    required String chamaId,
    String? dateFrom,
    String? dateTo,
  }) async {
    if (error != null) throw error!;
    return financial ??
        FinancialReportDto(const {
          'member_count': 12,
          'active_cycles': 1,
          'contributions': {
            'total_amount': 50000,
            'total_count': 40,
            'currency': 'KES',
          },
          'loans': {
            'total_applications': 5,
            'pending': 1,
            'approved': 1,
            'disbursed': 2,
            'repaid': 1,
            'outstanding_balance': 20000,
          },
          'repayments': {
            'total_amount': 8000,
            'total_count': 4,
            'currency': 'KES',
          },
        });
  }

  @override
  Future<LoanTotalsDto> getLoansReport({
    required String chamaId,
    String? dateFrom,
    String? dateTo,
  }) async {
    if (error != null) throw error!;
    return loans ??
        LoanTotalsDto(const {
          'total_applications': 5,
          'pending': 1,
          'approved': 1,
          'disbursed': 2,
          'repaid': 1,
          'outstanding_balance': 20000,
        });
  }

  @override
  Future<MemberStatementDto> getMemberFinancialReport({
    required String chamaId,
    required String memberId,
  }) async {
    if (error != null) throw error!;
    return member ??
        MemberStatementDto({
          'member_id': memberId,
          'contributions_total': 12000,
          'contributions_count': 6,
          'active_loans': 1,
          'repayments_total': 3000,
          'credit_score': 78,
          'credit_risk_level': 'good',
        });
  }

  @override
  Future<MonthlyReportDto> getMonthlyReport({
    required String chamaId,
    required int year,
    required int month,
  }) async {
    monthlyCalls++;
    if (error != null) throw error!;
    return monthly ??
        MonthlyReportDto({
          'year': year,
          'month': month,
          'contributions': {
            'total_amount': 10000,
            'total_count': 8,
            'currency': 'KES',
          },
          'loans': {
            'total_applications': 2,
            'pending': 0,
            'approved': 1,
            'disbursed': 1,
            'repaid': 0,
            'outstanding_balance': 5000,
          },
          'repayments': {
            'total_amount': 2000,
            'total_count': 2,
            'currency': 'KES',
          },
        });
  }

  @override
  Future<RepaymentTotalsDto> getRepaymentsReport({
    required String chamaId,
    String? dateFrom,
    String? dateTo,
  }) async {
    if (error != null) throw error!;
    return repayments ??
        RepaymentTotalsDto(const {
          'total_amount': 8000,
          'total_count': 4,
          'currency': 'KES',
        });
  }
}

void main() {
  late FakeReportApi api;
  late ReportRepositoryImpl repository;

  setUp(() {
    api = FakeReportApi();
    repository = ReportRepositoryImpl(api);
  });

  test('getMonthlyReport maps DTO to entity', () async {
    final report = await repository.getMonthlyReport(
      chamaId: 'c1',
      year: 2026,
      month: 7,
    );
    expect(report.year, 2026);
    expect(report.month, 7);
    expect(report.contributions.totalAmount, 10000);
    expect(report.loans.outstandingBalance, 5000);
  });

  test('getFinancialReport maps member and cycle counts', () async {
    final report = await repository.getFinancialReport(chamaId: 'c1');
    expect(report.memberCount, 12);
    expect(report.activeCycles, 1);
    expect(report.contributions.totalCount, 40);
  });

  test('getMemberStatement attaches optional line items', () async {
    repository = ReportRepositoryImpl(
      api,
      statementLinesLoader: (chamaId, memberId) async => [
        MemberStatementLine(
          date: DateTime(2026, 7, 1),
          label: 'July cycle',
          amount: 1000,
          category: 'Contribution',
        ),
      ],
    );
    final statement = await repository.getMemberStatement(
      chamaId: 'c1',
      memberId: 'u1',
    );
    expect(statement.creditScore, 78);
    expect(statement.lineItems, hasLength(1));
    expect(statement.lineItems.first.label, 'July cycle');
  });

  test('getReportsHome composes financial, trend, attendance, credit',
      () async {
    repository = ReportRepositoryImpl(
      api,
      attendanceLoader: (_) async => {'Completed': 3, 'Scheduled': 1},
      creditScoreLoader: (_) async => 82,
    );
    final home = await repository.getReportsHome(chamaId: 'c1');
    expect(home.financial.memberCount, 12);
    expect(home.analytics.monthly, hasLength(6));
    expect(home.analytics.attendanceByStatus['Completed'], 3);
    expect(home.analytics.creditScore, 82);
    expect(home.latestMonth, isNotNull);
    expect(api.monthlyCalls, 6);
  });

  test('getMonthlyTrend fills zeros when a month fails', () async {
    final failing = _FailingMonthlyApi(FakeReportApi());
    repository = ReportRepositoryImpl(failing);
    final trend = await repository.getMonthlyTrend(chamaId: 'c1', months: 3);
    expect(trend, hasLength(3));
    expect(trend.every((m) => m.contributions.totalAmount == 0), isTrue);
    expect(failing.calls, 3);
  });

  test('propagates server errors from financial report', () async {
    api.error = const ServerException(message: 'Forbidden');
    expect(
      () => repository.getFinancialReport(chamaId: 'c1'),
      throwsA(isA<ServerException>()),
    );
  });
}

class _FailingMonthlyApi implements ReportRemoteDataSource {
  _FailingMonthlyApi(this._inner);
  final FakeReportApi _inner;
  int calls = 0;

  @override
  Future<ContributionTotalsDto> getContributionsReport({
    required String chamaId,
    String? dateFrom,
    String? dateTo,
    String? cycleId,
  }) =>
      _inner.getContributionsReport(
        chamaId: chamaId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        cycleId: cycleId,
      );

  @override
  Future<FinancialReportDto> getFinancialReport({
    required String chamaId,
    String? dateFrom,
    String? dateTo,
  }) =>
      _inner.getFinancialReport(
        chamaId: chamaId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  @override
  Future<LoanTotalsDto> getLoansReport({
    required String chamaId,
    String? dateFrom,
    String? dateTo,
  }) =>
      _inner.getLoansReport(
        chamaId: chamaId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  @override
  Future<MemberStatementDto> getMemberFinancialReport({
    required String chamaId,
    required String memberId,
  }) =>
      _inner.getMemberFinancialReport(chamaId: chamaId, memberId: memberId);

  @override
  Future<MonthlyReportDto> getMonthlyReport({
    required String chamaId,
    required int year,
    required int month,
  }) async {
    calls++;
    throw const ServerException(message: 'missing');
  }

  @override
  Future<RepaymentTotalsDto> getRepaymentsReport({
    required String chamaId,
    String? dateFrom,
    String? dateTo,
  }) =>
      _inner.getRepaymentsReport(
        chamaId: chamaId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
}
