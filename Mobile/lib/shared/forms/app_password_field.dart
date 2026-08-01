import 'package:flutter/material.dart';

import 'app_text_field.dart';
import 'validators.dart';

/// Password field with visibility toggle, autofill, and shared validation.
class AppPasswordField extends StatefulWidget {
  /// Creates a password field.
  const AppPasswordField({
    super.key,
    this.controller,
    this.focusNode,
    this.label = 'Password',
    this.hint,
    this.helperText,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onSaved,
    this.enabled = true,
    this.readOnly = false,
    this.isRequired = true,
    this.minLength = 8,
    this.textInputAction = TextInputAction.done,
    this.autofillHints = const [AutofillHints.password],
    this.autovalidateMode,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helperText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final bool enabled;
  final bool readOnly;
  final bool isRequired;
  final int minLength;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final AutovalidateMode? autovalidateMode;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      label: widget.label,
      hint: widget.hint,
      helperText: widget.helperText,
      obscureText: _obscure,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        tooltip: _obscure ? 'Show password' : 'Hide password',
        onPressed: widget.enabled && !widget.readOnly
            ? () => setState(() => _obscure = !_obscure)
            : null,
        icon: Icon(
          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
      ),
      validator: widget.validator ??
          (value) {
            if (!widget.isRequired && (value == null || value.isEmpty)) {
              return null;
            }
            return AppValidators.minLength(
              value,
              length: widget.minLength,
              field: widget.label ?? 'Password',
            );
          },
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      onSaved: widget.onSaved,
      autovalidateMode: widget.autovalidateMode,
      inputFormatters: const [],
    );
  }
}
