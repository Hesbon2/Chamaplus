import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/charts/charts.dart';
import '../../domain/entities/dashboard.dart';
import '../utils/dashboard_formatters.dart';

/// Dashboard contribution / loan trend charts using shared analytics widgets.
class MonthlyChartsSection extends StatelessWidget {
  const MonthlyChartsSection({
    super.key,
    required this.contributions,
    required this.loanBalances,
    required this.currency,
  });

  final List<MonthlyChartPoint> contributions;
  final List<MonthlyChartPoint> loanBalances;
  final String currency;

  List<ChartPoint> _toPoints(List<MonthlyChartPoint> source) {
    return source
        .map((p) => ChartPoint(label: p.label, value: p.value))
        .toList();
  }

  String _format(double value) =>
      DashboardFormatters.currency(value, currencyCode: currency);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contributionPoints = _toPoints(contributions);
    final loanPoints = _toPoints(loanBalances);

    return Column(
      children: [
        ChartCard(
          title: 'Monthly Contributions',
          subtitle: 'Last 6 months',
          isEmpty: contributionPoints.isEmpty,
          emptyTitle: 'No contribution data',
          emptyMessage: 'Charts appear once cycles record payments.',
          legend: [
            ChartLegendItem(
              label: 'Contributions',
              color: theme.colorScheme.primary,
            ),
          ],
          child: AppBarChart(
            points: contributionPoints,
            barColor: theme.colorScheme.primary,
            valueFormatter: _format,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ChartCard(
          title: 'Loan Balance',
          subtitle: 'Outstanding balance trend',
          isEmpty: loanPoints.isEmpty,
          emptyTitle: 'No loan balance data',
          emptyMessage: 'Outstanding balances will plot here over time.',
          legend: [
            ChartLegendItem(
              label: 'Outstanding',
              color: theme.colorScheme.secondary,
            ),
          ],
          child: AppAreaChart(
            points: loanPoints,
            lineColor: theme.colorScheme.secondary,
            valueFormatter: _format,
          ),
        ),
      ],
    );
  }
}
