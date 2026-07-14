import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../shared/api_state.dart';
import '../../data/datasources/chama_api.dart';
import '../../data/repositories/chama_repository_impl.dart';
import '../../domain/entities/chama.dart';
import '../../domain/repositories/chama_repository.dart';
import '../controllers/chama_details_controller.dart';
import '../controllers/chama_list_controller.dart';
import '../controllers/join_requests_controller.dart';
import '../controllers/members_controller.dart';

final chamaApiProvider = Provider<ChamaApi>((ref) {
  return ChamaApi(ref.watch(apiClientProvider));
});

final chamaRepositoryProvider = Provider<ChamaRepository>((ref) {
  return ChamaRepositoryImpl(ref.watch(chamaApiProvider));
});

final chamaListControllerProvider =
    StateNotifierProvider.autoDispose<ChamaListController, ApiState<List<Chama>>>(
  (ref) {
    final controller = ChamaListController(ref.watch(chamaRepositoryProvider));
    Future.microtask(controller.load);
    return controller;
  },
);

final chamaDetailsControllerProvider = StateNotifierProvider.autoDispose
    .family<ChamaDetailsController, ApiState<ChamaDetails>, String>(
  (ref, chamaId) {
    final controller = ChamaDetailsController(
      repository: ref.watch(chamaRepositoryProvider),
      chamaId: chamaId,
    );
    Future.microtask(controller.load);
    return controller;
  },
);

final membersControllerProvider = StateNotifierProvider.autoDispose
    .family<MembersController, ApiState<List<Membership>>, String>(
  (ref, chamaId) {
    final controller = MembersController(
      repository: ref.watch(chamaRepositoryProvider),
      chamaId: chamaId,
    );
    Future.microtask(controller.load);
    return controller;
  },
);

final joinRequestsControllerProvider = StateNotifierProvider.autoDispose
    .family<JoinRequestsController, ApiState<List<Membership>>, String>(
  (ref, chamaId) {
    final controller = JoinRequestsController(
      repository: ref.watch(chamaRepositoryProvider),
      chamaId: chamaId,
    );
    Future.microtask(controller.load);
    return controller;
  },
);

final memberDetailsProvider = FutureProvider.autoDispose
    .family<Membership?, ({String chamaId, String membershipId})>(
  (ref, args) {
    return ref.watch(chamaRepositoryProvider).getMember(
          chamaId: args.chamaId,
          membershipId: args.membershipId,
        );
  },
);
