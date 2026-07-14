import 'package:chamaplus_mobile/shared/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? ThemeData(useMaterial3: true, brightness: Brightness.light),
    darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
    home: Scaffold(body: child),
  );
}

void main() {
  group('AppCard', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppCard(child: Text('Card body'))),
      );
      expect(find.text('Card body'), findsOneWidget);
    });

    testWidgets('invokes onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppCard(
            onTap: () => tapped = true,
            child: const Text('Tap me'),
          ),
        ),
      );
      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });
  });

  group('StatCard', () {
    testWidgets('shows label, value, and subtitle', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StatCard(
            label: 'Balance',
            value: 'KES 1,000',
            subtitle: 'This month',
            icon: Icons.savings_outlined,
          ),
        ),
      );
      expect(find.text('Balance'), findsOneWidget);
      expect(find.text('KES 1,000'), findsOneWidget);
      expect(find.text('This month'), findsOneWidget);
    });
  });

  group('SectionHeader', () {
    testWidgets('renders title and action', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        _wrap(
          SectionHeader(
            title: 'Recent',
            subtitle: 'Last 7 days',
            actionLabel: 'See all',
            onAction: () => pressed = true,
          ),
        ),
      );
      expect(find.text('Recent'), findsOneWidget);
      expect(find.text('Last 7 days'), findsOneWidget);
      await tester.tap(find.text('See all'));
      expect(pressed, isTrue);
    });
  });

  group('AvatarBadge', () {
    testWidgets('shows initials and badge count', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AvatarBadge(initials: 'JD', badgeCount: 3),
        ),
      );
      expect(find.text('JD'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });

  group('InfoTile', () {
    testWidgets('shows title and subtitle', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const InfoTile(
            title: 'Phone',
            subtitle: '+254712345678',
            leading: Icon(Icons.phone),
          ),
        ),
      );
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('+254712345678'), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsOneWidget);
    });
  });

  group('StatusChip', () {
    testWidgets('renders success tone label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StatusChip(
            label: 'Active',
            tone: StatusChipTone.success,
          ),
        ),
      );
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('works in dark theme', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StatusChip(label: 'Pending', tone: StatusChipTone.warning),
          theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
        ),
      );
      expect(find.text('Pending'), findsOneWidget);
    });
  });

  group('EmptyState', () {
    testWidgets('shows title and optional action', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        _wrap(
          EmptyState(
            title: 'Nothing here',
            message: 'Try again later',
            actionLabel: 'Retry',
            onAction: () => pressed = true,
          ),
        ),
      );
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Try again later'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(pressed, isTrue);
    });
  });

  group('ShimmerLoader', () {
    testWidgets('renders default shimmer blocks', (tester) async {
      await tester.pumpWidget(
        _wrap(const ShimmerLoader(itemCount: 2, itemHeight: 40)),
      );
      expect(find.byType(ShimmerBox), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 300));
    });
  });

  group('ActionButton', () {
    testWidgets('primary button invokes callback', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        _wrap(
          ActionButton(
            label: 'Continue',
            onPressed: () => pressed = true,
          ),
        ),
      );
      await tester.tap(find.text('Continue'));
      expect(pressed, isTrue);
    });

    testWidgets('loading state disables press', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        _wrap(
          ActionButton(
            label: 'Save',
            isLoading: true,
            onPressed: () => pressed = true,
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isFalse);
    });
  });

  group('ConfirmationDialog', () {
    testWidgets('confirm returns true', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await showAppConfirmationDialog(
                      context: context,
                      title: 'Delete item?',
                      message: 'This cannot be undone.',
                      isDestructive: true,
                    );
                  },
                  child: const Text('Open'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete item?'), findsOneWidget);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('cancel returns false', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await showAppConfirmationDialog(
                      context: context,
                      title: 'Leave?',
                      message: 'Discard changes?',
                    );
                  },
                  child: const Text('Open'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });
  });
}
