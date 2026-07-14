import 'package:flutter/material.dart';

import 'app_text_field.dart';
import 'form_field_style.dart';
import 'validators.dart';

/// Monetary amount input with decimal keyboard and amount validation.
class AppAmountField extends StatelessWidget {
  /// Creates an amount field.
  const AppAmountField({
    super.key,
    this.controller,
    this.initialValue,
    this.label = 'Amount',
    this.hint = '0.00',
    this.helperText,
    this.currencyCode = 'KES',
    this.validator,
    this.onChanged,
    this.onSaved,
    this.enabled = true,
    this.readOnly = false,
    this.isRequired = true,
    this.min,
    this.max,
    this.decimalPlaces = 2,
    this.autovalidateMode,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hint;
  final String? helperText;

  /// Shown as prefix text (e.g. `KES`).
  final String currencyCode;

  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;
  final bool enabled;
  final bool readOnly;
  final bool isRequired;
  final double? min;
  final double? max;
  final int decimalPlaces;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      initialValue: initialValue,
      label: label,
      hint: hint,
      helperText: helperText,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.attach_money),
      prefixText: '$currencyCode ',
      enabled: enabled,
      readOnly: readOnly,
      inputFormatters: amountInputFormatters(decimalPlaces: decimalPlaces),
      validator: validator ??
          (value) => AppValidators.amount(
                value,
                isRequired: isRequired,
                min: min,
                max: max,
              ),
      onChanged: onChanged,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
    );
  }
}
