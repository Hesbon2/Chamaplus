import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'form_field_style.dart';
import 'validators.dart';

/// Date selection field that opens a Material date picker.
class AppDatePicker extends FormField<DateTime> {
  /// Creates a date picker form field.
  AppDatePicker({
    super.key,
    super.initialValue,
    this.label = 'Date',
    this.hint = 'Select date',
    this.helperText,
    this.firstDate,
    this.lastDate,
    this.dateFormat,
    this.isEnabled = true,
    this.readOnly = false,
    this.isRequired = true,
    super.onSaved,
    FormFieldValidator<DateTime>? validator,
    this.onChanged,
    AutovalidateMode? autovalidateMode,
  }) : super(
          enabled: isEnabled && !readOnly,
          validator: validator ??
              (isRequired
                  ? (v) =>
                      AppValidators.requiredDate(v, field: label ?? 'Date')
                  : null),
          autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
          builder: (field) {
            final state = field as _AppDatePickerState;
            return state.buildField();
          },
        );

  final String? label;
  final String? hint;
  final String? helperText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateFormat? dateFormat;

  /// When false, the field ignores taps.
  final bool isEnabled;
  final bool readOnly;
  final bool isRequired;
  final ValueChanged<DateTime?>? onChanged;

  @override
  FormFieldState<DateTime> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends FormFieldState<DateTime> {
  AppDatePicker get _widget => widget as AppDatePicker;

  Future<void> _pick() async {
    if (!_widget.isEnabled || _widget.readOnly) return;

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: _widget.firstDate ?? DateTime(now.year - 10),
      lastDate: _widget.lastDate ?? DateTime(now.year + 10),
    );

    if (picked == null) return;
    didChange(picked);
    _widget.onChanged?.call(picked);
  }

  Widget buildField() {
    final format = _widget.dateFormat ?? DateFormat('d MMM yyyy');
    final display = value == null ? null : format.format(value!);

    return InkWell(
      onTap: _widget.isEnabled && !_widget.readOnly ? _pick : null,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: appFormDecoration(
          context,
          label: _widget.label,
          hint: _widget.hint,
          helperText: _widget.helperText,
          errorText: errorText,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          enabled: _widget.isEnabled,
          readOnly: _widget.readOnly,
        ).copyWith(errorText: errorText),
        isEmpty: display == null,
        child: Text(
          display ?? '',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
