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

    def test_defaulters_contribution_unpaid_member(
        self, treasurer_client, chama, active_member_in_chama, roles, chairperson_user
    ):
        from apps.chamas.models import Chama
        from apps.contributions.tests.test_contribution_cycles import (
            CYCLE_PAYLOAD,
            cycles_url,
        )
        from apps.memberships.constants import ACTIVE
        from apps.memberships.models import Membership
        from apps.roles.constants import MEMBER
        from apps.roles.models import Role

        # Open cycle with no contributions recorded for the member.
        cycle_response = treasurer_client.post(
            cycles_url(chama["id"]), CYCLE_PAYLOAD, format="json"
        )
        assert cycle_response.status_code == 201

        response = treasurer_client.get(
            f"{reports_url(chama['id'], 'defaulters')}?type=contribution"
        )
        assert response.status_code == 200
        data = response.data["data"]
        assert data["contribution_defaulters_count"] >= 1
        member_ids = {row["member_id"] for row in data["defaulters"]}
        assert str(active_member_in_chama.id) in member_ids

    def test_defaulters_excludes_paid_member(
        self, treasurer_client, chama, contribution_data, active_member_in_chama
    ):
        response = treasurer_client.get(
            f"{reports_url(chama['id'], 'defaulters')}?type=contribution"
            f"&cycle_id={contribution_data['id']}"
        )
        assert response.status_code == 200
        data = response.data["data"]
        unpaid_ids = {
            row["member_id"]
            for row in data["defaulters"]
            if row["type"] == "contribution"
            and row["cycle_id"] == contribution_data["id"]
        }
        assert str(active_member_in_chama.id) not in unpaid_ids

    def test_defaulters_loan_overdue(
        self, treasurer_client, chama, active_member_in_chama, auth_client
    ):
        from datetime import timedelta
        from decimal import Decimal

        from django.utils import timezone

        from apps.chamas.models import Chama
        from apps.loans.constants import DISBURSED
        from apps.loans.models import LoanApplication, LoanProduct
        from apps.loans.tests.test_loan_products import PRODUCT_PAYLOAD, products_url

        product_response = auth_client.post(
            products_url(chama["id"]), PRODUCT_PAYLOAD, format="json"
        )
        assert product_response.status_code == 201
        product = LoanProduct.objects.get(pk=product_response.data["data"]["id"])
        chama_obj = Chama.objects.get(pk=chama["id"])
        past = timezone.now() - timedelta(days=400)
        LoanApplication.objects.create(
            applicant=active_member_in_chama,
            chama=chama_obj,
            loan_product=product,
            requested_amount=Decimal("10000.00"),
            requested_duration=1,
            purpose="Test overdue",
            status=DISBURSED,
            applied_at=past,
            approved_at=past,
            approved_amount=Decimal("10000.00"),
            outstanding_balance=Decimal("5000.00"),
        )

        response = treasurer_client.get(
            f"{reports_url(chama['id'], 'defaulters')}?type=loan"
        )
        assert response.status_code == 200
        data = response.data["data"]
        assert data["loan_defaulters_count"] >= 1
        assert any(
            row["member_id"] == str(active_member_in_chama.id)
            and row["type"] == "loan"
            for row in data["defaulters"]
        )

    def test_defaulters_export_csv(self, treasurer_client, chama):
        response = treasurer_client.get(
            f"{CHAMAS_URL}{chama['id']}/reports/defaulters/export/?export_format=csv"
        )
        assert response.status_code == 200
        assert response["Content-Type"] == "text/csv"


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
