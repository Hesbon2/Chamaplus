import '../../domain/entities/loan.dart';
import '../../domain/repositories/loan_repository.dart';
import '../datasources/loan_api.dart';
import '../dtos/loan_dtos.dart';

/// Concrete [LoanRepository] backed by [LoanRemoteDataSource].
class LoanRepositoryImpl implements LoanRepository {
  LoanRepositoryImpl(this._api);

  final LoanRemoteDataSource _api;

  @override
  Future<List<LoanProduct>> listProducts({
    required String chamaId,
    String? search,
    bool? isActive,
  }) async {
    final dtos = await _api.listProducts(
      chamaId: chamaId,
      search: search,
      isActive: isActive,
    );
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<LoanProduct> getProduct({
    required String chamaId,
    required String productId,
  }) async {
    final dto = await _api.getProduct(chamaId: chamaId, productId: productId);
    return dto.toEntity();
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
    final dto = await _api.listApplications(
      chamaId: chamaId,
      search: search,
      status: status?.apiValue,
      memberId: memberId,
      page: page,
      pageSize: pageSize,
    );
    return PagedResult(
      items: dto.results.map((e) => e.toEntity()).toList(),
      count: dto.count,
      hasMore: dto.next != null,
      nextPage: dto.next != null ? page + 1 : null,
    );
  }

  @override
  Future<LoanApplication> getApplication({
    required String chamaId,
    required String applicationId,
  }) async {
    final dto = await _api.getApplication(
      chamaId: chamaId,
      applicationId: applicationId,
    );
    return dto.toEntity();
  }

  @override
  Future<LoanApplication> apply({
    required String chamaId,
    required ApplyLoanInput input,
  }) async {
    final dto = await _api.apply(
      chamaId: chamaId,
      body: {
        'loan_product_id': input.loanProductId,
        'requested_amount': input.requestedAmount.toStringAsFixed(2),
        'requested_duration': input.requestedDuration,
        'purpose': input.purpose,
        if (input.remarks != null && input.remarks!.trim().isNotEmpty)
          'remarks': input.remarks!.trim(),
        'submit': input.submit,
      },
    );
    return dto.toEntity();
  }

  @override
  Future<LoanApplication> submitApplication({
    required String chamaId,
    required String applicationId,
  }) async {
    final dto = await _api.submitApplication(
      chamaId: chamaId,
      applicationId: applicationId,
    );
    return dto.toEntity();
  }

  @override
  Future<LoanApplication> cancelApplication({
    required String chamaId,
    required String applicationId,
  }) async {
    final dto = await _api.cancelApplication(
      chamaId: chamaId,
      applicationId: applicationId,
    );
    return dto.toEntity();
  }

  @override
  Future<LoanApplication> approveApplication({
    required String chamaId,
    required String applicationId,
    double? approvedAmount,
    String? remarks,
  }) async {
    final dto = await _api.approveApplication(
      chamaId: chamaId,
      applicationId: applicationId,
      body: {
        if (approvedAmount != null)
          'approved_amount': approvedAmount.toStringAsFixed(2),
        if (remarks != null && remarks.trim().isNotEmpty)
          'remarks': remarks.trim(),
      },
    );
    return dto.toEntity();
  }

  @override
  Future<LoanApplication> rejectApplication({
    required String chamaId,
    required String applicationId,
    String? remarks,
  }) async {
    final dto = await _api.rejectApplication(
      chamaId: chamaId,
      applicationId: applicationId,
      body: {
        if (remarks != null && remarks.trim().isNotEmpty)
          'remarks': remarks.trim(),
      },
    );
    return dto.toEntity();
  }

  @override
  Future<LoanApplication> disburseApplication({
    required String chamaId,
    required String applicationId,
  }) async {
    final dto = await _api.disburseApplication(
      chamaId: chamaId,
      applicationId: applicationId,
    );
    return dto.toEntity();
  }

  @override
  Future<List<CommitteeVote>> listVotes({
    required String chamaId,
    required String applicationId,
  }) async {
    final dtos = await _api.listVotes(
      chamaId: chamaId,
      applicationId: applicationId,
    );
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<({CommitteeVote vote, LoanApplication application})> castVote({
    required String chamaId,
    required String applicationId,
    required CastVoteInput input,
  }) async {
    final data = await _api.castVote(
      chamaId: chamaId,
      applicationId: applicationId,
      body: {
        'decision': input.decision.apiValue,
        if (input.comment != null && input.comment!.trim().isNotEmpty)
          'comment': input.comment!.trim(),
      },
    );
    final vote = CommitteeVoteDto.fromJson(
      Map<String, dynamic>.from(data['vote'] as Map),
    ).toEntity();
    final application = LoanApplicationDto.fromJson(
      Map<String, dynamic>.from(data['application'] as Map),
    ).toEntity();
    return (vote: vote, application: application);
  }

  @override
  Future<PagedResult<LoanRepayment>> listRepayments({
    required String chamaId,
    required String applicationId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final dto = await _api.listRepayments(
      chamaId: chamaId,
      applicationId: applicationId,
      page: page,
      pageSize: pageSize,
    );
    return PagedResult(
      items: dto.results.map((e) => e.toEntity()).toList(),
      count: dto.count,
      hasMore: dto.next != null,
      nextPage: dto.next != null ? page + 1 : null,
    );
  }

  @override
  Future<LoanRepayment> getRepayment({
    required String chamaId,
    required String applicationId,
    required String repaymentId,
  }) async {
    final dto = await _api.getRepayment(
      chamaId: chamaId,
      applicationId: applicationId,
      repaymentId: repaymentId,
    );
    return dto.toEntity();
  }

  @override
  Future<({LoanRepayment repayment, LoanApplication application})>
      recordRepayment({
    required String chamaId,
    required String applicationId,
    required RecordRepaymentInput input,
  }) async {
    final data = await _api.recordRepayment(
      chamaId: chamaId,
      applicationId: applicationId,
      body: {
        'amount': input.amount.toStringAsFixed(2),
        'payment_method': input.paymentMethod.apiValue,
        'reference': input.reference,
        if (input.paymentDate != null)
          'payment_date':
              input.paymentDate!.toIso8601String().split('T').first,
      },
    );
    final repayment = LoanRepaymentDto.fromJson(
      Map<String, dynamic>.from(data['repayment'] as Map),
    ).toEntity();
    final application = LoanApplicationDto.fromJson(
      Map<String, dynamic>.from(data['application'] as Map),
    ).toEntity();
    return (repayment: repayment, application: application);
  }

  @override
  Future<MemberCreditScore?> getCurrentCreditScore({
    required String chamaId,
    required String memberId,
  }) async {
    final dto = await _api.getCurrentCreditScore(
      chamaId: chamaId,
      memberId: memberId,
    );
    return dto?.toEntity();
  }

  @override
  Future<LoanDashboard> getDashboard({
    required String chamaId,
    required String memberId,
    String currency = 'KES',
  }) async {
    final productsFuture = listProducts(chamaId: chamaId, isActive: true);
    final appsFuture = listApplications(
      chamaId: chamaId,
      memberId: memberId,
      page: 1,
      pageSize: 20,
    );
    final scoreFuture = getCurrentCreditScore(
      chamaId: chamaId,
      memberId: memberId,
    );

    final products = await productsFuture;
    final appsPage = await appsFuture;
    final creditScore = await scoreFuture;

    final applications = appsPage.items;
    LoanApplication? activeLoan;
    for (final app in applications) {
      if (app.status.isActiveLoan) {
        activeLoan = app;
        break;
      }
    }

    LoanProduct? activeProduct;
    if (activeLoan != null) {
      for (final p in products) {
        if (p.id == activeLoan.loanProductId) {
          activeProduct = p;
          break;
        }
      }
    }

    final loanLimit = products.isEmpty
        ? 0.0
        : products
            .map((p) => p.maximumAmount)
            .reduce((a, b) => a > b ? a : b);

    final outstanding = activeLoan?.outstandingBalance ??
        applications
            .where((a) => a.status.isActiveLoan)
            .fold<double>(0, (sum, a) => sum + (a.outstandingBalance ?? 0));

    double? nextInstallment;
    if (activeLoan != null && activeProduct != null) {
      final calc = LoanCalculation.flat(
        principal: activeLoan.principalAmount,
        durationMonths: activeLoan.requestedDuration,
        annualInterestRate: activeProduct.interestRate,
      );
      nextInstallment = calc.monthlyRepayment;
    }

    return LoanDashboard(
      activeLoan: activeLoan,
      activeProduct: activeProduct,
      loanLimit: loanLimit,
      outstandingBalance: outstanding,
      creditScore: creditScore,
      recentApplications: applications.take(5).toList(),
      nextInstallmentEstimate: nextInstallment,
      currency: currency,
    );
  }
}
