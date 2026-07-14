import '../../domain/entities/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../cache/dashboard_cache.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../dtos/dashboard_response_dto.dart';

/// Maps API responses into [Dashboard] and applies short-lived caching.
class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({
    required DashboardRemoteDataSource api,
    DashboardCache? cache,
  })  : _api = api,
        _cache = cache ?? DashboardCache();

  final DashboardRemoteDataSource _api;
  final DashboardCache _cache;

  @override
  Future<Dashboard> getDashboard({
    required String userId,
    required String welcomeName,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _cache.get();
      if (cached != null) {
        return cached;
      }
    }

    final chamas = await _api.listChamas();
    if (chamas.isEmpty) {
      final empty = _emptyDashboard(welcomeName);
      _cache.put(empty);
      return empty;
    }

    final chama = chamas.first;
    final dashboardDto = await _api.getDashboard(chama.id);
    final role = await _api.getUserRole(chamaId: chama.id, userId: userId);

    final unreadPage =
        await _api.listNotifications(isRead: false, pageSize: 1);
    final recentPage = await _api.listNotifications(pageSize: 5);

    final chartData = await _loadMonthlyCharts(
      chamaId: chama.id,
      dashboardDto: dashboardDto,
    );

    final dashboard = _mapToEntity(
      chamaId: chama.id,
      chamaName: chama.name,
      currency: chama.currency,
      welcomeName: welcomeName,
      userRole: role,
      dashboardDto: dashboardDto,
      unreadCount: unreadPage.count,
      recentActivities: recentPage.results
          .map(
            (n) => RecentActivity(
              id: n.id,
              title: n.title,
              message: n.message,
              createdAt: n.createdAt,
              isRead: n.isRead,
            ),
          )
          .toList(),
      monthlyContributions: chartData.contributions,
      monthlyLoanBalances: chartData.loanBalances,
    );

    _cache.put(dashboard);
    return dashboard;
  }

  @override
  void clearCache() => _cache.clear();

  Future<({List<MonthlyChartPoint> contributions, List<MonthlyChartPoint> loanBalances})>
      _loadMonthlyCharts({
    required String chamaId,
    required DashboardResponseDto dashboardDto,
  }) async {
    final now = DateTime.now();
    final contributions = <MonthlyChartPoint>[];
    final loanBalances = <MonthlyChartPoint>[];
    var hasMonthlyData = false;

    for (var i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final report = await _api.getMonthlyReport(
        chamaId: chamaId,
        year: monthDate.year,
        month: monthDate.month,
      );

      if (report != null) {
        hasMonthlyData = true;
        contributions.add(
          MonthlyChartPoint(
            month: monthDate,
            value: _parseAmount(report.contributionsTotal),
          ),
        );
        loanBalances.add(
          MonthlyChartPoint(
            month: monthDate,
            value: _parseAmount(report.loanOutstanding),
          ),
        );
      } else {
        contributions.add(MonthlyChartPoint(month: monthDate, value: 0));
        loanBalances.add(MonthlyChartPoint(month: monthDate, value: 0));
      }
    }

    if (!hasMonthlyData) {
      final currentMonth = DateTime(now.year, now.month, 1);
      contributions[contributions.length - 1] = MonthlyChartPoint(
        month: currentMonth,
        value: _parseAmount(dashboardDto.contributionsThisCycle),
      );
      loanBalances[loanBalances.length - 1] = MonthlyChartPoint(
        month: currentMonth,
        value: _parseAmount(dashboardDto.outstandingLoans),
      );
    }

    return (contributions: contributions, loanBalances: loanBalances);
  }

  Dashboard _mapToEntity({
    required String chamaId,
    required String chamaName,
    required String currency,
    required String welcomeName,
    required String? userRole,
    required DashboardResponseDto dashboardDto,
    required int unreadCount,
    required List<RecentActivity> recentActivities,
    required List<MonthlyChartPoint> monthlyContributions,
    required List<MonthlyChartPoint> monthlyLoanBalances,
  }) {
    return Dashboard(
      chamaId: chamaId,
      chamaName: chamaName,
      welcomeName: welcomeName,
      userRole: userRole,
      memberCount: dashboardDto.memberCount,
      contributionSummary: ContributionSummary(
        paidByUser: _parseAmount(dashboardDto.userSummary.contributionsPaid),
        cycleTotal: _parseAmount(dashboardDto.contributionsThisCycle),
        activeCycleName: dashboardDto.activeCycle,
        currency: currency,
      ),
      loanSummary: LoanSummary(
        outstandingBalance: _parseAmount(dashboardDto.outstandingLoans),
        activeLoansCount: dashboardDto.userSummary.activeLoans,
        pendingApplications: dashboardDto.pendingLoanApplications,
        currency: currency,
      ),
      creditScore: dashboardDto.userSummary.creditScore,
      upcomingMeeting: dashboardDto.nextMeeting == null
          ? null
          : DashboardMeeting(
              id: dashboardDto.nextMeeting!.id,
              title: dashboardDto.nextMeeting!.title,
              meetingDate:
                  DateTime.parse(dashboardDto.nextMeeting!.meetingDate),
              startTime: dashboardDto.nextMeeting!.startTime,
            ),
      unreadNotifications: unreadCount,
      recentActivities: recentActivities,
      monthlyContributions: monthlyContributions,
      monthlyLoanBalances: monthlyLoanBalances,
      completedMeetings: dashboardDto.completedMeetings,
    );
  }

  Dashboard _emptyDashboard(String welcomeName) {
    final now = DateTime.now();
    final months = List.generate(
      6,
      (index) => DateTime(now.year, now.month - (5 - index), 1),
    );

    return Dashboard(
      chamaId: '',
      chamaName: '',
      welcomeName: welcomeName,
      memberCount: 0,
      contributionSummary: const ContributionSummary(
        paidByUser: 0,
        cycleTotal: 0,
        currency: 'KES',
      ),
      loanSummary: const LoanSummary(
        outstandingBalance: 0,
        activeLoansCount: 0,
        pendingApplications: 0,
        currency: 'KES',
      ),
      unreadNotifications: 0,
      recentActivities: const [],
      monthlyContributions: months
          .map((m) => MonthlyChartPoint(month: m, value: 0))
          .toList(),
      monthlyLoanBalances: months
          .map((m) => MonthlyChartPoint(month: m, value: 0))
          .toList(),
      completedMeetings: 0,
    );
  }

  double _parseAmount(String value) => double.tryParse(value) ?? 0;
}
