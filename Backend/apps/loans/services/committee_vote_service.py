from django.db import transaction

from apps.core.exceptions import DomainError
from apps.loans.constants import APPROVED, REJECTED, VOTABLE_STATUSES
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
            old_status = application.status
            LoanApplicationService.evaluate_voting(application)

        application.refresh_from_db()
        if application.status != old_status and application.status in (APPROVED, REJECTED):
            from apps.core.integration.decision_support import (
                dispatch_decision_support_event,
            )
            from apps.core.integration.events import EVENT_COMMITTEE_VOTE_COMPLETED

            dispatch_decision_support_event(
                EVENT_COMMITTEE_VOTE_COMPLETED,
                actor=voter,
                chama=application.chama,
                member=application.applicant,
                entity_type="loan_application",
                entity_id=application.id,
                changes={"status": application.status},
            )

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
