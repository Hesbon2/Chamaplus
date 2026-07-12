from django.db import transaction
from django.db.models import Q
from django.utils import timezone

from apps.chamas.models import Chama
from apps.core.exceptions import DomainError
from apps.memberships.constants import ACTIVE
from apps.memberships.models import Membership
from apps.roles.constants import CHAIRPERSON
from apps.roles.models import Role


class ChamaService:
    @staticmethod
    def create_chama(user, validated_data):
        with transaction.atomic():
            chama = Chama.objects.create(created_by=user, **validated_data)
            chairperson_role = Role.objects.get(slug=CHAIRPERSON)
            Membership.objects.create(
                user=user,
                chama=chama,
                role=chairperson_role,
                status=ACTIVE,
                joined_at=timezone.now(),
            )
            return chama

    @staticmethod
    def list_chamas_for_user(user, search=None, ordering="-created_at"):
        queryset = Chama.objects.filter(
            memberships__user=user,
            memberships__status=ACTIVE,
            is_active=True,
        ).distinct()

        if search:
            queryset = queryset.filter(
                Q(name__icontains=search)
                | Q(description__icontains=search)
                | Q(location__icontains=search)
            )

        allowed_ordering = {"created_at", "-created_at", "name", "-name"}
        if ordering not in allowed_ordering:
            raise DomainError("Invalid ordering field.")
        return queryset.order_by(ordering)

    @staticmethod
    def get_chama(chama_id):
        try:
            return Chama.objects.get(pk=chama_id, is_active=True)
        except Chama.DoesNotExist as exc:
            raise DomainError("Chama not found.", status_code=404) from exc

    @staticmethod
    def update_chama(chama, validated_data):
        for field, value in validated_data.items():
            setattr(chama, field, value)
        chama.save()
        return chama

    @staticmethod
    def archive_chama(chama):
        chama.archive()
        return chama
