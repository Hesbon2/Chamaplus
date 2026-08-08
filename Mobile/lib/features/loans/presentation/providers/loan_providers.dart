import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../shared/api_state.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/loan_api.dart';
import '../../data/repositories/loan_repository_impl.dart';
import '../../domain/entities/loan.dart';
import '../../domain/repositories/loan_repository.dart';
import '../controllers/loan_controllers.dart';

final loanApiProvider = Provider<LoanApi>((ref) {
  return LoanApi(ref.watch(apiClientProvider));
});

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  return LoanRepositoryImpl(ref.watch(loanApiProvider));
});

final loanDashboardProvider = StateNotifierProvider.autoDispose
    .family<LoanDashboardController, ApiState<LoanDashboard>, String>(
  (ref, chamaId) {
    final userId = ref.watch(authControllerProvider).user?.id ?? '';
    final controller = LoanDashboardController(
      repository: ref.watch(loanRepositoryProvider),
      chamaId: chamaId,
      memberId: userId,
    );
    Future.microtask(controller.load);
    return controller;
  },
);

final loanProductsControllerProvider = StateNotifierProvider.autoDispose
    .family<LoanProductsController, ApiState<List<LoanProduct>>, String>(
  (ref, chamaId) {
    final controller = LoanProductsController(
      repository: ref.watch(loanRepositoryProvider),
      chamaId: chamaId,
    );
    Future.microtask(controller.load);
    return controller;
  },
);

final loanProductDetailsProvider = StateNotifierProvider.autoDispose.family<
    LoanProductDetailsController,
    ApiState<LoanProduct>,
    ({String chamaId, String productId})>((ref, args) {
  final controller = LoanProductDetailsController(
    repository: ref.watch(loanRepositoryProvider),
    chamaId: args.chamaId,
    productId: args.productId,
  );
  Future.microtask(controller.load);
  return controller;
});

final loanHistoryControllerProvider = StateNotifierProvider.autoDispose.family<
    LoanHistoryController,
    ApiState<List<LoanApplication>>,
    ({String chamaId, bool mineOnly})>((ref, args) {
  final userId = ref.watch(authControllerProvider).user?.id;
  final controller = LoanHistoryController(
    repository: ref.watch(loanRepositoryProvider),
    chamaId: args.chamaId,
    memberId: args.mineOnly ? userId : null,
  );
  Future.microtask(controller.load);
  return controller;
});

final loanDetailsControllerProvider = StateNotifierProvider.autoDispose.family<
    LoanDetailsController,
    ApiState<LoanApplication>,
    ({String chamaId, String applicationId})>((ref, args) {
  final controller = LoanDetailsController(
    repository: ref.watch(loanRepositoryProvider),
    chamaId: args.chamaId,
    applicationId: args.applicationId,
  );
  Future.microtask(controller.load);
  return controller;
});

final committeeVotingControllerProvider =
    StateNotifierProvider.autoDispose.family<
        CommitteeVotingController,
        ApiState<List<CommitteeVote>>,
        ({String chamaId, String applicationId})>((ref, args) {
  final controller = CommitteeVotingController(
    repository: ref.watch(loanRepositoryProvider),
    chamaId: args.chamaId,
    applicationId: args.applicationId,
  );
  Future.microtask(controller.load);
  return controller;
});

final repaymentHistoryControllerProvider =
    StateNotifierProvider.autoDispose.family<
        RepaymentHistoryController,
        ApiState<List<LoanRepayment>>,
        ({String chamaId, String applicationId})>((ref, args) {
  final controller = RepaymentHistoryController(
    repository: ref.watch(loanRepositoryProvider),
    chamaId: args.chamaId,
    applicationId: args.applicationId,
  );
  Future.microtask(controller.load);
  return controller;
});

final applyLoanControllerProvider =
    StateNotifierProvider.autoDispose<ApplyLoanController, ApplyLoanState>(
  (ref) => ApplyLoanController(ref.watch(loanRepositoryProvider)),
);

final manageLoanProductControllerProvider = StateNotifierProvider.autoDispose<
    ManageLoanProductController, ManageLoanProductState>(
  (ref) => ManageLoanProductController(ref.watch(loanRepositoryProvider)),
);

/// Active loan products for dropdowns / calculator.
final activeLoanProductsProvider =
    FutureProvider.autoDispose.family<List<LoanProduct>, String>(
  (ref, chamaId) {
    return ref.watch(loanRepositoryProvider).listProducts(
          chamaId: chamaId,
          isActive: true,
        );
  },
);
