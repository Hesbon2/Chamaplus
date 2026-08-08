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


@pytest.mark.django_db
class TestPendingInvitations:
    def test_list_pending_invitations_for_invitee(
        self, auth_client, member_client, chama, member_user, roles
    ):
        invite = auth_client.post(
            f"{CHAMAS_URL}{chama['id']}/invite/",
            {"phone_number": "0798765432", "role": "treasurer"},
            format="json",
        )
        assert invite.status_code == 201

        response = member_client.get(f"{MEMBERSHIPS_URL}pending/")
        assert response.status_code == 200
        assert response.data["success"] is True
        data = response.data["data"]
        assert len(data) == 1
        assert data[0]["status"] == "pending"
        assert data[0]["role"]["slug"] == "treasurer"
        assert data[0]["chama"]["id"] == str(chama["id"])
        assert data[0]["chama"]["name"] == chama["name"]

    def test_list_pending_excludes_other_users(
        self, auth_client, member_client, chama, roles
    ):
        auth_client.post(
            f"{CHAMAS_URL}{chama['id']}/invite/",
            {"phone_number": "0798765432"},
            format="json",
        )

        # Chairperson should not see the invitee's pending invitation.
        response = auth_client.get(f"{MEMBERSHIPS_URL}pending/")
        assert response.status_code == 200
        assert response.data["data"] == []

    def test_accept_invitation(
        self, auth_client, member_client, chama, member_user, roles
    ):
        invite = auth_client.post(
            f"{CHAMAS_URL}{chama['id']}/invite/",
            {"phone_number": "0798765432", "role": "secretary"},
            format="json",
        )
        membership_id = invite.data["data"]["id"]

        response = member_client.post(
            f"{MEMBERSHIPS_URL}{membership_id}/accept/",
            format="json",
        )
        assert response.status_code == 200
        assert response.data["data"]["status"] == "active"
        assert response.data["data"]["role"]["slug"] == "secretary"
        assert response.data["data"]["joined_at"] is not None

        pending = member_client.get(f"{MEMBERSHIPS_URL}pending/")
        assert pending.data["data"] == []

    def test_decline_invitation(
        self, auth_client, member_client, chama, member_user, roles
    ):
        invite = auth_client.post(
            f"{CHAMAS_URL}{chama['id']}/invite/",
            {"phone_number": "0798765432"},
            format="json",
        )
        membership_id = invite.data["data"]["id"]

        response = member_client.post(
            f"{MEMBERSHIPS_URL}{membership_id}/decline/",
            format="json",
        )
        assert response.status_code == 200
        assert response.data["data"]["status"] == "left"

        pending = member_client.get(f"{MEMBERSHIPS_URL}pending/")
        assert pending.data["data"] == []

    def test_accept_rejects_non_owner(
        self, auth_client, member_client, chama, member_user, roles
    ):
        invite = auth_client.post(
            f"{CHAMAS_URL}{chama['id']}/invite/",
            {"phone_number": "0798765432"},
            format="json",
        )
        membership_id = invite.data["data"]["id"]

        # Inviter (chair) cannot accept on behalf of invitee.
        response = auth_client.post(
            f"{MEMBERSHIPS_URL}{membership_id}/accept/",
            format="json",
        )
        assert response.status_code == 403
        assert response.data["success"] is False

    def test_reinvite_after_decline(
        self, auth_client, member_client, chama, member_user, roles
    ):
        invite = auth_client.post(
            f"{CHAMAS_URL}{chama['id']}/invite/",
            {"phone_number": "0798765432"},
            format="json",
        )
        membership_id = invite.data["data"]["id"]
        member_client.post(
            f"{MEMBERSHIPS_URL}{membership_id}/decline/",
            format="json",
        )

        again = auth_client.post(
            f"{CHAMAS_URL}{chama['id']}/invite/",
            {"phone_number": "0798765432", "role": "member"},
            format="json",
        )
        assert again.status_code == 201
        assert again.data["data"]["status"] == "pending"
