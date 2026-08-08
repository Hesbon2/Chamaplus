from django.contrib.auth import get_user_model
from rest_framework import serializers

from apps.core.utils.validators import normalize_kenyan_phone_number

User = get_user_model()


class KenyanPhoneField(serializers.CharField):
    def to_internal_value(self, data):
        value = super().to_internal_value(data)
        try:
            return normalize_kenyan_phone_number(value)
        except Exception as exc:
            raise serializers.ValidationError(str(exc)) from exc


class RegisterSerializer(serializers.ModelSerializer):
    phone_number = KenyanPhoneField()
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = (
            "phone_number",
            "email",
            "password",
            "password_confirm",
            "first_name",
            "last_name",
        )

    def validate(self, attrs):
        if attrs["password"] != attrs["password_confirm"]:
            raise serializers.ValidationError(
                {"password_confirm": "Passwords do not match."}
            )
        return attrs

    def validate_phone_number(self, value):
        if User.objects.filter(phone_number=value).exists():
            raise serializers.ValidationError(
                "A user with this phone number already exists."
            )
        return value

    def validate_email(self, value):
        if value and User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError("A user with this email already exists.")
        return value


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = (
            "id",
            "phone_number",
            "email",
            "first_name",
            "last_name",
            "is_staff",
            "date_joined",
            "last_login",
        )
        read_only_fields = fields


class ProfileUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ("email", "first_name", "last_name")

    def validate_email(self, value):
        user = self.context["request"].user
        if (
            value
            and User.objects.filter(email__iexact=value)
            .exclude(pk=user.pk)
            .exists()
        ):
            raise serializers.ValidationError("A user with this email already exists.")
        return value


class LoginSerializer(serializers.Serializer):
    phone_number = KenyanPhoneField()
    password = serializers.CharField(write_only=True)


class RefreshTokenSerializer(serializers.Serializer):
    refresh = serializers.CharField()


class LogoutSerializer(serializers.Serializer):
    refresh = serializers.CharField()


class ChangePasswordSerializer(serializers.Serializer):
    current_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True, min_length=8)
    new_password_confirm = serializers.CharField(write_only=True, min_length=8)

    def validate(self, attrs):
        if attrs["new_password"] != attrs["new_password_confirm"]:
            raise serializers.ValidationError(
                {"new_password_confirm": "New passwords do not match."}
            )
        return attrs


class ForgotPasswordSerializer(serializers.Serializer):
    phone_number = KenyanPhoneField()


class ResetPasswordSerializer(serializers.Serializer):
    phone_number = KenyanPhoneField()
    code = serializers.CharField(min_length=6, max_length=6)
    new_password = serializers.CharField(write_only=True, min_length=8)
    new_password_confirm = serializers.CharField(write_only=True, min_length=8)

    def validate_code(self, value):
        if not value.isdigit():
            raise serializers.ValidationError("Reset code must be 6 digits.")
        return value

    def validate(self, attrs):
        if attrs["new_password"] != attrs["new_password_confirm"]:
            raise serializers.ValidationError(
                {"new_password_confirm": "New passwords do not match."}
            )
        return attrs
