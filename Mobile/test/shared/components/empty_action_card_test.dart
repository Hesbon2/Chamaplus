import 'package:chamaplus_mobile/shared/components/empty_action_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EmptyActionCard shows title, message, and actions', (tester) async {
    var primaryTapped = false;
    var secondaryTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyActionCard(
            title: 'No data',
            message: 'Do something next',
            actionLabel: 'Primary',
            onAction: () => primaryTapped = true,
            secondaryActionLabel: 'Secondary',
            onSecondaryAction: () => secondaryTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('No data'), findsOneWidget);
    expect(find.text('Do something next'), findsOneWidget);

    await tester.tap(find.text('Primary'));
    await tester.pump();
    expect(primaryTapped, isTrue);

    await tester.tap(find.text('Secondary'));
    await tester.pump();
    expect(secondaryTapped, isTrue);
  });
}
