from django.contrib.auth import get_user_model
from rest_framework import serializers

from apps.accounts.serializers import KenyanPhoneField
from apps.memberships.constants import MEMBERSHIP_STATUSES
from apps.memberships.models import Membership
from apps.roles.models import Role

User = get_user_model()


class RoleSummarySerializer(serializers.ModelSerializer):
    class Meta:
        model = Role
        fields = ("id", "slug", "name")
        read_only_fields = fields


class UserSummarySerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ("id", "phone_number", "first_name", "last_name")
        read_only_fields = fields


class ChamaSummarySerializer(serializers.Serializer):
    """Minimal chama payload for invitation / membership context."""

    id = serializers.UUIDField(read_only=True)
    name = serializers.CharField(read_only=True)


class MembershipSerializer(serializers.ModelSerializer):
    user = UserSummarySerializer(read_only=True)
    role = RoleSummarySerializer(read_only=True)

    class Meta:
        model = Membership
        fields = (
            "id",
            "user",
            "role",
            "status",
            "joined_at",
            "created_at",
            "updated_at",
        )
        read_only_fields = fields


class PendingInvitationSerializer(serializers.ModelSerializer):
    """Pending membership owned by the authenticated user, with chama context."""

    user = UserSummarySerializer(read_only=True)
    role = RoleSummarySerializer(read_only=True)
    chama = ChamaSummarySerializer(read_only=True)

    class Meta:
        model = Membership
        fields = (
            "id",
            "user",
            "role",
            "status",
            "chama",
            "joined_at",
            "created_at",
            "updated_at",
        )
        read_only_fields = fields


class InviteMemberSerializer(serializers.Serializer):
    phone_number = KenyanPhoneField()
    role = serializers.SlugField(required=False, default="member")

    def validate_role(self, value):
        if value == "administrator":
            raise serializers.ValidationError(
                "Administrator role cannot be assigned to Chama members."
            )
        if not Role.objects.filter(slug=value, is_platform_role=False).exists():
            raise serializers.ValidationError("Invalid role.")
        return value


class JoinChamaSerializer(serializers.Serializer):
    invite_code = serializers.CharField(max_length=16)


class MembershipRoleUpdateSerializer(serializers.Serializer):
    role = serializers.SlugField()

    def validate_role(self, value):
        if value == "administrator":
            raise serializers.ValidationError(
                "Administrator role cannot be assigned to Chama members."
            )
        if not Role.objects.filter(slug=value, is_platform_role=False).exists():
            raise serializers.ValidationError("Invalid role.")
        return value


class MembershipStatusUpdateSerializer(serializers.Serializer):
    status = serializers.ChoiceField(choices=[s[0] for s in MEMBERSHIP_STATUSES])
