import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../dtos/contribution_dtos.dart';

/// Remote contribution and cycle API client.
abstract class ContributionRemoteDataSource {
  Future<List<ContributionCycleDto>> listCycles({
    required String chamaId,
    String? search,
    String? status,
  });

  Future<ContributionCycleDto> getCycle({
    required String chamaId,
    required String cycleId,
  });

  Future<ContributionCycleDto> createCycle({
    required String chamaId,
    required Map<String, dynamic> body,
  });

  Future<ContributionCycleDto> closeCycle({
    required String chamaId,
    required String cycleId,
  });

  Future<ContributionsPageDto> listContributions({
    required String chamaId,
    String? search,
    String? cycleId,
    String? memberId,
    int page = 1,
    int pageSize = ApiConstants.defaultPageSize,
  });

  Future<ContributionDto> getContribution({
    required String chamaId,
    required String contributionId,
  });

  Future<ContributionDto> recordContribution({
    required String chamaId,
    required Map<String, dynamic> body,
  });

  Future<ContributionSummaryDto> getContributionSummary({
    required String chamaId,
    String? cycleId,
  });

  Future<MemberContributionSummaryDto> getMemberSummary({
    required String chamaId,
    required String memberId,
  });
}

class ContributionApi implements ContributionRemoteDataSource {
  ContributionApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ContributionCycleDto>> listCycles({
    required String chamaId,
    String? search,
    String? status,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.contributionCycles(chamaId),
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null) 'status': status,
        'ordering': '-start_date',
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
        .map((e) => ContributionCycleDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ContributionCycleDto> getCycle({
    required String chamaId,
    required String cycleId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.contributionCycleDetail(chamaId, cycleId),
    );
    return ContributionCycleDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<ContributionCycleDto> createCycle({
    required String chamaId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.contributionCycles(chamaId),
      data: body,
    );
    return ContributionCycleDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<ContributionCycleDto> closeCycle({
    required String chamaId,
    required String cycleId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.contributionCycleClose(chamaId, cycleId),
    );
    return ContributionCycleDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<ContributionsPageDto> listContributions({
    required String chamaId,
    String? search,
    String? cycleId,
    String? memberId,
    int page = 1,
    int pageSize = ApiConstants.defaultPageSize,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.contributions(chamaId),
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        'ordering': '-recorded_at',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (cycleId != null) 'cycle_id': cycleId,
        if (memberId != null) 'member_id': memberId,
      },
    );
    return ContributionsPageDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<ContributionDto> getContribution({
    required String chamaId,
    required String contributionId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.contributionDetail(chamaId, contributionId),
    );
    return ContributionDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<ContributionDto> recordContribution({
    required String chamaId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.contributions(chamaId),
      data: body,
    );
    return ContributionDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<ContributionSummaryDto> getContributionSummary({
    required String chamaId,
    String? cycleId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.contributionsReport(chamaId),
      queryParameters: {
        if (cycleId != null) 'cycle_id': cycleId,
      },
    );
    return ContributionSummaryDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<MemberContributionSummaryDto> getMemberSummary({
    required String chamaId,
    required String memberId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.memberFinancialReport(chamaId, memberId),
    );
    return MemberContributionSummaryDto.fromJson(_unwrapMap(response.data));
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
