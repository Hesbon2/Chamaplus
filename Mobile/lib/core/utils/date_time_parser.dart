/// Parses API datetime strings, including Django's `+0300` offset format.
DateTime? parseApiDateTime(dynamic value) {
  if (value == null) return null;
  final raw = value.toString().trim();
  if (raw.isEmpty) return null;
  return DateTime.parse(normalizeApiDateTime(raw));
}

/// Normalizes Django/DRF offsets like `+0300` to ISO `+03:00` for [DateTime.parse].
String normalizeApiDateTime(String value) {
  final match = RegExp(r'([+-])(\d{2})(\d{2})$').firstMatch(value);
  if (match == null) return value;
  return value.replaceFirst(
    RegExp(r'([+-])(\d{2})(\d{2})$'),
    '${match.group(1)}${match.group(2)}:${match.group(3)}',
  );
}
