import secrets

from django.conf import settings
from django.db import models

from apps.chamas.constants import DEFAULT_CURRENCY
from apps.core.models import TimeStampedModel


def generate_invite_code():
    return secrets.token_hex(4).upper()


class Chama(TimeStampedModel):
    """Informal savings group."""

    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    location = models.CharField(max_length=200, blank=True)
    currency = models.CharField(max_length=3, default=DEFAULT_CURRENCY)
    invite_code = models.CharField(max_length=16, unique=True, default=generate_invite_code)
    is_active = models.BooleanField(default=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="created_chamas",
    )

    class Meta:
        db_table = "chamas"
        ordering = ["-created_at"]

    def __str__(self):
        return self.name

    def archive(self):
        self.is_active = False
        self.save(update_fields=["is_active", "updated_at"])
