import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Shimmer-style loading placeholders for the dashboard.
class DashboardSkeleton extends StatefulWidget {
  const DashboardSkeleton({super.key});

  @override
  State<DashboardSkeleton> createState() => _DashboardSkeletonState();
}

class _DashboardSkeletonState extends State<DashboardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.35 + (_controller.value * 0.35);
        return Opacity(opacity: opacity, child: child);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _block(height: 120),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _block(height: 96)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _block(height: 96)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _block(height: 180),
          const SizedBox(height: AppSpacing.md),
          _block(height: 220),
          const SizedBox(height: AppSpacing.md),
          _block(height: 140),
        ],
      ),
    );
  }

  Widget _block({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.borderLight.withOpacity(0.45),
        borderRadius: AppRadius.lgAll,
      ),
    );
  }
}
