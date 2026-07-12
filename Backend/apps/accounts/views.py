from drf_spectacular.utils import extend_schema
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.exceptions import TokenError

from apps.accounts.serializers import (
    ChangePasswordSerializer,
    LoginSerializer,
    LogoutSerializer,
    ProfileUpdateSerializer,
    RefreshTokenSerializer,
    RegisterSerializer,
    UserSerializer,
)
from apps.accounts.services.auth_service import AuthService
from apps.core.exceptions import DomainError
from apps.core.responses import EnvelopeAPIView, success_response


class RegisterView(EnvelopeAPIView):
    permission_classes = [AllowAny]

    @extend_schema(
        tags=["Authentication"],
        summary="Register a new user with phone number",
        request=RegisterSerializer,
        responses={201: UserSerializer},
    )
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = AuthService.register_user(serializer.validated_data)
        return success_response(
            data=UserSerializer(user).data,
            message="Registration successful.",
            status_code=status.HTTP_201_CREATED,
        )


class LoginView(EnvelopeAPIView):
    permission_classes = [AllowAny]

    @extend_schema(
        tags=["Authentication"],
        summary="Login with phone number and password",
        request=LoginSerializer,
    )
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        tokens = AuthService.login(
            phone_number=serializer.validated_data["phone_number"],
            password=serializer.validated_data["password"],
        )
        return success_response(
            data=tokens,
            message="Login successful.",
        )


class RefreshTokenView(EnvelopeAPIView):
    permission_classes = [AllowAny]

    @extend_schema(
        tags=["Authentication"],
        summary="Refresh JWT access token",
        request=RefreshTokenSerializer,
    )
    def post(self, request):
        serializer = RefreshTokenSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        tokens = AuthService.refresh_token(serializer.validated_data["refresh"])
        return success_response(
            data=tokens,
            message="Token refreshed successfully.",
        )


class LogoutView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        tags=["Authentication"],
        summary="Logout and blacklist refresh token",
        request=LogoutSerializer,
    )
    def post(self, request):
        serializer = LogoutSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            AuthService.logout(serializer.validated_data["refresh"])
        except TokenError as exc:
            raise DomainError("Invalid or expired refresh token.") from exc
        return success_response(
            data=None,
            message="Logout successful.",
        )


class MeView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        tags=["Users"],
        summary="Get current authenticated user profile",
        responses={200: UserSerializer},
    )
    def get(self, request):
        return success_response(
            data=UserSerializer(request.user).data,
            message="Profile retrieved successfully.",
        )

    @extend_schema(
        tags=["Users"],
        summary="Update current user profile",
        request=ProfileUpdateSerializer,
        responses={200: UserSerializer},
    )
    def patch(self, request):
        serializer = ProfileUpdateSerializer(
            request.user,
            data=request.data,
            partial=True,
            context={"request": request},
        )
        serializer.is_valid(raise_exception=True)
        user = AuthService.update_profile(request.user, serializer.validated_data)
        return success_response(
            data=UserSerializer(user).data,
            message="Profile updated successfully.",
        )


class ChangePasswordView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        tags=["Authentication"],
        summary="Change password for authenticated user",
        request=ChangePasswordSerializer,
    )
    def post(self, request):
        serializer = ChangePasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        AuthService.change_password(
            user=request.user,
            current_password=serializer.validated_data["current_password"],
            new_password=serializer.validated_data["new_password"],
        )
        return success_response(
            data=None,
            message="Password changed successfully.",
        )
