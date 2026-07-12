DRAFT = "draft"
PENDING = "pending"
APPROVED = "approved"
REJECTED = "rejected"
CANCELLED = "cancelled"
DISBURSED = "disbursed"
REPAID = "repaid"

APPLICATION_STATUS_CHOICES = (
    (DRAFT, "Draft"),
    (PENDING, "Pending"),
    (APPROVED, "Approved"),
    (REJECTED, "Rejected"),
    (CANCELLED, "Cancelled"),
    (DISBURSED, "Disbursed"),
    (REPAID, "Repaid"),
)

OPEN_APPLICATION_STATUSES = (DRAFT, PENDING, APPROVED)
ACTIVE_LOAN_STATUSES = (DISBURSED,)
VOTABLE_STATUSES = (PENDING,)
CLOSED_VOTING_STATUSES = (APPROVED, REJECTED, CANCELLED, DISBURSED, REPAID)

VOTE_APPROVE = "approve"
VOTE_REJECT = "reject"
VOTE_ABSTAIN = "abstain"

VOTE_DECISION_CHOICES = (
    (VOTE_APPROVE, "Approve"),
    (VOTE_REJECT, "Reject"),
    (VOTE_ABSTAIN, "Abstain"),
)
