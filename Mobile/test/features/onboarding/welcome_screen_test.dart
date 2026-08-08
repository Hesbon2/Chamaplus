import 'package:chamaplus_mobile/features/auth/domain/entities/user.dart';
import 'package:chamaplus_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:chamaplus_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:chamaplus_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:chamaplus_mobile/features/chamas/domain/entities/chama.dart';
import 'package:chamaplus_mobile/features/chamas/domain/repositories/chama_repository.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/providers/chama_providers.dart';
import 'package:chamaplus_mobile/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:chamaplus_mobile/core/models/paged_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _EmptyChamaRepo implements ChamaRepository {
  @override
  Future<Membership> approveJoinRequest(String membershipId) =>
      throw UnimplementedError();

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
  Future<List<Chama>> listChamas({String? search}) async => [];

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

  @override
  Future<List<Membership>> listPendingInvitations() async => const [];

  @override
  Future<Membership> acceptInvitation(String membershipId) =>
      throw UnimplementedError();

  @override
  Future<Membership> declineInvitation(String membershipId) =>
      throw UnimplementedError();
}

class _StubAuthRepository implements AuthRepository {
  @override
  Future<User> getCurrentUser() async => _user;

  @override
  Future<User> login({
    required String phoneNumber,
    required String password,
  }) async =>
      _user;

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
      _user;

  @override
  Future<User?> restoreSession() async => _user;

  @override
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async =>
      _user;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {}

  static final _user = User(
    id: 'u1',
    phoneNumber: '+254700000000',
    firstName: 'Ada',
    isStaff: false,
    dateJoined: DateTime(2026, 1, 1),
  );
}

void main() {
  testWidgets('WelcomeScreen shows create and join actions', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/create-chama',
          builder: (context, state) => const SizedBox(),
        ),
        GoRoute(
          path: '/join-chama',
          builder: (context, state) => const SizedBox(),
        ),
        GoRoute(
          path: '/pending-approval',
          builder: (context, state) => const SizedBox(),
        ),
        GoRoute(
          path: '/pending-invitations',
          builder: (context, state) => const Scaffold(
            body: Text('Pending invitations screen'),
          ),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const SizedBox(),
        ),
      ],
    );

    final authController = AuthController(_StubAuthRepository())
      ..setAuthenticated(_StubAuthRepository._user);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chamaRepositoryProvider.overrideWithValue(_EmptyChamaRepo()),
          authRepositoryProvider.overrideWithValue(_StubAuthRepository()),
          authControllerProvider.overrideWith((ref) => authController),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Welcome, Ada'), findsOneWidget);
    expect(find.text('Create a Chama'), findsOneWidget);
    expect(find.text('Join a Chama'), findsOneWidget);
    expect(find.text('View pending invitations'), findsOneWidget);

    await tester.tap(find.text('View pending invitations'));
    await tester.pumpAndSettle();
    expect(find.text('Pending invitations screen'), findsOneWidget);
  });
}
