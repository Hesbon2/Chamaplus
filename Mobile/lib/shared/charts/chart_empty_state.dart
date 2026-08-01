import 'package:flutter/material.dart';

import '../components/empty_state.dart';

/// Empty placeholder shown inside a [ChartCard] when there is no data.
class ChartEmptyState extends StatelessWidget {
  const ChartEmptyState({
    super.key,
    this.title = 'No chart data',
    this.message = 'There is nothing to display for this period yet.',
    this.icon = Icons.insights_outlined,
    this.height = 200,
  });

  final String title;
  final String? message;
  final IconData icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: EmptyState(
        title: title,
        message: message,
        icon: icon,
        iconSize: 40,
      ),
    );
  }
}
