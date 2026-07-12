from rest_framework import serializers

from apps.roles.models import Role


class RoleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Role
        fields = (
            "id",
            "name",
            "slug",
            "description",
            "is_platform_role",
            "created_at",
            "updated_at",
        )
        read_only_fields = fields
