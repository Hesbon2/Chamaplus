from rest_framework import serializers

from apps.credit_scoring.models import CreditScore


class CreditScoreSerializer(serializers.ModelSerializer):
    member_id = serializers.UUIDField(read_only=True)

    class Meta:
        model = CreditScore
        fields = (
            "id",
            "member_id",
            "score",
            "risk_level",
            "breakdown",
            "weights",
            "calculated_at",
            "created_at",
        )
        read_only_fields = fields
