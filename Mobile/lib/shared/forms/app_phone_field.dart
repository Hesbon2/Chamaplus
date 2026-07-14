import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_text_field.dart';
import 'validators.dart';

/// Kenyan phone number field with phone keyboard and validation.
class AppPhoneField extends StatelessWidget {
  /// Creates a phone input field.
  const AppPhoneField({
    super.key,
    this.controller,
    this.initialValue,
    this.label = 'Phone number',
    this.hint = '0712345678',
    this.helperText,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.enabled = true,
    this.readOnly = false,
    this.isRequired = true,
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
  final bool isRequired;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      initialValue: initialValue,
      label: label,
      hint: hint,
      helperText: helperText,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.phone_outlined),
      enabled: enabled,
      readOnly: readOnly,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
      ],
      validator: validator ??
          (value) => AppValidators.phone(value, isRequired: isRequired),
      onChanged: onChanged,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
    );
  }
}
