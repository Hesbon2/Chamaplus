from rest_framework.permissions import BasePermission

from apps.memberships.permissions import get_chama_from_kwargs
from apps.memberships.services.membership_service import MembershipService
from apps.roles.constants import CHAIRPERSON, TREASURER


class IsChamaTreasurerOrChairperson(BasePermission):
    message = "Only the Treasurer or Chairperson can access reports."

    def has_permission(self, request, view):
        chama = get_chama_from_kwargs(view)
        if chama is None:
            return False
        return MembershipService.user_has_role(
            request.user, chama, [TREASURER, CHAIRPERSON]
        )


class IsChamaChairpersonForAudit(BasePermission):
    message = "Only the Chairperson can view Chama audit logs."

    def has_permission(self, request, view):
        chama = get_chama_from_kwargs(view)
        if chama is None:
            return False
        return MembershipService.user_has_role(request.user, chama, [CHAIRPERSON])
