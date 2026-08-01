import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Theme-aware colors and text styles for shared charts.
class ChartTheme {
  ChartTheme._(this.context);

  factory ChartTheme.of(BuildContext context) => ChartTheme._(context);

  final BuildContext context;

  ThemeData get theme => Theme.of(context);
  ColorScheme get scheme => theme.colorScheme;
  bool get isDark => theme.brightness == Brightness.dark;

  Color get gridLine =>
      (isDark ? AppColors.borderDark : AppColors.borderLight).withOpacity(0.55);

  Color get axisLabel => scheme.onSurfaceVariant;

  Color get tooltipBg => scheme.inverseSurface;

  Color get tooltipFg => scheme.onInverseSurface;

  List<Color> get palette => [
        scheme.primary,
        scheme.secondary,
        scheme.tertiary,
        AppColors.info,
        AppColors.warning,
        AppColors.error,
        AppColors.primaryLight,
      ];

  Color colorAt(int index) => palette[index % palette.length];

  TextStyle get bottomTitleStyle =>
      theme.textTheme.labelSmall?.copyWith(color: axisLabel) ??
      TextStyle(fontSize: 11, color: axisLabel);

  TextStyle get tooltipStyle =>
      theme.textTheme.labelMedium?.copyWith(color: tooltipFg) ??
      TextStyle(fontSize: 12, color: tooltipFg);
}
