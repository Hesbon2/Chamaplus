import 'package:chamaplus_mobile/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home screen displays ChamaPlus Mobile', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ChamaplusApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ChamaPlus Mobile'), findsOneWidget);
  });
}
