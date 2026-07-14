import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/chamas/presentation/screens/chama_details_screen.dart';
import '../../features/chamas/presentation/screens/join_requests_screen.dart';
import '../../features/chamas/presentation/screens/member_details_screen.dart';
import '../../features/chamas/presentation/screens/members_screen.dart';
import '../../features/chamas/presentation/screens/my_chamas_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../shared/components/feature_placeholder_screen.dart';
import 'route_paths.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Notifies GoRouter when auth state changes for redirect evaluation.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authControllerProvider);
    final location = state.matchedLocation;
    final isPublicRoute = RoutePaths.publicRoutes.contains(location);

    if (authState.status == AuthStatus.initial ||
        authState.status == AuthStatus.loading) {
      return location == RoutePaths.splash ? null : RoutePaths.splash;
    }

    if (authState.isAuthenticated) {
      if (isPublicRoute) {
        return RoutePaths.home;
      }
      return null;
    }

    if (location == RoutePaths.login ||
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
        path: RoutePaths.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        name: 'home',
        builder: (context, state) => const DashboardScreen(),
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
            ],
          ),
        ],
      ),
      _placeholderRoute(RoutePaths.contributions, 'Contributions'),
      _placeholderRoute(RoutePaths.loans, 'Loans'),
      _placeholderRoute(RoutePaths.meetings, 'Meetings'),
      _placeholderRoute(RoutePaths.reports, 'Reports'),
      _placeholderRoute(RoutePaths.profile, 'Profile'),
    ],
  );
});
