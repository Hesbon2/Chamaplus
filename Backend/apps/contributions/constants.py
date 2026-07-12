WEEKLY = "weekly"
MONTHLY = "monthly"
QUARTERLY = "quarterly"
ANNUALLY = "annually"

FREQUENCY_CHOICES = (
    (WEEKLY, "Weekly"),
    (MONTHLY, "Monthly"),
    (QUARTERLY, "Quarterly"),
    (ANNUALLY, "Annually"),
)

OPEN = "open"
CLOSED = "closed"

STATUS_CHOICES = (
    (OPEN, "Open"),
    (CLOSED, "Closed"),
)

WEEKLY_DUE_DAY_MIN = 1
WEEKLY_DUE_DAY_MAX = 7
MONTHLY_DUE_DAY_MIN = 1
MONTHLY_DUE_DAY_MAX = 31

CASH = "cash"
MPESA = "mpesa"
BANK = "bank"

PAYMENT_METHOD_CHOICES = (
    (CASH, "Cash"),
    (MPESA, "M-Pesa"),
    (BANK, "Bank"),
)
