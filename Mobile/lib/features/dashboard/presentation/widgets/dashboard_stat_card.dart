import 'package:flutter/material.dart';

import '../../../../shared/components/summary_metric_tile.dart';

/// Home dashboard KPI tile — thin wrapper over [SummaryMetricTile].
class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.accentColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return SummaryMetricTile(
      title: title,
      value: value,
      subtitle: subtitle,
      icon: icon,
      accentColor: accentColor,
    );
  }
}
