/// Kenyan phone number validation and normalization utilities.
class PhoneValidator {
  PhoneValidator._();

  static final RegExp _pattern = RegExp(r'^(?:\+?254|0)?([17]\d{8})$');

  /// Returns an error message when invalid, otherwise `null`.
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final normalized = value.trim().replaceAll(RegExp(r'\s'), '');
    if (!_pattern.hasMatch(normalized)) {
      return 'Enter a valid Kenyan phone number';
    }

    return null;
  }

  /// Normalizes input to E.164 format (`+254XXXXXXXXX`).
  static String normalize(String input) {
    final normalized = input.trim().replaceAll(RegExp(r'\s'), '');
    final match = _pattern.firstMatch(normalized);
    if (match == null) {
      throw FormatException('Invalid Kenyan phone number: $input');
    }
    return '+254${match.group(1)}';
  }
}

/// Password validation utilities.
class PasswordValidator {
  PasswordValidator._();

  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}
