import '../../domain/entities/chama.dart';
import '../../domain/repositories/chama_repository.dart';
import '../datasources/chama_api.dart';

/// Maps Chama APIs into domain models.
class ChamaRepositoryImpl implements ChamaRepository {
  ChamaRepositoryImpl(this._api);

  final ChamaRemoteDataSource _api;

  static const _committeeSlugs = {
    'chairperson',
    'treasurer',
    'secretary',
    'committee_member',
  };

  @override
  Future<List<Chama>> listChamas({String? search}) async {
    final dtos = await _api.listChamas(search: search);
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<Chama> getChama(String chamaId) async {
    final dto = await _api.getChama(chamaId);
    return dto.toEntity();
  }

  @override
  Future<Chama> createChama(CreateChamaInput input) async {
    final dto = await _api.createChama({
      'name': input.name,
      if (input.description != null && input.description!.trim().isNotEmpty)
        'description': input.description!.trim(),
      if (input.location != null && input.location!.trim().isNotEmpty)
        'location': input.location!.trim(),
      'currency': input.currency,
    });
    return dto.toEntity();
  }

  @override
  Future<Membership> joinChama({required String inviteCode}) async {
    final dto = await _api.joinChama(inviteCode: inviteCode.trim().toUpperCase());
    return dto.toEntity();
  }

  @override
  Future<Membership> inviteMember({
    required String chamaId,
    required InviteMemberInput input,
  }) async {
    final dto = await _api.inviteMember(
      chamaId: chamaId,
      body: {
        'phone_number': input.phoneNumber,
        'role': input.role,
      },
    );
    return dto.toEntity();
  }

  @override
  Future<ChamaDetails> getChamaDetails(String chamaId) async {
    final chama = await getChama(chamaId);
    final dashboard = await _api.getDashboard(chamaId);
    final activeMembers = await _api.listMembers(
      chamaId: chamaId,
      status: MembershipStatus.active.apiValue,
      pageSize: 100,
    );
    final pending = await _api.listMembers(
      chamaId: chamaId,
      status: MembershipStatus.pending.apiValue,
      pageSize: 1,
    );

    final committee = activeMembers.results
        .map((m) => m.toEntity())
        .where((m) => _committeeSlugs.contains(m.role.slug))
        .toList();

    UpcomingMeeting? upcoming;
    final next = dashboard['next_meeting'] as Map<String, dynamic>?;
    if (next != null) {
      upcoming = UpcomingMeeting(
        id: next['id'] as String,
        title: next['title'] as String,
        meetingDate: DateTime.parse(next['meeting_date'] as String),
        startTime: next['start_time'] as String?,
      );
    }

    return ChamaDetails(
      chama: chama,
      memberCount: dashboard['member_count'] as int? ?? activeMembers.count,
      pendingJoinRequests: pending.count,
      committeeMembers: committee,
      upcomingMeeting: upcoming,
      activeCycleName: dashboard['active_cycle'] as String?,
      contributionsThisCycle:
          dashboard['contributions_this_cycle']?.toString(),
      outstandingLoans: dashboard['outstanding_loans']?.toString(),
    );
  }

  @override
  Future<PagedResult<Membership>> listMembers({
    required String chamaId,
    String? search,
    MembershipStatus? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final dto = await _api.listMembers(
      chamaId: chamaId,
      search: search,
      status: status?.apiValue,
      page: page,
      pageSize: pageSize,
    );

    return PagedResult(
      items: dto.results.map((m) => m.toEntity()).toList(),
      count: dto.count,
      nextPage: dto.next != null ? page + 1 : null,
      hasMore: dto.next != null,
    );
  }

  @override
  Future<Membership?> getMember({
    required String chamaId,
    required String membershipId,
  }) async {
    var page = 1;
    while (true) {
      final result = await listMembers(
        chamaId: chamaId,
        page: page,
        pageSize: 50,
      );
      for (final member in result.items) {
        if (member.id == membershipId) return member;
      }
      if (!result.hasMore || result.nextPage == null) break;
      page = result.nextPage!;
    }
    return null;
  }

  @override
  Future<List<Membership>> listCommitteeMembers(String chamaId) async {
    final result = await listMembers(
      chamaId: chamaId,
      status: MembershipStatus.active,
      pageSize: 100,
    );
    return result.items
        .where((m) => _committeeSlugs.contains(m.role.slug))
        .toList();
  }

  @override
  Future<PagedResult<Membership>> listJoinRequests({
    required String chamaId,
    int page = 1,
    int pageSize = 20,
  }) {
    return listMembers(
      chamaId: chamaId,
      status: MembershipStatus.pending,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<Membership> approveJoinRequest(String membershipId) async {
    final dto = await _api.updateMembershipStatus(
      membershipId: membershipId,
      status: MembershipStatus.active.apiValue,
    );
    return dto.toEntity();
  }

  @override
  Future<Membership> rejectJoinRequest(String membershipId) async {
    final dto = await _api.updateMembershipStatus(
      membershipId: membershipId,
      status: MembershipStatus.left.apiValue,
    );
    return dto.toEntity();
  }

  @override
  Future<Membership> updateMembershipRole({
    required String membershipId,
    required String role,
  }) async {
    final dto = await _api.updateMembershipRole(
      membershipId: membershipId,
      role: role,
    );
    return dto.toEntity();
  }

  @override
  Future<Membership> updateMembershipStatus({
    required String membershipId,
    required MembershipStatus status,
  }) async {
    final dto = await _api.updateMembershipStatus(
      membershipId: membershipId,
      status: status.apiValue,
    );
    return dto.toEntity();
  }

  @override
  Future<List<Membership>> listPendingInvitations() async {
    final dtos = await _api.listPendingInvitations();
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<Membership> acceptInvitation(String membershipId) async {
    final dto = await _api.acceptInvitation(membershipId);
    return dto.toEntity();
  }

  @override
  Future<Membership> declineInvitation(String membershipId) async {
    final dto = await _api.declineInvitation(membershipId);
    return dto.toEntity();
  }
}
