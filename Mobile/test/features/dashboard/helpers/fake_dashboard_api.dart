import 'package:chamaplus_mobile/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:chamaplus_mobile/features/dashboard/data/dtos/chama_dto.dart';
import 'package:chamaplus_mobile/features/dashboard/data/dtos/dashboard_response_dto.dart';
import 'package:chamaplus_mobile/features/dashboard/data/dtos/monthly_report_dto.dart';
import 'package:chamaplus_mobile/features/dashboard/data/dtos/notification_dto.dart';

/// Test double for [DashboardRemoteDataSource].
class FakeDashboardApi implements DashboardRemoteDataSource {
  List<ChamaDto> chamas = const [];
  DashboardResponseDto? dashboard;
  String? userRole = 'Member';
  NotificationsPageDto unreadNotifications = const NotificationsPageDto(
    count: 0,
    results: [],
  );
  NotificationsPageDto recentNotifications = const NotificationsPageDto(
    count: 0,
    results: [],
  );
  List<MonthlyReportDto?> monthlyReports = List.filled(6, null);
  Object? listChamasError;

  @override
  Future<List<ChamaDto>> listChamas() async {
    if (listChamasError != null) throw listChamasError!;
    return chamas;
  }

  @override
  Future<DashboardResponseDto> getDashboard(String chamaId) async {
    return dashboard!;
  }

  @override
  Future<String?> getUserRole({
    required String chamaId,
    required String userId,
  }) async {
    return userRole;
  }

  @override
  Future<NotificationsPageDto> listNotifications({
    bool? isRead,
    int pageSize = 10,
  }) async {
    if (isRead == false) return unreadNotifications;
    return recentNotifications;
  }

  @override
  Future<MonthlyReportDto?> getMonthlyReport({
    required String chamaId,
    required int year,
    required int month,
  }) async {
    return null;
  }
}

DashboardResponseDto sampleDashboardDto() {
  return const DashboardResponseDto(
    memberCount: 8,
    activeCycle: 'March Cycle',
    contributionsThisCycle: '25000.00',
    outstandingLoans: '12000.00',
    pendingLoanApplications: 1,
    completedMeetings: 4,
    nextMeeting: NextMeetingDto(
      id: 'meeting-1',
      title: 'Monthly Review',
      meetingDate: '2026-07-20',
      startTime: '18:00:00',
    ),
    userSummary: UserSummaryDto(
      contributionsPaid: '5000.00',
      activeLoans: 1,
      creditScore: 82,
    ),
  );
}
