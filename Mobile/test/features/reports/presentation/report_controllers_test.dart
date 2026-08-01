import 'package:chamaplus_mobile/core/errors/app_exception.dart';
import 'package:chamaplus_mobile/features/reports/domain/entities/report.dart';
import 'package:chamaplus_mobile/features/reports/domain/repositories/report_repository.dart';
import 'package:chamaplus_mobile/features/reports/presentation/controllers/report_controllers.dart';
import 'package:chamaplus_mobile/shared/api_state.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeReportRepository implements ReportRepository {
  Object? error;
  MonthlyReport? monthly;
  FinancialReport? financial;
  MemberStatement? statement;
  ReportsHomeData? home;
  List<MonthlyReport> trend = const [];

  @override
  Future<ContributionTotals> getContributionsReport({
    required String chamaId,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? cycleId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<FinancialReport> getFinancialReport({
    required String chamaId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    if (error != null) throw error!;
    return financial ??
        const FinancialReport(
          contributions: ContributionTotals(
            totalAmount: 1000,
            totalCount: 1,
            currency: 'KES',
          ),
          loans: LoanTotals(
            totalApplications: 1,
            pending: 0,
            approved: 0,
            disbursed: 1,
            repaid: 0,
            outstandingBalance: 500,
          ),
          repayments: RepaymentTotals(
            totalAmount: 100,
            totalCount: 1,
            currency: 'KES',
          ),
          memberCount: 5,
          activeCycles: 1,
        );
  }

  @override
  Future<LoanTotals> getLoansReport({
    required String chamaId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MemberStatement> getMemberStatement({
    required String chamaId,
    required String memberId,
  }) async {
    if (error != null) throw error!;
    return statement ??
        MemberStatement(
          memberId: memberId,
          contributionsTotal: 2000,
          contributionsCount: 2,
          activeLoans: 0,
          repaymentsTotal: 0,
        );
  }

  @override
  Future<MonthlyReport> getMonthlyReport({
    required String chamaId,
    required int year,
    required int month,
  }) async {
    if (error != null) throw error!;
    return monthly ??
        MonthlyReport(
          year: year,
          month: month,
          contributions: const ContributionTotals(
            totalAmount: 3000,
            totalCount: 3,
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
        );
  }

  @override
  Future<List<MonthlyReport>> getMonthlyTrend({
    required String chamaId,
    int months = 6,
  }) async {
    if (error != null) throw error!;
    return trend;
  }

  @override
  Future<RepaymentTotals> getRepaymentsReport({
    required String chamaId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ReportsHomeData> getReportsHome({required String chamaId}) async {
    if (error != null) throw error!;
    return home ??
        ReportsHomeData(
          financial: await getFinancialReport(chamaId: chamaId),
          analytics: const ReportsAnalytics(
            monthly: [],
            attendanceByStatus: {},
          ),
        );
  }
}

void main() {
  late FakeReportRepository repository;

  setUp(() {
    repository = FakeReportRepository();
  });

  test('ReportsHomeController loads success state', () async {
    final controller = ReportsHomeController(
      repository: repository,
      chamaId: 'c1',
    );
    await controller.load();
    expect(controller.state.status, ApiStatus.success);
    expect(controller.state.data!.financial.memberCount, 5);
  });

  test('ReportsHomeController surfaces errors', () async {
    repository.error = const ServerException(message: 'boom');
    final controller = ReportsHomeController(
      repository: repository,
      chamaId: 'c1',
    );
    await controller.load();
    expect(controller.state.status, ApiStatus.error);
  });

  test('MonthlyReportController setPeriod reloads', () async {
    final controller = MonthlyReportController(
      repository: repository,
      chamaId: 'c1',
      year: 2026,
      month: 1,
    );
    await controller.load();
    await controller.setPeriod(year: 2026, month: 6);
    expect(controller.year, 2026);
    expect(controller.month, 6);
    expect(controller.state.data!.month, 6);
  });

  test('FinancialReportController loads financial data', () async {
    final controller = FinancialReportController(
      repository: repository,
      chamaId: 'c1',
    );
    await controller.load();
    expect(controller.state.data!.activeCycles, 1);
  });

  test('MemberStatementController loads statement', () async {
    final controller = MemberStatementController(
      repository: repository,
      chamaId: 'c1',
      memberId: 'u1',
    );
    await controller.load();
    expect(controller.state.data!.memberId, 'u1');
    expect(controller.state.data!.contributionsTotal, 2000);
  });
}
