import 'package:flutter/material.dart';

import 'app_dropdown.dart';
import 'validators.dart';

/// Currency code selector (ISO 4217 style labels).
///
/// Defaults to Kenyan Shilling (`KES`) which is the ChamaPlus primary currency.
class AppCurrencyField extends StatelessWidget {
  /// Creates a currency dropdown.
  const AppCurrencyField({
    super.key,
    this.value,
    this.label = 'Currency',
    this.hint = 'Select currency',
    this.currencies = const ['KES', 'USD', 'EUR', 'GBP'],
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.isRequired = true,
    this.autovalidateMode,
  });

  /// Currently selected currency code.
  final String? value;

  final String? label;
  final String? hint;

  /// Available currency codes.
  final List<String> currencies;

  final ValueChanged<String?>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool readOnly;
  final bool isRequired;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return AppDropdown<String>(
      value: value,
      label: label,
      hint: hint,
      prefixIcon: const Icon(Icons.payments_outlined),
      items: currencies
          .map(
            (code) => DropdownMenuItem<String>(
              value: code,
              child: Text(code),
            ),
          )
          .toList(),
      onChanged: readOnly || !enabled ? null : onChanged,
      validator: validator ??
          (isRequired
              ? (v) => AppValidators.requiredSelection(v, field: 'Currency')
              : null),
      enabled: enabled,
      readOnly: readOnly,
      autovalidateMode: autovalidateMode,
    );
  }
}
