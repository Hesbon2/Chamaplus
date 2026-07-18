import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../shared/api_state.dart';
import '../../../chamas/domain/entities/chama.dart';
import '../../../chamas/presentation/providers/chama_providers.dart';
import '../../data/datasources/contribution_api.dart';
import '../../data/repositories/contribution_repository_impl.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/repositories/contribution_repository.dart';
import '../controllers/contribution_dashboard_controller.dart';
import '../controllers/contribution_details_controller.dart';
import '../controllers/contribution_history_controller.dart';
import '../controllers/cycle_details_controller.dart';
import '../controllers/cycles_controller.dart';
import '../controllers/member_contribution_summary_controller.dart';
import '../controllers/record_contribution_controller.dart';

final contributionApiProvider = Provider<ContributionApi>((ref) {
  return ContributionApi(ref.watch(apiClientProvider));
});

final contributionRepositoryProvider = Provider<ContributionRepository>((ref) {
  return ContributionRepositoryImpl(ref.watch(contributionApiProvider));
});

final contributionDashboardProvider = StateNotifierProvider.autoDispose
    .family<ContributionDashboardController, ApiState<ContributionDashboard>,
        String>((ref, chamaId) {
  final controller = ContributionDashboardController(
    repository: ref.watch(contributionRepositoryProvider),
    chamaId: chamaId,
  );
  Future.microtask(controller.load);
  return controller;
});

final cyclesControllerProvider = StateNotifierProvider.autoDispose
    .family<CyclesController, ApiState<List<ContributionCycle>>, String>(
  (ref, chamaId) {
    final controller = CyclesController(
      repository: ref.watch(contributionRepositoryProvider),
      chamaId: chamaId,
    );
    Future.microtask(controller.load);
    return controller;
  },
);

final cycleDetailsControllerProvider = StateNotifierProvider.autoDispose
    .family<CycleDetailsController, ApiState<ContributionCycle>,
        ({String chamaId, String cycleId})>((ref, args) {
  final controller = CycleDetailsController(
    repository: ref.watch(contributionRepositoryProvider),
    chamaId: args.chamaId,
    cycleId: args.cycleId,
  );
  Future.microtask(controller.load);
  return controller;
});

final contributionHistoryControllerProvider = StateNotifierProvider.autoDispose
    .family<ContributionHistoryController, ApiState<List<Contribution>>,
        ({String chamaId, String? cycleId, String? memberId})>((ref, args) {
  final controller = ContributionHistoryController(
    repository: ref.watch(contributionRepositoryProvider),
    chamaId: args.chamaId,
    initialCycleId: args.cycleId,
    initialMemberId: args.memberId,
  );
  Future.microtask(controller.load);
  return controller;
});

final contributionDetailsControllerProvider = StateNotifierProvider.autoDispose
    .family<ContributionDetailsController, ApiState<Contribution>,
        ({String chamaId, String contributionId})>((ref, args) {
  final controller = ContributionDetailsController(
    repository: ref.watch(contributionRepositoryProvider),
    chamaId: args.chamaId,
    contributionId: args.contributionId,
  );
  Future.microtask(controller.load);
  return controller;
});

final memberContributionSummaryProvider = StateNotifierProvider.autoDispose
    .family<MemberContributionSummaryController,
        ApiState<MemberContributionSummary>,
        ({String chamaId, String memberId})>((ref, args) {
  final controller = MemberContributionSummaryController(
    repository: ref.watch(contributionRepositoryProvider),
    chamaId: args.chamaId,
    memberId: args.memberId,
  );
  Future.microtask(controller.load);
  return controller;
});

final recordContributionControllerProvider = StateNotifierProvider.autoDispose
    .family<RecordContributionController, RecordContributionState, String>(
  (ref, chamaId) {
    return RecordContributionController(
      repository: ref.watch(contributionRepositoryProvider),
      chamaId: chamaId,
    );
  },
);

/// Open cycles available when recording a contribution.
final openCyclesProvider =
    FutureProvider.autoDispose.family<List<ContributionCycle>, String>(
  (ref, chamaId) {
    return ref.watch(contributionRepositoryProvider).listCycles(
          chamaId: chamaId,
          status: CycleStatus.open,
        );
  },
);

/// Active members for the record-contribution member dropdown.
final activeMembersForContributionsProvider =
    FutureProvider.autoDispose.family<List<Membership>, String>(
  (ref, chamaId) async {
    final result = await ref.watch(chamaRepositoryProvider).listMembers(
          chamaId: chamaId,
          status: MembershipStatus.active,
          pageSize: 100,
        );
    return result.items;
  },
);
