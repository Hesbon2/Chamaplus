import 'package:chamaplus_mobile/core/errors/app_exception.dart';
import 'package:chamaplus_mobile/features/contributions/data/dtos/contribution_dtos.dart';
import 'package:chamaplus_mobile/features/contributions/data/repositories/contribution_repository_impl.dart';
import 'package:chamaplus_mobile/features/contributions/domain/entities/contribution.dart';
import 'package:chamaplus_mobile/features/contributions/presentation/controllers/contribution_history_controller.dart';
import 'package:chamaplus_mobile/features/contributions/presentation/controllers/cycles_controller.dart';
import 'package:chamaplus_mobile/features/contributions/presentation/controllers/record_contribution_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/contribution_repository_impl_test.dart';

void main() {
  late FakeContributionApi api;
  late ContributionRepositoryImpl repository;

  setUp(() {
    api = FakeContributionApi()
      ..cycles = [sampleCycle(), sampleCycle(id: 'cycle-2', name: 'June')]
      ..contributionsPage = ContributionsPageDto(
        count: 2,
        results: [
          sampleContribution(id: 'c1', reference: 'CASH-001'),
          sampleContribution(id: 'c2', reference: 'CASH-002'),
        ],
      );
    repository = ContributionRepositoryImpl(api);
  });

  group('CyclesController', () {
    test('load populates cycles', () async {
      final controller = CyclesController(
        repository: repository,
        chamaId: 'chama-1',
      );
      await controller.load();
      expect(controller.state.isSuccess, isTrue);
      expect(controller.state.data, hasLength(2));
    });

    test('search filters cycles', () async {
      final controller = CyclesController(
        repository: repository,
        chamaId: 'chama-1',
      );
      await controller.search('july');
      expect(controller.state.data, hasLength(1));
      expect(controller.state.data!.first.name, 'July Cycle');
    });

    test('surfaces list errors', () async {
      api.listError = const ServerException(message: 'Boom');
      final controller = CyclesController(
        repository: repository,
        chamaId: 'chama-1',
      );
      await controller.load();
      expect(controller.state.isError, isTrue);
      expect(controller.state.errorMessage, 'Boom');
    });
  });

  group('ContributionHistoryController', () {
    test('load and search', () async {
      final controller = ContributionHistoryController(
        repository: repository,
        chamaId: 'chama-1',
        pageSize: 20,
      );
      await controller.load();
      expect(controller.state.data, hasLength(2));

      await controller.search('CASH-002');
      expect(controller.state.data, hasLength(1));
      expect(controller.state.data!.first.reference, 'CASH-002');
    });
  });

  group('RecordContributionController', () {
    test('submit records contribution', () async {
      final controller = RecordContributionController(
        repository: repository,
        chamaId: 'chama-1',
      );
      final recorded = await controller.submit(
        const RecordContributionInput(
          cycleId: 'cycle-1',
          memberId: 'member-1',
          amount: '1000.00',
          paymentMethod: PaymentMethod.cash,
          reference: 'REF-1',
        ),
      );
      expect(recorded, isNotNull);
      expect(controller.state.recorded?.reference, 'REF-1');
    });

    test('submit surfaces errors', () async {
      api.error = const ServerException(message: 'Denied');
      final controller = RecordContributionController(
        repository: repository,
        chamaId: 'chama-1',
      );
      final recorded = await controller.submit(
        const RecordContributionInput(
          cycleId: 'cycle-1',
          memberId: 'member-1',
          amount: '1000.00',
          paymentMethod: PaymentMethod.cash,
          reference: 'REF-1',
        ),
      );
      expect(recorded, isNull);
      expect(controller.state.errorMessage, 'Denied');
    });
  });
}
