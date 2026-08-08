import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../dtos/chama_dtos.dart';

/// Remote Chama and membership API client.
abstract class ChamaRemoteDataSource {
  Future<List<ChamaDto>> listChamas({String? search});

  Future<ChamaDto> getChama(String chamaId);

  Future<ChamaDto> createChama(Map<String, dynamic> body);

  Future<MembershipDto> joinChama({required String inviteCode});

  Future<MembershipDto> inviteMember({
    required String chamaId,
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> getDashboard(String chamaId);

  Future<MembersPageDto> listMembers({
    required String chamaId,
    String? search,
    String? status,
    int page = 1,
    int pageSize = ApiConstants.defaultPageSize,
  });

  Future<MembershipDto> updateMembershipStatus({
    required String membershipId,
    required String status,
  });

  Future<MembershipDto> updateMembershipRole({
    required String membershipId,
    required String role,
  });

  Future<List<MembershipDto>> listPendingInvitations();

  Future<MembershipDto> acceptInvitation(String membershipId);

  Future<MembershipDto> declineInvitation(String membershipId);
}

class ChamaApi implements ChamaRemoteDataSource {
  ChamaApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ChamaDto>> listChamas({String? search}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.chamas,
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'ordering': '-created_at',
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
        .map((item) => ChamaDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ChamaDto> getChama(String chamaId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.chamaDetail(chamaId),
    );
    return ChamaDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<ChamaDto> createChama(Map<String, dynamic> body) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chamas,
      data: body,
    );
    return ChamaDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<MembershipDto> joinChama({required String inviteCode}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chamaJoin,
      data: {'invite_code': inviteCode},
    );
    return MembershipDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<MembershipDto> inviteMember({
    required String chamaId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chamaInvite(chamaId),
      data: body,
    );
    return MembershipDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<Map<String, dynamic>> getDashboard(String chamaId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.chamaDashboard(chamaId),
    );
    return _unwrapMap(response.data);
  }

  @override
  Future<MembersPageDto> listMembers({
    required String chamaId,
    String? search,
    String? status,
    int page = 1,
    int pageSize = ApiConstants.defaultPageSize,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.chamaMembers(chamaId),
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null) 'status': status,
        'ordering': '-created_at',
      },
    );

    return MembersPageDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<MembershipDto> updateMembershipStatus({
    required String membershipId,
    required String status,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiConstants.membershipStatus(membershipId),
      data: {'status': status},
    );
    return MembershipDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<MembershipDto> updateMembershipRole({
    required String membershipId,
    required String role,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiConstants.membershipRole(membershipId),
      data: {'role': role},
    );
    return MembershipDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<List<MembershipDto>> listPendingInvitations() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.membershipsPending,
    );
    final envelope = ApiResponse<List<dynamic>>.fromJson(
      response.data ?? {},
      (data) => data as List<dynamic>? ?? [],
    );
    if (!envelope.success || envelope.data == null) {
      throw ServerException(message: envelope.message);
    }
    return envelope.data!
        .map((item) => MembershipDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MembershipDto> acceptInvitation(String membershipId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.membershipAccept(membershipId),
    );
    return MembershipDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<MembershipDto> declineInvitation(String membershipId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.membershipDecline(membershipId),
    );
    return MembershipDto.fromJson(_unwrapMap(response.data));
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
