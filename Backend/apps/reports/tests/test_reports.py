import pytest

from apps.conftest import CHAMAS_URL
from apps.contributions.tests.test_contribution_cycles import CYCLE_PAYLOAD, cycles_url
from apps.contributions.tests.test_contributions import contributions_url


def reports_url(chama_id, report_type):
    return f"{CHAMAS_URL}{chama_id}/reports/{report_type}/"


def dashboard_url(chama_id):
    return f"{CHAMAS_URL}{chama_id}/dashboard/"


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
def contribution_data(treasurer_client, chama, active_member_in_chama):
    cycle_response = treasurer_client.post(
        cycles_url(chama["id"]), CYCLE_PAYLOAD, format="json"
    )
    treasurer_client.post(
        contributions_url(chama["id"]),
        {
            "cycle_id": cycle_response.data["data"]["id"],
            "member_id": str(active_member_in_chama.id),
            "amount": "5000.00",
            "payment_method": "cash",
            "reference": "RPT-001",
        },
        format="json",
    )
    return cycle_response.data["data"]


@pytest.mark.django_db
class TestReports:
    def test_contributions_report(
        self, treasurer_client, chama, contribution_data
    ):
        response = treasurer_client.get(reports_url(chama["id"], "contributions"))
        assert response.status_code == 200
        assert response.data["data"]["total_amount"] == "5000.00"
        assert response.data["data"]["total_count"] == 1

    def test_loans_report(self, treasurer_client, chama):
        response = treasurer_client.get(reports_url(chama["id"], "loans"))
        assert response.status_code == 200
        assert "total_applications" in response.data["data"]

    def test_repayments_report(self, treasurer_client, chama):
        response = treasurer_client.get(reports_url(chama["id"], "repayments"))
        assert response.status_code == 200
        assert "total_amount" in response.data["data"]

    def test_financial_report(self, treasurer_client, chama, contribution_data):
        response = treasurer_client.get(reports_url(chama["id"], "financial"))
        assert response.status_code == 200
        assert "contributions" in response.data["data"]
        assert "loans" in response.data["data"]

    def test_monthly_report(self, treasurer_client, chama, contribution_data):
        response = treasurer_client.get(reports_url(chama["id"], "monthly"))
        assert response.status_code == 200
        assert "year" in response.data["data"]
        assert "contributions" in response.data["data"]

    def test_member_financial_report(
        self, member_client, chama, active_member_in_chama, contribution_data
    ):
        response = member_client.get(
            f"{CHAMAS_URL}{chama['id']}/reports/members/{active_member_in_chama.id}/financial/"
        )
        assert response.status_code == 200
        assert response.data["data"]["contributions_total"] == "5000.00"
        assert response.data["data"]["credit_score"] is not None

    def test_reports_forbidden_for_member(self, member_client, chama):
        response = member_client.get(reports_url(chama["id"], "contributions"))
        assert response.status_code == 403

    def test_export_csv(self, treasurer_client, chama, contribution_data):
        response = treasurer_client.get(
            f"{CHAMAS_URL}{chama['id']}/reports/contributions/export/?export_format=csv"
        )
        assert response.status_code == 200
        assert response["Content-Type"] == "text/csv"

    def test_export_pdf(self, treasurer_client, chama, contribution_data):
        response = treasurer_client.get(
            f"{CHAMAS_URL}{chama['id']}/reports/contributions/export/?export_format=pdf"
        )
        assert response.status_code == 200
        assert response["Content-Type"] == "application/pdf"


@pytest.mark.django_db
class TestDashboard:
    def test_dashboard_summary(
        self, member_client, chama, contribution_data
    ):
        response = member_client.get(dashboard_url(chama["id"]))
        assert response.status_code == 200
        assert response.data["data"]["member_count"] >= 1
        assert response.data["data"]["user_summary"]["credit_score"] is not None
        assert response.data["data"]["contributions_this_cycle"] == "5000.00"

    def test_dashboard_requires_membership(self, api_client, chama):
        response = api_client.get(dashboard_url(chama["id"]))
        assert response.status_code == 401
