import 'package:chamaplus_mobile/core/errors/app_exception.dart';
import 'package:chamaplus_mobile/core/models/paged_result.dart';
import 'package:chamaplus_mobile/core/routing/route_paths.dart';
import 'package:chamaplus_mobile/features/chamas/domain/entities/chama.dart';
import 'package:chamaplus_mobile/features/chamas/domain/repositories/chama_repository.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/controllers/chama_details_controller.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/controllers/join_requests_controller.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/controllers/manage_membership_controller.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/providers/chama_providers.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/screens/chama_details_screen.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/screens/join_requests_screen.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/screens/member_details_screen.dart';
import 'package:chamaplus_mobile/shared/api_state.dart';
import 'package:chamaplus_mobile/shared/components/components.dart';
import 'package:chamaplus_mobile/shared/navigation/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _member = Membership(
  id: 'm1',
  user: MemberUser(
    id: 'u1',
    phoneNumber: '+254712345678',
    firstName: 'Jane',
    lastName: 'Doe',
  ),
  role: MemberRole(id: 'r1', slug: 'member', name: 'Member'),
  status: MembershipStatus.active,
);

const _pending = Membership(
  id: 'm2',
  user: MemberUser(
    id: 'u2',
    phoneNumber: '+254700000001',
    firstName: 'Pending',
    lastName: 'User',
  ),
  role: MemberRole(id: 'r2', slug: 'member', name: 'Member'),
  status: MembershipStatus.pending,
);

class _FakeRepo implements ChamaRepository {
  _FakeRepo({this.member = _member, this.error});

  Membership member;
  Object? error;
  int roleCalls = 0;
  String? lastRole;

  @override
  Future<Membership> approveJoinRequest(String membershipId) {
    throw UnimplementedError();
  }

  @override
  Future<Chama> createChama(CreateChamaInput input) {
    throw UnimplementedError();
  }

  @override
  Future<Chama> getChama(String chamaId) {
    throw UnimplementedError();
  }

  @override
  Future<ChamaDetails> getChamaDetails(String chamaId) async {
    return const ChamaDetails(
      chama: Chama(
        id: 'c1',
        name: 'Unity Chama',
        currency: 'KES',
        isActive: true,
      ),
      memberCount: 2,
      pendingJoinRequests: 1,
      committeeMembers: [_member],
    );
  }

  @override
  Future<Membership?> getMember({
    required String chamaId,
    required String membershipId,
  }) async =>
      member;

  @override
  Future<Membership> inviteMember({
    required String chamaId,
    required InviteMemberInput input,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Membership> joinChama({required String inviteCode}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Chama>> listChamas({String? search}) async => const [];

  @override
  Future<List<Membership>> listCommitteeMembers(String chamaId) async =>
      const [_member];

  @override
  Future<PagedResult<Membership>> listJoinRequests({
    required String chamaId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return const PagedResult(items: [_pending], count: 1);
  }

  @override
  Future<PagedResult<Membership>> listMembers({
    required String chamaId,
    String? search,
    MembershipStatus? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    return PagedResult(items: [member], count: 1);
  }

  @override
  Future<Membership> rejectJoinRequest(String membershipId) {
    throw UnimplementedError();
  }

  @override
  Future<Membership> updateMembershipRole({
    required String membershipId,
    required String role,
  }) async {
    roleCalls++;
    lastRole = role;
    if (error != null) throw error!;
    member = Membership(
      id: membershipId,
      user: member.user,
      role: MemberRole(id: 'r-new', slug: role, name: role),
      status: member.status,
      joinedAt: member.joinedAt,
    );
    return member;
  }

  @override
  Future<Membership> updateMembershipStatus({
    required String membershipId,
    required MembershipStatus status,
  }) async {
    if (error != null) throw error!;
    member = Membership(
      id: membershipId,
      user: member.user,
      role: member.role,
      status: status,
      joinedAt: member.joinedAt,
    );
    return member;
  }

  @override
  Future<List<Membership>> listPendingInvitations() async => const [];

  @override
  Future<Membership> acceptInvitation(String membershipId) =>
      throw UnimplementedError();

  @override
  Future<Membership> declineInvitation(String membershipId) =>
      throw UnimplementedError();
}

class _SeededDetailsController extends ChamaDetailsController {
  _SeededDetailsController(ChamaRepository repo)
      : super(repository: repo, chamaId: 'c1') {
    state = const ApiState.success(
      ChamaDetails(
        chama: Chama(
          id: 'c1',
          name: 'Unity Chama',
          currency: 'KES',
          isActive: true,
        ),
        memberCount: 2,
        pendingJoinRequests: 1,
        committeeMembers: [_member],
      ),
    );
  }

  @override
  Future<void> load({bool forceRefresh = false}) async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<void> retry() async {}
}

class _SeededJoinRequestsController extends JoinRequestsController {
  _SeededJoinRequestsController(ChamaRepository repo)
      : super(repository: repo, chamaId: 'c1') {
    state = const ApiState.success([_pending]);
  }

  @override
  Future<void> load({bool forceRefresh = false}) async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<void> retry() async {}
}

void main() {
  test('AppMemberRole membership permissions', () {
    expect(AppMemberRole.chairperson.canInviteMembers, isTrue);
    expect(AppMemberRole.chairperson.canManageMemberships, isTrue);
    expect(AppMemberRole.secretary.canInviteMembers, isTrue);
    expect(AppMemberRole.secretary.canManageMemberships, isFalse);
    expect(AppMemberRole.treasurer.canInviteMembers, isFalse);
    expect(AppMemberRole.member.canInviteMembers, isFalse);
    expect(AppMemberRole.member.canManageMemberships, isFalse);
  });

  test('RoleNavigationService invite/join-request actions by role', () {
    final chair = RoleNavigationService.quickActionsFor(
      roleLabel: 'chairperson',
      chamaId: 'c1',
    );
    expect(chair.any((a) => a.id == 'invite_members'), isTrue);
    expect(chair.any((a) => a.id == 'join_requests'), isTrue);

    final secretary = RoleNavigationService.quickActionsFor(
      roleLabel: 'secretary',
      chamaId: 'c1',
    );
    expect(secretary.any((a) => a.id == 'invite_members'), isTrue);
    expect(secretary.any((a) => a.id == 'join_requests'), isFalse);

    final member = RoleNavigationService.quickActionsFor(
      roleLabel: 'member',
      chamaId: 'c1',
    );
    expect(member.any((a) => a.id == 'invite_members'), isFalse);
    expect(member.any((a) => a.id == 'join_requests'), isFalse);
    expect(
      member.any((a) => a.route == RoutePaths.chamaInviteMembers('c1')),
      isFalse,
    );
  });

  test('ManageMembershipController updates role and surfaces errors', () async {
    final repo = _FakeRepo();
    final controller = ManageMembershipController(repo);

    final updated = await controller.updateRole(
      membershipId: 'm1',
      role: 'treasurer',
    );
    expect(updated?.role.slug, 'treasurer');
    expect(repo.roleCalls, 1);
    expect(repo.lastRole, 'treasurer');

    final failing = ManageMembershipController(
      _FakeRepo(error: const ServerException(message: 'Forbidden')),
    );
    final failed = await failing.updateRole(
      membershipId: 'm1',
      role: 'secretary',
    );
    expect(failed, isNull);
    expect(failing.state.errorMessage, contains('Forbidden'));
  });

  testWidgets('chairperson sees Change role on member details', (tester) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(repo),
          currentMemberRoleProvider.overrideWithValue(AppMemberRole.chairperson),
          memberDetailsProvider.overrideWith(
            (ref, args) async => repo.member,
          ),
        ],
        child: const MaterialApp(
          home: MemberDetailsScreen(chamaId: 'c1', membershipId: 'm1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Change role'), findsOneWidget);
    expect(find.text('Suspend member'), findsOneWidget);
  });

  testWidgets('non-chairperson does not see Manage Role', (tester) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(repo),
          currentMemberRoleProvider.overrideWithValue(AppMemberRole.member),
          memberDetailsProvider.overrideWith(
            (ref, args) async => repo.member,
          ),
        ],
        child: const MaterialApp(
          home: MemberDetailsScreen(chamaId: 'c1', membershipId: 'm1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Change role'), findsNothing);
    expect(find.text('Management'), findsNothing);
  });

  testWidgets('role selection dialog updates membership', (tester) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(repo),
          currentMemberRoleProvider.overrideWithValue(AppMemberRole.chairperson),
          memberDetailsProvider.overrideWith(
            (ref, args) async => repo.member,
          ),
        ],
        child: const MaterialApp(
          home: MemberDetailsScreen(chamaId: 'c1', membershipId: 'm1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Change role'));
    await tester.tap(find.text('Change role'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Changing Jane Doe'),
      findsOneWidget,
    );

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Treasurer').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(repo.roleCalls, 1);
    expect(repo.lastRole, 'treasurer');
  });

  testWidgets('invite visible to chairperson', (tester) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(repo),
          currentMemberRoleProvider.overrideWithValue(AppMemberRole.chairperson),
          chamaDetailsControllerProvider.overrideWith(
            (ref, chamaId) => _SeededDetailsController(repo),
          ),
        ],
        child: const MaterialApp(home: ChamaDetailsScreen(chamaId: 'c1')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(ActionButton, 'Invite members'));
    expect(find.widgetWithText(ActionButton, 'Invite members'), findsOneWidget);
    expect(find.widgetWithText(ActionButton, 'Join requests'), findsOneWidget);
  });

  testWidgets('invite visible to secretary without join-request management',
      (tester) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(repo),
          currentMemberRoleProvider.overrideWithValue(AppMemberRole.secretary),
          chamaDetailsControllerProvider.overrideWith(
            (ref, chamaId) => _SeededDetailsController(repo),
          ),
        ],
        child: const MaterialApp(home: ChamaDetailsScreen(chamaId: 'c1')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(ActionButton, 'Invite members'));
    expect(find.widgetWithText(ActionButton, 'Invite members'), findsOneWidget);
    expect(find.widgetWithText(ActionButton, 'Join requests'), findsNothing);
  });

  testWidgets('invite and join-request actions hidden for ordinary member',
      (tester) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(repo),
          currentMemberRoleProvider.overrideWithValue(AppMemberRole.member),
          chamaDetailsControllerProvider.overrideWith(
            (ref, chamaId) => _SeededDetailsController(repo),
          ),
        ],
        child: const MaterialApp(home: ChamaDetailsScreen(chamaId: 'c1')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ActionButton, 'Invite members'), findsNothing);
    expect(find.widgetWithText(ActionButton, 'Join requests'), findsNothing);
  });

  testWidgets('join-request actions shown for chairperson', (tester) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(repo),
          currentMemberRoleProvider.overrideWithValue(AppMemberRole.chairperson),
          joinRequestsControllerProvider.overrideWith(
            (ref, chamaId) => _SeededJoinRequestsController(repo),
          ),
        ],
        child: const MaterialApp(home: JoinRequestsScreen(chamaId: 'c1')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
  });

  testWidgets('join-request actions hidden for ordinary member', (tester) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(repo),
          currentMemberRoleProvider.overrideWithValue(AppMemberRole.member),
          joinRequestsControllerProvider.overrideWith(
            (ref, chamaId) => _SeededJoinRequestsController(repo),
          ),
        ],
        child: const MaterialApp(home: JoinRequestsScreen(chamaId: 'c1')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Approve'), findsNothing);
    expect(find.text('Reject'), findsNothing);
    expect(find.text('Waiting for chairperson approval.'), findsOneWidget);
  });
}
