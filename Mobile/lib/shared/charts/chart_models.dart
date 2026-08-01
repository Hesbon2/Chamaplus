import 'package:flutter/material.dart';

/// A single labeled numeric value for charts.
@immutable
class ChartPoint {
  const ChartPoint({
    required this.label,
    required this.value,
    this.color,
    this.id,
  });

  final String label;
  final double value;
  final Color? color;
  final String? id;
}

/// A named series of points (multi-line / grouped charts).
@immutable
class ChartSeries {
  const ChartSeries({
    required this.name,
    required this.points,
    required this.color,
    this.id,
  });

  final String name;
  final List<ChartPoint> points;
  final Color color;
  final String? id;
}

/// Legend entry shown under / beside a chart.
@immutable
class ChartLegendItem {
  const ChartLegendItem({
    required this.label,
    required this.color,
    this.valueLabel,
  });

  final String label;
  final Color color;
  final String? valueLabel;
}

/// Computes a padded max Y for fl_chart axes.
double chartMaxY(Iterable<double> values, {double fallback = 1}) {
  var max = 0.0;
  for (final v in values) {
    if (v > max) max = v;
  }
  if (max <= 0) return fallback;
  return max * 1.15;
}

/// Collects all numeric values from one or more series.
Iterable<double> chartSeriesValues(Iterable<ChartSeries> series) sync* {
  for (final s in series) {
    for (final p in s.points) {
      yield p.value;
    }
  }
}
