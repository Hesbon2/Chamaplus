import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'chart_models.dart';
import 'chart_theme.dart';

/// Reusable animated line chart built on fl_chart.
class AppLineChart extends StatelessWidget {
  const AppLineChart({
    super.key,
    required this.points,
    this.series = const [],
    this.lineColor,
    this.curved = true,
    this.showDots = true,
    this.showGrid = true,
    this.valueFormatter,
    this.animationDuration = const Duration(milliseconds: 650),
  });

  /// Single-series points (ignored when [series] is non-empty).
  final List<ChartPoint> points;

  /// Optional multi-series mode.
  final List<ChartSeries> series;

  final Color? lineColor;
  final bool curved;
  final bool showDots;
  final bool showGrid;
  final String Function(double value)? valueFormatter;
  final Duration animationDuration;

  List<ChartSeries> get _resolvedSeries {
    if (series.isNotEmpty) return series;
    return [
      ChartSeries(
        name: 'Series',
        points: points,
        color: lineColor ?? Colors.blue,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChartTheme.of(context);
    final resolved = _resolvedSeries.map((s) {
      if (identical(s.color, Colors.blue) && lineColor == null && series.isEmpty) {
        return ChartSeries(
          name: s.name,
          points: s.points,
          color: theme.scheme.primary,
          id: s.id,
        );
      }
      return s;
    }).toList();

    final labels = resolved.isEmpty
        ? <String>[]
        : resolved.first.points.map((p) => p.label).toList();
    final maxY = chartMaxY(chartSeriesValues(resolved));

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
              showTitles: labels.isNotEmpty,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[index], style: theme.bottomTitleStyle),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          for (final s in resolved)
            LineChartBarData(
              spots: [
                for (var i = 0; i < s.points.length; i++)
                  FlSpot(i.toDouble(), s.points[i].value),
              ],
              isCurved: curved,
              color: s.color,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: showDots),
              belowBarData: BarAreaData(show: false),
            ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => theme.tooltipBg,
            getTooltipItems: (touched) {
              return touched.map((spot) {
                final seriesIndex = spot.barIndex;
                final pointIndex = spot.x.toInt();
                final s = resolved[seriesIndex];
                final label = pointIndex >= 0 && pointIndex < s.points.length
                    ? s.points[pointIndex].label
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
