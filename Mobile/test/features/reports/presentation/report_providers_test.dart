import 'package:chamaplus_mobile/features/reports/domain/entities/report.dart';
import 'package:chamaplus_mobile/features/reports/domain/repositories/report_repository.dart';
import 'package:chamaplus_mobile/features/reports/presentation/controllers/report_controllers.dart';
import 'package:chamaplus_mobile/features/reports/presentation/providers/report_providers.dart';
import 'package:chamaplus_mobile/shared/api_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRepo implements ReportRepository {
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
  }) async =>
      const FinancialReport(
        contributions: ContributionTotals(
          totalAmount: 10,
          totalCount: 1,
          currency: 'KES',
        ),
        loans: LoanTotals(
          totalApplications: 0,
          pending: 0,
          approved: 0,
          disbursed: 0,
          repaid: 0,
          outstandingBalance: 0,
        ),
        repayments: RepaymentTotals(
          totalAmount: 0,
          totalCount: 0,
          currency: 'KES',
        ),
        memberCount: 3,
        activeCycles: 1,
      );

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
  }) async =>
      MemberStatement(
        memberId: memberId,
        contributionsTotal: 1,
        contributionsCount: 1,
        activeLoans: 0,
        repaymentsTotal: 0,
      );

  @override
  Future<MonthlyReport> getMonthlyReport({
    required String chamaId,
    required int year,
    required int month,
  }) async =>
      MonthlyReport(
        year: year,
        month: month,
        contributions: const ContributionTotals(
          totalAmount: 50,
          totalCount: 1,
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

  @override
  Future<List<MonthlyReport>> getMonthlyTrend({
    required String chamaId,
    int months = 6,
  }) async =>
      [];

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
    return ReportsHomeData(
      financial: await getFinancialReport(chamaId: chamaId),
      analytics: const ReportsAnalytics(
        monthly: [],
        attendanceByStatus: {'Completed': 2},
        creditScore: 70,
      ),
    );
  }
}

void main() {
  test('financialReportProvider loads via repository override', () async {
    final container = ProviderContainer(
      overrides: [
        reportRepositoryProvider.overrideWithValue(_StubRepo()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(financialReportProvider('c1').notifier).load();

    final state = container.read(financialReportProvider('c1'));
    expect(state.status, ApiStatus.success);
    expect(state.data!.memberCount, 3);
  });

  test('reportsHomeProvider exposes analytics', () async {
    final container = ProviderContainer(
      overrides: [
        reportRepositoryProvider.overrideWithValue(_StubRepo()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(reportsHomeProvider('c1').notifier).load();

    final state = container.read(reportsHomeProvider('c1'));
    expect(state.data!.analytics.creditScore, 70);
    expect(state.data!.analytics.attendanceByStatus['Completed'], 2);
  });

  test('monthlyReportProvider family keys by period', () async {
    final container = ProviderContainer(
      overrides: [
        reportRepositoryProvider.overrideWithValue(_StubRepo()),
      ],
    );
    addTearDown(container.dispose);

    final args = (chamaId: 'c1', year: 2026, month: 3);
    await container.read(monthlyReportProvider(args).notifier).load();

    final state = container.read(monthlyReportProvider(args));
    expect(state.data!.month, 3);
    expect(
      container.read(monthlyReportProvider(args).notifier),
      isA<MonthlyReportController>(),
    );
  });
}
