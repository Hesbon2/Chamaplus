from django.conf import settings
from django.db import models

from apps.core.models import TimeStampedModel
from apps.loans.constants import VOTE_DECISION_CHOICES


class CommitteeVote(TimeStampedModel):
    """Committee member vote on a loan application."""

    loan_application = models.ForeignKey(
        "loans.LoanApplication",
        on_delete=models.CASCADE,
        related_name="votes",
    )
    committee_member = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="committee_votes",
    )
    decision = models.CharField(max_length=20, choices=VOTE_DECISION_CHOICES)
    comment = models.TextField(blank=True)

    class Meta:
        db_table = "committee_votes"
        ordering = ["-created_at"]
        constraints = [
            models.UniqueConstraint(
                fields=["loan_application", "committee_member"],
                name="unique_vote_per_committee_member",
            ),
        ]

    def __str__(self):
        return f"{self.committee_member} - {self.decision}"
