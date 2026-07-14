import 'package:flutter/material.dart';

/// Reusable, feature-agnostic form validators for ChamaPlus.
///
/// Each method returns an error message when validation fails, otherwise `null`.
class AppValidators {
  AppValidators._();

  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phonePattern = RegExp(r'^(?:\+?254|0)?([17]\d{8})$');

  /// Requires a non-empty trimmed value.
  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  /// Requires a minimum character length.
  static String? minLength(
    String? value, {
    required int length,
    String field = 'This field',
  }) {
    final requiredError = required(value, field: field);
    if (requiredError != null) return requiredError;
    if (value!.trim().length < length) {
      return '$field must be at least $length characters';
    }
    return null;
  }

  /// Requires a maximum character length.
  static String? maxLength(
    String? value, {
    required int length,
    String field = 'This field',
  }) {
    if (value == null || value.isEmpty) return null;
    if (value.trim().length > length) {
      return '$field must be at most $length characters';
    }
    return null;
  }

  /// Validates email format when a value is present.
  static String? email(String? value, {bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? 'Email is required' : null;
    }
    if (!_emailPattern.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates Kenyan mobile numbers (`07…`, `+254…`, etc.).
  static String? phone(String? value, {bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? 'Phone number is required' : null;
    }
    final normalized = value.trim().replaceAll(RegExp(r'\s'), '');
    if (!_phonePattern.hasMatch(normalized)) {
      return 'Enter a valid Kenyan phone number';
    }
    return null;
  }

  /// Normalizes a Kenyan phone number to E.164 (`+254XXXXXXXXX`).
  static String normalizePhone(String input) {
    final normalized = input.trim().replaceAll(RegExp(r'\s'), '');
    final match = _phonePattern.firstMatch(normalized);
    if (match == null) {
      throw FormatException('Invalid Kenyan phone number: $input');
    }
    return '+254${match.group(1)}';
  }

  /// Password with a minimum length of 8 by default.
  static String? password(
    String? value, {
    int minChars = 8,
    bool isRequired = true,
  }) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Password is required' : null;
    }
    if (value.length < minChars) {
      return 'Password must be at least $minChars characters';
    }
    return null;
  }

  /// Positive decimal amount (e.g. contributions, loan principal).
  static String? amount(
    String? value, {
    bool isRequired = true,
    double? min,
    double? max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? 'Amount is required' : null;
    }
    final parsed = double.tryParse(value.trim().replaceAll(',', ''));
    if (parsed == null) {
      return 'Enter a valid amount';
    }
    if (parsed <= 0) {
      return 'Amount must be greater than zero';
    }
    if (min != null && parsed < min) {
      return 'Amount must be at least $min';
    }
    if (max != null && parsed > max) {
      return 'Amount must be at most $max';
    }
    return null;
  }

  /// Ensures a dropdown / selectable value was chosen.
  static String? requiredSelection<T>(T? value, {String field = 'Selection'}) {
    if (value == null) {
      return '$field is required';
    }
    return null;
  }

  /// Ensures a date was selected.
  static String? requiredDate(DateTime? value, {String field = 'Date'}) {
    if (value == null) {
      return '$field is required';
    }
    return null;
  }

  /// Ensures a time was selected.
  static String? requiredTime(TimeOfDay? value, {String field = 'Time'}) {
    if (value == null) {
      return '$field is required';
    }
    return null;
  }

  /// Composes multiple validators; returns the first error.
  static FormFieldValidator<String> compose(
    List<FormFieldValidator<String>> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
