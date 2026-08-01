import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'chart_models.dart';
import 'chart_theme.dart';

/// Reusable animated bar chart built on fl_chart.
class AppBarChart extends StatelessWidget {
  const AppBarChart({
    super.key,
    required this.points,
    this.barColor,
    this.showGrid = false,
    this.valueFormatter,
  });

  final List<ChartPoint> points;
  final Color? barColor;
  final bool showGrid;
  final String Function(double value)? valueFormatter;

  @override
  Widget build(BuildContext context) {
    final theme = ChartTheme.of(context);
    final color = barColor ?? theme.scheme.primary;
    final maxY = chartMaxY(points.map((p) => p.value));

    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: FlGridData(
          show: showGrid,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.gridLine,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    points[index].label,
                    style: theme.bottomTitleStyle,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: points[i].value,
                  color: points[i].color ?? color,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            ),
        ],
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => theme.tooltipBg,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final point = points[group.x.toInt()];
              final formatted =
                  valueFormatter?.call(rod.toY) ?? rod.toY.toStringAsFixed(0);
              return BarTooltipItem(
                '${point.label}\n$formatted',
                theme.tooltipStyle,
              );
            },
          ),
        ),
      ),
    );
  }
}
