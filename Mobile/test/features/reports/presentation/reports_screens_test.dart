import 'package:chamaplus_mobile/features/reports/domain/entities/report.dart';
import 'package:chamaplus_mobile/features/reports/domain/repositories/report_repository.dart';
import 'package:chamaplus_mobile/features/reports/presentation/controllers/report_controllers.dart';
import 'package:chamaplus_mobile/features/reports/presentation/providers/report_providers.dart';
import 'package:chamaplus_mobile/features/reports/presentation/screens/export_center_screen.dart';
import 'package:chamaplus_mobile/features/reports/presentation/screens/reports_home_screen.dart';
import 'package:chamaplus_mobile/shared/api_state.dart';
import 'package:chamaplus_mobile/shared/components/summary_metric_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements ReportRepository {
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
      _financial;

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
        contributionsTotal: 5000,
        contributionsCount: 3,
        activeLoans: 1,
        repaymentsTotal: 500,
        creditScore: 80,
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
          totalAmount: 5000,
          totalCount: 4,
          currency: 'KES',
        ),
        loans: const LoanTotals(
          totalApplications: 1,
          pending: 0,
          approved: 0,
          disbursed: 1,
          repaid: 0,
          outstandingBalance: 2000,
        ),
        repayments: const RepaymentTotals(
          totalAmount: 500,
          totalCount: 1,
          currency: 'KES',
        ),
      );

  @override
  Future<List<MonthlyReport>> getMonthlyTrend({
    required String chamaId,
    int months = 6,
  }) async =>
      const [];

  @override
  Future<RepaymentTotals> getRepaymentsReport({
    required String chamaId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ReportsHomeData> getReportsHome({required String chamaId}) async =>
      _home;

  @override
  Future<DefaultersReport> getDefaultersReport({
    required String chamaId,
    String? cycleId,
    String type = 'all',
  }) async =>
      const DefaultersReport(
        currency: 'KES',
        contributionDefaultersCount: 1,
        loanDefaultersCount: 0,
        defaulters: [],
      );
}

const _financial = FinancialReport(
  contributions: ContributionTotals(
    totalAmount: 25000,
    totalCount: 10,
    currency: 'KES',
  ),
  loans: LoanTotals(
    totalApplications: 4,
    pending: 1,
    approved: 1,
    disbursed: 1,
    repaid: 1,
    outstandingBalance: 9000,
  ),
  repayments: RepaymentTotals(
    totalAmount: 4000,
    totalCount: 2,
    currency: 'KES',
  ),
  memberCount: 8,
  activeCycles: 2,
);

final _home = ReportsHomeData(
  financial: _financial,
  analytics: const ReportsAnalytics(
    monthly: [],
    attendanceByStatus: {'Completed': 2},
    creditScore: 80,
  ),
);

class _SeededHomeController extends ReportsHomeController {
  _SeededHomeController()
      : super(repository: _FakeRepo(), chamaId: 'c1') {
    state = ApiState.success(_home);
  }

  @override
  Future<void> load({bool forceRefresh = false}) async {}

  @override
  Future<void> refresh() async {}
}

void main() {
  testWidgets('ReportsHomeScreen shows KPIs and report library',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reportRepositoryProvider.overrideWithValue(_FakeRepo()),
          reportsHomeProvider.overrideWith(
            (ref, chamaId) => _SeededHomeController(),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const ReportsHomeScreen(chamaId: 'c1'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Reports & analytics'), findsOneWidget);
    expect(find.text('Report library'), findsOneWidget);
    expect(find.text('Monthly report'), findsOneWidget);
    expect(find.text('Financial report'), findsOneWidget);
    expect(find.text('Defaulters report'), findsOneWidget);
    expect(find.byType(SummaryMetricTile), findsNWidgets(4));

    await tester.scrollUntilVisible(
      find.text('Export center'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Export center'), findsOneWidget);
  });

  testWidgets('ExportCenterScreen lists export targets', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reportRepositoryProvider.overrideWithValue(_FakeRepo()),
        ],
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const ExportCenterScreen(chamaId: 'c1'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Export center'), findsOneWidget);
    expect(find.text('Monthly report'), findsOneWidget);
    expect(find.text('Financial report'), findsOneWidget);
    expect(find.text('Defaulters report'), findsOneWidget);
    expect(find.text('My member statement'), findsOneWidget);
  });

  testWidgets('SummaryMetricTile golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6E4F)),
        ),
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: SummaryMetricTile(
              title: 'Contributions',
              value: 'KES 12,500.00',
              icon: Icons.payments_outlined,
              trend: MetricTrend.up,
              percentage: 4.5,
              subtitle: '12 payments',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(SummaryMetricTile),
      matchesGoldenFile('goldens/summary_metric_tile.png'),
    );
  });
}
