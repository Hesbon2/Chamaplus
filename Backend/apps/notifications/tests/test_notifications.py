import pytest

from apps.audit.models import AuditLog
from apps.conftest import CHAMAS_URL
from apps.contributions.tests.test_contribution_cycles import CYCLE_PAYLOAD, cycles_url
from apps.contributions.tests.test_contributions import contributions_url
from apps.notifications.models import Notification


NOTIFICATIONS_URL = "/api/v1/notifications/"
AUDIT_LOGS_URL = "/api/v1/audit-logs/"


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
def platform_admin_user(db, roles):
    from django.contrib.auth import get_user_model

    User = get_user_model()
    return User.objects.create_superuser(
        phone_number="+254799999999",
        password="SecurePass123",
        email="admin@example.com",
        first_name="Admin",
        last_name="User",
    )


@pytest.fixture
def platform_admin_client(platform_admin_user):
    from rest_framework.test import APIClient

    from apps.conftest import LOGIN_URL

    client = APIClient()
    response = client.post(
        LOGIN_URL,
        {"phone_number": "0799999999", "password": "SecurePass123"},
        format="json",
    )
    client.credentials(HTTP_AUTHORIZATION=f"Bearer {response.data['data']['access']}")
    return client


@pytest.mark.django_db
class TestNotifications:
    def test_contribution_creates_notification_and_audit(
        self, treasurer_client, chama, active_member_in_chama, member_client
    ):
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
                "reference": "NOTIF-001",
            },
            format="json",
        )

        assert Notification.objects.filter(user=active_member_in_chama).exists()
        assert AuditLog.objects.filter(action="contribution.created").exists()

        response = member_client.get(NOTIFICATIONS_URL)
        assert response.status_code == 200
        assert response.data["data"]["count"] >= 1
        assert response.data["data"]["results"][0]["title"] == "Contribution recorded"

    def test_mark_notification_read(self, member_client, active_member_in_chama):
        from apps.notifications.services.notification_service import NotificationService
        from apps.notifications.constants import NOTIFICATION_CONTRIBUTION_RECORDED

        notification = NotificationService.create(
            user=active_member_in_chama,
            title="Test",
            message="Test message",
            notification_type=NOTIFICATION_CONTRIBUTION_RECORDED,
        )

        response = member_client.patch(
            f"{NOTIFICATIONS_URL}{notification.id}/",
            {"is_read": True},
            format="json",
        )
        assert response.status_code == 200
        assert response.data["data"]["is_read"] is True

    def test_mark_all_read(self, member_client, active_member_in_chama):
        from apps.notifications.services.notification_service import NotificationService
        from apps.notifications.constants import NOTIFICATION_CONTRIBUTION_RECORDED

        NotificationService.create(
            user=active_member_in_chama,
            title="Test 1",
            message="Message 1",
            notification_type=NOTIFICATION_CONTRIBUTION_RECORDED,
        )
        NotificationService.create(
            user=active_member_in_chama,
            title="Test 2",
            message="Message 2",
            notification_type=NOTIFICATION_CONTRIBUTION_RECORDED,
        )

        response = member_client.post(f"{NOTIFICATIONS_URL}mark-all-read/")
        assert response.status_code == 200
        assert response.data["data"]["updated_count"] == 2

    def test_filter_unread_notifications(self, member_client, active_member_in_chama):
        from apps.notifications.services.notification_service import NotificationService
        from apps.notifications.constants import NOTIFICATION_CONTRIBUTION_RECORDED

        NotificationService.create(
            user=active_member_in_chama,
            title="Unread",
            message="Unread message",
            notification_type=NOTIFICATION_CONTRIBUTION_RECORDED,
        )

        response = member_client.get(f"{NOTIFICATIONS_URL}?is_read=false")
        assert response.status_code == 200
        assert response.data["data"]["count"] >= 1


@pytest.mark.django_db
class TestAuditLogs:
    def test_platform_audit_logs_as_admin(self, platform_admin_client, treasurer_client, chama, active_member_in_chama):
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
                "reference": "AUDIT-001",
            },
            format="json",
        )

        response = platform_admin_client.get(AUDIT_LOGS_URL)
        assert response.status_code == 200
        assert len(response.data["data"]) >= 1

    def test_platform_audit_logs_forbidden_for_member(self, member_client):
        response = member_client.get(AUDIT_LOGS_URL)
        assert response.status_code == 403

    def test_chama_audit_logs_as_chairperson(
        self, auth_client, treasurer_client, chama, active_member_in_chama
    ):
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
                "reference": "CHAMA-AUDIT-001",
            },
            format="json",
        )

        response = auth_client.get(f"{CHAMAS_URL}{chama['id']}/audit-logs/")
        assert response.status_code == 200
        assert len(response.data["data"]) >= 1

    def test_chama_audit_logs_forbidden_for_member(self, member_client, chama):
        response = member_client.get(f"{CHAMAS_URL}{chama['id']}/audit-logs/")
        assert response.status_code == 403
