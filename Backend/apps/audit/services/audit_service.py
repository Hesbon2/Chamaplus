from apps.audit.models import AuditLog


class AuditService:
    @staticmethod
    def log(
        actor,
        action,
        entity_type,
        entity_id=None,
        chama=None,
        changes=None,
        ip_address=None,
    ):
        return AuditLog.objects.create(
            actor=actor,
            chama=chama,
            action=action,
            entity_type=entity_type,
            entity_id=entity_id,
            changes=changes or {},
            ip_address=ip_address,
        )

    @staticmethod
    def list_chama_logs(chama, action=None, limit=100):
        queryset = AuditLog.objects.filter(chama=chama).select_related("actor")
        if action:
            queryset = queryset.filter(action=action)
        return queryset.order_by("-created_at")[:limit]

    @staticmethod
    def list_platform_logs(action=None, limit=100):
        queryset = AuditLog.objects.select_related("actor", "chama")
        if action:
            queryset = queryset.filter(action=action)
        return queryset.order_by("-created_at")[:limit]
