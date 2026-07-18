import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/chamas/presentation/screens/chama_details_screen.dart';
import '../../features/chamas/presentation/screens/create_chama_screen.dart';
import '../../features/chamas/presentation/screens/invite_members_screen.dart';
import '../../features/chamas/presentation/screens/join_chama_screen.dart';
import '../../features/chamas/presentation/screens/join_requests_screen.dart';
import '../../features/chamas/presentation/screens/member_details_screen.dart';
import '../../features/chamas/presentation/screens/members_screen.dart';
import '../../features/chamas/presentation/screens/my_chamas_screen.dart';
import '../../features/contributions/presentation/screens/contribution_dashboard_screen.dart';
import '../../features/contributions/presentation/screens/contribution_details_screen.dart';
import '../../features/contributions/presentation/screens/contribution_history_screen.dart';
import '../../features/contributions/presentation/screens/contributions_hub_screen.dart';
import '../../features/contributions/presentation/screens/create_cycle_screen.dart';
import '../../features/contributions/presentation/screens/cycle_details_screen.dart';
import '../../features/contributions/presentation/screens/cycles_screen.dart';
import '../../features/contributions/presentation/screens/member_contribution_summary_screen.dart';
import '../../features/contributions/presentation/screens/record_contribution_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_providers.dart';
import '../../features/onboarding/presentation/screens/pending_approval_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../shared/components/feature_placeholder_screen.dart';
import 'route_paths.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Notifies GoRouter when auth or onboarding gate changes.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (_, __) {
      notifyListeners();
    });
    _ref.listen<OnboardingGate>(onboardingGateProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authControllerProvider);
    final gate = _ref.read(onboardingGateProvider);
    final location = state.matchedLocation;
    final isPublicRoute = RoutePaths.publicRoutes.contains(location);

    if (authState.status == AuthStatus.initial ||
        authState.status == AuthStatus.loading) {
      return location == RoutePaths.splash ? null : RoutePaths.splash;
    }

    if (authState.isAuthenticated) {
      if (gate == OnboardingGate.unknown) {
        return location == RoutePaths.splash ? null : RoutePaths.splash;
      }

      if (isPublicRoute) {
        return gate == OnboardingGate.needsOnboarding
            ? RoutePaths.welcome
            : RoutePaths.home;
      }

      if (gate == OnboardingGate.needsOnboarding) {
        if (RoutePaths.onboardingRoutes.contains(location)) {
          return null;
        }
        return RoutePaths.welcome;
      }

      if (location == RoutePaths.welcome ||
          location == RoutePaths.pendingApproval) {
        return RoutePaths.home;
      }

      return null;
    }

    if (location == RoutePaths.login ||
        location == RoutePaths.register ||
        location == RoutePaths.forgotPassword) {
      return null;
    }

    return RoutePaths.login;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

GoRoute _placeholderRoute(String path, String title) {
  return GoRoute(
    path: path,
    name: path.replaceAll('/', ''),
    builder: (context, state) => FeaturePlaceholderScreen(title: title),
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.createChama,
        name: 'create-chama',
        builder: (context, state) => const CreateChamaScreen(),
      ),
      GoRoute(
        path: RoutePaths.joinChama,
        name: 'join-chama',
        builder: (context, state) => const JoinChamaScreen(),
      ),
      GoRoute(
        path: RoutePaths.pendingApproval,
        name: 'pending-approval',
        builder: (context, state) => const PendingApprovalScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        name: 'home',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            name: 'edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.contributions,
        name: 'contributions-hub',
        builder: (context, state) => const ContributionsHubScreen(),
      ),
      GoRoute(
        path: RoutePaths.chamas,
        name: 'chamas',
        builder: (context, state) => const MyChamasScreen(),
        routes: [
          GoRoute(
            path: ':chamaId',
            name: 'chama-details',
            builder: (context, state) => ChamaDetailsScreen(
              chamaId: state.pathParameters['chamaId']!,
            ),
            routes: [
              GoRoute(
                path: 'invite',
                name: 'chama-invite-members',
                builder: (context, state) => InviteMembersScreen(
                  chamaId: state.pathParameters['chamaId']!,
                ),
              ),
              GoRoute(
                path: 'members',
                name: 'chama-members',
                builder: (context, state) => MembersScreen(
                  chamaId: state.pathParameters['chamaId']!,
                ),
                routes: [
                  GoRoute(
                    path: ':membershipId',
                    name: 'member-details',
                    builder: (context, state) => MemberDetailsScreen(
                      chamaId: state.pathParameters['chamaId']!,
                      membershipId: state.pathParameters['membershipId']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'join-requests',
                name: 'chama-join-requests',
                builder: (context, state) => JoinRequestsScreen(
                  chamaId: state.pathParameters['chamaId']!,
                ),
              ),
              GoRoute(
                path: 'contributions',
                name: 'chama-contributions',
                builder: (context, state) => ContributionDashboardScreen(
                  chamaId: state.pathParameters['chamaId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'history',
                    name: 'contribution-history',
                    builder: (context, state) => ContributionHistoryScreen(
                      chamaId: state.pathParameters['chamaId']!,
                      cycleId: state.uri.queryParameters['cycleId'],
                      memberId: state.uri.queryParameters['memberId'],
                    ),
                  ),
                  GoRoute(
                    path: 'record',
                    name: 'record-contribution',
                    builder: (context, state) => RecordContributionScreen(
                      chamaId: state.pathParameters['chamaId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'members/:memberId',
                    name: 'member-contribution-summary',
                    builder: (context, state) =>
                        MemberContributionSummaryScreen(
                      chamaId: state.pathParameters['chamaId']!,
                      memberId: state.pathParameters['memberId']!,
                      memberName: state.uri.queryParameters['name'],
                    ),
                  ),
                  GoRoute(
                    path: ':contributionId',
                    name: 'contribution-details',
                    builder: (context, state) => ContributionDetailsScreen(
                      chamaId: state.pathParameters['chamaId']!,
                      contributionId:
                          state.pathParameters['contributionId']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'contribution-cycles',
                name: 'contribution-cycles',
                builder: (context, state) => CyclesScreen(
                  chamaId: state.pathParameters['chamaId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'create',
                    name: 'create-contribution-cycle',
                    builder: (context, state) => CreateCycleScreen(
                      chamaId: state.pathParameters['chamaId']!,
                    ),
                  ),
                  GoRoute(
                    path: ':cycleId',
                    name: 'cycle-details',
                    builder: (context, state) => CycleDetailsScreen(
                      chamaId: state.pathParameters['chamaId']!,
                      cycleId: state.pathParameters['cycleId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      _placeholderRoute(RoutePaths.loans, 'Loans'),
      _placeholderRoute(RoutePaths.meetings, 'Meetings'),
      _placeholderRoute(RoutePaths.reports, 'Reports'),
    ],
  );
});
