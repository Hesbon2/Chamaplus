import 'package:chamaplus_mobile/core/routing/route_paths.dart';
import 'package:chamaplus_mobile/features/chamas/domain/entities/chama.dart';
import 'package:chamaplus_mobile/features/chamas/domain/repositories/chama_repository.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/controllers/chama_list_controller.dart';
import 'package:chamaplus_mobile/features/chamas/presentation/providers/chama_providers.dart';
import 'package:chamaplus_mobile/features/meetings/presentation/screens/meetings_hub_screen.dart';
import 'package:chamaplus_mobile/shared/api_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeRepo implements ChamaRepository {
  @override
  Future<List<Chama>> listChamas({String? search}) async => const [];

  @override
  Future<List<Membership>> listPendingInvitations() async => const [];

  @override
  Future<Membership> acceptInvitation(String membershipId) =>
      throw UnimplementedError();

  @override
  Future<Membership> declineInvitation(String membershipId) =>
      throw UnimplementedError();

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SeededChamaListController extends ChamaListController {
  _SeededChamaListController(List<Chama> chamas) : super(_FakeRepo()) {
    state =
        chamas.isEmpty ? const ApiState.empty() : ApiState.success(chamas);
  }

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<void> retry() async {}
}

void main() {
  const chama = Chama(
    id: 'c1',
    name: 'Sunrise Chama',
    currency: 'KES',
    isActive: true,
  );

  testWidgets(
    'More hub can push into chama meetings when route uses root navigator',
    (tester) async {
      final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
      final moreKey = GlobalKey<NavigatorState>(debugLabel: 'more');
      final chamasKey = GlobalKey<NavigatorState>(debugLabel: 'chamas');

      final router = GoRouter(
        navigatorKey: rootKey,
        initialLocation: RoutePaths.more,
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return Scaffold(body: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                navigatorKey: chamasKey,
                routes: [
                  GoRoute(
                    path: RoutePaths.chamas,
                    builder: (context, state) =>
                        const Scaffold(body: Text('My chamas')),
                    routes: [
                      GoRoute(
                        path: ':chamaId',
                        builder: (context, state) => Scaffold(
                          body: Text(
                            'Chama ${state.pathParameters['chamaId']}',
                          ),
                        ),
                        routes: [
                          GoRoute(
                            path: 'meetings',
                            parentNavigatorKey: rootKey,
                            builder: (context, state) => const Scaffold(
                              body: Text('Governance dashboard content'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: moreKey,
                routes: [
                  GoRoute(
                    path: RoutePaths.more,
                    builder: (context, state) => Scaffold(
                      body: ListTile(
                        key: const Key('open-meetings'),
                        title: const Text('Meetings & governance'),
                        onTap: () => context.push(RoutePaths.meetings),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.meetings,
            parentNavigatorKey: rootKey,
            builder: (context, state) => const MeetingsHubScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chamaListControllerProvider.overrideWith(
              (ref) => _SeededChamaListController(const [chama]),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open-meetings')));
      await tester.pumpAndSettle();
      expect(find.text('Sunrise Chama'), findsOneWidget);

      await tester.tap(find.text('Sunrise Chama'));
      await tester.pumpAndSettle();
      expect(find.text('Governance dashboard content'), findsOneWidget);
    },
  );
}
