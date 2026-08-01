import 'package:chamaplus_mobile/shared/charts/charts.dart';
import 'package:chamaplus_mobile/shared/reports/reports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChartCard shows header and legend', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChartCard(
            title: 'Contributions',
            subtitle: 'Last 6 months',
            legend: const [
              ChartLegendItem(label: 'Paid', color: Colors.green),
            ],
            child: AppBarChart(
              points: const [
                ChartPoint(label: 'Jan', value: 10),
                ChartPoint(label: 'Feb', value: 20),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Contributions'), findsOneWidget);
    expect(find.text('Last 6 months'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
  });

  testWidgets('ChartCard shows empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChartCard(
            title: 'Empty',
            isEmpty: true,
            emptyTitle: 'No data',
            emptyMessage: 'Try again later',
            child: SizedBox.shrink(),
          ),
        ),
      ),
    );

    expect(find.text('No data'), findsOneWidget);
    expect(find.text('Try again later'), findsOneWidget);
  });

  testWidgets('ChartCard shows loading shimmer', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChartCard(
            title: 'Loading',
            isLoading: true,
            child: SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Loading'), findsOneWidget);
    expect(find.byType(ChartLoading), findsOneWidget);
  });

  testWidgets('ChartEmptyState golden-ish layout', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 300));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ChartEmptyState(
              title: 'No chart data',
              message: 'Nothing to display',
            ),
          ),
        ),
      ),
    );

    expect(find.text('No chart data'), findsOneWidget);
    expect(find.byIcon(Icons.insights_outlined), findsOneWidget);
  });

  testWidgets('ReportCard and ExportButton render', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ReportCard(
                title: 'Monthly report',
                subtitle: 'Contributions & loans',
                badgeLabel: 'PDF / CSV',
                onTap: () => tapped = true,
              ),
              ExportButton(onPressed: () => tapped = true),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Monthly report'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
    await tester.tap(find.text('Export'));
    expect(tapped, isTrue);
  });

  testWidgets('AppPieChart builds with sections', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 220,
            child: AppPieChart(
              points: const [
                ChartPoint(label: 'Loans', value: 40),
                ChartPoint(label: 'Savings', value: 60),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AppPieChart), findsOneWidget);
  });
}
