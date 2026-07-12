from decimal import Decimal

from rest_framework import serializers

from apps.contributions.constants import (
    ANNUALLY,
    MONTHLY,
    MONTHLY_DUE_DAY_MAX,
    MONTHLY_DUE_DAY_MIN,
    PAYMENT_METHOD_CHOICES,
    QUARTERLY,
    WEEKLY,
    WEEKLY_DUE_DAY_MAX,
    WEEKLY_DUE_DAY_MIN,
)
from apps.contributions.models import Contribution, ContributionCycle


def validate_due_day_for_frequency(frequency, due_day):
    if frequency == WEEKLY:
        if not WEEKLY_DUE_DAY_MIN <= due_day <= WEEKLY_DUE_DAY_MAX:
            raise serializers.ValidationError(
                "Due day for weekly cycles must be between 1 (Monday) and 7 (Sunday)."
            )
    elif frequency in (MONTHLY, QUARTERLY, ANNUALLY):
        if not MONTHLY_DUE_DAY_MIN <= due_day <= MONTHLY_DUE_DAY_MAX:
            raise serializers.ValidationError(
                "Due day must be between 1 and 31 for this frequency."
            )


def validate_date_range(start_date, end_date):
    if start_date and end_date and end_date < start_date:
        raise serializers.ValidationError(
            {"end_date": "End date must be on or after start date."}
        )


class ContributionCycleSerializer(serializers.ModelSerializer):
    class Meta:
        model = ContributionCycle
        fields = (
            "id",
            "chama_id",
            "name",
            "frequency",
            "contribution_amount",
            "start_date",
            "end_date",
            "due_day",
            "penalty_amount",
            "status",
            "created_at",
            "updated_at",
        )
        read_only_fields = (
            "id",
            "chama_id",
            "status",
            "created_at",
            "updated_at",
        )


class ContributionCycleCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = ContributionCycle
        fields = (
            "name",
            "frequency",
            "contribution_amount",
            "start_date",
            "end_date",
            "due_day",
            "penalty_amount",
        )

    def validate_name(self, value):
        if not value.strip():
            raise serializers.ValidationError("Cycle name cannot be empty.")
        return value.strip()

    def validate_contribution_amount(self, value):
        if value <= Decimal("0"):
            raise serializers.ValidationError(
                "Contribution amount must be greater than zero."
            )
        return value

    def validate_penalty_amount(self, value):
        if value < Decimal("0"):
            raise serializers.ValidationError("Penalty amount cannot be negative.")
        return value

    def validate(self, attrs):
        frequency = attrs.get("frequency")
        due_day = attrs.get("due_day")
        if frequency is not None and due_day is not None:
            validate_due_day_for_frequency(frequency, due_day)
        validate_date_range(attrs.get("start_date"), attrs.get("end_date"))
        return attrs


class ContributionCycleUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = ContributionCycle
        fields = (
            "name",
            "frequency",
            "contribution_amount",
            "start_date",
            "end_date",
            "due_day",
            "penalty_amount",
        )

    def validate_name(self, value):
        if value is not None and not value.strip():
            raise serializers.ValidationError("Cycle name cannot be empty.")
        return value.strip() if value else value

    def validate_contribution_amount(self, value):
        if value is not None and value <= Decimal("0"):
            raise serializers.ValidationError(
                "Contribution amount must be greater than zero."
            )
        return value

    def validate_penalty_amount(self, value):
        if value is not None and value < Decimal("0"):
            raise serializers.ValidationError("Penalty amount cannot be negative.")
        return value

    def validate(self, attrs):
        instance = self.instance
        frequency = attrs.get("frequency", instance.frequency if instance else None)
        due_day = attrs.get("due_day", instance.due_day if instance else None)
        start_date = attrs.get(
            "start_date", instance.start_date if instance else None
        )
        end_date = attrs.get("end_date", instance.end_date if instance else None)

        if frequency is not None and due_day is not None:
            validate_due_day_for_frequency(frequency, due_day)
        validate_date_range(start_date, end_date)
        return attrs


class ContributionSerializer(serializers.ModelSerializer):
    member_id = serializers.UUIDField(read_only=True)
    cycle_id = serializers.UUIDField(read_only=True)
    recorded_by = serializers.UUIDField(source="recorded_by_id", read_only=True)

    class Meta:
        model = Contribution
        fields = (
            "id",
            "member_id",
            "cycle_id",
            "amount",
            "currency",
            "payment_method",
            "reference",
            "recorded_by",
            "recorded_at",
            "created_at",
        )
        read_only_fields = fields


class ContributionCreateSerializer(serializers.Serializer):
    cycle_id = serializers.UUIDField()
    member_id = serializers.UUIDField()
    amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    payment_method = serializers.ChoiceField(
        choices=[choice[0] for choice in PAYMENT_METHOD_CHOICES]
    )
    reference = serializers.CharField(max_length=100)
    recorded_at = serializers.DateTimeField(required=False)
    idempotency_key = serializers.CharField(
        max_length=64, required=False, allow_blank=True
    )

    def validate_amount(self, value):
        if value <= Decimal("0"):
            raise serializers.ValidationError("Amount must be greater than zero.")
        return value

    def validate_reference(self, value):
        if not value.strip():
            raise serializers.ValidationError("Reference cannot be empty.")
        return value.strip()

    def validate_idempotency_key(self, value):
        if value is not None and not value.strip():
            return None
        return value.strip() if value else None
