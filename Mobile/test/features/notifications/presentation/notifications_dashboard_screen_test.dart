import 'package:chamaplus_mobile/features/dashboard/domain/entities/dashboard.dart';
import 'package:chamaplus_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:chamaplus_mobile/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:chamaplus_mobile/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:chamaplus_mobile/features/notifications/domain/entities/notification.dart';
import 'package:chamaplus_mobile/features/notifications/domain/repositories/notification_repository.dart';
import 'package:chamaplus_mobile/features/notifications/presentation/controllers/notification_controllers.dart';
import 'package:chamaplus_mobile/features/notifications/presentation/providers/notification_providers.dart';
import 'package:chamaplus_mobile/features/notifications/presentation/screens/notifications_dashboard_screen.dart';
import 'package:chamaplus_mobile/shared/api_state.dart';
import 'package:chamaplus_mobile/shared/components/notification_card.dart';
import 'package:chamaplus_mobile/shared/navigation/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements NotificationRepository {
  @override
  Future<int> countUnread() async => 2;

  @override
  Future<NotificationsDashboard> getDashboard() async {
    return NotificationsDashboard(
      unreadCount: 2,
      totalCount: 5,
      recent: [
        AppNotification(
          id: 'n1',
          title: 'Loan approved',
          message: 'Your emergency loan was approved',
          type: NotificationType.loanApproved,
          channel: NotificationChannel.inApp,
          isRead: false,
          metadata: const {'chama_id': 'c1'},
          createdAt: DateTime(2026, 7, 26, 9),
        ),
      ],
    );
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
  }) async {
    return const PagedResult(items: [], count: 0);
  }

  @override
  Future<int> markAllRead() async => 2;

  @override
  Future<AppNotification> markRead(String notificationId) {
    throw UnimplementedError();
  }
}

class _SeededDashboardController extends NotificationsDashboardController {
  _SeededDashboardController() : super(repository: _FakeRepo()) {
    state = ApiState.success(
      NotificationsDashboard(
        unreadCount: 2,
        totalCount: 5,
        recent: [
          AppNotification(
            id: 'n1',
            title: 'Loan approved',
            message: 'Your emergency loan was approved',
            type: NotificationType.loanApproved,
            channel: NotificationChannel.inApp,
            isRead: false,
            metadata: const {'chama_id': 'c1'},
            createdAt: DateTime(2026, 7, 26, 9),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> load({bool forceRefresh = false}) async {}

  @override
  Future<void> refresh() async {}
}

class _SeededUnreadController extends NotificationUnreadCountController {
  _SeededUnreadController() : super(repository: _FakeRepo()) {
    state = 2;
  }

  @override
  Future<void> refresh() async {}
}

void main() {
  testWidgets('NotificationCard shows unread emphasis', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NotificationCard(
            title: 'Hello',
            body: 'World',
            isUnread: true,
            categoryLabel: 'Loans',
            tone: NotificationCardTone.success,
          ),
        ),
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('World'), findsOneWidget);
    expect(find.text('Loans'), findsOneWidget);
  });

  testWidgets('NotificationsDashboardScreen shows unread and recent card',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(_FakeRepo()),
          notificationUnreadCountProvider.overrideWith(
            (ref) => _SeededUnreadController(),
          ),
          notificationsDashboardProvider.overrideWith(
            (ref) => _SeededDashboardController(),
          ),
        ],
        child: const MaterialApp(
          home: NotificationsDashboardScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Loan approved'), findsOneWidget);
    expect(find.text('Mark all read'), findsOneWidget);
    expect(find.text('Inbox progress'), findsOneWidget);
  });

  test('navigationBadgesProvider uses live unread count', () {
    final container = ProviderContainer(
      overrides: [
        notificationRepositoryProvider.overrideWithValue(_FakeRepo()),
        notificationUnreadCountProvider.overrideWith(
          (ref) => _SeededUnreadController(),
        ),
        dashboardProvider.overrideWith(
          (ref) => _UnusedDashboardController(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final badges = container.read(navigationBadgesProvider);
    expect(badges.alerts, 2);
  });
}

class _UnusedDashboardController extends DashboardController {
  _UnusedDashboardController()
      : super(
          repository: _NoopDashboardRepo(),
          userId: 'u1',
          welcomeName: 'Test',
        ) {
    state = const ApiState.success(
      Dashboard(
        chamaId: 'c1',
        chamaName: 'Test',
        welcomeName: 'Test',
        memberCount: 1,
        contributionSummary: ContributionSummary(
          paidByUser: 0,
          cycleTotal: 0,
          currency: 'KES',
        ),
        loanSummary: LoanSummary(
          outstandingBalance: 0,
          activeLoansCount: 0,
          pendingApplications: 1,
          currency: 'KES',
        ),
        unreadNotifications: 0,
        recentActivities: [],
        monthlyContributions: [],
        monthlyLoanBalances: [],
        completedMeetings: 0,
      ),
    );
  }

  @override
  Future<void> load({bool forceRefresh = false}) async {}
}

class _NoopDashboardRepo implements DashboardRepository {
  @override
  void clearCache() {}

  @override
  Future<Dashboard> getDashboard({
    required String userId,
    required String welcomeName,
    bool forceRefresh = false,
  }) {
    throw UnimplementedError();
  }
}
