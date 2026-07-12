import re

from django.core.exceptions import ValidationError

KENYAN_PHONE_PATTERN = re.compile(r"^(?:\+?254|0)?([17]\d{8})$")


def normalize_kenyan_phone_number(value: str) -> str:
    """Normalize a Kenyan phone number to E.164 (+254XXXXXXXXX)."""
    if not value:
        raise ValidationError("Phone number is required.")

    cleaned = re.sub(r"[\s\-()]", "", value.strip())
    match = KENYAN_PHONE_PATTERN.match(cleaned)
    if not match:
        raise ValidationError(
            "Enter a valid Kenyan phone number (e.g. 0712345678 or +254712345678)."
        )
    return f"+254{match.group(1)}"


def validate_kenyan_phone_number(value: str) -> str:
    """Django field validator for Kenyan phone numbers."""
    return normalize_kenyan_phone_number(value)
