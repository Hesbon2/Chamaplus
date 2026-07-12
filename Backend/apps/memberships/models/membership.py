from django.conf import settings
from django.db import models
from django.utils import timezone

from apps.core.models import TimeStampedModel
from apps.memberships.constants import ACTIVE, MEMBERSHIP_STATUSES


class Membership(TimeStampedModel):
    """Links a user to a Chama with a role and status."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="memberships",
    )
    chama = models.ForeignKey(
        "chamas.Chama",
        on_delete=models.CASCADE,
        related_name="memberships",
    )
    role = models.ForeignKey(
        "roles.Role",
        on_delete=models.PROTECT,
        related_name="memberships",
    )
    status = models.CharField(
        max_length=20,
        choices=MEMBERSHIP_STATUSES,
        default=ACTIVE,
    )
    joined_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = "memberships"
        ordering = ["-created_at"]
        constraints = [
            models.UniqueConstraint(
                fields=["user", "chama"],
                name="unique_user_chama_membership",
            )
        ]

    def __str__(self):
        return f"{self.user} @ {self.chama} ({self.role.slug})"

    def activate(self):
        self.status = ACTIVE
        self.joined_at = timezone.now()
        self.save(update_fields=["status", "joined_at", "updated_at"])
