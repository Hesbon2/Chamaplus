import 'package:chamaplus_mobile/features/dashboard/domain/entities/dashboard.dart';
import 'package:chamaplus_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:chamaplus_mobile/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:chamaplus_mobile/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:chamaplus_mobile/features/notifications/domain/entities/notification.dart';
import 'package:chamaplus_mobile/features/notifications/domain/repositories/notification_repository.dart';
import 'package:chamaplus_mobile/features/notifications/presentation/controllers/notification_controllers.dart';
import 'package:chamaplus_mobile/features/notifications/presentation/providers/notification_providers.dart';
import 'package:chamaplus_mobile/shared/api_state.dart';
import 'package:chamaplus_mobile/shared/navigation/navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<Dashboard> getDashboard({
    required String userId,
    required String welcomeName,
    bool forceRefresh = false,
  }) async {
    return const Dashboard(
      chamaId: 'c1',
      chamaName: 'Umoja',
      welcomeName: 'Amina',
      userRole: 'treasurer',
      memberCount: 12,
      contributionSummary: ContributionSummary(
        paidByUser: 1000,
        cycleTotal: 5000,
        currency: 'KES',
      ),
      loanSummary: LoanSummary(
        outstandingBalance: 0,
        activeLoansCount: 0,
        pendingApplications: 3,
        currency: 'KES',
      ),
      unreadNotifications: 7,
      recentActivities: [],
      monthlyContributions: [],
      monthlyLoanBalances: [],
      completedMeetings: 2,
    );
  }

  @override
  void clearCache() {}
}

class _SeededDashboardController extends DashboardController {
  _SeededDashboardController()
      : super(
          repository: _FakeDashboardRepository(),
          userId: 'u1',
          welcomeName: 'Amina',
        ) {
    state = const ApiState.success(
      Dashboard(
        chamaId: 'c1',
        chamaName: 'Umoja',
        welcomeName: 'Amina',
        userRole: 'treasurer',
        memberCount: 12,
        contributionSummary: ContributionSummary(
          paidByUser: 1000,
          cycleTotal: 5000,
          currency: 'KES',
        ),
        loanSummary: LoanSummary(
          outstandingBalance: 0,
          activeLoansCount: 0,
          pendingApplications: 3,
          currency: 'KES',
        ),
        unreadNotifications: 7,
        recentActivities: [],
        monthlyContributions: [],
        monthlyLoanBalances: [],
        completedMeetings: 2,
      ),
    );
  }

  @override
  Future<void> load({bool forceRefresh = false}) async {}
}

class _FakeNotificationRepository implements NotificationRepository {
  @override
  Future<int> countUnread() async => 7;

  @override
  Future<NotificationsDashboard> getDashboard() {
    throw UnimplementedError();
  }

  @override
  Future<AppNotification> getNotification(String notificationId) {
    throw UnimplementedError();
  }

  @override
  Future<PagedResult<AppNotification>> listNotifications({
    bool? isRead,
    int page = 1,
    int pageSize = 20,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<int> markAllRead() async => 0;

  @override
  Future<AppNotification> markRead(String notificationId) {
    throw UnimplementedError();
  }
}

class _SeededUnreadController extends NotificationUnreadCountController {
  _SeededUnreadController() : super(repository: _FakeNotificationRepository()) {
    state = 7;
  }

  @override
  Future<void> refresh() async {}
}

void main() {
  test('navigationBadgesProvider maps live unread and pending loans', () {
    final container = ProviderContainer(
      overrides: [
        dashboardProvider.overrideWith((ref) => _SeededDashboardController()),
        notificationRepositoryProvider
            .overrideWithValue(_FakeNotificationRepository()),
        notificationUnreadCountProvider.overrideWith(
          (ref) => _SeededUnreadController(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final badges = container.read(navigationBadgesProvider);
    expect(badges.alerts, 7);
    expect(badges.loans, 3);

    final ctx = container.read(shellNavigationContextProvider);
    expect(ctx.chamaId, 'c1');
    expect(ctx.roleLabel, 'treasurer');
  });
}
