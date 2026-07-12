from django.db import models

from apps.core.models import TimeStampedModel


class Role(TimeStampedModel):
    """Static role catalog for ChamaPlus RBAC."""

    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=100, unique=True)
    description = models.TextField(blank=True)
    is_platform_role = models.BooleanField(
        default=False,
        help_text="True for platform-wide roles such as Administrator.",
    )

    class Meta:
        db_table = "roles"
        ordering = ["name"]

    def __str__(self):
        return self.name
