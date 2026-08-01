import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'chart_models.dart';
import 'chart_theme.dart';

/// Area chart (filled line) built on fl_chart.
class AppAreaChart extends StatelessWidget {
  const AppAreaChart({
    super.key,
    required this.points,
    this.lineColor,
    this.fillOpacity = 0.18,
    this.curved = true,
    this.showDots = false,
    this.showGrid = true,
    this.valueFormatter,
    this.animationDuration = const Duration(milliseconds: 650),
  });

  final List<ChartPoint> points;
  final Color? lineColor;
  final double fillOpacity;
  final bool curved;
  final bool showDots;
  final bool showGrid;
  final String Function(double value)? valueFormatter;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final theme = ChartTheme.of(context);
    final color = lineColor ?? theme.scheme.primary;
    final maxY = chartMaxY(points.map((p) => p.value));

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: showGrid,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
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
              interval: 1,
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
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].value),
            ],
            isCurved: curved,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: showDots),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(fillOpacity),
                  color.withOpacity(0.02),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => theme.tooltipBg,
            getTooltipItems: (touched) {
              return touched.map((spot) {
                final index = spot.x.toInt();
                final label = index >= 0 && index < points.length
                    ? points[index].label
                    : '';
                final formatted = valueFormatter?.call(spot.y) ??
                    spot.y.toStringAsFixed(0);
                return LineTooltipItem(
                  '$label\n$formatted',
                  theme.tooltipStyle,
                );
              }).toList();
            },
          ),
        ),
      ),
      duration: animationDuration,
      curve: Curves.easeOutCubic,
    );
  }
}
