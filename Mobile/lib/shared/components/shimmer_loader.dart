import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

/// Animated shimmer placeholder for loading states.
///
/// Provide either [child] for a custom layout of shimmer boxes, or use the
/// built-in block list when [itemCount] / [itemHeight] are sufficient.
class ShimmerLoader extends StatefulWidget {
  /// Creates a shimmer loading placeholder.
  const ShimmerLoader({
    super.key,
    this.child,
    this.itemCount = 3,
    this.itemHeight = 72,
    this.spacing = AppSpacing.md,
    this.borderRadius,
  });

  /// Custom shimmer layout. When null, a vertical list of blocks is used.
  final Widget? child;

  /// Number of default blocks when [child] is null.
  final int itemCount;

  /// Height of each default block.
  final double itemHeight;

  /// Gap between default blocks.
  final double spacing;

  /// Corner radius for default blocks.
  final BorderRadius? borderRadius;

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? AppColors.borderDark.withOpacity(0.55)
        : AppColors.borderLight.withOpacity(0.7);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.4 + (_controller.value * 0.45);
        return Opacity(opacity: opacity, child: child);
      },
      child: widget.child ??
          Column(
            children: List.generate(widget.itemCount, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == widget.itemCount - 1 ? 0 : widget.spacing,
                ),
                child: ShimmerBox(
                  height: widget.itemHeight,
                  color: base,
                  borderRadius: widget.borderRadius,
                ),
              );
            }),
          ),
    );
  }
}

/// A single shimmer rectangle for composing custom loading layouts.
class ShimmerBox extends StatelessWidget {
  /// Creates a shimmer rectangle.
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.color,
    this.borderRadius,
  });

  /// Optional fixed width. Expands when null.
  final double? width;

  /// Box height.
  final double height;

  /// Fill color. Defaults to a theme-aware border tone.
  final Color? color;

  /// Corner radius. Defaults to [AppRadius.mdAll].
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: color ??
            (isDark
                ? AppColors.borderDark.withOpacity(0.55)
                : AppColors.borderLight.withOpacity(0.7)),
        borderRadius: borderRadius ?? AppRadius.mdAll,
      ),
    );
  }
}
