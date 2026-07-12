import pytest

from apps.conftest import CHAMAS_URL
from apps.loans.tests.test_loan_products import PRODUCT_PAYLOAD, products_url


def applications_url(chama_id):
    return f"{CHAMAS_URL}{chama_id}/loan-applications/"


def application_detail_url(chama_id, application_id):
    return f"{applications_url(chama_id)}{application_id}/"


def application_action_url(chama_id, application_id, action):
    return f"{applications_url(chama_id)}{application_id}/{action}/"


def votes_url(chama_id, application_id):
    return f"{applications_url(chama_id)}{application_id}/votes/"


def repayments_url(chama_id, application_id):
    return f"{applications_url(chama_id)}{application_id}/repayments/"


@pytest.fixture
def loan_product(auth_client, chama):
    response = auth_client.post(
        products_url(chama["id"]), PRODUCT_PAYLOAD, format="json"
    )
    return response.data["data"]


@pytest.fixture
def member_in_chama(chama, member_user, roles):
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
def member_with_contribution(
    member_in_chama, treasurer_client, chama, loan_product, roles
):
    from apps.contributions.tests.test_contribution_cycles import (
        CYCLE_PAYLOAD,
        cycles_url,
    )
    from apps.contributions.tests.test_contributions import contributions_url

    cycle_response = treasurer_client.post(
        cycles_url(chama["id"]), CYCLE_PAYLOAD, format="json"
    )
    cycle_id = cycle_response.data["data"]["id"]
    treasurer_client.post(
        contributions_url(chama["id"]),
        {
            "cycle_id": cycle_id,
            "member_id": str(member_in_chama.id),
            "amount": "5000.00",
            "payment_method": "cash",
            "reference": "CASH-LOAN-ELIG",
        },
        format="json",
    )
    return member_in_chama


def application_payload(loan_product_id):
    return {
        "loan_product_id": loan_product_id,
        "requested_amount": "10000.00",
        "requested_duration": 6,
        "purpose": "School fees",
        "submit": True,
    }


@pytest.mark.django_db
class TestLoanApplicationCreate:
    def test_apply_as_member_with_contribution_history(
        self, member_client, chama, loan_product, member_with_contribution
    ):
        response = member_client.post(
            applications_url(chama["id"]),
            application_payload(loan_product["id"]),
            format="json",
        )
        assert response.status_code == 201
        assert response.data["data"]["status"] == "pending"
        assert response.data["data"]["requested_amount"] == "10000.00"

    def test_apply_without_contribution_history_fails(
        self, member_client, chama, loan_product, member_in_chama
    ):
        response = member_client.post(
            applications_url(chama["id"]),
            application_payload(loan_product["id"]),
            format="json",
        )
        assert response.status_code == 400
        assert response.data["success"] is False

    def test_apply_amount_exceeds_product_max_fails(
        self, member_client, chama, loan_product, member_with_contribution
    ):
        payload = application_payload(loan_product["id"])
        payload["requested_amount"] = "100000.00"
        response = member_client.post(
            applications_url(chama["id"]), payload, format="json"
        )
        assert response.status_code == 400


@pytest.mark.django_db
class TestLoanApplicationWorkflow:
    def test_approve_reject_cancel(
        self,
        member_client,
        committee_client,
        chama,
        loan_product,
        member_with_contribution,
    ):
        create = member_client.post(
            applications_url(chama["id"]),
            application_payload(loan_product["id"]),
            format="json",
        )
        app_id = create.data["data"]["id"]

        approve = committee_client.post(
            application_action_url(chama["id"], app_id, "approve"),
            {"approved_amount": "10000.00"},
            format="json",
        )
        assert approve.status_code == 200
        assert approve.data["data"]["status"] == "approved"

    def test_cancel_by_applicant(
        self, member_client, chama, loan_product, member_with_contribution
    ):
        create = member_client.post(
            applications_url(chama["id"]),
            application_payload(loan_product["id"]),
            format="json",
        )
        app_id = create.data["data"]["id"]
        response = member_client.post(
            application_action_url(chama["id"], app_id, "cancel"), format="json"
        )
        assert response.status_code == 200
        assert response.data["data"]["status"] == "cancelled"

    def test_reject_by_committee(
        self,
        member_client,
        committee_client,
        chama,
        loan_product,
        member_with_contribution,
    ):
        create = member_client.post(
            applications_url(chama["id"]),
            application_payload(loan_product["id"]),
            format="json",
        )
        app_id = create.data["data"]["id"]
        response = committee_client.post(
            application_action_url(chama["id"], app_id, "reject"),
            {"remarks": "Insufficient savings"},
            format="json",
        )
        assert response.status_code == 200
        assert response.data["data"]["status"] == "rejected"


@pytest.mark.django_db
class TestCommitteeVoting:
    def test_cast_vote_auto_approves(
        self,
        member_client,
        committee_client,
        chama,
        loan_product,
        member_with_contribution,
    ):
        create = member_client.post(
            applications_url(chama["id"]),
            application_payload(loan_product["id"]),
            format="json",
        )
        app_id = create.data["data"]["id"]

        response = committee_client.post(
            votes_url(chama["id"], app_id),
            {"decision": "approve", "comment": "Good member"},
            format="json",
        )
        assert response.status_code == 201
        assert response.data["data"]["application"]["status"] == "approved"

    def test_duplicate_vote_fails(
        self,
        member_client,
        committee_client,
        chama,
        loan_product,
        member_with_contribution,
    ):
        create = member_client.post(
            applications_url(chama["id"]),
            application_payload(loan_product["id"]),
            format="json",
        )
        app_id = create.data["data"]["id"]
        committee_client.post(
            votes_url(chama["id"], app_id),
            {"decision": "approve"},
            format="json",
        )
        second = committee_client.post(
            votes_url(chama["id"], app_id),
            {"decision": "approve"},
            format="json",
        )
        assert second.status_code == 400

    def test_member_cannot_vote(self, member_client, chama, loan_product):
        response = member_client.post(
            votes_url(chama["id"], loan_product["id"]),
            {"decision": "approve"},
            format="json",
        )
        assert response.status_code in (400, 403, 404)


@pytest.mark.django_db
class TestLoanRepayments:
    def _approved_and_disbursed(
        self, member_client, committee_client, treasurer_client, chama, loan_product, member_with_contribution
    ):
        create = member_client.post(
            applications_url(chama["id"]),
            application_payload(loan_product["id"]),
            format="json",
        )
        app_id = create.data["data"]["id"]
        committee_client.post(
            application_action_url(chama["id"], app_id, "approve"),
            {"approved_amount": "10000.00"},
            format="json",
        )
        treasurer_client.post(
            application_action_url(chama["id"], app_id, "disburse"), format="json"
        )
        return app_id

    def test_record_repayment(
        self,
        member_client,
        committee_client,
        treasurer_client,
        chama,
        loan_product,
        member_with_contribution,
    ):
        app_id = self._approved_and_disbursed(
            member_client,
            committee_client,
            treasurer_client,
            chama,
            loan_product,
            member_with_contribution,
        )
        response = treasurer_client.post(
            repayments_url(chama["id"], app_id),
            {
                "amount": "5000.00",
                "payment_method": "cash",
                "reference": "REP-001",
            },
            format="json",
        )
        assert response.status_code == 201
        assert response.data["data"]["application"]["outstanding_balance"] == "5000.00"

    def test_full_repayment_marks_loan_repaid(
        self,
        member_client,
        committee_client,
        treasurer_client,
        chama,
        loan_product,
        member_with_contribution,
    ):
        app_id = self._approved_and_disbursed(
            member_client,
            committee_client,
            treasurer_client,
            chama,
            loan_product,
            member_with_contribution,
        )
        response = treasurer_client.post(
            repayments_url(chama["id"], app_id),
            {
                "amount": "10000.00",
                "payment_method": "cash",
                "reference": "REP-FULL",
            },
            format="json",
        )
        assert response.status_code == 201
        assert response.data["data"]["application"]["status"] == "repaid"
        assert response.data["data"]["application"]["outstanding_balance"] == "0.00"

    def test_repayment_exceeds_balance_fails(
        self,
        member_client,
        committee_client,
        treasurer_client,
        chama,
        loan_product,
        member_with_contribution,
    ):
        app_id = self._approved_and_disbursed(
            member_client,
            committee_client,
            treasurer_client,
            chama,
            loan_product,
            member_with_contribution,
        )
        response = treasurer_client.post(
            repayments_url(chama["id"], app_id),
            {
                "amount": "15000.00",
                "payment_method": "cash",
                "reference": "REP-OVER",
            },
            format="json",
        )
        assert response.status_code == 400

    def test_member_cannot_record_repayment(
        self,
        member_client,
        committee_client,
        treasurer_client,
        chama,
        loan_product,
        member_with_contribution,
    ):
        app_id = self._approved_and_disbursed(
            member_client,
            committee_client,
            treasurer_client,
            chama,
            loan_product,
            member_with_contribution,
        )
        response = member_client.post(
            repayments_url(chama["id"], app_id),
            {
                "amount": "1000.00",
                "payment_method": "cash",
                "reference": "REP-BAD",
            },
            format="json",
        )
        assert response.status_code == 403
