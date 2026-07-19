import 'package:chamaplus_mobile/core/errors/app_exception.dart';
import 'package:chamaplus_mobile/features/loans/domain/entities/loan.dart';
import 'package:chamaplus_mobile/features/loans/domain/repositories/loan_repository.dart';
import 'package:chamaplus_mobile/features/loans/presentation/controllers/loan_controllers.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeLoanRepository implements LoanRepository {
  List<LoanProduct> products = [];
  PagedResult<LoanApplication> applications =
      const PagedResult(items: [], count: 0);
  Object? error;

  @override
  Future<LoanApplication> apply({
    required String chamaId,
    required ApplyLoanInput input,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanApplication> approveApplication({
    required String chamaId,
    required String applicationId,
    double? approvedAmount,
    String? remarks,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanApplication> cancelApplication({
    required String chamaId,
    required String applicationId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<({CommitteeVote vote, LoanApplication application})> castVote({
    required String chamaId,
    required String applicationId,
    required CastVoteInput input,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanApplication> disburseApplication({
    required String chamaId,
    required String applicationId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanApplication> getApplication({
    required String chamaId,
    required String applicationId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MemberCreditScore?> getCurrentCreditScore({
    required String chamaId,
    required String memberId,
  }) async =>
      null;

  @override
  Future<LoanDashboard> getDashboard({
    required String chamaId,
    required String memberId,
    String currency = 'KES',
  }) async {
    if (error != null) throw error!;
    return LoanDashboard(
      loanLimit: 50000,
      outstandingBalance: 0,
      recentApplications: const [],
      currency: currency,
    );
  }

  @override
  Future<LoanProduct> getProduct({
    required String chamaId,
    required String productId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanRepayment> getRepayment({
    required String chamaId,
    required String applicationId,
    required String repaymentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PagedResult<LoanApplication>> listApplications({
    required String chamaId,
    String? search,
    LoanApplicationStatus? status,
    String? memberId,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (error != null) throw error!;
    return applications;
  }

  @override
  Future<List<LoanProduct>> listProducts({
    required String chamaId,
    String? search,
    bool? isActive,
  }) async {
    if (error != null) throw error!;
    var list = products;
    if (search != null && search.isNotEmpty) {
      list = list
          .where((p) => p.name.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Future<PagedResult<LoanRepayment>> listRepayments({
    required String chamaId,
    required String applicationId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return const PagedResult(items: [], count: 0);
  }

  @override
  Future<List<CommitteeVote>> listVotes({
    required String chamaId,
    required String applicationId,
  }) async =>
      [];

  @override
  Future<({LoanRepayment repayment, LoanApplication application})>
      recordRepayment({
    required String chamaId,
    required String applicationId,
    required RecordRepaymentInput input,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanApplication> rejectApplication({
    required String chamaId,
    required String applicationId,
    String? remarks,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoanApplication> submitApplication({
    required String chamaId,
    required String applicationId,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  test('LoanProductsController loads products', () async {
    final repo = FakeLoanRepository()
      ..products = [
        const LoanProduct(
          id: 'p1',
          chamaId: 'c1',
          name: 'Emergency',
          interestRate: 10,
          minimumAmount: 1000,
          maximumAmount: 20000,
          maximumDuration: 6,
          gracePeriodDays: 0,
          processingFee: 0,
          isActive: true,
        ),
      ];
    final controller = LoanProductsController(
      repository: repo,
      chamaId: 'c1',
    );

    await controller.load();
    expect(controller.state.isSuccess, isTrue);
    expect(controller.state.data, hasLength(1));
  });

  test('LoanProductsController search refreshes list', () async {
    final repo = FakeLoanRepository()
      ..products = [
        const LoanProduct(
          id: 'p1',
          chamaId: 'c1',
          name: 'Emergency',
          interestRate: 10,
          minimumAmount: 1000,
          maximumAmount: 20000,
          maximumDuration: 6,
          gracePeriodDays: 0,
          processingFee: 0,
          isActive: true,
        ),
        const LoanProduct(
          id: 'p2',
          chamaId: 'c1',
          name: 'Business',
          interestRate: 12,
          minimumAmount: 5000,
          maximumAmount: 80000,
          maximumDuration: 12,
          gracePeriodDays: 0,
          processingFee: 0,
          isActive: true,
        ),
      ];
    final controller = LoanProductsController(
      repository: repo,
      chamaId: 'c1',
    );

    await controller.search('bus');
    expect(controller.state.data, hasLength(1));
    expect(controller.state.data!.first.name, 'Business');
  });

  test('LoanDashboardController surfaces errors', () async {
    final repo = FakeLoanRepository()
      ..error = const ServerException(message: 'Offline');
    final controller = LoanDashboardController(
      repository: repo,
      chamaId: 'c1',
      memberId: 'u1',
    );

    await controller.load();
    expect(controller.state.isError, isTrue);
    expect(controller.state.errorMessage, contains('Offline'));
  });
}
