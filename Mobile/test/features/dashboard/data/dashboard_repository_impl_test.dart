import 'package:chamaplus_mobile/features/dashboard/data/cache/dashboard_cache.dart';
import 'package:chamaplus_mobile/features/dashboard/data/dtos/chama_dto.dart';
import 'package:chamaplus_mobile/features/dashboard/data/dtos/dashboard_response_dto.dart';
import 'package:chamaplus_mobile/features/dashboard/data/dtos/notification_dto.dart';
import 'package:chamaplus_mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_dashboard_api.dart';

void main() {
  late FakeDashboardApi api;
  late DashboardCache cache;
  late DashboardRepositoryImpl repository;

  setUp(() {
    api = FakeDashboardApi();
    cache = DashboardCache();
    repository = DashboardRepositoryImpl(api: api, cache: cache);
    api.chamas = const [
      ChamaDto(id: 'chama-1', name: 'Kileleshwa Unity', currency: 'KES'),
    ];
    api.dashboard = sampleDashboardDto();
    api.unreadNotifications = const NotificationsPageDto(count: 3, results: []);
    api.recentNotifications = NotificationsPageDto(
      count: 1,
      results: [
        NotificationDto(
          id: 'n1',
          title: 'Contribution recorded',
          message: 'Your contribution was received.',
          isRead: false,
          createdAt: DateTime.parse('2026-07-12T10:00:00+03:00'),
        ),
      ],
    );
  });

  group('DashboardRepositoryImpl', () {
    test('maps dashboard response into entity', () async {
      final dashboard = await repository.getDashboard(
        userId: 'user-1',
        welcomeName: 'Jane Doe',
      );

      expect(dashboard.chamaName, 'Kileleshwa Unity');
      expect(dashboard.userRole, 'Member');
      expect(dashboard.creditScore, 82);
      expect(dashboard.unreadNotifications, 3);
      expect(dashboard.recentActivities, hasLength(1));
      expect(dashboard.contributionSummary.paidByUser, 5000);
    });

    test('returns cached dashboard within TTL', () async {
      await repository.getDashboard(
        userId: 'user-1',
        welcomeName: 'Jane Doe',
      );

      api.dashboard = sampleDashboardDto().copyWith(
        memberCount: 99,
      );

      final cached = await repository.getDashboard(
        userId: 'user-1',
        welcomeName: 'Jane Doe',
      );

      expect(cached.memberCount, 8);
    });

    test('force refresh bypasses cache', () async {
      await repository.getDashboard(
        userId: 'user-1',
        welcomeName: 'Jane Doe',
      );

      api.dashboard = DashboardResponseDto(
        memberCount: 12,
        activeCycle: 'April Cycle',
        contributionsThisCycle: '1000.00',
        outstandingLoans: '500.00',
        pendingLoanApplications: 0,
        completedMeetings: 1,
        userSummary: const UserSummaryDto(
          contributionsPaid: '1000.00',
          activeLoans: 0,
          creditScore: 70,
        ),
      );

      final refreshed = await repository.getDashboard(
        userId: 'user-1',
        welcomeName: 'Jane Doe',
        forceRefresh: true,
      );

      expect(refreshed.memberCount, 12);
    });

    test('returns empty dashboard when user has no chamas', () async {
      api.chamas = [];

      final dashboard = await repository.getDashboard(
        userId: 'user-1',
        welcomeName: 'Jane Doe',
      );

      expect(dashboard.hasChama, isFalse);
      expect(dashboard.welcomeName, 'Jane Doe');
    });
  });
}

extension on DashboardResponseDto {
  DashboardResponseDto copyWith({int? memberCount}) {
    return DashboardResponseDto(
      memberCount: memberCount ?? this.memberCount,
      activeCycle: activeCycle,
      contributionsThisCycle: contributionsThisCycle,
      outstandingLoans: outstandingLoans,
      pendingLoanApplications: pendingLoanApplications,
      completedMeetings: completedMeetings,
      nextMeeting: nextMeeting,
      userSummary: userSummary,
    );
  }
}
