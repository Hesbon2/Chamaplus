import '../entities/loan.dart';

/// Contract for loan products, applications, votes, and repayments.
abstract class LoanRepository {
  Future<List<LoanProduct>> listProducts({
    required String chamaId,
    String? search,
    bool? isActive,
  });

  Future<LoanProduct> getProduct({
    required String chamaId,
    required String productId,
  });

  Future<PagedResult<LoanApplication>> listApplications({
    required String chamaId,
    String? search,
    LoanApplicationStatus? status,
    String? memberId,
    int page = 1,
    int pageSize = 20,
  });

  Future<LoanApplication> getApplication({
    required String chamaId,
    required String applicationId,
  });

  Future<LoanApplication> apply({
    required String chamaId,
    required ApplyLoanInput input,
  });

  Future<LoanApplication> submitApplication({
    required String chamaId,
    required String applicationId,
  });

  Future<LoanApplication> cancelApplication({
    required String chamaId,
    required String applicationId,
  });

  Future<LoanApplication> approveApplication({
    required String chamaId,
    required String applicationId,
    double? approvedAmount,
    String? remarks,
  });

  Future<LoanApplication> rejectApplication({
    required String chamaId,
    required String applicationId,
    String? remarks,
  });

  Future<LoanApplication> disburseApplication({
    required String chamaId,
    required String applicationId,
  });

  Future<List<CommitteeVote>> listVotes({
    required String chamaId,
    required String applicationId,
  });

  Future<({CommitteeVote vote, LoanApplication application})> castVote({
    required String chamaId,
    required String applicationId,
    required CastVoteInput input,
  });

  Future<PagedResult<LoanRepayment>> listRepayments({
    required String chamaId,
    required String applicationId,
    int page = 1,
    int pageSize = 20,
  });

  Future<LoanRepayment> getRepayment({
    required String chamaId,
    required String applicationId,
    required String repaymentId,
  });

  Future<({LoanRepayment repayment, LoanApplication application})>
      recordRepayment({
    required String chamaId,
    required String applicationId,
    required RecordRepaymentInput input,
  });

  Future<MemberCreditScore?> getCurrentCreditScore({
    required String chamaId,
    required String memberId,
  });

  Future<LoanDashboard> getDashboard({
    required String chamaId,
    required String memberId,
    String currency,
  });
}
