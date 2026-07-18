import 'package:chamaplus_mobile/features/chamas/data/datasources/chama_api.dart';
import 'package:chamaplus_mobile/features/chamas/data/dtos/chama_dtos.dart';
import 'package:chamaplus_mobile/features/chamas/data/repositories/chama_repository_impl.dart';
import 'package:chamaplus_mobile/features/chamas/domain/entities/chama.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeChamaApi implements ChamaRemoteDataSource {
  List<ChamaDto> chamas = const [];
  ChamaDto? chama;
  Map<String, dynamic> dashboard = {};
  MembersPageDto activeMembers = const MembersPageDto(count: 0, results: []);
  MembersPageDto pendingMembers = const MembersPageDto(count: 0, results: []);
  MembershipDto? updatedMembership;
  Object? error;

  @override
  Future<List<ChamaDto>> listChamas({String? search}) async {
    if (error != null) throw error!;
    if (search == null || search.isEmpty) return chamas;
    return chamas
        .where((c) => c.name.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  @override
  Future<ChamaDto> getChama(String chamaId) async {
    return chama!;
  }

  @override
  Future<ChamaDto> createChama(Map<String, dynamic> body) async {
    return chama!;
  }

  @override
  Future<MembershipDto> joinChama({required String inviteCode}) async {
    return updatedMembership!;
  }

  @override
  Future<MembershipDto> inviteMember({
    required String chamaId,
    required Map<String, dynamic> body,
  }) async {
    return updatedMembership!;
  }

  @override
  Future<Map<String, dynamic>> getDashboard(String chamaId) async {
    return dashboard;
  }

  @override
  Future<MembersPageDto> listMembers({
    required String chamaId,
    String? search,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (status == 'pending') return pendingMembers;
    return activeMembers;
  }

  @override
  Future<MembershipDto> updateMembershipStatus({
    required String membershipId,
    required String status,
  }) async {
    return updatedMembership!;
  }
}

MembershipDto sampleMembership({
  String id = 'm1',
  String status = 'active',
  String roleSlug = 'member',
  String roleName = 'Member',
}) {
  return MembershipDto(
    id: id,
    user: const MemberUserDto(
      id: 'u1',
      phoneNumber: '+254712345678',
      firstName: 'Jane',
      lastName: 'Doe',
    ),
    role: MemberRoleDto(id: 'r1', slug: roleSlug, name: roleName),
    status: status,
    joinedAt: '2026-01-15T10:00:00+03:00',
  );
}

void main() {
  late FakeChamaApi api;
  late ChamaRepositoryImpl repository;

  setUp(() {
    api = FakeChamaApi();
    repository = ChamaRepositoryImpl(api);
    api.chamas = [
      const ChamaDto(
        id: 'c1',
        name: 'Unity Chama',
        location: 'Nairobi',
        currency: 'KES',
        inviteCode: 'ABCD1234',
        isActive: true,
      ),
    ];
    api.chama = api.chamas.first;
    api.dashboard = {
      'member_count': 2,
      'active_cycle': 'July',
      'contributions_this_cycle': '10000.00',
      'outstanding_loans': '2000.00',
      'next_meeting': {
        'id': 'meet-1',
        'title': 'Monthly AGM',
        'meeting_date': '2026-07-20',
        'start_time': '18:00:00',
      },
    };
    api.activeMembers = MembersPageDto(
      count: 2,
      results: [
        sampleMembership(id: 'm1', roleSlug: 'chairperson', roleName: 'Chairperson'),
        sampleMembership(id: 'm2'),
      ],
    );
    api.pendingMembers = MembersPageDto(
      count: 1,
      results: [sampleMembership(id: 'm3', status: 'pending')],
    );
  });

  test('listChamas maps entities', () async {
    final list = await repository.listChamas();
    expect(list, hasLength(1));
    expect(list.first.name, 'Unity Chama');
  });

  test('getChamaDetails aggregates dashboard and committee', () async {
    final details = await repository.getChamaDetails('c1');
    expect(details.memberCount, 2);
    expect(details.pendingJoinRequests, 1);
    expect(details.committeeMembers, hasLength(1));
    expect(details.upcomingMeeting?.title, 'Monthly AGM');
  });

  test('approveJoinRequest updates status', () async {
    api.updatedMembership = sampleMembership(id: 'm3', status: 'active');
    final result = await repository.approveJoinRequest('m3');
    expect(result.status, MembershipStatus.active);
  });

  test('rejectJoinRequest marks left', () async {
    api.updatedMembership = sampleMembership(id: 'm3', status: 'left');
    final result = await repository.rejectJoinRequest('m3');
    expect(result.status, MembershipStatus.left);
  });
}
