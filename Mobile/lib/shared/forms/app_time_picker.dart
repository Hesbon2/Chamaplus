import 'package:flutter/material.dart';

import 'form_field_style.dart';
import 'validators.dart';

/// Time selection field that opens a Material time picker.
class AppTimePicker extends FormField<TimeOfDay> {
  /// Creates a time picker form field.
  AppTimePicker({
    super.key,
    super.initialValue,
    this.label = 'Time',
    this.hint = 'Select time',
    this.helperText,
    this.isEnabled = true,
    this.readOnly = false,
    this.isRequired = true,
    this.use24HourFormat = true,
    super.onSaved,
    FormFieldValidator<TimeOfDay>? validator,
    this.onChanged,
    AutovalidateMode? autovalidateMode,
  }) : super(
          enabled: isEnabled && !readOnly,
          validator: validator ??
              (isRequired
                  ? (v) =>
                      AppValidators.requiredTime(v, field: label ?? 'Time')
                  : null),
          autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
          builder: (field) {
            final state = field as _AppTimePickerState;
            return state.buildField();
          },
        );

  final String? label;
  final String? hint;
  final String? helperText;

  /// When false, the field ignores taps.
  final bool isEnabled;
  final bool readOnly;
  final bool isRequired;
  final bool use24HourFormat;
  final ValueChanged<TimeOfDay?>? onChanged;

  @override
  FormFieldState<TimeOfDay> createState() => _AppTimePickerState();
}

class _AppTimePickerState extends FormFieldState<TimeOfDay> {
  AppTimePicker get _widget => widget as AppTimePicker;

  Future<void> _pick() async {
    if (!_widget.isEnabled || _widget.readOnly) return;

    final picked = await showTimePicker(
      context: context,
      initialTime: value ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: _widget.use24HourFormat,
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;
    didChange(picked);
    _widget.onChanged?.call(picked);
  }

  String? get _display {
    if (value == null) return null;
    return value!.format(context);
  }

  Widget buildField() {
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
          prefixIcon: const Icon(Icons.schedule_outlined),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          enabled: _widget.isEnabled,
          readOnly: _widget.readOnly,
        ).copyWith(errorText: errorText),
        isEmpty: _display == null,
        child: Text(
          _display ?? '',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
