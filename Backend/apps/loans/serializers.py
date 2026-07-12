from decimal import Decimal

from rest_framework import serializers

from apps.contributions.constants import PAYMENT_METHOD_CHOICES
from apps.loans.constants import APPLICATION_STATUS_CHOICES, VOTE_DECISION_CHOICES
from apps.loans.models import (
    CommitteeVote,
    LoanApplication,
    LoanProduct,
    LoanRepayment,
)


class LoanProductSerializer(serializers.ModelSerializer):
    chama_id = serializers.UUIDField(read_only=True)

    class Meta:
        model = LoanProduct
        fields = (
            "id",
            "chama_id",
            "name",
            "description",
            "interest_rate",
            "minimum_amount",
            "maximum_amount",
            "maximum_duration",
            "grace_period_days",
            "processing_fee",
            "is_active",
            "created_at",
            "updated_at",
        )
        read_only_fields = ("id", "chama_id", "created_at", "updated_at")


class LoanProductCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = LoanProduct
        fields = (
            "name",
            "description",
            "interest_rate",
            "minimum_amount",
            "maximum_amount",
            "maximum_duration",
            "grace_period_days",
            "processing_fee",
            "is_active",
        )

    def validate_name(self, value):
        if not value.strip():
            raise serializers.ValidationError("Product name cannot be empty.")
        return value.strip()

    def validate(self, attrs):
        min_amount = attrs.get("minimum_amount")
        max_amount = attrs.get("maximum_amount")
        if min_amount is not None and max_amount is not None and min_amount > max_amount:
            raise serializers.ValidationError(
                {"maximum_amount": "Maximum amount must be greater than minimum amount."}
            )
        return attrs


class LoanProductUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = LoanProduct
        fields = (
            "name",
            "description",
            "interest_rate",
            "minimum_amount",
            "maximum_amount",
            "maximum_duration",
            "grace_period_days",
            "processing_fee",
            "is_active",
        )

    def validate(self, attrs):
        instance = self.instance
        min_amount = attrs.get("minimum_amount", instance.minimum_amount if instance else None)
        max_amount = attrs.get("maximum_amount", instance.maximum_amount if instance else None)
        if min_amount is not None and max_amount is not None and min_amount > max_amount:
            raise serializers.ValidationError(
                {"maximum_amount": "Maximum amount must be greater than minimum amount."}
            )
        return attrs


class LoanApplicationSerializer(serializers.ModelSerializer):
    applicant_id = serializers.UUIDField(read_only=True)
    chama_id = serializers.UUIDField(read_only=True)
    loan_product_id = serializers.UUIDField(read_only=True)
    approved_by = serializers.UUIDField(source="approved_by_id", read_only=True, allow_null=True)

    class Meta:
        model = LoanApplication
        fields = (
            "id",
            "applicant_id",
            "chama_id",
            "loan_product_id",
            "requested_amount",
            "requested_duration",
            "purpose",
            "status",
            "applied_at",
            "approved_at",
            "rejected_at",
            "approved_by",
            "approved_amount",
            "outstanding_balance",
            "remarks",
            "created_at",
            "updated_at",
        )
        read_only_fields = fields


class LoanApplicationCreateSerializer(serializers.Serializer):
    loan_product_id = serializers.UUIDField()
    requested_amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    requested_duration = serializers.IntegerField(min_value=1)
    purpose = serializers.CharField(max_length=500)
    remarks = serializers.CharField(required=False, allow_blank=True, default="")
    submit = serializers.BooleanField(required=False, default=False)

    def validate_requested_amount(self, value):
        if value <= Decimal("0"):
            raise serializers.ValidationError("Requested amount must be greater than zero.")
        return value

    def validate_purpose(self, value):
        if not value.strip():
            raise serializers.ValidationError("Purpose cannot be empty.")
        return value.strip()


class LoanApplicationUpdateSerializer(serializers.Serializer):
    loan_product_id = serializers.UUIDField(required=False)
    requested_amount = serializers.DecimalField(
        max_digits=12, decimal_places=2, required=False
    )
    requested_duration = serializers.IntegerField(min_value=1, required=False)
    purpose = serializers.CharField(max_length=500, required=False)
    remarks = serializers.CharField(required=False, allow_blank=True)


class LoanApplicationApproveSerializer(serializers.Serializer):
    approved_amount = serializers.DecimalField(
        max_digits=12, decimal_places=2, required=False
    )
    remarks = serializers.CharField(required=False, allow_blank=True, default="")


class LoanApplicationRejectSerializer(serializers.Serializer):
    remarks = serializers.CharField(required=False, allow_blank=True, default="")


class CommitteeVoteSerializer(serializers.ModelSerializer):
    loan_application_id = serializers.UUIDField(read_only=True)
    voter_id = serializers.UUIDField(source="committee_member_id", read_only=True)

    class Meta:
        model = CommitteeVote
        fields = (
            "id",
            "loan_application_id",
            "voter_id",
            "decision",
            "comment",
            "created_at",
        )
        read_only_fields = fields


class CommitteeVoteCreateSerializer(serializers.Serializer):
    decision = serializers.ChoiceField(
        choices=[choice[0] for choice in VOTE_DECISION_CHOICES]
    )
    comment = serializers.CharField(required=False, allow_blank=True, default="")


class LoanRepaymentSerializer(serializers.ModelSerializer):
    loan_application_id = serializers.UUIDField(read_only=True)
    recorded_by = serializers.UUIDField(source="recorded_by_id", read_only=True)

    class Meta:
        model = LoanRepayment
        fields = (
            "id",
            "loan_application_id",
            "amount",
            "currency",
            "payment_method",
            "reference",
            "payment_date",
            "recorded_by",
            "created_at",
        )
        read_only_fields = fields


class LoanRepaymentCreateSerializer(serializers.Serializer):
    amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    payment_method = serializers.ChoiceField(
        choices=[choice[0] for choice in PAYMENT_METHOD_CHOICES]
    )
    reference = serializers.CharField(max_length=100)
    payment_date = serializers.DateTimeField(required=False)

    def validate_amount(self, value):
        if value <= Decimal("0"):
            raise serializers.ValidationError("Amount must be greater than zero.")
        return value

    def validate_reference(self, value):
        if not value.strip():
            raise serializers.ValidationError("Reference cannot be empty.")
        return value.strip()
