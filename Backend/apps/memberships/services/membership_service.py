from decimal import Decimal

from django.contrib.auth import get_user_model
from django.db import transaction
from django.db.models import Count, DecimalField, OuterRef, Q, Subquery, Sum, Value
from django.db.models.functions import Coalesce
from django.utils import timezone

from apps.chamas.models import Chama
from apps.contributions.models import Contribution
from apps.core.exceptions import DomainError
from apps.loans.constants import DISBURSED
from apps.loans.models import LoanApplication
from apps.memberships.constants import ACTIVE, LEFT, PENDING, SUSPENDED
from apps.memberships.models import Membership
from apps.roles.constants import MEMBER
from apps.roles.models import Role

User = get_user_model()


class MembershipService:
    @staticmethod
    def _get_chama_role(slug):
        try:
            return Role.objects.get(slug=slug, is_platform_role=False)
        except Role.DoesNotExist as exc:
            raise DomainError("Invalid role.") from exc

    @staticmethod
    def get_membership(membership_id):
        try:
            return Membership.objects.select_related("user", "role", "chama").get(
                pk=membership_id
            )
        except Membership.DoesNotExist as exc:
            raise DomainError("Membership not found.", status_code=404) from exc

    @staticmethod
    def get_user_membership(user, chama):
        return Membership.objects.filter(user=user, chama=chama).first()

    @staticmethod
    def user_is_active_member(user, chama):
        return Membership.objects.filter(
            user=user, chama=chama, status=ACTIVE
        ).exists()

    @staticmethod
    def user_has_role(user, chama, role_slugs):
        return Membership.objects.filter(
            user=user,
            chama=chama,
            status=ACTIVE,
            role__slug__in=role_slugs,
        ).exists()

    @staticmethod
    def invite_member(chama, phone_number, role_slug=MEMBER):
        try:
            user = User.objects.get(phone_number=phone_number)
        except User.DoesNotExist as exc:
            raise DomainError(
                "User with this phone number is not registered."
            ) from exc

        existing = Membership.objects.filter(user=user, chama=chama).first()
        if existing:
            if existing.status == ACTIVE:
                raise DomainError("User is already an active member of this Chama.")
            if existing.status == PENDING:
                raise DomainError("User already has a pending invitation.")
            if existing.status == SUSPENDED:
                raise DomainError(
                    "User is suspended. Update status instead of re-inviting."
                )
            if existing.status == LEFT:
                role = MembershipService._get_chama_role(role_slug)
                existing.role = role
                existing.status = PENDING
                existing.joined_at = None
                existing.save(
                    update_fields=["role", "status", "joined_at", "updated_at"]
                )
                return existing

        role = MembershipService._get_chama_role(role_slug)
        return Membership.objects.create(
            user=user,
            chama=chama,
            role=role,
            status=PENDING,
        )

    @staticmethod
    def list_pending_invitations(user):
        """Pending memberships for the authenticated invitee only."""
        return (
            Membership.objects.filter(user=user, status=PENDING)
            .select_related("user", "role", "chama")
            .order_by("-created_at")
        )

    @staticmethod
    def accept_invitation(user, membership_id):
        membership = MembershipService.get_membership(membership_id)
        if membership.user_id != user.id:
            raise DomainError(
                "You can only accept your own invitations.",
                status_code=403,
            )
        if membership.status != PENDING:
            raise DomainError("Only pending invitations can be accepted.")
        membership.activate()
        return membership

    @staticmethod
    def decline_invitation(user, membership_id):
        """
        Decline a pending invitation.

        Maps to status ``left`` — there is no dedicated ``declined`` status.
        A chairperson/secretary may re-invite the same user afterward.
        """
        membership = MembershipService.get_membership(membership_id)
        if membership.user_id != user.id:
            raise DomainError(
                "You can only decline your own invitations.",
                status_code=403,
            )
        if membership.status != PENDING:
            raise DomainError("Only pending invitations can be declined.")
        membership.status = LEFT
        membership.save(update_fields=["status", "updated_at"])
        return membership

    @staticmethod
    def join_chama(user, invite_code):
        try:
            chama = Chama.objects.get(invite_code=invite_code.upper(), is_active=True)
        except Chama.DoesNotExist as exc:
            raise DomainError("Invalid invite code.") from exc

        existing = Membership.objects.filter(user=user, chama=chama).first()
        if existing:
            if existing.status == ACTIVE:
                raise DomainError("You are already a member of this Chama.")
            if existing.status == PENDING:
                existing.activate()
                return existing
            if existing.status == SUSPENDED:
                raise DomainError(
                    "Your membership is suspended. Contact the Chairperson."
                )
            if existing.status == LEFT:
                member_role = MembershipService._get_chama_role(MEMBER)
                existing.role = member_role
                existing.activate()
                return existing

        member_role = MembershipService._get_chama_role(MEMBER)
        membership = Membership.objects.create(
            user=user,
            chama=chama,
            role=member_role,
            status=ACTIVE,
            joined_at=timezone.now(),
        )
        return membership

    @staticmethod
    def list_members(chama, search=None, status=None, ordering="-created_at"):
        contrib_total_sq = (
            Contribution.objects.filter(
                member_id=OuterRef("user_id"),
                cycle__chama_id=chama.id,
            )
            .values("member_id")
            .annotate(total=Sum("amount"))
            .values("total")[:1]
        )
        contrib_count_sq = (
            Contribution.objects.filter(
                member_id=OuterRef("user_id"),
                cycle__chama_id=chama.id,
            )
            .values("member_id")
            .annotate(cnt=Count("id"))
            .values("cnt")[:1]
        )
        active_loans_sq = (
            LoanApplication.objects.filter(
                applicant_id=OuterRef("user_id"),
                chama_id=chama.id,
                status=DISBURSED,
            )
            .values("applicant_id")
            .annotate(cnt=Count("id"))
            .values("cnt")[:1]
        )
        outstanding_sq = (
            LoanApplication.objects.filter(
                applicant_id=OuterRef("user_id"),
                chama_id=chama.id,
                status=DISBURSED,
            )
            .values("applicant_id")
            .annotate(total=Sum("outstanding_balance"))
            .values("total")[:1]
        )

        decimal_field = DecimalField(max_digits=14, decimal_places=2)
        queryset = (
            Membership.objects.filter(chama=chama)
            .select_related("user", "role")
            .annotate(
                contributions_total=Coalesce(
                    Subquery(contrib_total_sq, output_field=decimal_field),
                    Value(Decimal("0.00"), output_field=decimal_field),
                ),
                contributions_count=Coalesce(
                    Subquery(contrib_count_sq),
                    Value(0),
                ),
                active_loans_count=Coalesce(
                    Subquery(active_loans_sq),
                    Value(0),
                ),
                outstanding_loans_balance=Coalesce(
                    Subquery(outstanding_sq, output_field=decimal_field),
                    Value(Decimal("0.00"), output_field=decimal_field),
                ),
            )
        )

        if status:
            queryset = queryset.filter(status=status)

        if search:
            queryset = queryset.filter(
                Q(user__first_name__icontains=search)
                | Q(user__last_name__icontains=search)
                | Q(user__phone_number__icontains=search)
            )

        allowed_ordering = {"created_at", "-created_at", "joined_at", "-joined_at"}
        if ordering not in allowed_ordering:
            raise DomainError("Invalid ordering field.")
        return queryset.order_by(ordering)

    @staticmethod
    def update_role(membership, role_slug):
        if membership.status != ACTIVE:
            raise DomainError("Can only update role for active memberships.")

        new_role = MembershipService._get_chama_role(role_slug)
        membership.role = new_role
        membership.save(update_fields=["role", "updated_at"])
        return membership

    @staticmethod
    def update_status(membership, status):
        if status == PENDING:
            raise DomainError("Cannot set status back to pending.")

        if status == ACTIVE and membership.status != ACTIVE:
            membership.activate()
            return membership

        membership.status = status
        membership.save(update_fields=["status", "updated_at"])
        return membership
