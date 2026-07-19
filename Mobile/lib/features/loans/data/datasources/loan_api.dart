import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../dtos/loan_dtos.dart';

/// Remote loan products / applications / votes / repayments API.
abstract class LoanRemoteDataSource {
  Future<List<LoanProductDto>> listProducts({
    required String chamaId,
    String? search,
    bool? isActive,
  });

  Future<LoanProductDto> getProduct({
    required String chamaId,
    required String productId,
  });

  Future<LoanApplicationsPageDto> listApplications({
    required String chamaId,
    String? search,
    String? status,
    String? memberId,
    int page = 1,
    int pageSize = ApiConstants.defaultPageSize,
  });

  Future<LoanApplicationDto> getApplication({
    required String chamaId,
    required String applicationId,
  });

  Future<LoanApplicationDto> apply({
    required String chamaId,
    required Map<String, dynamic> body,
  });

  Future<LoanApplicationDto> submitApplication({
    required String chamaId,
    required String applicationId,
  });

  Future<LoanApplicationDto> cancelApplication({
    required String chamaId,
    required String applicationId,
  });

  Future<LoanApplicationDto> approveApplication({
    required String chamaId,
    required String applicationId,
    required Map<String, dynamic> body,
  });

  Future<LoanApplicationDto> rejectApplication({
    required String chamaId,
    required String applicationId,
    required Map<String, dynamic> body,
  });

  Future<LoanApplicationDto> disburseApplication({
    required String chamaId,
    required String applicationId,
  });

  Future<List<CommitteeVoteDto>> listVotes({
    required String chamaId,
    required String applicationId,
  });

  Future<Map<String, dynamic>> castVote({
    required String chamaId,
    required String applicationId,
    required Map<String, dynamic> body,
  });

  Future<LoanRepaymentsPageDto> listRepayments({
    required String chamaId,
    required String applicationId,
    int page = 1,
    int pageSize = ApiConstants.defaultPageSize,
  });

  Future<LoanRepaymentDto> getRepayment({
    required String chamaId,
    required String applicationId,
    required String repaymentId,
  });

  Future<Map<String, dynamic>> recordRepayment({
    required String chamaId,
    required String applicationId,
    required Map<String, dynamic> body,
  });

  Future<CreditScoreDto?> getCurrentCreditScore({
    required String chamaId,
    required String memberId,
  });
}

class LoanApi implements LoanRemoteDataSource {
  LoanApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<LoanProductDto>> listProducts({
    required String chamaId,
    String? search,
    bool? isActive,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.loanProducts(chamaId),
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (isActive != null) 'is_active': isActive ? 'true' : 'false',
        'ordering': 'name',
      },
    );

    final envelope = ApiResponse<List<dynamic>>.fromJson(
      response.data ?? {},
      (data) => data as List<dynamic>? ?? [],
    );
    if (!envelope.success || envelope.data == null) {
      throw ServerException(message: envelope.message);
    }

    return envelope.data!
        .map((e) => LoanProductDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<LoanProductDto> getProduct({
    required String chamaId,
    required String productId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.loanProductDetail(chamaId, productId),
    );
    return LoanProductDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<LoanApplicationsPageDto> listApplications({
    required String chamaId,
    String? search,
    String? status,
    String? memberId,
    int page = 1,
    int pageSize = ApiConstants.defaultPageSize,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.loanApplications(chamaId),
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        'ordering': '-created_at',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null) 'status': status,
        if (memberId != null) 'member_id': memberId,
      },
    );
    return LoanApplicationsPageDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<LoanApplicationDto> getApplication({
    required String chamaId,
    required String applicationId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.loanApplicationDetail(chamaId, applicationId),
    );
    return LoanApplicationDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<LoanApplicationDto> apply({
    required String chamaId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.loanApplications(chamaId),
      data: body,
    );
    return LoanApplicationDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<LoanApplicationDto> submitApplication({
    required String chamaId,
    required String applicationId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.loanApplicationSubmit(chamaId, applicationId),
    );
    return LoanApplicationDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<LoanApplicationDto> cancelApplication({
    required String chamaId,
    required String applicationId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.loanApplicationCancel(chamaId, applicationId),
    );
    return LoanApplicationDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<LoanApplicationDto> approveApplication({
    required String chamaId,
    required String applicationId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.loanApplicationApprove(chamaId, applicationId),
      data: body,
    );
    return LoanApplicationDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<LoanApplicationDto> rejectApplication({
    required String chamaId,
    required String applicationId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.loanApplicationReject(chamaId, applicationId),
      data: body,
    );
    return LoanApplicationDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<LoanApplicationDto> disburseApplication({
    required String chamaId,
    required String applicationId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.loanApplicationDisburse(chamaId, applicationId),
    );
    return LoanApplicationDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<List<CommitteeVoteDto>> listVotes({
    required String chamaId,
    required String applicationId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.loanVotes(chamaId, applicationId),
    );
    final envelope = ApiResponse<List<dynamic>>.fromJson(
      response.data ?? {},
      (data) => data as List<dynamic>? ?? [],
    );
    if (!envelope.success || envelope.data == null) {
      throw ServerException(message: envelope.message);
    }
    return envelope.data!
        .map((e) => CommitteeVoteDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> castVote({
    required String chamaId,
    required String applicationId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.loanVotes(chamaId, applicationId),
      data: body,
    );
    return _unwrapMap(response.data);
  }

  @override
  Future<LoanRepaymentsPageDto> listRepayments({
    required String chamaId,
    required String applicationId,
    int page = 1,
    int pageSize = ApiConstants.defaultPageSize,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.loanRepayments(chamaId, applicationId),
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return LoanRepaymentsPageDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<LoanRepaymentDto> getRepayment({
    required String chamaId,
    required String applicationId,
    required String repaymentId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.loanRepaymentDetail(chamaId, applicationId, repaymentId),
    );
    return LoanRepaymentDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<Map<String, dynamic>> recordRepayment({
    required String chamaId,
    required String applicationId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.loanRepayments(chamaId, applicationId),
      data: body,
    );
    return _unwrapMap(response.data);
  }

  @override
  Future<CreditScoreDto?> getCurrentCreditScore({
    required String chamaId,
    required String memberId,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.memberCreditScoreCurrent(chamaId, memberId),
      );
      return CreditScoreDto.fromJson(_unwrapMap(response.data));
    } on AppException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _unwrapMap(Map<String, dynamic>? json) {
    final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
      json ?? {},
      (data) => Map<String, dynamic>.from(data as Map? ?? {}),
    );
    if (!envelope.success || envelope.data == null) {
      throw ServerException(message: envelope.message);
    }
    return envelope.data!;
  }
}
