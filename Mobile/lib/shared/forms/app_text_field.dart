import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'form_field_style.dart';

/// Primary single-line text input for ChamaPlus forms.
///
/// Supports validation, read-only / disabled states, icons, and keyboard types.
class AppTextField extends StatelessWidget {
  /// Creates a styled text field.
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onSaved,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLength,
    this.inputFormatters,
    this.autovalidateMode,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      autovalidateMode: autovalidateMode,
      decoration: appFormDecoration(
        context,
        label: label,
        hint: hint,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefixText: prefixText,
        suffixText: suffixText,
        enabled: enabled,
        readOnly: readOnly,
      ),
    );
  }
}
