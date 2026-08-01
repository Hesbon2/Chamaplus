import 'package:flutter/material.dart';

import 'summary_metric_tile.dart';

/// Compact metric display — thin alias over [SummaryMetricTile].
///
/// Prefer [SummaryMetricTile] for new code (supports trend / percentage / footer).
class StatCard extends StatelessWidget {
  /// Creates a statistic card.
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
    this.accentColor,
    this.onTap,
  });

  /// Short metric title (e.g. "Balance").
  final String label;

  /// Primary numeric or textual value.
  final String value;

  /// Optional supporting text under the value.
  final String? subtitle;

  /// Optional leading icon.
  final IconData? icon;

  /// Accent color for the icon container. Defaults to brand primary.
  final Color? accentColor;

  /// Optional tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SummaryMetricTile(
      title: label,
      value: value,
      subtitle: subtitle,
      icon: icon,
      accentColor: accentColor,
      onTap: onTap,
    );
  }
}
