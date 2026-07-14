import 'package:chamaplus_mobile/core/errors/app_exception.dart';
import 'package:chamaplus_mobile/features/dashboard/data/cache/dashboard_cache.dart';
import 'package:chamaplus_mobile/features/dashboard/data/dtos/chama_dto.dart';
import 'package:chamaplus_mobile/features/dashboard/data/dtos/dashboard_response_dto.dart';
import 'package:chamaplus_mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:chamaplus_mobile/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_dashboard_api.dart';

void main() {
  late FakeDashboardApi api;
  late DashboardController controller;

  setUp(() {
    api = FakeDashboardApi()
      ..chamas = const [
        ChamaDto(id: 'chama-1', name: 'Unity Chama', currency: 'KES'),
      ]
      ..dashboard = sampleDashboardDto();
    final repository = DashboardRepositoryImpl(
      api: api,
      cache: DashboardCache(),
    );
    controller = DashboardController(
      repository: repository,
      userId: 'user-1',
      welcomeName: 'Jane Doe',
    );
  });

  group('DashboardController', () {
    test('load emits dashboard data', () async {
      await controller.load();

      expect(controller.state.isSuccess, isTrue);
      expect(controller.state.data?.welcomeName, 'Jane Doe');
      expect(controller.state.data?.creditScore, 82);
    });

    test('refresh bypasses cached repository data', () async {
      await controller.load();
      api.dashboard = sampleDashboardDto().copyWith(memberCount: 20);

      await controller.refresh();

      expect(controller.state.data?.memberCount, 20);
    });

    test('load surfaces repository errors', () async {
      api.listChamasError = const ServerException(message: 'Network down');

      await controller.load();

      expect(controller.state.isError, isTrue);
      expect(controller.state.errorMessage, 'Network down');
    });

    test('empty when user has no chama', () async {
      api.chamas = const [];

      await controller.load();

      expect(controller.state.isEmpty, isTrue);
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
