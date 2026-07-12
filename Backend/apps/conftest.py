import pytest
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient

from apps.roles.constants import DEFAULT_ROLES
from apps.roles.models import Role

User = get_user_model()

CHAMAS_URL = "/api/v1/chamas/"
MEMBERSHIPS_URL = "/api/v1/memberships/"
LOGIN_URL = "/api/v1/auth/login/"


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def roles(db):
    for role_data in DEFAULT_ROLES:
        Role.objects.update_or_create(
            slug=role_data["slug"],
            defaults={
                "name": role_data["name"],
                "description": role_data["description"],
                "is_platform_role": role_data["is_platform_role"],
            },
        )
    return Role.objects.all()


@pytest.fixture
def chairperson_user(db, roles):
    return User.objects.create_user(
        phone_number="+254712345678",
        password="SecurePass123",
        email="chair@example.com",
        first_name="Jane",
        last_name="Chair",
    )


@pytest.fixture
def member_user(db, roles):
    return User.objects.create_user(
        phone_number="+254798765432",
        password="SecurePass123",
        email="member@example.com",
        first_name="John",
        last_name="Member",
    )


@pytest.fixture
def auth_client(chairperson_user):
    client = APIClient()
    response = client.post(
        LOGIN_URL,
        {"phone_number": "0712345678", "password": "SecurePass123"},
        format="json",
    )
    client.credentials(HTTP_AUTHORIZATION=f"Bearer {response.data['data']['access']}")
    return client


@pytest.fixture
def member_client(member_user):
    client = APIClient()
    response = client.post(
        LOGIN_URL,
        {"phone_number": "0798765432", "password": "SecurePass123"},
        format="json",
    )
    client.credentials(HTTP_AUTHORIZATION=f"Bearer {response.data['data']['access']}")
    return client


@pytest.fixture
def treasurer_user(db, roles):
    return User.objects.create_user(
        phone_number="+254711111111",
        password="SecurePass123",
        email="treasurer@example.com",
        first_name="Mary",
        last_name="Treasurer",
    )


@pytest.fixture
def treasurer_client(treasurer_user, chama, roles):
    from apps.chamas.models import Chama
    from apps.memberships.constants import ACTIVE
    from apps.memberships.models import Membership
    from apps.roles.constants import TREASURER

    chama_obj = Chama.objects.get(pk=chama["id"])
    treasurer_role = Role.objects.get(slug=TREASURER)
    Membership.objects.get_or_create(
        user=treasurer_user,
        chama=chama_obj,
        defaults={"role": treasurer_role, "status": ACTIVE},
    )

    client = APIClient()
    response = client.post(
        LOGIN_URL,
        {"phone_number": "0711111111", "password": "SecurePass123"},
        format="json",
    )
    client.credentials(HTTP_AUTHORIZATION=f"Bearer {response.data['data']['access']}")
    return client


@pytest.fixture
def committee_user(db, roles):
    return User.objects.create_user(
        phone_number="+254722222222",
        password="SecurePass123",
        email="committee@example.com",
        first_name="Peter",
        last_name="Committee",
    )


@pytest.fixture
def committee_client(committee_user, chama, roles):
    from apps.chamas.models import Chama
    from apps.memberships.constants import ACTIVE
    from apps.memberships.models import Membership
    from apps.roles.constants import COMMITTEE_MEMBER

    chama_obj = Chama.objects.get(pk=chama["id"])
    committee_role = Role.objects.get(slug=COMMITTEE_MEMBER)
    Membership.objects.get_or_create(
        user=committee_user,
        chama=chama_obj,
        defaults={"role": committee_role, "status": ACTIVE},
    )

    client = APIClient()
    response = client.post(
        LOGIN_URL,
        {"phone_number": "0722222222", "password": "SecurePass123"},
        format="json",
    )
    client.credentials(HTTP_AUTHORIZATION=f"Bearer {response.data['data']['access']}")
    return client


@pytest.fixture
def secretary_user(db, roles):
    return User.objects.create_user(
        phone_number="+254733333333",
        password="SecurePass123",
        email="secretary@example.com",
        first_name="Sarah",
        last_name="Secretary",
    )


@pytest.fixture
def secretary_client(secretary_user, chama, roles):
    from apps.chamas.models import Chama
    from apps.memberships.constants import ACTIVE
    from apps.memberships.models import Membership
    from apps.roles.constants import SECRETARY

    chama_obj = Chama.objects.get(pk=chama["id"])
    secretary_role = Role.objects.get(slug=SECRETARY)
    Membership.objects.get_or_create(
        user=secretary_user,
        chama=chama_obj,
        defaults={"role": secretary_role, "status": ACTIVE},
    )

    client = APIClient()
    response = client.post(
        LOGIN_URL,
        {"phone_number": "0733333333", "password": "SecurePass123"},
        format="json",
    )
    client.credentials(HTTP_AUTHORIZATION=f"Bearer {response.data['data']['access']}")
    return client


@pytest.fixture
def chama(auth_client, roles):
    response = auth_client.post(
        CHAMAS_URL,
        {
            "name": "Kileleshwa Women Chama",
            "description": "Monthly savings",
            "location": "Nairobi",
        },
        format="json",
    )
    return response.data["data"]
