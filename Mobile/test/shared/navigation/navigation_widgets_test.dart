import 'package:chamaplus_mobile/shared/navigation/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NavigationBadge shows count and hides when zero', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NavigationBadge(
            count: 5,
            child: Icon(Icons.notifications),
          ),
        ),
      ),
    );

    expect(find.text('5'), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NavigationBadge(
            count: 0,
            child: Icon(Icons.notifications),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('0'), findsNothing);
  });

  testWidgets('AppBottomNavigation selects destination', (tester) async {
    var selected = 0;
    final items = defaultBottomNavItems(
      badges: const NavigationBadgeState(alerts: 2, loans: 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNavigation(
            items: items,
            selectedIndex: selected,
            onDestinationSelected: (index) => selected = index,
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('Loans'));
    await tester.pump();
    expect(selected, ShellTabIndex.loans);
  });

  testWidgets('QuickActionTile compact renders label', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickActionTile(
            compact: true,
            label: 'Apply loan',
            icon: Icons.account_balance_wallet_outlined,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Apply loan'), findsOneWidget);
    await tester.tap(find.text('Apply loan'));
    expect(tapped, isTrue);
  });
}
