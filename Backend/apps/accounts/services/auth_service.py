from django.contrib.auth import authenticate, get_user_model
from rest_framework_simplejwt.serializers import TokenRefreshSerializer
from rest_framework_simplejwt.tokens import RefreshToken

from apps.core.exceptions import DomainError

User = get_user_model()


class AuthService:
    @staticmethod
    def register_user(validated_data):
        password = validated_data.pop("password")
        validated_data.pop("password_confirm")
        return User.objects.create_user(password=password, **validated_data)

    @staticmethod
    def login(phone_number, password):
        user = authenticate(username=phone_number, password=password)
        if user is None:
            raise DomainError("Invalid phone number or password.")
        if not user.is_active:
            raise DomainError("This account is inactive.")

        refresh = RefreshToken.for_user(user)
        return {
            "access": str(refresh.access_token),
            "refresh": str(refresh),
        }

    @staticmethod
    def refresh_token(refresh_token):
        serializer = TokenRefreshSerializer(data={"refresh": refresh_token})
        serializer.is_valid(raise_exception=True)
        return serializer.validated_data

    @staticmethod
    def logout(refresh_token):
        token = RefreshToken(refresh_token)
        token.blacklist()

    @staticmethod
    def update_profile(user, validated_data):
        for field, value in validated_data.items():
            setattr(user, field, value)
        user.save(update_fields=list(validated_data.keys()))
        return user

    @staticmethod
    def change_password(user, current_password, new_password):
        if not user.check_password(current_password):
            raise DomainError("Current password is incorrect.")
        user.set_password(new_password)
        user.save(update_fields=["password"])
