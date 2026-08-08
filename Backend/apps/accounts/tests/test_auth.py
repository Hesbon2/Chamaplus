import pytest
from django.contrib.auth import get_user_model

from apps.accounts.tests.conftest import (
    CHANGE_PASSWORD_URL,
    FORGOT_PASSWORD_URL,
    LOGIN_URL,
    LOGOUT_URL,
    ME_URL,
    REFRESH_URL,
    REGISTER_URL,
    RESET_PASSWORD_URL,
    VALID_USER,
)
from apps.core.utils.validators import normalize_kenyan_phone_number

User = get_user_model()


@pytest.mark.django_db
class TestKenyanPhoneValidation:
    def test_normalize_local_format(self):
        assert normalize_kenyan_phone_number("0712345678") == "+254712345678"

    def test_normalize_international_format(self):
        assert normalize_kenyan_phone_number("+254712345678") == "+254712345678"

    def test_normalize_without_plus(self):
        assert normalize_kenyan_phone_number("254712345678") == "+254712345678"

    def test_reject_invalid_number(self):
        with pytest.raises(Exception):
            normalize_kenyan_phone_number("0812345678")


@pytest.mark.django_db
class TestRegister:
    def test_register_success(self, api_client):
        response = api_client.post(REGISTER_URL, VALID_USER, format="json")

        assert response.status_code == 201
        assert response.data["success"] is True
        assert response.data["data"]["phone_number"] == "+254712345678"
        assert User.objects.filter(phone_number="+254712345678").exists()

    def test_register_duplicate_phone(self, api_client, registered_user):
        response = api_client.post(REGISTER_URL, VALID_USER, format="json")

        assert response.status_code == 400
        assert response.data["success"] is False

    def test_register_password_mismatch(self, api_client):
        payload = {**VALID_USER, "password_confirm": "DifferentPass1"}
        response = api_client.post(REGISTER_URL, payload, format="json")

        assert response.status_code == 400
        assert response.data["success"] is False


@pytest.mark.django_db
class TestLogin:
    def test_login_success(self, api_client, registered_user):
        response = api_client.post(
            LOGIN_URL,
            {"phone_number": "0712345678", "password": "SecurePass123"},
            format="json",
        )

        assert response.status_code == 200
        assert response.data["success"] is True
        assert "access" in response.data["data"]
        assert "refresh" in response.data["data"]

    def test_login_invalid_password(self, api_client, registered_user):
        response = api_client.post(
            LOGIN_URL,
            {"phone_number": "0712345678", "password": "WrongPass123"},
            format="json",
        )

        assert response.status_code == 400
        assert response.data["success"] is False


@pytest.mark.django_db
class TestRefreshToken:
    def test_refresh_success(self, api_client, registered_user):
        login_response = api_client.post(
            LOGIN_URL,
            {"phone_number": "0712345678", "password": "SecurePass123"},
            format="json",
        )
        refresh = login_response.data["data"]["refresh"]

        response = api_client.post(REFRESH_URL, {"refresh": refresh}, format="json")

        assert response.status_code == 200
        assert response.data["success"] is True
        assert "access" in response.data["data"]


@pytest.mark.django_db
class TestLogout:
    def test_logout_success(self, auth_client, registered_user):
        login_response = auth_client.post(
            LOGIN_URL,
            {"phone_number": "0712345678", "password": "SecurePass123"},
            format="json",
        )
        refresh = login_response.data["data"]["refresh"]

        response = auth_client.post(LOGOUT_URL, {"refresh": refresh}, format="json")

        assert response.status_code == 200
        assert response.data["success"] is True


@pytest.mark.django_db
class TestProfile:
    def test_get_profile(self, auth_client, registered_user):
        response = auth_client.get(ME_URL)

        assert response.status_code == 200
        assert response.data["success"] is True
        assert response.data["data"]["phone_number"] == "+254712345678"

    def test_update_profile(self, auth_client, registered_user):
        response = auth_client.patch(
            ME_URL,
            {"first_name": "Janet", "email": "janet@example.com"},
            format="json",
        )

        assert response.status_code == 200
        assert response.data["success"] is True
        assert response.data["data"]["first_name"] == "Janet"
        assert response.data["data"]["email"] == "janet@example.com"

    def test_profile_requires_auth(self, api_client):
        response = api_client.get(ME_URL)

        assert response.status_code == 401
        assert response.data["success"] is False


@pytest.mark.django_db
class TestChangePassword:
    def test_change_password_success(self, auth_client, registered_user):
        response = auth_client.post(
            CHANGE_PASSWORD_URL,
            {
                "current_password": "SecurePass123",
                "new_password": "NewSecurePass1",
                "new_password_confirm": "NewSecurePass1",
            },
            format="json",
        )

        assert response.status_code == 200
        assert response.data["success"] is True
        registered_user.refresh_from_db()
        assert registered_user.check_password("NewSecurePass1")

    def test_change_password_wrong_current(self, auth_client):
        response = auth_client.post(
            CHANGE_PASSWORD_URL,
            {
                "current_password": "WrongPass123",
                "new_password": "NewSecurePass1",
                "new_password_confirm": "NewSecurePass1",
            },
            format="json",
        )

        assert response.status_code == 400
        assert response.data["success"] is False


@pytest.mark.django_db
class TestPasswordReset:
    def test_forgot_password_anti_enumeration(self, api_client, registered_user):
        known = api_client.post(
            FORGOT_PASSWORD_URL,
            {"phone_number": "0712345678"},
            format="json",
        )
        unknown = api_client.post(
            FORGOT_PASSWORD_URL,
            {"phone_number": "0799999999"},
            format="json",
        )

        assert known.status_code == 200
        assert unknown.status_code == 200
        assert known.data["message"] == unknown.data["message"]
        assert "account exists" in known.data["message"].lower()

    def test_reset_password_success(self, api_client, registered_user, settings):
        settings.DEBUG = True
        request = api_client.post(
            FORGOT_PASSWORD_URL,
            {"phone_number": "0712345678"},
            format="json",
        )
        code = request.data["data"]["debug_reset_code"]

        response = api_client.post(
            RESET_PASSWORD_URL,
            {
                "phone_number": "0712345678",
                "code": code,
                "new_password": "BrandNewPass1",
                "new_password_confirm": "BrandNewPass1",
            },
            format="json",
        )
        assert response.status_code == 200
        registered_user.refresh_from_db()
        assert registered_user.check_password("BrandNewPass1")

        login = api_client.post(
            LOGIN_URL,
            {"phone_number": "0712345678", "password": "BrandNewPass1"},
            format="json",
        )
        assert login.status_code == 200

    def test_reset_password_invalid_code(self, api_client, registered_user, settings):
        settings.DEBUG = True
        api_client.post(
            FORGOT_PASSWORD_URL,
            {"phone_number": "0712345678"},
            format="json",
        )
        response = api_client.post(
            RESET_PASSWORD_URL,
            {
                "phone_number": "0712345678",
                "code": "000000",
                "new_password": "BrandNewPass1",
                "new_password_confirm": "BrandNewPass1",
            },
            format="json",
        )
        assert response.status_code == 400
        assert response.data["success"] is False
