import 'package:flutter/material.dart';

/// A reusable badge for navigation destinations and list tiles.
class NavigationBadge extends StatelessWidget {
  const NavigationBadge({
    super.key,
    required this.count,
    this.maxCount = 99,
    this.child,
    this.backgroundColor,
    this.textColor,
    this.showZero = false,
  });

  /// Unread / pending count.
  final int count;

  /// Cap displayed as `{maxCount}+`.
  final int maxCount;

  /// Optional host widget (e.g. an [Icon]). When null, renders the chip alone.
  final Widget? child;

  final Color? backgroundColor;
  final Color? textColor;

  /// When true, still shows a badge for `0`.
  final bool showZero;

  bool get _visible => showZero ? count >= 0 : count > 0;

  String get _label {
    if (count > maxCount) return '$maxCount+';
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.error;
    final fg = textColor ?? theme.colorScheme.onError;

    if (!_visible) {
      return child ?? const SizedBox.shrink();
    }

    final badge = AnimatedScale(
      scale: 1,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: Container(
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          _label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: fg,
            fontWeight: FontWeight.w700,
            fontSize: 10,
            height: 1.1,
          ),
        ),
      ),
    );

    if (child == null) return badge;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child!,
        Positioned(
          right: -6,
          top: -4,
          child: badge,
        ),
      ],
    );
  }
}
