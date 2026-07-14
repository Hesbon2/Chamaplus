import 'package:flutter/material.dart';

import 'form_field_style.dart';

/// Generic Material 3 dropdown field for form selections.
class AppDropdown<T> extends StatelessWidget {
  /// Creates a dropdown form field.
  const AppDropdown({
    super.key,
    required this.items,
    this.value,
    this.label,
    this.hint,
    this.helperText,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.prefixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.autovalidateMode,
  });

  /// Menu items to display.
  final List<DropdownMenuItem<T>> items;

  /// Currently selected value.
  final T? value;

  final String? label;
  final String? hint;
  final String? helperText;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final FormFieldSetter<T>? onSaved;
  final Widget? prefixIcon;
  final bool enabled;
  final bool readOnly;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final isInteractive = enabled && !readOnly;

    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: isInteractive ? onChanged : null,
      validator: validator,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      decoration: appFormDecoration(
        context,
        label: label,
        hint: hint,
        helperText: helperText,
        prefixIcon: prefixIcon,
        enabled: enabled,
        readOnly: readOnly,
      ),
      isExpanded: true,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
