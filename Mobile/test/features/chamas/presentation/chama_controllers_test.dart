import 'package:chamaplus_mobile/core/errors/app_exception.dart';
import 'package:chamaplus_mobile/features/chamas/data/dtos/chama_dtos.dart';
import 'package:chamaplus_mobile/features/chamas/data/repositories/chama_repository_impl.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/controllers/chama_list_controller.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/controllers/join_requests_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/chama_repository_impl_test.dart';

void main() {
  late FakeChamaApi api;
  late ChamaRepositoryImpl repository;

  setUp(() {
    api = FakeChamaApi();
    repository = ChamaRepositoryImpl(api);
    api.chamas = [
      const ChamaDto(
        id: 'c1',
        name: 'Unity Chama',
        currency: 'KES',
        isActive: true,
      ),
      const ChamaDto(
        id: 'c2',
        name: 'Westlands',
        currency: 'KES',
        isActive: true,
      ),
    ];
    api.pendingMembers = MembersPageDto(
      count: 1,
      results: [sampleMembership(id: 'm3', status: 'pending')],
    );
  });

  group('ChamaListController', () {
    test('load populates chamas', () async {
      final controller = ChamaListController(repository);
      await controller.load();
      expect(controller.state.isSuccess, isTrue);
      expect(controller.state.data, hasLength(2));
      expect(controller.state.isLoading, isFalse);
    });

    test('search filters via repository', () async {
      final controller = ChamaListController(repository);
      await controller.search('unity');
      expect(controller.state.data, hasLength(1));
      expect(controller.state.data!.first.name, 'Unity Chama');
    });

    test('loadMore appends client-side pages', () async {
      final controller = ChamaListController(repository, pageSize: 1);
      await controller.load();
      expect(controller.state.data, hasLength(1));
      expect(controller.state.hasMore, isTrue);

      await controller.loadMore();
      expect(controller.state.data, hasLength(2));
      expect(controller.state.hasMore, isFalse);
    });
  });

  group('JoinRequestsController', () {
    test('approve removes request from list', () async {
      api.updatedMembership = sampleMembership(id: 'm3', status: 'active');
      final controller = JoinRequestsController(
        repository: repository,
        chamaId: 'c1',
      );
      await controller.load();
      expect(controller.state.data, hasLength(1));

      await controller.approve('m3');
      expect(controller.state.isEmpty, isTrue);
      expect(controller.actionMessage, contains('approved'));
    });

    test('surfaces errors', () async {
      api.error = const ServerException(message: 'Boom');
      final controller = ChamaListController(repository);
      await controller.load();
      expect(controller.state.isError, isTrue);
      expect(controller.state.errorMessage, 'Boom');
    });
  });
}
