import 'package:chamaplus_mobile/features/dashboard/presentation/widgets/welcome_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WelcomeCard displays user and role', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WelcomeCard(
            name: 'Jane Doe',
            chamaName: 'Unity Chama',
            role: 'Treasurer',
            memberCount: 10,
          ),
        ),
      ),
    );

    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('Unity Chama'), findsOneWidget);
    expect(find.text('Treasurer'), findsOneWidget);
    expect(find.text('10 members'), findsOneWidget);
  });
}
