from django.contrib.auth import get_user_model
from django.db import transaction
from django.db.models import Q
from django.utils import timezone

from apps.contributions.models import Contribution, ContributionCycle
from apps.core.exceptions import DomainError
from apps.memberships.services.membership_service import MembershipService

User = get_user_model()


class ContributionService:
    @staticmethod
    def record_contribution(chama, recorded_by, validated_data):
        cycle_id = validated_data["cycle_id"]
        member_id = validated_data["member_id"]

        try:
            cycle = ContributionCycle.objects.get(pk=cycle_id, chama=chama)
        except ContributionCycle.DoesNotExist as exc:
            raise DomainError(
                "Contribution cycle not found for this Chama.",
                status_code=404,
            ) from exc

        if cycle.is_closed:
            raise DomainError("Cannot record contributions to a closed cycle.")

        try:
            member = User.objects.get(pk=member_id)
        except User.DoesNotExist as exc:
            raise DomainError("Member not found.", status_code=404) from exc

        if not MembershipService.user_is_active_member(member, chama):
            raise DomainError(
                "Member must be an active member of this Chama.",
                status_code=400,
            )

        idempotency_key = validated_data.get("idempotency_key")
        if idempotency_key:
            existing = Contribution.objects.filter(idempotency_key=idempotency_key).first()
            if existing:
                raise DomainError(
                    "A contribution with this idempotency key already exists.",
                    status_code=409,
                )

        recorded_at = validated_data.get("recorded_at") or timezone.now()
        currency = validated_data.get("currency") or chama.currency

        with transaction.atomic():
            return Contribution.objects.create(
                cycle=cycle,
                member=member,
                amount=validated_data["amount"],
                currency=currency,
                payment_method=validated_data["payment_method"],
                reference=validated_data["reference"],
                recorded_by=recorded_by,
                recorded_at=recorded_at,
                idempotency_key=idempotency_key,
            )

    @staticmethod
    def list_contributions(
        chama,
        member_id=None,
        cycle_id=None,
        search=None,
        ordering="-recorded_at",
    ):
        queryset = (
            Contribution.objects.filter(cycle__chama=chama)
            .select_related("cycle", "member", "recorded_by")
        )

        if member_id:
            queryset = queryset.filter(member_id=member_id)

        if cycle_id:
            queryset = queryset.filter(cycle_id=cycle_id)

        if search:
            queryset = queryset.filter(
                Q(reference__icontains=search)
                | Q(member__first_name__icontains=search)
                | Q(member__last_name__icontains=search)
                | Q(member__phone_number__icontains=search)
            )

        allowed_ordering = {
            "recorded_at",
            "-recorded_at",
            "amount",
            "-amount",
            "created_at",
            "-created_at",
        }
        if ordering not in allowed_ordering:
            raise DomainError("Invalid ordering field.")
        return queryset.order_by(ordering)

    @staticmethod
    def get_contribution(chama, contribution_id):
        try:
            return Contribution.objects.select_related(
                "cycle", "member", "recorded_by"
            ).get(pk=contribution_id, cycle__chama=chama)
        except Contribution.DoesNotExist as exc:
            raise DomainError("Contribution not found.", status_code=404) from exc
