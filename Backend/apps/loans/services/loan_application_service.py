import math
from decimal import Decimal

from django.conf import settings
from django.db import transaction
from django.db.models import Q
from django.utils import timezone

from apps.chamas.services.chama_service import ChamaService
from apps.core.exceptions import DomainError
from apps.loans.constants import (
    APPROVED,
    CANCELLED,
    DISBURSED,
    DRAFT,
    PENDING,
    REJECTED,
    VOTABLE_STATUSES,
    VOTE_APPROVE,
    VOTE_REJECT,
)
from apps.loans.models import CommitteeVote, LoanApplication, LoanProduct
from apps.loans.services.eligibility_service import LoanEligibilityService
from apps.memberships.constants import ACTIVE
from apps.memberships.models import Membership
from apps.memberships.services.membership_service import MembershipService
from apps.roles.constants import CHAIRPERSON, COMMITTEE_MEMBER, TREASURER


class LoanApplicationService:
    @staticmethod
    def get_chama(chama_id):
        return ChamaService.get_chama(chama_id)

    @staticmethod
    def _get_product(chama, product_id):
        try:
            return LoanProduct.objects.get(pk=product_id, chama=chama, is_active=True)
        except LoanProduct.DoesNotExist as exc:
            raise DomainError("Loan product not found.", status_code=404) from exc

    @staticmethod
    def apply(applicant, chama, validated_data, submit=False):
        data = dict(validated_data)
        submit = data.pop("submit", submit)
        loan_product = LoanApplicationService._get_product(
            chama, data["loan_product_id"]
        )
        LoanEligibilityService.validate_eligibility(
            applicant=applicant,
            chama=chama,
            loan_product=loan_product,
            requested_amount=data["requested_amount"],
            requested_duration=data["requested_duration"],
        )

        status = PENDING if submit else DRAFT
        applied_at = timezone.now() if submit else None

        return LoanApplication.objects.create(
            applicant=applicant,
            chama=chama,
            loan_product=loan_product,
            requested_amount=data["requested_amount"],
            requested_duration=data["requested_duration"],
            purpose=data["purpose"],
            remarks=data.get("remarks", ""),
            status=status,
            applied_at=applied_at,
        )

    @staticmethod
    def submit(application, applicant):
        if application.applicant_id != applicant.id:
            raise DomainError("Only the applicant can submit this application.", status_code=403)

        if application.status != DRAFT:
            raise DomainError("Only draft applications can be submitted.")

        LoanEligibilityService.validate_eligibility(
            applicant=application.applicant,
            chama=application.chama,
            loan_product=application.loan_product,
            requested_amount=application.requested_amount,
            requested_duration=application.requested_duration,
        )

        application.status = PENDING
        application.applied_at = timezone.now()
        application.save(update_fields=["status", "applied_at", "updated_at"])
        return application

    @staticmethod
    def update_application(application, applicant, validated_data):
        if application.applicant_id != applicant.id:
            raise DomainError("Only the applicant can update this application.", status_code=403)

        if application.status != DRAFT:
            raise DomainError("Only draft applications can be updated.")

        if "loan_product_id" in validated_data:
            application.loan_product = LoanApplicationService._get_product(
                application.chama, validated_data.pop("loan_product_id")
            )

        for field, value in validated_data.items():
            setattr(application, field, value)

        LoanEligibilityService.validate_eligibility(
            applicant=application.applicant,
            chama=application.chama,
            loan_product=application.loan_product,
            requested_amount=application.requested_amount,
            requested_duration=application.requested_duration,
        )
        application.save()
        return application

    @staticmethod
    def cancel(application, user):
        if application.applicant_id != user.id:
            raise DomainError("Only the applicant can cancel this application.", status_code=403)

        if application.status not in (DRAFT, PENDING):
            raise DomainError("Only draft or pending applications can be cancelled.")

        application.status = CANCELLED
        application.save(update_fields=["status", "updated_at"])
        return application

    @staticmethod
    def approve(application, approver, approved_amount=None, remarks=""):
        if application.status not in VOTABLE_STATUSES:
            raise DomainError("Only pending applications can be approved.")

        if not MembershipService.user_has_role(
            approver, application.chama, [COMMITTEE_MEMBER, CHAIRPERSON]
        ):
            raise DomainError(
                "Only committee members can approve loan applications.",
                status_code=403,
            )

        amount = approved_amount or application.requested_amount
        if amount > application.loan_product.maximum_amount:
            raise DomainError("Approved amount exceeds product maximum.")

        application.status = APPROVED
        application.approved_amount = amount
        application.approved_at = timezone.now()
        application.approved_by = approver
        if remarks:
            application.remarks = remarks
        application.save()
        return application

    @staticmethod
    def reject(application, reviewer, remarks=""):
        if application.status not in VOTABLE_STATUSES:
            raise DomainError("Only pending applications can be rejected.")

        if not MembershipService.user_has_role(
            reviewer, application.chama, [COMMITTEE_MEMBER, CHAIRPERSON]
        ):
            raise DomainError(
                "Only committee members can reject loan applications.",
                status_code=403,
            )

        application.status = REJECTED
        application.rejected_at = timezone.now()
        if remarks:
            application.remarks = remarks
        application.save()
        return application

    @staticmethod
    def disburse(application, treasurer):
        if application.status != APPROVED:
            raise DomainError("Only approved applications can be disbursed.")

        if not MembershipService.user_has_role(
            treasurer, application.chama, [TREASURER]
        ):
            raise DomainError(
                "Only the Treasurer can disburse loans.",
                status_code=403,
            )

        with transaction.atomic():
            application.status = DISBURSED
            application.outstanding_balance = application.approved_amount
            application.save(
                update_fields=["status", "outstanding_balance", "updated_at"]
            )
        return application

    @staticmethod
    def list_applications(
        chama,
        user,
        status=None,
        member_id=None,
        search=None,
        ordering="-created_at",
    ):
        queryset = LoanApplication.objects.filter(chama=chama).select_related(
            "applicant", "loan_product", "approved_by"
        )

        can_view_all = MembershipService.user_has_role(
            user,
            chama,
            [CHAIRPERSON, TREASURER, COMMITTEE_MEMBER],
        )
        if not can_view_all:
            queryset = queryset.filter(applicant=user)

        if status:
            queryset = queryset.filter(status=status)

        if member_id and can_view_all:
            queryset = queryset.filter(applicant_id=member_id)

        if search:
            queryset = queryset.filter(
                Q(purpose__icontains=search)
                | Q(applicant__first_name__icontains=search)
                | Q(applicant__last_name__icontains=search)
                | Q(applicant__phone_number__icontains=search)
            )

        allowed_ordering = {"created_at", "-created_at", "applied_at", "-applied_at"}
        if ordering not in allowed_ordering:
            raise DomainError("Invalid ordering field.")
        return queryset.order_by(ordering)

    @staticmethod
    def get_application(chama, application_id, user):
        try:
            application = LoanApplication.objects.select_related(
                "applicant", "loan_product", "approved_by"
            ).get(pk=application_id, chama=chama)
        except LoanApplication.DoesNotExist as exc:
            raise DomainError("Loan application not found.", status_code=404) from exc

        can_view_all = MembershipService.user_has_role(
            user,
            chama,
            [CHAIRPERSON, TREASURER, COMMITTEE_MEMBER],
        )
        if not can_view_all and application.applicant_id != user.id:
            raise DomainError(
                "You do not have permission to view this application.",
                status_code=403,
            )
        return application

    @staticmethod
    def _committee_member_count(chama):
        return Membership.objects.filter(
            chama=chama,
            status=ACTIVE,
            role__slug=COMMITTEE_MEMBER,
        ).count()

    @staticmethod
    def evaluate_voting(application):
        if application.status not in VOTABLE_STATUSES:
            return application

        votes = CommitteeVote.objects.filter(loan_application=application)
        approve_count = votes.filter(decision=VOTE_APPROVE).count()
        reject_count = votes.filter(decision=VOTE_REJECT).count()
        total_decisive = approve_count + reject_count

        if total_decisive == 0:
            return application

        committee_size = LoanApplicationService._committee_member_count(application.chama)
        required_votes = max(
            1,
            math.ceil(committee_size * settings.LOAN_VOTE_APPROVAL_THRESHOLD),
        ) if committee_size > 0 else 1

        approval_ratio = approve_count / total_decisive
        rejection_ratio = reject_count / total_decisive
        threshold = settings.LOAN_VOTE_APPROVAL_THRESHOLD

        with transaction.atomic():
            application = LoanApplication.objects.select_for_update().get(
                pk=application.pk
            )
            if application.status not in VOTABLE_STATUSES:
                return application

            if approve_count >= required_votes and approval_ratio >= threshold:
                application.status = APPROVED
                application.approved_amount = application.requested_amount
                application.approved_at = timezone.now()
                application.save(
                    update_fields=[
                        "status",
                        "approved_amount",
                        "approved_at",
                        "updated_at",
                    ]
                )
            elif reject_count >= required_votes and rejection_ratio >= threshold:
                application.status = REJECTED
                application.rejected_at = timezone.now()
                application.save(
                    update_fields=["status", "rejected_at", "updated_at"]
                )

        return application

    @staticmethod
    def is_voting_open(application):
        return application.status in VOTABLE_STATUSES

    @staticmethod
    def mark_repaid(application):
        application.status = REPAID
        application.outstanding_balance = Decimal("0.00")
        application.save(
            update_fields=["status", "outstanding_balance", "updated_at"]
        )
        return application
