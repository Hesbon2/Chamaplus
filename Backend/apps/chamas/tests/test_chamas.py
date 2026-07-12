import pytest

from apps.conftest import CHAMAS_URL
from apps.roles.models import Role


@pytest.mark.django_db
class TestChamaCreate:
    def test_create_chama_success(self, auth_client, roles):
        response = auth_client.post(
            CHAMAS_URL,
            {
                "name": "Test Chama",
                "description": "A test group",
                "location": "Nairobi",
            },
            format="json",
        )

        assert response.status_code == 201
        assert response.data["success"] is True
        assert response.data["data"]["name"] == "Test Chama"
        assert response.data["data"]["invite_code"]
        assert response.data["data"]["is_active"] is True

    def test_create_chama_requires_auth(self, api_client, roles):
        response = api_client.post(
            CHAMAS_URL,
            {"name": "Test Chama"},
            format="json",
        )
        assert response.status_code == 401


@pytest.mark.django_db
class TestChamaList:
    def test_list_user_chamas(self, auth_client, chama):
        response = auth_client.get(CHAMAS_URL)

        assert response.status_code == 200
        assert response.data["success"] is True
        assert len(response.data["data"]) == 1
        assert response.data["data"][0]["name"] == chama["name"]

    def test_list_excludes_other_users_chamas(self, auth_client, member_client, chama):
        response = member_client.get(CHAMAS_URL)
        assert response.status_code == 200
        assert len(response.data["data"]) == 0


@pytest.mark.django_db
class TestChamaDetail:
    def test_get_chama_detail(self, auth_client, chama):
        response = auth_client.get(f"{CHAMAS_URL}{chama['id']}/")

        assert response.status_code == 200
        assert response.data["data"]["id"] == chama["id"]

    def test_update_chama_as_chairperson(self, auth_client, chama):
        response = auth_client.patch(
            f"{CHAMAS_URL}{chama['id']}/",
            {"name": "Updated Chama Name"},
            format="json",
        )

        assert response.status_code == 200
        assert response.data["data"]["name"] == "Updated Chama Name"

    def test_update_chama_forbidden_for_non_chairperson(
        self, auth_client, member_client, chama, member_user, roles
    ):
        from apps.chamas.models import Chama
        from apps.memberships.constants import ACTIVE
        from apps.memberships.models import Membership
        from apps.roles.constants import MEMBER

        chama_obj = Chama.objects.get(pk=chama["id"])
        member_role = Role.objects.get(slug=MEMBER)
        Membership.objects.get_or_create(
            user=member_user,
            chama=chama_obj,
            defaults={"role": member_role, "status": ACTIVE},
        )

        response = member_client.patch(
            f"{CHAMAS_URL}{chama['id']}/",
            {"name": "Hacked Name"},
            format="json",
        )
        assert response.status_code == 403

    def test_archive_chama(self, auth_client, chama):
        response = auth_client.delete(f"{CHAMAS_URL}{chama['id']}/")

        assert response.status_code == 200
        assert response.data["data"]["is_active"] is False
