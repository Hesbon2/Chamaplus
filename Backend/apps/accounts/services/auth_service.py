import secrets
from datetime import timedelta

from django.conf import settings
from django.contrib.auth import authenticate, get_user_model
from django.contrib.auth.hashers import check_password, make_password
from django.utils import timezone
from rest_framework_simplejwt.serializers import TokenRefreshSerializer
from rest_framework_simplejwt.token_blacklist.models import (
    BlacklistedToken,
    OutstandingToken,
)
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import PasswordResetChallenge
from apps.core.exceptions import DomainError
from apps.notifications.channels.delivery import EmailChannel, SMSChannel

User = get_user_model()

_RESET_CODE_TTL_MINUTES = 15
_RESET_MAX_ATTEMPTS = 5
_GENERIC_RESET_MESSAGE = (
    "If an account exists for that phone number, a reset code has been sent."
)


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
        AuthService._blacklist_user_refresh_tokens(user)

    @staticmethod
    def request_password_reset(phone_number):
        """
        Start password reset for a phone number.

        Always returns the same public message to avoid account enumeration.
        When DEBUG is True, the plaintext code is included for local testing
        because SMS/email providers are not wired yet.
        """
        payload = {"message": _GENERIC_RESET_MESSAGE}
        user = User.objects.filter(phone_number=phone_number, is_active=True).first()
        if user is None:
            return payload

        code = f"{secrets.randbelow(1_000_000):06d}"
        PasswordResetChallenge.objects.filter(
            user=user, used_at__isnull=True
        ).update(used_at=timezone.now())

        PasswordResetChallenge.objects.create(
            user=user,
            code_hash=make_password(code),
            expires_at=timezone.now() + timedelta(minutes=_RESET_CODE_TTL_MINUTES),
        )

        title = "ChamaPlus password reset"
        body = (
            f"Your ChamaPlus password reset code is {code}. "
            f"It expires in {_RESET_CODE_TTL_MINUTES} minutes."
        )
        SMSChannel.send(
            user,
            title,
            body,
            "password_reset",
            metadata={"channel": "sms"},
        )
        if user.email:
            EmailChannel.send(
                user,
                title,
                body,
                "password_reset",
                metadata={"channel": "email"},
            )

        if settings.DEBUG:
            # SMS/email providers are stubs — expose code only in DEBUG.
            payload["debug_reset_code"] = code

        return payload

    @staticmethod
    def reset_password(phone_number, code, new_password):
        user = User.objects.filter(phone_number=phone_number, is_active=True).first()
        if user is None:
            raise DomainError("Invalid or expired reset code.")

        challenge = (
            PasswordResetChallenge.objects.filter(user=user, used_at__isnull=True)
            .order_by("-created_at")
            .first()
        )
        if challenge is None or challenge.is_expired:
            raise DomainError("Invalid or expired reset code.")

        if challenge.attempts >= _RESET_MAX_ATTEMPTS:
            raise DomainError("Too many invalid attempts. Request a new code.")

        if not check_password(code, challenge.code_hash):
            challenge.attempts += 1
            challenge.save(update_fields=["attempts"])
            raise DomainError("Invalid or expired reset code.")

        user.set_password(new_password)
        user.save(update_fields=["password"])
        challenge.used_at = timezone.now()
        challenge.save(update_fields=["used_at"])
        AuthService._blacklist_user_refresh_tokens(user)
        return user

    @staticmethod
    def _blacklist_user_refresh_tokens(user):
        try:
            for outstanding in OutstandingToken.objects.filter(user=user):
                BlacklistedToken.objects.get_or_create(token=outstanding)
        except Exception:
            # Blacklist tables may be unavailable in some test setups.
            pass
