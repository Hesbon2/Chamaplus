import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../components/shimmer_loader.dart';

/// Shimmer placeholder sized for chart bodies.
class ChartLoading extends StatelessWidget {
  const ChartLoading({
    super.key,
    this.height = 200,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ShimmerLoader(
        itemCount: 1,
        itemHeight: height,
        spacing: AppSpacing.sm,
      ),
    );
  }
}
