import pytest
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient

User = get_user_model()

REGISTER_URL = "/api/v1/auth/register/"
LOGIN_URL = "/api/v1/auth/login/"
REFRESH_URL = "/api/v1/auth/refresh/"
LOGOUT_URL = "/api/v1/auth/logout/"
ME_URL = "/api/v1/users/me/"
FORGOT_PASSWORD_URL = "/api/v1/auth/forgot-password/"
RESET_PASSWORD_URL = "/api/v1/auth/reset-password/"
CHANGE_PASSWORD_URL = "/api/v1/auth/change-password/"

VALID_USER = {
    "phone_number": "0712345678",
    "email": "test@example.com",
    "password": "SecurePass123",
    "password_confirm": "SecurePass123",
    "first_name": "Jane",
    "last_name": "Doe",
}


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def registered_user(db):
    return User.objects.create_user(
        phone_number="+254712345678",
        password="SecurePass123",
        email="test@example.com",
        first_name="Jane",
        last_name="Doe",
    )


@pytest.fixture
def auth_client(api_client, registered_user):
    response = api_client.post(
        LOGIN_URL,
        {
            "phone_number": "0712345678",
            "password": "SecurePass123",
        },
        format="json",
    )
    access = response.data["data"]["access"]
    api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {access}")
    return api_client
