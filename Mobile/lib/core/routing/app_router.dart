import 'package:flutter/foundation.dart';
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
import '../../features/loans/presentation/screens/active_loan_screen.dart';
import '../../features/loans/presentation/screens/apply_loan_screen.dart';
import '../../features/loans/presentation/screens/committee_voting_screen.dart';
import '../../features/loans/presentation/screens/create_loan_product_screen.dart';
import '../../features/loans/presentation/screens/edit_loan_product_screen.dart';
import '../../features/loans/presentation/screens/loan_calculator_screen.dart';
import '../../features/loans/presentation/screens/loan_dashboard_screen.dart';
import '../../features/loans/presentation/screens/loan_details_screen.dart';
import '../../features/loans/presentation/screens/loan_history_screen.dart';
import '../../features/loans/presentation/screens/loan_product_details_screen.dart';
import '../../features/loans/presentation/screens/loan_products_screen.dart';
import '../../features/loans/presentation/screens/loans_hub_screen.dart';
import '../../features/loans/presentation/screens/repayment_history_screen.dart';
import '../../features/meetings/presentation/screens/governance_dashboard_screen.dart';
import '../../features/meetings/presentation/screens/meeting_action_items_screen.dart';
import '../../features/meetings/presentation/screens/meeting_attendance_screen.dart';
import '../../features/meetings/presentation/screens/meeting_details_screen.dart';
import '../../features/meetings/presentation/screens/meeting_minutes_screen.dart';
import '../../features/meetings/presentation/screens/meetings_hub_screen.dart';
import '../../features/meetings/presentation/screens/meetings_list_screen.dart';
import '../../features/meetings/presentation/screens/schedule_meeting_screen.dart';
import '../../features/notifications/presentation/screens/notification_details_screen.dart';
import '../../features/notifications/presentation/screens/notifications_list_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_providers.dart';
import '../../features/onboarding/presentation/screens/pending_approval_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/chamas/presentation/screens/pending_invitations_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/reports/presentation/screens/defaulters_report_screen.dart';
import '../../features/reports/presentation/screens/export_center_screen.dart';
import '../../features/reports/presentation/screens/financial_report_screen.dart';
import '../../features/reports/presentation/screens/member_statement_screen.dart';
import '../../features/reports/presentation/screens/monthly_report_screen.dart';
import '../../features/reports/presentation/screens/reports_home_screen.dart';
import '../../features/reports/presentation/screens/reports_hub_screen.dart';
import '../../features/settings/presentation/screens/about_screen.dart';
import '../../features/settings/presentation/screens/appearance_settings_screen.dart';
import '../../features/settings/presentation/screens/diagnostics_screen.dart';
import '../../features/settings/presentation/screens/help_support_screen.dart';
import '../../features/settings/presentation/screens/notification_preferences_screen.dart';
import '../../features/settings/presentation/screens/security_settings_screen.dart';
import '../../features/settings/presentation/screens/settings_home_screen.dart';
import '../../shared/navigation/navigation.dart';
import 'pending_deep_link.dart';
import 'route_paths.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell-home');
final _shellNavigatorChamasKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell-chamas');
final _shellNavigatorLoansKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell-loans');
final _shellNavigatorAlertsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell-alerts');
final _shellNavigatorMoreKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell-more');

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
    final fullUri = state.uri.toString();
    final isPublicRoute = RoutePaths.publicRoutes.contains(location);

    void capturePending() {
      if (!isEphemeralAuthLocation(location) &&
          location != RoutePaths.welcome &&
          location != RoutePaths.pendingApproval) {
        _ref.read(pendingDeepLinkProvider.notifier).state = fullUri;
      }
    }

    String? consumePending() {
      final pending = _ref.read(pendingDeepLinkProvider);
      if (pending == null || pending.isEmpty) return null;
      _ref.read(pendingDeepLinkProvider.notifier).state = null;
      return pending;
    }

    if (authState.status == AuthStatus.initial ||
        authState.status == AuthStatus.loading) {
      if (location == RoutePaths.splash) return null;
      capturePending();
      return RoutePaths.splash;
    }

    if (authState.isAuthenticated) {
      if (gate == OnboardingGate.unknown ||
          gate == OnboardingGate.unresolved) {
        if (location == RoutePaths.splash) return null;
        capturePending();
        return RoutePaths.splash;
      }

      if (isPublicRoute) {
        if (gate == OnboardingGate.needsOnboarding) {
          return RoutePaths.welcome;
        }
        return consumePending() ?? RoutePaths.home;
      }

      if (gate == OnboardingGate.needsOnboarding) {
        if (RoutePaths.onboardingRoutes.contains(location)) {
          return null;
        }
        capturePending();
        return RoutePaths.welcome;
      }

      if (location == RoutePaths.welcome ||
          location == RoutePaths.pendingApproval ||
          location == RoutePaths.pendingInvitations) {
        return consumePending() ?? RoutePaths.home;
      }

      return null;
    }

    if (location == RoutePaths.login ||
        location == RoutePaths.register ||
        location == RoutePaths.forgotPassword) {
      return null;
    }

    capturePending();
    return RoutePaths.login;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// Chama-scoped feature routes nested under `/chamas/:chamaId`.
List<RouteBase> _chamaScopedRoutes() {
  return [
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: 'invite',
      name: 'chama-invite-members',
      builder: (context, state) => InviteMembersScreen(
        chamaId: state.pathParameters['chamaId']!,
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: 'members',
      name: 'chama-members',
      builder: (context, state) => MembersScreen(
        chamaId: state.pathParameters['chamaId']!,
      ),
      routes: [
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
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
      parentNavigatorKey: _rootNavigatorKey,
      path: 'join-requests',
      name: 'chama-join-requests',
      builder: (context, state) => JoinRequestsScreen(
        chamaId: state.pathParameters['chamaId']!,
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: 'contributions',
      name: 'chama-contributions',
      builder: (context, state) => ContributionDashboardScreen(
        chamaId: state.pathParameters['chamaId']!,
      ),
      routes: [
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: 'history',
          name: 'contribution-history',
          builder: (context, state) => ContributionHistoryScreen(
            chamaId: state.pathParameters['chamaId']!,
            cycleId: state.uri.queryParameters['cycleId'],
            memberId: state.uri.queryParameters['memberId'],
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: 'record',
          name: 'record-contribution',
          builder: (context, state) => RecordContributionScreen(
            chamaId: state.pathParameters['chamaId']!,
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: 'members/:memberId',
          name: 'member-contribution-summary',
          builder: (context, state) => MemberContributionSummaryScreen(
            chamaId: state.pathParameters['chamaId']!,
            memberId: state.pathParameters['memberId']!,
            memberName: state.uri.queryParameters['name'],
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: ':contributionId',
          name: 'contribution-details',
          builder: (context, state) => ContributionDetailsScreen(
            chamaId: state.pathParameters['chamaId']!,
            contributionId: state.pathParameters['contributionId']!,
          ),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: 'contribution-cycles',
      name: 'contribution-cycles',
      builder: (context, state) => CyclesScreen(
        chamaId: state.pathParameters['chamaId']!,
      ),
      routes: [
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: 'create',
          name: 'create-contribution-cycle',
          builder: (context, state) => CreateCycleScreen(
            chamaId: state.pathParameters['chamaId']!,
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: ':cycleId',
          name: 'cycle-details',
          builder: (context, state) => CycleDetailsScreen(
            chamaId: state.pathParameters['chamaId']!,
            cycleId: state.pathParameters['cycleId']!,
          ),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: 'loans',
      name: 'chama-loans',
      builder: (context, state) => LoanDashboardScreen(
        chamaId: state.pathParameters['chamaId']!,
      ),
      routes: [
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: 'products',
          name: 'loan-products',
          builder: (context, state) => LoanProductsScreen(
            chamaId: state.pathParameters['chamaId']!,
          ),
          routes: [
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: 'create',
              name: 'create-loan-product',
              builder: (context, state) => CreateLoanProductScreen(
                chamaId: state.pathParameters['chamaId']!,
              ),
            ),
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: ':productId',
              name: 'loan-product-details',
              builder: (context, state) => LoanProductDetailsScreen(
                chamaId: state.pathParameters['chamaId']!,
                productId: state.pathParameters['productId']!,
              ),
              routes: [
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  path: 'edit',
                  name: 'edit-loan-product',
                  builder: (context, state) => EditLoanProductScreen(
                    chamaId: state.pathParameters['chamaId']!,
                    productId: state.pathParameters['productId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: 'calculator',
          name: 'loan-calculator',
          builder: (context, state) => LoanCalculatorScreen(
            chamaId: state.pathParameters['chamaId']!,
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: 'apply',
          name: 'apply-loan',
          builder: (context, state) => ApplyLoanScreen(
            chamaId: state.pathParameters['chamaId']!,
            initialProductId: state.uri.queryParameters['productId'],
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: 'history',
          name: 'loan-history',
          builder: (context, state) => LoanHistoryScreen(
            chamaId: state.pathParameters['chamaId']!,
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: 'applications/:applicationId',
          name: 'loan-details',
          builder: (context, state) => LoanDetailsScreen(
            chamaId: state.pathParameters['chamaId']!,
            applicationId: state.pathParameters['applicationId']!,
          ),
          routes: [
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: 'vote',
              name: 'loan-committee-voting',
              builder: (context, state) => CommitteeVotingScreen(
                chamaId: state.pathParameters['chamaId']!,
                applicationId: state.pathParameters['applicationId']!,
              ),
            ),
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: 'repayments',
              name: 'loan-repayment-history',
              builder: (context, state) => RepaymentHistoryScreen(
                chamaId: state.pathParameters['chamaId']!,
                applicationId: state.pathParameters['applicationId']!,
              ),
            ),
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: 'active',
              name: 'active-loan',
              builder: (context, state) => ActiveLoanScreen(
                chamaId: state.pathParameters['chamaId']!,
                applicationId: state.pathParameters['applicationId']!,
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: 'meetings',
      name: 'chama-meetings',
      builder: (context, state) => GovernanceDashboardScreen(
        chamaId: state.pathParameters['chamaId']!,
      ),
      routes: [
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: 'list',
          name: 'meetings-list',
          builder: (context, state) => MeetingsListScreen(
            chamaId: state.pathParameters['chamaId']!,
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: 'upcoming',
          name: 'upcoming-meetings',
          builder: (context, state) => MeetingsListScreen(
            chamaId: state.pathParameters['chamaId']!,
            upcomingOnly: true,
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: 'schedule',
          name: 'schedule-meeting',
          builder: (context, state) => ScheduleMeetingScreen(
            chamaId: state.pathParameters['chamaId']!,
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: ':meetingId',
          name: 'meeting-details',
          builder: (context, state) => MeetingDetailsScreen(
            chamaId: state.pathParameters['chamaId']!,
            meetingId: state.pathParameters['meetingId']!,
          ),
          routes: [
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: 'attendance',
              name: 'meeting-attendance',
              builder: (context, state) => MeetingAttendanceScreen(
                chamaId: state.pathParameters['chamaId']!,
                meetingId: state.pathParameters['meetingId']!,
              ),
            ),
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: 'minutes',
              name: 'meeting-minutes',
              builder: (context, state) => MeetingMinutesScreen(
                chamaId: state.pathParameters['chamaId']!,
                meetingId: state.pathParameters['meetingId']!,
              ),
            ),
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: 'action-items',
              name: 'meeting-action-items',
              builder: (context, state) => MeetingActionItemsScreen(
                chamaId: state.pathParameters['chamaId']!,
                meetingId: state.pathParameters['meetingId']!,
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: 'reports',
      name: 'chama-reports',
      builder: (context, state) => ReportsHomeScreen(
        chamaId: state.pathParameters['chamaId']!,
      ),
      routes: [
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: 'monthly',
          name: 'monthly-report',
          builder: (context, state) => MonthlyReportScreen(
            chamaId: state.pathParameters['chamaId']!,
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: 'financial',
          name: 'financial-report',
          builder: (context, state) => FinancialReportScreen(
            chamaId: state.pathParameters['chamaId']!,
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: 'defaulters',
          name: 'defaulters-report',
          builder: (context, state) => DefaultersReportScreen(
            chamaId: state.pathParameters['chamaId']!,
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: 'member-statement',
          name: 'member-statement',
          builder: (context, state) => MemberStatementScreen(
            chamaId: state.pathParameters['chamaId']!,
            memberId: state.uri.queryParameters['memberId'],
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: 'export',
          name: 'export-center',
          builder: (context, state) => ExportCenterScreen(
            chamaId: state.pathParameters['chamaId']!,
          ),
        ),
      ],
    ),
  ];
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
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateChamaScreen(),
      ),
      GoRoute(
        path: RoutePaths.joinChama,
        name: 'join-chama',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const JoinChamaScreen(),
      ),
      GoRoute(
        path: RoutePaths.pendingApproval,
        name: 'pending-approval',
        builder: (context, state) => const PendingApprovalScreen(),
      ),
      GoRoute(
        path: RoutePaths.pendingInvitations,
        name: 'pending-invitations',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PendingInvitationsScreen(),
      ),

      /// Persistent bottom-nav shell (Home / Chamas / Loans / Alerts / More).
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: 'home',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorChamasKey,
            routes: [
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
                    routes: _chamaScopedRoutes(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorLoansKey,
            routes: [
              GoRoute(
                path: RoutePaths.loans,
                name: 'loans-hub',
                builder: (context, state) => const LoansHubScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorAlertsKey,
            routes: [
              GoRoute(
                path: RoutePaths.alerts,
                name: 'alerts',
                builder: (context, state) => const AlertsTabScreen(),
                routes: [
                  GoRoute(
                    path: 'list',
                    name: 'alerts-list',
                    builder: (context, state) => NotificationsListScreen(
                      unreadOnly:
                          state.uri.queryParameters['unread'] == '1',
                    ),
                  ),
                  GoRoute(
                    path: ':notificationId',
                    name: 'alert-details',
                    builder: (context, state) => NotificationDetailsScreen(
                      notificationId:
                          state.pathParameters['notificationId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorMoreKey,
            routes: [
              GoRoute(
                path: RoutePaths.more,
                name: 'more',
                builder: (context, state) => const MoreTabScreen(),
              ),
            ],
          ),
        ],
      ),

      // Full-screen / overflow destinations (cover the shell).
      GoRoute(
        path: RoutePaths.profile,
        name: 'profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            name: 'edit-profile',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.contributions,
        name: 'contributions-hub',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ContributionsHubScreen(),
      ),
      GoRoute(
        path: RoutePaths.meetings,
        name: 'meetings-hub',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MeetingsHubScreen(),
      ),
      GoRoute(
        path: RoutePaths.reports,
        name: 'reports-hub',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReportsHubScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: 'settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsHomeScreen(),
        routes: [
          GoRoute(
            path: 'appearance',
            name: 'settings-appearance',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const AppearanceSettingsScreen(),
          ),
          GoRoute(
            path: 'security',
            name: 'settings-security',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const SecuritySettingsScreen(),
          ),
          GoRoute(
            path: 'notifications',
            name: 'settings-notifications',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const NotificationPreferencesScreen(),
          ),
          GoRoute(
            path: 'help',
            name: 'settings-help',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const HelpSupportScreen(),
          ),
          GoRoute(
            path: 'about',
            name: 'settings-about',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const AboutScreen(),
          ),
          if (kDebugMode)
            GoRoute(
              path: 'diagnostics',
              name: 'settings-diagnostics',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const DiagnosticsScreen(),
            ),
        ],
      ),
    ],
  );
});
