import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_shell_scaffold.dart';

/// Top-level application shell wrapping [StatefulNavigationShell].
///
/// Built by [StatefulShellRoute.indexedStack] so each bottom-nav branch keeps
/// its own navigator stack (state preserved across tabs).
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return AppShellScaffold(navigationShell: navigationShell);
  }
}
