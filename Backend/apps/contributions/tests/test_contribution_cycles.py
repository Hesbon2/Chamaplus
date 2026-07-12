import pytest

from apps.conftest import CHAMAS_URL
from apps.roles.models import Role


def cycles_url(chama_id):
    return f"{CHAMAS_URL}{chama_id}/contribution-cycles/"


def cycle_detail_url(chama_id, cycle_id):
    return f"{cycles_url(chama_id)}{cycle_id}/"


def cycle_close_url(chama_id, cycle_id):
    return f"{cycle_detail_url(chama_id, cycle_id)}close/"


CYCLE_PAYLOAD = {
    "name": "July 2026 Cycle",
    "frequency": "monthly",
    "contribution_amount": "5000.00",
    "start_date": "2026-07-01",
    "end_date": "2026-07-31",
    "due_day": 15,
    "penalty_amount": "200.00",
}


@pytest.mark.django_db
class TestContributionCycleCreate:
    def test_create_cycle_as_chairperson(self, auth_client, chama):
        response = auth_client.post(
            cycles_url(chama["id"]),
            CYCLE_PAYLOAD,
            format="json",
        )

        assert response.status_code == 201
        assert response.data["success"] is True
        assert response.data["data"]["name"] == "July 2026 Cycle"
        assert response.data["data"]["frequency"] == "monthly"
        assert response.data["data"]["contribution_amount"] == "5000.00"
        assert response.data["data"]["status"] == "open"

    def test_create_cycle_as_treasurer(self, treasurer_client, chama):
        response = treasurer_client.post(
            cycles_url(chama["id"]),
            CYCLE_PAYLOAD,
            format="json",
        )

        assert response.status_code == 201
        assert response.data["data"]["status"] == "open"

    def test_create_cycle_forbidden_for_member(self, member_client, chama):
        response = member_client.post(
            cycles_url(chama["id"]),
            CYCLE_PAYLOAD,
            format="json",
        )

        assert response.status_code == 403

    def test_create_cycle_invalid_due_day(self, auth_client, chama):
        payload = {**CYCLE_PAYLOAD, "due_day": 32}
        response = auth_client.post(
            cycles_url(chama["id"]),
            payload,
            format="json",
        )

        assert response.status_code == 400
        assert response.data["success"] is False

    def test_create_weekly_cycle_valid_due_day(self, auth_client, chama):
        payload = {
            **CYCLE_PAYLOAD,
            "name": "Weekly Savings",
            "frequency": "weekly",
            "due_day": 5,
            "start_date": "2026-07-01",
            "end_date": "2026-07-31",
        }
        response = auth_client.post(
            cycles_url(chama["id"]),
            payload,
            format="json",
        )

        assert response.status_code == 201
        assert response.data["data"]["frequency"] == "weekly"
        assert response.data["data"]["due_day"] == 5


@pytest.mark.django_db
class TestContributionCycleList:
    def test_list_cycles_as_member(
        self, auth_client, member_client, chama, member_user, roles
    ):
        from apps.chamas.models import Chama
        from apps.memberships.constants import ACTIVE
        from apps.memberships.models import Membership
        from apps.roles.constants import MEMBER

        auth_client.post(cycles_url(chama["id"]), CYCLE_PAYLOAD, format="json")

        chama_obj = Chama.objects.get(pk=chama["id"])
        member_role = Role.objects.get(slug=MEMBER)
        Membership.objects.get_or_create(
            user=member_user,
            chama=chama_obj,
            defaults={"role": member_role, "status": ACTIVE},
        )

        response = member_client.get(cycles_url(chama["id"]))

        assert response.status_code == 200
        assert response.data["success"] is True
        assert len(response.data["data"]) == 1

    def test_list_cycles_requires_membership(self, member_client, chama):
        response = member_client.get(cycles_url(chama["id"]))
        assert response.status_code == 403


@pytest.mark.django_db
class TestContributionCycleDetail:
    def test_get_cycle_detail(self, auth_client, chama):
        create_response = auth_client.post(
            cycles_url(chama["id"]),
            CYCLE_PAYLOAD,
            format="json",
        )
        cycle_id = create_response.data["data"]["id"]

        response = auth_client.get(cycle_detail_url(chama["id"], cycle_id))

        assert response.status_code == 200
        assert response.data["data"]["id"] == cycle_id

    def test_update_cycle_as_treasurer(self, treasurer_client, chama):
        create_response = treasurer_client.post(
            cycles_url(chama["id"]),
            CYCLE_PAYLOAD,
            format="json",
        )
        cycle_id = create_response.data["data"]["id"]

        response = treasurer_client.patch(
            cycle_detail_url(chama["id"], cycle_id),
            {"name": "Updated Cycle Name"},
            format="json",
        )

        assert response.status_code == 200
        assert response.data["data"]["name"] == "Updated Cycle Name"

    def test_update_cycle_forbidden_for_chairperson(self, auth_client, chama):
        create_response = auth_client.post(
            cycles_url(chama["id"]),
            CYCLE_PAYLOAD,
            format="json",
        )
        cycle_id = create_response.data["data"]["id"]

        response = auth_client.patch(
            cycle_detail_url(chama["id"], cycle_id),
            {"name": "Chair Update"},
            format="json",
        )

        assert response.status_code == 403

    def test_delete_open_cycle(self, treasurer_client, chama):
        create_response = treasurer_client.post(
            cycles_url(chama["id"]),
            CYCLE_PAYLOAD,
            format="json",
        )
        cycle_id = create_response.data["data"]["id"]

        response = treasurer_client.delete(cycle_detail_url(chama["id"], cycle_id))

        assert response.status_code == 200
        assert response.data["success"] is True


@pytest.mark.django_db
class TestContributionCycleClose:
    def test_close_cycle(self, treasurer_client, chama):
        create_response = treasurer_client.post(
            cycles_url(chama["id"]),
            CYCLE_PAYLOAD,
            format="json",
        )
        cycle_id = create_response.data["data"]["id"]

        response = treasurer_client.post(cycle_close_url(chama["id"], cycle_id))

        assert response.status_code == 200
        assert response.data["data"]["status"] == "closed"

    def test_cannot_update_closed_cycle(self, treasurer_client, chama):
        create_response = treasurer_client.post(
            cycles_url(chama["id"]),
            CYCLE_PAYLOAD,
            format="json",
        )
        cycle_id = create_response.data["data"]["id"]
        treasurer_client.post(cycle_close_url(chama["id"], cycle_id))

        response = treasurer_client.patch(
            cycle_detail_url(chama["id"], cycle_id),
            {"name": "Should Fail"},
            format="json",
        )

        assert response.status_code == 400
        assert response.data["success"] is False

    def test_cannot_close_already_closed_cycle(self, treasurer_client, chama):
        create_response = treasurer_client.post(
            cycles_url(chama["id"]),
            CYCLE_PAYLOAD,
            format="json",
        )
        cycle_id = create_response.data["data"]["id"]
        treasurer_client.post(cycle_close_url(chama["id"], cycle_id))

        response = treasurer_client.post(cycle_close_url(chama["id"], cycle_id))

        assert response.status_code == 400
        assert response.data["success"] is False
