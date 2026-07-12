from rest_framework.permissions import BasePermission

from apps.memberships.permissions import get_chama_from_kwargs
from apps.memberships.services.membership_service import MembershipService
from apps.roles.constants import CHAIRPERSON, COMMITTEE_MEMBER, TREASURER


class IsChamaCommitteeMember(BasePermission):
    message = "Only committee members can perform this action."

    def has_permission(self, request, view):
        chama = get_chama_from_kwargs(view)
        if chama is None:
            return False
        return MembershipService.user_has_role(
            request.user, chama, [COMMITTEE_MEMBER, CHAIRPERSON]
        )


class IsChamaTreasurer(BasePermission):
    message = "Only the Treasurer can perform this action."

    def has_permission(self, request, view):
        chama = get_chama_from_kwargs(view)
        if chama is None:
            return False
        return MembershipService.user_has_role(request.user, chama, [TREASURER])


class IsChamaChairpersonOrTreasurer(BasePermission):
    message = "Only the Chairperson or Treasurer can perform this action."

    def has_permission(self, request, view):
        chama = get_chama_from_kwargs(view)
        if chama is None:
            return False
        return MembershipService.user_has_role(
            request.user, chama, [CHAIRPERSON, TREASURER]
        )
