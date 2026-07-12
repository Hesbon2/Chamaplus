import pytest

from apps.conftest import CHAMAS_URL


def products_url(chama_id):
    return f"{CHAMAS_URL}{chama_id}/loan-products/"


def product_detail_url(chama_id, product_id):
    return f"{products_url(chama_id)}{product_id}/"


PRODUCT_PAYLOAD = {
    "name": "Standard Member Loan",
    "description": "General purpose member loan",
    "interest_rate": "10.00",
    "minimum_amount": "5000.00",
    "maximum_amount": "50000.00",
    "maximum_duration": 12,
    "grace_period_days": 7,
    "processing_fee": "500.00",
    "is_active": True,
}


@pytest.mark.django_db
class TestLoanProductCreate:
    def test_create_product_as_chairperson(self, auth_client, chama):
        response = auth_client.post(
            products_url(chama["id"]), PRODUCT_PAYLOAD, format="json"
        )
        assert response.status_code == 201
        assert response.data["data"]["name"] == "Standard Member Loan"
        assert response.data["data"]["is_active"] is True

    def test_create_product_forbidden_for_member(self, member_client, chama):
        response = member_client.post(
            products_url(chama["id"]), PRODUCT_PAYLOAD, format="json"
        )
        assert response.status_code == 403


@pytest.mark.django_db
class TestLoanProductList:
    def test_list_products(self, auth_client, chama):
        auth_client.post(products_url(chama["id"]), PRODUCT_PAYLOAD, format="json")
        response = auth_client.get(products_url(chama["id"]))
        assert response.status_code == 200
        assert len(response.data["data"]) == 1


@pytest.mark.django_db
class TestLoanProductDetail:
    def test_update_product_as_chairperson(self, auth_client, chama):
        create = auth_client.post(
            products_url(chama["id"]), PRODUCT_PAYLOAD, format="json"
        )
        product_id = create.data["data"]["id"]
        response = auth_client.patch(
            product_detail_url(chama["id"], product_id),
            {"name": "Updated Loan Product"},
            format="json",
        )
        assert response.status_code == 200
        assert response.data["data"]["name"] == "Updated Loan Product"

    def test_delete_product(self, auth_client, chama):
        create = auth_client.post(
            products_url(chama["id"]), PRODUCT_PAYLOAD, format="json"
        )
        product_id = create.data["data"]["id"]
        response = auth_client.delete(product_detail_url(chama["id"], product_id))
        assert response.status_code == 200
