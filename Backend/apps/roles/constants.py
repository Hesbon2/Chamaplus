CHAIRPERSON = "chairperson"
TREASURER = "treasurer"
SECRETARY = "secretary"
COMMITTEE_MEMBER = "committee_member"
MEMBER = "member"
ADMINISTRATOR = "administrator"

DEFAULT_ROLES = (
    {
        "name": "Chairperson",
        "slug": CHAIRPERSON,
        "description": "Leads the Chama and oversees group operations.",
        "is_platform_role": False,
    },
    {
        "name": "Treasurer",
        "slug": TREASURER,
        "description": "Manages contributions, disbursements, and financial records.",
        "is_platform_role": False,
    },
    {
        "name": "Secretary",
        "slug": SECRETARY,
        "description": "Maintains meeting records and group documentation.",
        "is_platform_role": False,
    },
    {
        "name": "Committee Member",
        "slug": COMMITTEE_MEMBER,
        "description": "Participates in committee decisions including loan voting.",
        "is_platform_role": False,
    },
    {
        "name": "Member",
        "slug": MEMBER,
        "description": "Regular Chama member.",
        "is_platform_role": False,
    },
    {
        "name": "Administrator",
        "slug": ADMINISTRATOR,
        "description": "Platform administrator with system-wide access.",
        "is_platform_role": True,
    },
)
