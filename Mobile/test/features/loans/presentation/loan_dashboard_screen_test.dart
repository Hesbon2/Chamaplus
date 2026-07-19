import 'package:chamaplus_mobile/features/loans/domain/entities/loan.dart';
import 'package:chamaplus_mobile/features/loans/domain/repositories/loan_repository.dart';
import 'package:chamaplus_mobile/features/loans/presentation/controllers/loan_controllers.dart';
import 'package:chamaplus_mobile/features/loans/presentation/providers/loan_providers.dart';
import 'package:chamaplus_mobile/features/loans/presentation/screens/loan_dashboard_screen.dart';
import 'package:chamaplus_mobile/shared/api_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLoanRepository implements LoanRepository {
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
    return const LoanDashboard(
      loanLimit: 50000,
      outstandingBalance: 12000,
      recentApplications: [],
      currency: 'KES',
      creditScore: MemberCreditScore(
        id: 'cs1',
        memberId: 'u1',
        score: 78,
        riskLevel: 'good',
      ),
      nextInstallmentEstimate: 2200,
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
    return const PagedResult(items: [], count: 0);
  }

  @override
  Future<List<LoanProduct>> listProducts({
    required String chamaId,
    String? search,
    bool? isActive,
  }) async =>
      [];

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

class _SeededDashboardController extends LoanDashboardController {
  _SeededDashboardController()
      : super(
          repository: _FakeLoanRepository(),
          chamaId: 'c1',
          memberId: 'u1',
        ) {
    state = const ApiState.success(
      LoanDashboard(
        loanLimit: 50000,
        outstandingBalance: 12000,
        recentApplications: [],
        currency: 'KES',
        creditScore: MemberCreditScore(
          id: 'cs1',
          memberId: 'u1',
          score: 78,
          riskLevel: 'good',
        ),
        nextInstallmentEstimate: 2200,
      ),
    );
  }

  @override
  Future<void> load({bool forceRefresh = false}) async {}

  @override
  Future<void> refresh() async {}
}

void main() {
  testWidgets('LoanDashboardScreen shows limit and credit score',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loanRepositoryProvider.overrideWithValue(_FakeLoanRepository()),
          loanDashboardProvider.overrideWith(
            (ref, chamaId) => _SeededDashboardController(),
          ),
        ],
        child: const MaterialApp(
          home: LoanDashboardScreen(chamaId: 'c1'),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Loan limit'), findsOneWidget);
    expect(find.textContaining('50,000'), findsWidgets);
    expect(find.text('Credit score'), findsOneWidget);
    expect(find.text('78'), findsOneWidget);
    expect(find.text('Quick actions'), findsOneWidget);
  });
}
