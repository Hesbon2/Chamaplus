import pytest

from apps.conftest import CHAMAS_URL
from apps.contributions.tests.test_contribution_cycles import (
    CYCLE_PAYLOAD,
    cycle_close_url,
    cycle_detail_url,
    cycles_url,
)
from apps.roles.models import Role


def contributions_url(chama_id):
    return f"{CHAMAS_URL}{chama_id}/contributions/"


def contribution_detail_url(chama_id, contribution_id):
    return f"{contributions_url(chama_id)}{contribution_id}/"


@pytest.fixture
def contribution_cycle(treasurer_client, chama):
    response = treasurer_client.post(
        cycles_url(chama["id"]),
        CYCLE_PAYLOAD,
        format="json",
    )
    return response.data["data"]


@pytest.fixture
def active_member_in_chama(chama, member_user, roles):
    from apps.chamas.models import Chama
    from apps.memberships.constants import ACTIVE
    from apps.memberships.models import Membership
    from apps.roles.constants import MEMBER

    chama_obj = Chama.objects.get(pk=chama["id"])
    member_role = Role.objects.get(slug=MEMBER)
    membership, _ = Membership.objects.get_or_create(
        user=member_user,
        chama=chama_obj,
        defaults={"role": member_role, "status": ACTIVE},
    )
    if membership.status != ACTIVE:
        membership.activate()
    return member_user


def contribution_payload(cycle_id, member_id):
    return {
        "cycle_id": cycle_id,
        "member_id": member_id,
        "amount": "5000.00",
        "payment_method": "cash",
        "reference": "CASH-001",
    }


@pytest.mark.django_db
class TestRecordContribution:
    def test_record_contribution_as_treasurer(
        self, treasurer_client, chama, contribution_cycle, active_member_in_chama
    ):
        response = treasurer_client.post(
            contributions_url(chama["id"]),
            contribution_payload(
                contribution_cycle["id"], str(active_member_in_chama.id)
            ),
            format="json",
        )

        assert response.status_code == 201
        assert response.data["success"] is True
        assert response.data["data"]["amount"] == "5000.00"
        assert response.data["data"]["payment_method"] == "cash"
        assert response.data["data"]["reference"] == "CASH-001"
        assert response.data["data"]["currency"] == "KES"
        assert response.data["data"]["member_id"] == str(active_member_in_chama.id)
        assert response.data["data"]["cycle_id"] == contribution_cycle["id"]
        assert response.data["data"]["recorded_by"]

    def test_record_contribution_forbidden_for_member(
        self, member_client, chama, contribution_cycle, active_member_in_chama
    ):
        response = member_client.post(
            contributions_url(chama["id"]),
            contribution_payload(
                contribution_cycle["id"], str(active_member_in_chama.id)
            ),
            format="json",
        )

        assert response.status_code == 403

    def test_record_contribution_forbidden_for_chairperson(
        self, auth_client, chama, contribution_cycle, active_member_in_chama
    ):
        response = auth_client.post(
            contributions_url(chama["id"]),
            contribution_payload(
                contribution_cycle["id"], str(active_member_in_chama.id)
            ),
            format="json",
        )

        assert response.status_code == 403

    def test_record_contribution_non_member_fails(
        self, treasurer_client, chama, contribution_cycle, member_user
    ):
        response = treasurer_client.post(
            contributions_url(chama["id"]),
            contribution_payload(contribution_cycle["id"], str(member_user.id)),
            format="json",
        )

        assert response.status_code == 400
        assert response.data["success"] is False

    def test_record_contribution_closed_cycle_fails(
        self, treasurer_client, chama, contribution_cycle, active_member_in_chama
    ):
        treasurer_client.post(
            cycle_close_url(chama["id"], contribution_cycle["id"])
        )

        response = treasurer_client.post(
            contributions_url(chama["id"]),
            contribution_payload(
                contribution_cycle["id"], str(active_member_in_chama.id)
            ),
            format="json",
        )

        assert response.status_code == 400
        assert response.data["success"] is False

    def test_record_contribution_idempotency_key(
        self, treasurer_client, chama, contribution_cycle, active_member_in_chama
    ):
        payload = contribution_payload(
            contribution_cycle["id"], str(active_member_in_chama.id)
        )
        payload["idempotency_key"] = "mpesa-tx-12345"

        first = treasurer_client.post(
            contributions_url(chama["id"]), payload, format="json"
        )
        second = treasurer_client.post(
            contributions_url(chama["id"]), payload, format="json"
        )

        assert first.status_code == 201
        assert second.status_code == 409
        assert second.data["success"] is False


@pytest.mark.django_db
class TestListContributions:
    def test_list_contributions_as_member(
        self,
        treasurer_client,
        member_client,
        chama,
        contribution_cycle,
        active_member_in_chama,
    ):
        from apps.chamas.models import Chama
        from apps.memberships.constants import ACTIVE
        from apps.memberships.models import Membership
        from apps.roles.constants import MEMBER

        chama_obj = Chama.objects.get(pk=chama["id"])
        member_role = Role.objects.get(slug=MEMBER)
        Membership.objects.get_or_create(
            user=active_member_in_chama,
            chama=chama_obj,
            defaults={"role": member_role, "status": ACTIVE},
        )

        treasurer_client.post(
            contributions_url(chama["id"]),
            contribution_payload(
                contribution_cycle["id"], str(active_member_in_chama.id)
            ),
            format="json",
        )

        response = member_client.get(contributions_url(chama["id"]))

        assert response.status_code == 200
        assert response.data["success"] is True
        assert response.data["data"]["count"] == 1
        assert len(response.data["data"]["results"]) == 1

    def test_filter_by_member_id(
        self, treasurer_client, chama, contribution_cycle, active_member_in_chama
    ):
        treasurer_client.post(
            contributions_url(chama["id"]),
            contribution_payload(
                contribution_cycle["id"], str(active_member_in_chama.id)
            ),
            format="json",
        )

        response = treasurer_client.get(
            contributions_url(chama["id"]),
            {"member_id": str(active_member_in_chama.id)},
        )

        assert response.status_code == 200
        assert response.data["data"]["count"] == 1

    def test_filter_by_cycle_id(
        self, treasurer_client, chama, contribution_cycle, active_member_in_chama
    ):
        treasurer_client.post(
            contributions_url(chama["id"]),
            contribution_payload(
                contribution_cycle["id"], str(active_member_in_chama.id)
            ),
            format="json",
        )

        response = treasurer_client.get(
            contributions_url(chama["id"]),
            {"cycle_id": contribution_cycle["id"]},
        )

        assert response.status_code == 200
        assert response.data["data"]["count"] == 1

    def test_list_requires_membership(self, member_client, chama):
        response = member_client.get(contributions_url(chama["id"]))
        assert response.status_code == 403


@pytest.mark.django_db
class TestContributionDetail:
    def test_get_contribution_detail(
        self, treasurer_client, chama, contribution_cycle, active_member_in_chama
    ):
        create_response = treasurer_client.post(
            contributions_url(chama["id"]),
            contribution_payload(
                contribution_cycle["id"], str(active_member_in_chama.id)
            ),
            format="json",
        )
        contribution_id = create_response.data["data"]["id"]

        response = treasurer_client.get(
            contribution_detail_url(chama["id"], contribution_id)
        )

        assert response.status_code == 200
        assert response.data["data"]["id"] == contribution_id


@pytest.mark.django_db
class TestContributionCycleDeleteGuard:
    def test_cannot_delete_cycle_with_contributions(
        self, treasurer_client, chama, contribution_cycle, active_member_in_chama
    ):
        treasurer_client.post(
            contributions_url(chama["id"]),
            contribution_payload(
                contribution_cycle["id"], str(active_member_in_chama.id)
            ),
            format="json",
        )

        response = treasurer_client.delete(
            cycle_detail_url(chama["id"], contribution_cycle["id"])
        )

        assert response.status_code == 400
        assert response.data["success"] is False
