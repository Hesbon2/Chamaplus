import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../components/app_card.dart';
import 'chart_empty_state.dart';
import 'chart_header.dart';
import 'chart_legend.dart';
import 'chart_loading.dart';
import 'chart_models.dart';

/// Standard container for analytics charts (title, legend, loading, empty).
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.legend = const [],
    this.isLoading = false,
    this.isEmpty = false,
    this.emptyTitle,
    this.emptyMessage,
    this.emptyIcon,
    this.height = 220,
    this.trailing,
    this.padding,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<ChartLegendItem> legend;
  final bool isLoading;
  final bool isEmpty;
  final String? emptyTitle;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final double height;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 600;
        final chartHeight = wide ? height + 24 : height;

        Widget body;
        if (isLoading) {
          body = ChartLoading(height: chartHeight);
        } else if (isEmpty) {
          body = ChartEmptyState(
            title: emptyTitle ?? 'No chart data',
            message: emptyMessage,
            icon: emptyIcon ?? Icons.insights_outlined,
            height: chartHeight,
          );
        } else {
          body = AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: SizedBox(
              key: ValueKey(title),
              height: chartHeight,
              width: double.infinity,
              child: child,
            ),
          );
        }

        return AppCard(
          onTap: onTap,
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChartHeader(
                title: title,
                subtitle: subtitle,
                trailing: trailing,
              ),
              const SizedBox(height: AppSpacing.md),
              body,
              if (!isLoading && !isEmpty && legend.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                ChartLegend(items: legend, compact: !wide),
              ],
            ],
          ),
        );
      },
    );
  }
}
