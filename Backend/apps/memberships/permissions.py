from rest_framework.permissions import BasePermission

from apps.chamas.models import Chama
from apps.memberships.services.membership_service import MembershipService
from apps.roles.constants import CHAIRPERSON, SECRETARY


def get_chama_from_kwargs(view):
    chama_id = view.kwargs.get("chama_id") or view.kwargs.get("pk")
    if not chama_id:
        return None
    try:
        return Chama.objects.get(pk=chama_id, is_active=True)
    except Chama.DoesNotExist:
        return None


class IsChamaMember(BasePermission):
    message = "You must be an active member of this Chama."

    def has_permission(self, request, view):
        chama = get_chama_from_kwargs(view)
        if chama is None:
            return False
        return MembershipService.user_is_active_member(request.user, chama)


class IsChamaChairperson(BasePermission):
    message = "Only the Chairperson can perform this action."

    def has_permission(self, request, view):
        chama = get_chama_from_kwargs(view)
        if chama is None:
            return False
        return MembershipService.user_has_role(
            request.user, chama, [CHAIRPERSON]
        )


class IsChamaOfficial(BasePermission):
    message = "Only the Chairperson or Secretary can perform this action."

    def has_permission(self, request, view):
        chama = get_chama_from_kwargs(view)
        if chama is None:
            return False
        return MembershipService.user_has_role(
            request.user, chama, [CHAIRPERSON, SECRETARY]
        )


class IsMembershipChairperson(BasePermission):
    message = "Only the Chairperson can perform this action."

    def has_permission(self, request, view):
        from apps.memberships.models import Membership

        membership_id = view.kwargs.get("pk")
        try:
            membership = Membership.objects.select_related("chama").get(
                pk=membership_id
            )
        except Membership.DoesNotExist:
            return False
        return MembershipService.user_has_role(
            request.user, membership.chama, [CHAIRPERSON]
        )
