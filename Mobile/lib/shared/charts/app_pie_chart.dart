import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'chart_models.dart';
import 'chart_theme.dart';

/// Reusable animated pie / donut chart built on fl_chart.
class AppPieChart extends StatefulWidget {
  const AppPieChart({
    super.key,
    required this.points,
    this.centerSpaceRadius = 40,
    this.sectionRadius = 48,
    this.showPercentLabels = true,
    this.valueFormatter,
  });

  final List<ChartPoint> points;
  final double centerSpaceRadius;
  final double sectionRadius;
  final bool showPercentLabels;
  final String Function(double value)? valueFormatter;

  @override
  State<AppPieChart> createState() => _AppPieChartState();
}

class _AppPieChartState extends State<AppPieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = ChartTheme.of(context);
    final total = widget.points.fold<double>(0, (sum, p) => sum + p.value);
    if (total <= 0 || widget.points.isEmpty) {
      return const SizedBox.shrink();
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: widget.centerSpaceRadius,
        pieTouchData: PieTouchData(
          touchCallback: (event, response) {
            setState(() {
              final index =
                  response?.touchedSection?.touchedSectionIndex;
              _touchedIndex =
                  event.isInterestedForInteractions ? index : null;
            });
          },
        ),
        sections: [
          for (var i = 0; i < widget.points.length; i++)
            PieChartSectionData(
              value: widget.points[i].value,
              color: widget.points[i].color ?? theme.colorAt(i),
              radius: _touchedIndex == i
                  ? widget.sectionRadius + 6
                  : widget.sectionRadius,
              title: widget.showPercentLabels
                  ? '${((widget.points[i].value / total) * 100).round()}%'
                  : '',
              titleStyle: theme.theme.textTheme.labelSmall?.copyWith(
                color: theme.scheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
              badgeWidget: _touchedIndex == i
                  ? _PieBadge(
                      label: widget.points[i].label,
                      value: widget.valueFormatter
                              ?.call(widget.points[i].value) ??
                          widget.points[i].value.toStringAsFixed(0),
                    )
                  : null,
              badgePositionPercentageOffset: 1.25,
            ),
        ],
      ),
    );
  }
}

class _PieBadge extends StatelessWidget {
  const _PieBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      color: theme.colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          '$label\n$value',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall,
        ),
      ),
    );
  }
}
