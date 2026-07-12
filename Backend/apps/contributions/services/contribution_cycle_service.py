from django.db.models import Q

from apps.chamas.services.chama_service import ChamaService
from apps.contributions.models import ContributionCycle
from apps.core.exceptions import DomainError


class ContributionCycleService:
    @staticmethod
    def create_cycle(chama, validated_data):
        return ContributionCycle.objects.create(chama=chama, **validated_data)

    @staticmethod
    def list_cycles(chama, search=None, status=None, ordering="-start_date"):
        queryset = ContributionCycle.objects.filter(chama=chama)

        if status:
            queryset = queryset.filter(status=status)

        if search:
            queryset = queryset.filter(Q(name__icontains=search))

        allowed_ordering = {
            "start_date",
            "-start_date",
            "created_at",
            "-created_at",
            "name",
            "-name",
        }
        if ordering not in allowed_ordering:
            raise DomainError("Invalid ordering field.")
        return queryset.order_by(ordering)

    @staticmethod
    def get_cycle(chama, cycle_id):
        try:
            return ContributionCycle.objects.get(pk=cycle_id, chama=chama)
        except ContributionCycle.DoesNotExist as exc:
            raise DomainError("Contribution cycle not found.", status_code=404) from exc

    @staticmethod
    def update_cycle(cycle, validated_data):
        if cycle.is_closed:
            raise DomainError("Cannot update a closed contribution cycle.")

        for field, value in validated_data.items():
            setattr(cycle, field, value)
        cycle.save()
        return cycle

    @staticmethod
    def close_cycle(cycle):
        if cycle.is_closed:
            raise DomainError("Contribution cycle is already closed.")
        cycle.close()
        return cycle

    @staticmethod
    def delete_cycle(cycle):
        if cycle.is_closed:
            raise DomainError("Cannot delete a closed contribution cycle.")

        if cycle.contributions.exists():
            raise DomainError(
                "Cannot delete a contribution cycle that has recorded contributions."
            )

        cycle.delete()

    @staticmethod
    def get_chama(chama_id):
        return ChamaService.get_chama(chama_id)
