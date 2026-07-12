from rest_framework.permissions import BasePermission

from apps.memberships.permissions import get_chama_from_kwargs
from apps.memberships.services.membership_service import MembershipService
from apps.roles.constants import CHAIRPERSON, SECRETARY


class IsChamaSecretaryOrChairperson(BasePermission):
    message = "Only the Secretary or Chairperson can perform this action."

    def has_permission(self, request, view):
        chama = get_chama_from_kwargs(view)
        if chama is None:
            return False
        return MembershipService.user_has_role(
            request.user, chama, [SECRETARY, CHAIRPERSON]
        )


class IsChamaSecretary(BasePermission):
    message = "Only the Secretary can perform this action."

    def has_permission(self, request, view):
        chama = get_chama_from_kwargs(view)
        if chama is None:
            return False
        return MembershipService.user_has_role(request.user, chama, [SECRETARY])
