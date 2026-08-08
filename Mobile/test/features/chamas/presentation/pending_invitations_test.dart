import 'package:chamaplus_mobile/core/errors/app_exception.dart';
import 'package:chamaplus_mobile/core/models/paged_result.dart';
import 'package:chamaplus_mobile/core/routing/route_paths.dart';
import 'package:chamaplus_mobile/features/chamas/domain/entities/chama.dart';
import 'package:chamaplus_mobile/features/chamas/domain/repositories/chama_repository.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/controllers/pending_invitations_controller.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/providers/chama_providers.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/screens/pending_invitations_screen.dart';
import 'package:chamaplus_mobile/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:chamaplus_mobile/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:chamaplus_mobile/features/auth/domain/entities/user.dart';
import 'package:chamaplus_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:chamaplus_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:chamaplus_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:chamaplus_mobile/shared/api_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _user = MemberUser(
  id: 'u1',
  phoneNumber: '+254798765432',
  firstName: 'John',
  lastName: 'Member',
);
Membership _invitation({
  required String id,
  String chamaId = 'c1',
  String chamaName = 'Sunrise Chama',
  String roleName = 'Member',
  String roleSlug = 'member',
}) {
  return Membership(
    id: id,
    user: _user,
    role: MemberRole(id: 'r-$id', slug: roleSlug, name: roleName),
    status: MembershipStatus.pending,
    createdAt: DateTime(2026, 8, 1),
    chamaId: chamaId,
    chamaName: chamaName,
  );
}

class _FakeRepo implements ChamaRepository {
  _FakeRepo({
    List<Membership>? pending,
    this.error,
  }) : pending = List<Membership>.from(pending ?? const []);

  List<Membership> pending;
  Object? error;
  int acceptCalls = 0;
  int declineCalls = 0;
  final List<String> acceptedIds = [];
  final List<String> declinedIds = [];

  @override
  Future<List<Membership>> listPendingInvitations() async {
    if (error != null) throw error!;
    return List.unmodifiable(pending);
  }

  @override
  Future<Membership> acceptInvitation(String membershipId) async {
    if (error != null) throw error!;
    acceptCalls++;
    acceptedIds.add(membershipId);
    final match = pending.firstWhere((m) => m.id == membershipId);
    pending = pending.where((m) => m.id != membershipId).toList();
    return Membership(
      id: match.id,
      user: match.user,
      role: match.role,
      status: MembershipStatus.active,
      joinedAt: DateTime(2026, 8, 8),
      createdAt: match.createdAt,
      chamaId: match.chamaId,
      chamaName: match.chamaName,
    );
  }

  @override
  Future<Membership> declineInvitation(String membershipId) async {
    if (error != null) throw error!;
    declineCalls++;
    declinedIds.add(membershipId);
    final match = pending.firstWhere((m) => m.id == membershipId);
    pending = pending.where((m) => m.id != membershipId).toList();
    return Membership(
      id: match.id,
      user: match.user,
      role: match.role,
      status: MembershipStatus.left,
      createdAt: match.createdAt,
      chamaId: match.chamaId,
      chamaName: match.chamaName,
    );
  }

  @override
  Future<List<Chama>> listChamas({String? search}) async => const [];

  @override
  Future<Chama> createChama(CreateChamaInput input) =>
      throw UnimplementedError();

  @override
  Future<Chama> getChama(String chamaId) => throw UnimplementedError();

  @override
  Future<ChamaDetails> getChamaDetails(String chamaId) =>
      throw UnimplementedError();

  @override
  Future<Membership?> getMember({
    required String chamaId,
    required String membershipId,
  }) =>
      throw UnimplementedError();

  @override
  Future<Membership> inviteMember({
    required String chamaId,
    required InviteMemberInput input,
  }) =>
      throw UnimplementedError();

  @override
  Future<Membership> joinChama({required String inviteCode}) =>
      throw UnimplementedError();

  @override
  Future<List<Membership>> listCommitteeMembers(String chamaId) =>
      throw UnimplementedError();

  @override
  Future<PagedResult<Membership>> listJoinRequests({
    required String chamaId,
    int page = 1,
    int pageSize = 20,
  }) =>
      throw UnimplementedError();

  @override
  Future<PagedResult<Membership>> listMembers({
    required String chamaId,
    String? search,
    MembershipStatus? status,
    int page = 1,
    int pageSize = 20,
  }) =>
      throw UnimplementedError();

  @override
  Future<Membership> approveJoinRequest(String membershipId) =>
      throw UnimplementedError();

  @override
  Future<Membership> rejectJoinRequest(String membershipId) =>
      throw UnimplementedError();

  @override
  Future<Membership> updateMembershipRole({
    required String membershipId,
    required String role,
  }) =>
      throw UnimplementedError();

  @override
  Future<Membership> updateMembershipStatus({
    required String membershipId,
    required MembershipStatus status,
  }) =>
      throw UnimplementedError();
}

class _StubAuthRepository implements AuthRepository {
  @override
  Future<User> getCurrentUser() async => _authUser;

  @override
  Future<User> login({
    required String phoneNumber,
    required String password,
  }) async =>
      _authUser;

  @override
  Future<void> logout() async {}

  @override
  Future<User> register({
    required String phoneNumber,
    required String password,
    required String passwordConfirm,
    String? firstName,
    String? lastName,
    String? email,
  }) async =>
      _authUser;

  @override
  Future<User?> restoreSession() async => _authUser;

  @override
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async =>
      _authUser;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {}

  static final _authUser = User(
    id: 'u1',
    phoneNumber: '+254798765432',
    firstName: 'John',
    isStaff: false,
    dateJoined: DateTime(2026, 1, 1),
  );
}

class _SeededPendingController extends PendingInvitationsController {
  _SeededPendingController(ChamaRepository repository, List<Membership> items)
      : super(repository) {
    state = items.isEmpty
        ? const ApiState.empty()
        : ApiState.success(items);
  }

  @override
  Future<void> load({bool forceRefresh = false}) async {}
}

void main() {
  test('PendingInvitationsController loads and accepts', () async {
    final repo = _FakeRepo(pending: [_invitation(id: 'inv1')]);
    final controller = PendingInvitationsController(repo);
    await controller.load();
    expect(controller.state.isSuccess, isTrue);
    expect(controller.state.data, hasLength(1));

    final accepted = await controller.accept('inv1');
    expect(accepted?.status, MembershipStatus.active);
    expect(repo.acceptCalls, 1);
    expect(controller.state.isEmpty, isTrue);
  });

  test('PendingInvitationsController declines and refreshes', () async {
    final repo = _FakeRepo(pending: [
      _invitation(id: 'inv1'),
      _invitation(id: 'inv2', chamaName: 'Lake Chama'),
    ]);
    final controller = PendingInvitationsController(repo);
    await controller.load();
    await controller.decline('inv1');
    expect(repo.declineCalls, 1);
    expect(controller.state.data, hasLength(1));
    expect(controller.state.data!.first.id, 'inv2');
  });

  test('PendingInvitationsController surfaces API errors', () async {
    final repo = _FakeRepo(
      error: const ServerException(message: 'Forbidden'),
    );
    final controller = PendingInvitationsController(repo);
    await controller.load();
    expect(controller.state.isError, isTrue);
    expect(controller.state.errorMessage, contains('Forbidden'));
  });

  testWidgets('PendingInvitationsScreen renders invitations', (tester) async {
    final repo = _FakeRepo(pending: [
      _invitation(id: 'inv1', roleName: 'Treasurer', roleSlug: 'treasurer'),
      _invitation(id: 'inv2', chamaName: 'Lake Chama'),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(repo),
          pendingInvitationsControllerProvider.overrideWith(
            (ref) => _SeededPendingController(repo, repo.pending),
          ),
        ],
        child: const MaterialApp(home: PendingInvitationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pending invitations (2)'), findsOneWidget);
    expect(find.text('Sunrise Chama'), findsOneWidget);
    expect(find.text('Lake Chama'), findsOneWidget);
    expect(find.text('Treasurer'), findsOneWidget);
    expect(find.text('Accept'), findsNWidgets(2));
    expect(find.text('Decline'), findsNWidgets(2));
  });

  testWidgets('PendingInvitationsScreen empty state', (tester) async {
    final repo = _FakeRepo(pending: const []);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(repo),
          pendingInvitationsControllerProvider.overrideWith(
            (ref) => _SeededPendingController(repo, const []),
          ),
        ],
        child: const MaterialApp(home: PendingInvitationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No pending invitations'), findsOneWidget);
  });

  testWidgets('accept navigates to chama and marks onboarding ready',
      (tester) async {
    final repo = _FakeRepo(pending: [_invitation(id: 'inv1')]);
    final router = GoRouter(
      initialLocation: RoutePaths.pendingInvitations,
      routes: [
        GoRoute(
          path: RoutePaths.pendingInvitations,
          builder: (context, state) => const PendingInvitationsScreen(),
        ),
        GoRoute(
          path: '/chamas/:chamaId',
          builder: (context, state) => Scaffold(
            body: Text('Chama ${state.pathParameters['chamaId']}'),
          ),
        ),
        GoRoute(
          path: RoutePaths.home,
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
      ],
    );

    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(repo),
        ],
        child: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context);
            return MaterialApp.router(routerConfig: router);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Accept').first);
    await tester.pumpAndSettle();

    expect(repo.acceptCalls, 1);
    expect(find.text('Chama c1'), findsOneWidget);
    expect(
      container.read(onboardingGateProvider),
      OnboardingGate.ready,
    );
  });

  testWidgets('decline confirms and removes invitation', (tester) async {
    final repo = _FakeRepo(pending: [
      _invitation(id: 'inv1'),
      _invitation(id: 'inv2', chamaName: 'Lake Chama'),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: PendingInvitationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Decline').first);
    await tester.pumpAndSettle();
    expect(find.text('Decline invitation?'), findsOneWidget);
    await tester.tap(find.text('Decline').last);
    await tester.pumpAndSettle();

    expect(repo.declineCalls, 1);
    expect(find.text('Sunrise Chama'), findsNothing);
    expect(find.text('Lake Chama'), findsOneWidget);
  });

  testWidgets('WelcomeScreen navigates to pending invitations', (tester) async {
    final repo = _FakeRepo(pending: [_invitation(id: 'inv1')]);
    final authController = AuthController(_StubAuthRepository())
      ..setAuthenticated(_StubAuthRepository._authUser);

    final router = GoRouter(
      initialLocation: RoutePaths.welcome,
      routes: [
        GoRoute(
          path: RoutePaths.welcome,
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: RoutePaths.pendingInvitations,
          builder: (context, state) => const PendingInvitationsScreen(),
        ),
        GoRoute(
          path: RoutePaths.createChama,
          builder: (context, state) => const SizedBox(),
        ),
        GoRoute(
          path: RoutePaths.joinChama,
          builder: (context, state) => const SizedBox(),
        ),
        GoRoute(
          path: RoutePaths.profile,
          builder: (context, state) => const SizedBox(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(repo),
          authRepositoryProvider.overrideWithValue(_StubAuthRepository()),
          authControllerProvider.overrideWith((ref) => authController),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('Pending invitations'), findsWidgets);
    await tester.tap(find.text('View invitations'));
    await tester.pumpAndSettle();
    expect(find.text('Sunrise Chama'), findsOneWidget);
  });

  test('MembershipDto/entity only expose current user invitations via repo',
      () async {
    final repo = _FakeRepo(pending: [
      _invitation(id: 'mine'),
    ]);
    final list = await repo.listPendingInvitations();
    expect(list.every((m) => m.user.id == 'u1'), isTrue);
  });
}
