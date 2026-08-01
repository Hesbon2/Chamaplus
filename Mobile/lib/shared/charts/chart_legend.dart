import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'chart_models.dart';

/// Horizontal / wrap legend for chart series or pie slices.
class ChartLegend extends StatelessWidget {
  const ChartLegend({
    super.key,
    required this.items,
    this.compact = false,
  });

  final List<ChartLegendItem> items;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 8 : 10,
                height: compact ? 8 : 10,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: AppRadius.smAll,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                item.valueLabel == null
                    ? item.label
                    : '${item.label}: ${item.valueLabel}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
