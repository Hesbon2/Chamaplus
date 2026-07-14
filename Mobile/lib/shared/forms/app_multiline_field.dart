import 'package:flutter/material.dart';

import 'form_field_style.dart';

/// Multi-line text area for notes, descriptions, and messages.
class AppMultilineField extends StatelessWidget {
  /// Creates a multi-line text field.
  const AppMultilineField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.helperText,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.enabled = true,
    this.readOnly = false,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.autovalidateMode,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hint;
  final String? helperText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;
  final bool enabled;
  final bool readOnly;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      decoration: appFormDecoration(
        context,
        label: label,
        hint: hint,
        helperText: helperText,
        prefixIcon: const Icon(Icons.notes_outlined),
        enabled: enabled,
        readOnly: readOnly,
      ).copyWith(alignLabelWithHint: true),
    );
  }
}
