from rest_framework.permissions import BasePermission

from apps.memberships.models import Membership
from apps.roles.constants import ADMINISTRATOR


class IsPlatformAdministrator(BasePermission):
    message = "Only platform administrators can access this resource."

    def has_permission(self, request, view):
        return (
            request.user.is_superuser
            or Membership.objects.filter(
                user=request.user,
                role__slug=ADMINISTRATOR,
                role__is_platform_role=True,
            ).exists()
        )
