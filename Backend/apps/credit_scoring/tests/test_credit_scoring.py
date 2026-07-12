import pytest

from apps.conftest import CHAMAS_URL
from apps.contributions.tests.test_contribution_cycles import CYCLE_PAYLOAD, cycles_url
from apps.contributions.tests.test_contributions import contributions_url
from apps.credit_scoring.models import CreditScore


def credit_scores_url(chama_id, member_id):
    return f"{CHAMAS_URL}{chama_id}/members/{member_id}/credit-scores/"


@pytest.fixture
def active_member_in_chama(chama, member_user, roles):
    from apps.chamas.models import Chama
    from apps.memberships.constants import ACTIVE
    from apps.memberships.models import Membership
    from apps.roles.constants import MEMBER
    from apps.roles.models import Role

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


@pytest.fixture
def member_with_contribution(treasurer_client, chama, active_member_in_chama):
    cycle_response = treasurer_client.post(
        cycles_url(chama["id"]), CYCLE_PAYLOAD, format="json"
    )
    cycle_id = cycle_response.data["data"]["id"]
    treasurer_client.post(
        contributions_url(chama["id"]),
        {
            "cycle_id": cycle_id,
            "member_id": str(active_member_in_chama.id),
            "amount": "5000.00",
            "payment_method": "cash",
            "reference": "SCORE-001",
        },
        format="json",
    )
    return active_member_in_chama


@pytest.mark.django_db
class TestCreditScoring:
    def test_contribution_triggers_auto_score(
        self, member_client, chama, member_with_contribution
    ):
        scores = CreditScore.objects.filter(
            member=member_with_contribution, chama_id=chama["id"]
        )
        assert scores.exists()
        score = scores.first()
        assert 0 <= score.score <= 100
        assert score.risk_level in ("excellent", "good", "fair", "high_risk")

    def test_get_current_score(
        self, member_client, chama, member_with_contribution
    ):
        response = member_client.get(
            f"{credit_scores_url(chama['id'], member_with_contribution.id)}current/"
        )
        assert response.status_code == 200
        assert response.data["data"]["score"] is not None
        assert "breakdown" in response.data["data"]
        assert "weights" in response.data["data"]

    def test_score_history(
        self, treasurer_client, chama, member_with_contribution
    ):
        treasurer_client.post(
            f"{credit_scores_url(chama['id'], member_with_contribution.id)}recalculate/"
        )
        response = treasurer_client.get(
            credit_scores_url(chama["id"], member_with_contribution.id)
        )
        assert response.status_code == 200
        assert len(response.data["data"]) >= 2

    def test_recalculate_as_treasurer(
        self, treasurer_client, chama, member_with_contribution
    ):
        response = treasurer_client.post(
            f"{credit_scores_url(chama['id'], member_with_contribution.id)}recalculate/"
        )
        assert response.status_code == 200
        assert response.data["data"]["score"] is not None

    def test_recalculate_forbidden_for_member(
        self, member_client, chama, member_with_contribution
    ):
        response = member_client.post(
            f"{credit_scores_url(chama['id'], member_with_contribution.id)}recalculate/"
        )
        assert response.status_code == 403

    def test_member_can_view_own_score(
        self, member_client, chama, member_with_contribution
    ):
        response = member_client.get(
            f"{credit_scores_url(chama['id'], member_with_contribution.id)}current/"
        )
        assert response.status_code == 200

    def test_no_score_returns_404(self, member_client, chama, active_member_in_chama):
        response = member_client.get(
            f"{credit_scores_url(chama['id'], active_member_in_chama.id)}current/"
        )
        assert response.status_code == 404
