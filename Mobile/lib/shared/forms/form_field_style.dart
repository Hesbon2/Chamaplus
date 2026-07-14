import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_spacing.dart';

/// Shared decoration builder for form fields.
///
/// Applies consistent Material 3 input styling while remaining theme-aware.
InputDecoration appFormDecoration(
  BuildContext context, {
  String? label,
  String? hint,
  String? helperText,
  String? errorText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? prefixText,
  String? suffixText,
  bool enabled = true,
  bool readOnly = false,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    helperText: helperText,
    errorText: errorText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    prefixText: prefixText,
    suffixText: suffixText,
    filled: true,
    enabled: enabled && !readOnly,
  );
}

/// Vertical gap used between stacked form fields.
const formFieldGap = SizedBox(height: AppSpacing.md);

/// Common text formatters for numeric amounts.
List<TextInputFormatter> amountInputFormatters({int decimalPlaces = 2}) {
  final pattern = decimalPlaces <= 0
      ? RegExp(r'^\d*$')
      : RegExp(r'^\d*\.?\d{0,$decimalPlaces}$');
  return [FilteringTextInputFormatter.allow(pattern)];
}
