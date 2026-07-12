from rest_framework import serializers

from apps.audit.models import AuditLog


class AuditLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = AuditLog
        fields = (
            "id",
            "actor_id",
            "action",
            "entity_type",
            "entity_id",
            "changes",
            "ip_address",
            "created_at",
        )
        read_only_fields = fields
