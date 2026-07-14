import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/dashboard.dart';
import '../utils/dashboard_formatters.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChartCard(
          title: 'Monthly Contributions',
          subtitle: 'Last 6 months',
          points: contributions,
          barColor: AppColors.primary,
          currency: currency,
        ),
        const SizedBox(height: AppSpacing.md),
        _ChartCard(
          title: 'Loan Balance',
          subtitle: 'Outstanding balance trend',
          points: loanBalances,
          barColor: AppColors.secondaryDark,
          currency: currency,
          isLineChart: true,
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.barColor,
    required this.currency,
    this.isLineChart = false,
  });

  final String title;
  final String subtitle;
  final List<MonthlyChartPoint> points;
  final Color barColor;
  final String currency;
  final bool isLineChart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxY = points.fold<double>(
      0,
      (current, point) => point.value > current ? point.value : current,
    );
    final chartMaxY = maxY <= 0 ? 1000.0 : maxY * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            Text(subtitle, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 200,
              child: isLineChart
                  ? _buildLineChart(chartMaxY)
                  : _buildBarChart(chartMaxY),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(double chartMaxY) {
    return BarChart(
      BarChartData(
        maxY: chartMaxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    points[index].label,
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(points.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: points[index].value,
                color: barColor,
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLineChart(double chartMaxY) {
    return LineChart(
      LineChartData(
        maxY: chartMaxY,
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: chartMaxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.borderLight.withOpacity(0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                return Text(points[index].label, style: const TextStyle(fontSize: 11));
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              points.length,
              (index) => FlSpot(index.toDouble(), points[index].value),
            ),
            isCurved: true,
            color: barColor,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: barColor.withOpacity(0.12),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final index = spot.x.toInt();
                final value = DashboardFormatters.currency(
                  spot.y,
                  currencyCode: currency,
                );
                return LineTooltipItem(
                  '${points[index].label}\n$value',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
