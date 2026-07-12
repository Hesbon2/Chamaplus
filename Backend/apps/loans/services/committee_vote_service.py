from django.db import transaction

from apps.core.exceptions import DomainError
from apps.loans.constants import VOTABLE_STATUSES
from apps.loans.models import CommitteeVote
from apps.loans.services.loan_application_service import LoanApplicationService
from apps.memberships.services.membership_service import MembershipService
from apps.roles.constants import CHAIRPERSON, COMMITTEE_MEMBER


class CommitteeVoteService:
    @staticmethod
    def cast_vote(application, voter, validated_data):
        if application.status not in VOTABLE_STATUSES:
            raise DomainError("Voting is closed for this loan application.")

        if not MembershipService.user_has_role(
            voter, application.chama, [COMMITTEE_MEMBER, CHAIRPERSON]
        ):
            raise DomainError(
                "Only committee members can vote on loan applications.",
                status_code=403,
            )

        if CommitteeVote.objects.filter(
            loan_application=application,
            committee_member=voter,
        ).exists():
            raise DomainError("You have already voted on this application.")

        with transaction.atomic():
            vote = CommitteeVote.objects.create(
                loan_application=application,
                committee_member=voter,
                decision=validated_data["decision"],
                comment=validated_data.get("comment", ""),
            )
            LoanApplicationService.evaluate_voting(application)

        return vote

    @staticmethod
    def list_votes(application, user):
        if not MembershipService.user_has_role(
            user, application.chama, [COMMITTEE_MEMBER, CHAIRPERSON, TREASURER]
        ):
            raise DomainError(
                "Only committee members can view votes.",
                status_code=403,
            )

        return CommitteeVote.objects.filter(
            loan_application=application
        ).select_related("committee_member")
