import pytest

from apps.conftest import CHAMAS_URL, MEMBERSHIPS_URL
from apps.roles.models import Role


@pytest.mark.django_db
class TestInviteMember:
    def test_invite_member_success(
        self, auth_client, chama, member_user, roles
    ):
        response = auth_client.post(
            f"{CHAMAS_URL}{chama['id']}/invite/",
            {"phone_number": "0798765432", "role": "member"},
            format="json",
        )

        assert response.status_code == 201
        assert response.data["success"] is True
        assert response.data["data"]["status"] == "pending"
        assert response.data["data"]["user"]["phone_number"] == "+254798765432"

    def test_invite_unregistered_phone_fails(self, auth_client, chama, roles):
        response = auth_client.post(
            f"{CHAMAS_URL}{chama['id']}/invite/",
            {"phone_number": "0700000001"},
            format="json",
        )

        assert response.status_code == 400
        assert response.data["success"] is False


@pytest.mark.django_db
class TestJoinChama:
    def test_join_with_invite_code(self, member_client, chama, roles):
        response = member_client.post(
            f"{CHAMAS_URL}join/",
            {"invite_code": chama["invite_code"]},
            format="json",
        )

        assert response.status_code == 200
        assert response.data["success"] is True
        assert response.data["data"]["status"] == "active"

    def test_join_pending_invitation_activates(
        self, auth_client, member_client, chama, member_user, roles
    ):
        auth_client.post(
            f"{CHAMAS_URL}{chama['id']}/invite/",
            {"phone_number": "0798765432"},
            format="json",
        )

        response = member_client.post(
            f"{CHAMAS_URL}join/",
            {"invite_code": chama["invite_code"]},
            format="json",
        )

        assert response.status_code == 200
        assert response.data["data"]["status"] == "active"

    def test_join_invalid_code_fails(self, member_client, roles):
        response = member_client.post(
            f"{CHAMAS_URL}join/",
            {"invite_code": "INVALID1"},
            format="json",
        )

        assert response.status_code == 400
        assert response.data["success"] is False


@pytest.mark.django_db
class TestMemberList:
    def test_list_members(self, auth_client, chama, roles):
        response = auth_client.get(f"{CHAMAS_URL}{chama['id']}/members/")

        assert response.status_code == 200
        assert response.data["success"] is True
        assert response.data["data"]["count"] >= 1
        assert len(response.data["data"]["results"]) >= 1


@pytest.mark.django_db
class TestMembershipUpdates:
    def test_update_member_role(
        self, auth_client, member_client, chama, member_user, roles
    ):
        from apps.chamas.models import Chama
        from apps.memberships.constants import ACTIVE
        from apps.memberships.models import Membership
        from apps.roles.constants import MEMBER

        chama_obj = Chama.objects.get(pk=chama["id"])
        membership, _ = Membership.objects.get_or_create(
            user=member_user,
            chama=chama_obj,
            defaults={
                "role": Role.objects.get(slug=MEMBER),
                "status": ACTIVE,
            },
        )

        response = auth_client.patch(
            f"{MEMBERSHIPS_URL}{membership.id}/role/",
            {"role": "treasurer"},
            format="json",
        )

        assert response.status_code == 200
        assert response.data["data"]["role"]["slug"] == "treasurer"

    def test_update_member_status(
        self, auth_client, member_client, chama, member_user, roles
    ):
        from apps.chamas.models import Chama
        from apps.memberships.constants import ACTIVE
        from apps.memberships.models import Membership
        from apps.roles.constants import MEMBER

        chama_obj = Chama.objects.get(pk=chama["id"])
        membership, _ = Membership.objects.get_or_create(
            user=member_user,
            chama=chama_obj,
            defaults={
                "role": Role.objects.get(slug=MEMBER),
                "status": ACTIVE,
            },
        )

        response = auth_client.patch(
            f"{MEMBERSHIPS_URL}{membership.id}/status/",
            {"status": "suspended"},
            format="json",
        )

        assert response.status_code == 200
        assert response.data["data"]["status"] == "suspended"
