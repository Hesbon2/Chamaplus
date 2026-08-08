import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/api_state.dart';
import '../../domain/entities/loan.dart';
import '../../domain/repositories/loan_repository.dart';

class LoanDashboardController extends RefreshController<LoanDashboard> {
  LoanDashboardController({
    required LoanRepository repository,
    required String chamaId,
    required String memberId,
    this.currency = 'KES',
  })  : _repository = repository,
        _chamaId = chamaId,
        _memberId = memberId;

  final LoanRepository _repository;
  final String _chamaId;
  final String _memberId;
  final String currency;

  @override
  Future<LoanDashboard> fetchData({bool forceRefresh = false}) {
    return _repository.getDashboard(
      chamaId: _chamaId,
      memberId: _memberId,
      currency: currency,
    );
  }
}

class LoanProductsController extends RefreshController<List<LoanProduct>> {
  LoanProductsController({
    required LoanRepository repository,
    required String chamaId,
  })  : _repository = repository,
        _chamaId = chamaId;

  final LoanRepository _repository;
  final String _chamaId;

  String searchQuery = '';
  bool? activeOnly = true;

  @override
  Future<List<LoanProduct>> fetchData({bool forceRefresh = false}) {
    return _repository.listProducts(
      chamaId: _chamaId,
      search: searchQuery.isEmpty ? null : searchQuery,
      isActive: activeOnly,
    );
  }

  @override
  bool isEmptyData(List<LoanProduct> data) => data.isEmpty;

  Future<void> search(String query) async {
    searchQuery = query;
    await load(forceRefresh: true);
  }

  Future<void> setActiveOnly(bool? value) async {
    activeOnly = value;
    await load(forceRefresh: true);
  }
}

class LoanProductDetailsController extends RefreshController<LoanProduct> {
  LoanProductDetailsController({
    required LoanRepository repository,
    required String chamaId,
    required String productId,
  })  : _repository = repository,
        _chamaId = chamaId,
        _productId = productId;

  final LoanRepository _repository;
  final String _chamaId;
  final String _productId;

  @override
  Future<LoanProduct> fetchData({bool forceRefresh = false}) {
    return _repository.getProduct(chamaId: _chamaId, productId: _productId);
  }
}

class LoanHistoryController extends PaginationController<LoanApplication> {
  LoanHistoryController({
    required LoanRepository repository,
    required String chamaId,
    this.memberId,
    super.pageSize = 20,
  })  : _repository = repository,
        _chamaId = chamaId;

  final LoanRepository _repository;
  final String _chamaId;
  final String? memberId;

  String searchQuery = '';
  LoanApplicationStatus? statusFilter;

  @override
  Future<PageResult<LoanApplication>> fetchPage({
    required int page,
    required int pageSize,
  }) async {
    final result = await _repository.listApplications(
      chamaId: _chamaId,
      search: searchQuery.isEmpty ? null : searchQuery,
      status: statusFilter,
      memberId: memberId,
      page: page,
      pageSize: pageSize,
    );
    return PageResult(
      items: result.items,
      hasMore: result.hasMore,
      totalCount: result.count,
    );
  }

  Future<void> search(String query) async {
    searchQuery = query;
    await load();
  }

  Future<void> setStatusFilter(LoanApplicationStatus? status) async {
    statusFilter = status;
    await load();
  }
}

class LoanDetailsController extends RefreshController<LoanApplication> {
  LoanDetailsController({
    required LoanRepository repository,
    required String chamaId,
    required String applicationId,
  })  : _repository = repository,
        _chamaId = chamaId,
        _applicationId = applicationId;

  final LoanRepository _repository;
  final String _chamaId;
  final String _applicationId;

  bool isActing = false;
  String? actionError;
  List<CommitteeVote> votes = const [];

  @override
  Future<LoanApplication> fetchData({bool forceRefresh = false}) async {
    final app = await _repository.getApplication(
      chamaId: _chamaId,
      applicationId: _applicationId,
    );
    try {
      votes = await _repository.listVotes(
        chamaId: _chamaId,
        applicationId: _applicationId,
      );
    } catch (_) {
      votes = const [];
    }
    return app;
  }

  Future<bool> cancel() => _mutate(
        () => _repository.cancelApplication(
          chamaId: _chamaId,
          applicationId: _applicationId,
        ),
      );

  Future<bool> submit() => _mutate(
        () => _repository.submitApplication(
          chamaId: _chamaId,
          applicationId: _applicationId,
        ),
      );

  Future<bool> approve({double? approvedAmount, String? remarks}) => _mutate(
        () => _repository.approveApplication(
          chamaId: _chamaId,
          applicationId: _applicationId,
          approvedAmount: approvedAmount,
          remarks: remarks,
        ),
      );

  Future<bool> reject({String? remarks}) => _mutate(
        () => _repository.rejectApplication(
          chamaId: _chamaId,
          applicationId: _applicationId,
          remarks: remarks,
        ),
      );

  Future<bool> disburse() => _mutate(
        () => _repository.disburseApplication(
          chamaId: _chamaId,
          applicationId: _applicationId,
        ),
      );

  Future<bool> _mutate(Future<LoanApplication> Function() action) async {
    if (isActing) return false;
    isActing = true;
    actionError = null;
    if (mounted) state = state.copyWith();
    try {
      final updated = await action();
      if (!mounted) return false;
      state = ApiState.success(updated);
      return true;
    } catch (error) {
      if (!mounted) return false;
      actionError = error.toString();
      state = state.copyWith();
      return false;
    } finally {
      isActing = false;
      if (mounted) state = state.copyWith();
    }
  }
}

class CommitteeVotingController extends RefreshController<List<CommitteeVote>> {
  CommitteeVotingController({
    required LoanRepository repository,
    required String chamaId,
    required String applicationId,
  })  : _repository = repository,
        _chamaId = chamaId,
        _applicationId = applicationId;

  final LoanRepository _repository;
  final String _chamaId;
  final String _applicationId;

  bool isSubmitting = false;
  String? actionError;
  LoanApplication? latestApplication;

  @override
  Future<List<CommitteeVote>> fetchData({bool forceRefresh = false}) {
    return _repository.listVotes(
      chamaId: _chamaId,
      applicationId: _applicationId,
    );
  }

  @override
  bool isEmptyData(List<CommitteeVote> data) => false;

  Future<bool> castVote(CastVoteInput input) async {
    if (isSubmitting) return false;
    isSubmitting = true;
    actionError = null;
    if (mounted) state = state.copyWith();
    try {
      final result = await _repository.castVote(
        chamaId: _chamaId,
        applicationId: _applicationId,
        input: input,
      );
      if (!mounted) return false;
      latestApplication = result.application;
      await load(forceRefresh: true);
      return true;
    } catch (error) {
      if (!mounted) return false;
      actionError = error.toString();
      state = state.copyWith();
      return false;
    } finally {
      isSubmitting = false;
      if (mounted) state = state.copyWith();
    }
  }
}

class RepaymentHistoryController extends PaginationController<LoanRepayment> {
  RepaymentHistoryController({
    required LoanRepository repository,
    required String chamaId,
    required String applicationId,
    super.pageSize = 20,
  })  : _repository = repository,
        _chamaId = chamaId,
        _applicationId = applicationId;

  final LoanRepository _repository;
  final String _chamaId;
  final String _applicationId;

  double? remainingBalance;

  @override
  Future<PageResult<LoanRepayment>> fetchPage({
    required int page,
    required int pageSize,
  }) async {
    if (page == 1) {
      try {
        final app = await _repository.getApplication(
          chamaId: _chamaId,
          applicationId: _applicationId,
        );
        remainingBalance = app.outstandingBalance;
      } catch (_) {
        remainingBalance = null;
      }
    }
    final result = await _repository.listRepayments(
      chamaId: _chamaId,
      applicationId: _applicationId,
      page: page,
      pageSize: pageSize,
    );
    return PageResult(
      items: result.items,
      hasMore: result.hasMore,
      totalCount: result.count,
    );
  }
}

class ApplyLoanState {
  const ApplyLoanState({
    this.isSubmitting = false,
    this.errorMessage,
    this.application,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final LoanApplication? application;

  ApplyLoanState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    LoanApplication? application,
    bool clearError = false,
  }) {
    return ApplyLoanState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      application: application ?? this.application,
    );
  }
}

class ApplyLoanController extends StateNotifier<ApplyLoanState> {
  ApplyLoanController(this._repository) : super(const ApplyLoanState());

  final LoanRepository _repository;

  Future<LoanApplication?> submit({
    required String chamaId,
    required ApplyLoanInput input,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final app = await _repository.apply(chamaId: chamaId, input: input);
      if (!mounted) return null;
      state = state.copyWith(isSubmitting: false, application: app);
      return app;
    } catch (error) {
      if (!mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );
      return null;
    }
  }
}

class ManageLoanProductState {
  const ManageLoanProductState({
    this.isSubmitting = false,
    this.errorMessage,
    this.product,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final LoanProduct? product;

  ManageLoanProductState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    LoanProduct? product,
    bool clearError = false,
  }) {
    return ManageLoanProductState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      product: product ?? this.product,
    );
  }
}

class ManageLoanProductController
    extends StateNotifier<ManageLoanProductState> {
  ManageLoanProductController(this._repository)
      : super(const ManageLoanProductState());

  final LoanRepository _repository;

  Future<LoanProduct?> create({
    required String chamaId,
    required LoanProductInput input,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final product = await _repository.createProduct(
        chamaId: chamaId,
        input: input,
      );
      if (!mounted) return null;
      state = state.copyWith(isSubmitting: false, product: product);
      return product;
    } catch (error) {
      if (!mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );
      return null;
    }
  }

  Future<LoanProduct?> update({
    required String chamaId,
    required String productId,
    required LoanProductInput input,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final product = await _repository.updateProduct(
        chamaId: chamaId,
        productId: productId,
        input: input,
      );
      if (!mounted) return null;
      state = state.copyWith(isSubmitting: false, product: product);
      return product;
    } catch (error) {
      if (!mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );
      return null;
    }
  }

  Future<bool> delete({
    required String chamaId,
    required String productId,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.deleteProduct(
        chamaId: chamaId,
        productId: productId,
      );
      if (!mounted) return false;
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );
      return false;
    }
  }
}
