import pytest

from apps.audit.models import AuditLog
from apps.conftest import CHAMAS_URL
from apps.credit_scoring.models import CreditScore
from apps.notifications.models import Notification


def meetings_url(chama_id):
    return f"{CHAMAS_URL}{chama_id}/meetings/"


def meeting_detail_url(chama_id, meeting_id):
    return f"{meetings_url(chama_id)}{meeting_id}/"


def attendance_url(chama_id, meeting_id):
    return f"{meeting_detail_url(chama_id, meeting_id)}attendance/"


def minutes_url(chama_id, meeting_id):
    return f"{meeting_detail_url(chama_id, meeting_id)}minutes/"


MEETING_PAYLOAD = {
    "title": "July Monthly Meeting",
    "description": "Review contributions and loans",
    "meeting_type": "ordinary",
    "venue": "Community Hall",
    "meeting_date": "2026-07-20",
    "start_time": "14:00:00",
    "end_time": "16:00:00",
}


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
def scheduled_meeting(secretary_client, chama):
    response = secretary_client.post(
        meetings_url(chama["id"]), MEETING_PAYLOAD, format="json"
    )
    return response.data["data"]


@pytest.mark.django_db
class TestMeetings:
    def test_create_meeting_as_secretary(self, secretary_client, chama):
        response = secretary_client.post(
            meetings_url(chama["id"]), MEETING_PAYLOAD, format="json"
        )
        assert response.status_code == 201
        assert response.data["data"]["title"] == MEETING_PAYLOAD["title"]
        assert response.data["data"]["status"] == "scheduled"

    def test_create_meeting_as_chairperson(self, auth_client, chama):
        response = auth_client.post(
            meetings_url(chama["id"]), MEETING_PAYLOAD, format="json"
        )
        assert response.status_code == 201

    def test_create_meeting_forbidden_for_member(
        self, member_client, chama, active_member_in_chama
    ):
        response = member_client.post(
            meetings_url(chama["id"]), MEETING_PAYLOAD, format="json"
        )
        assert response.status_code == 403

    def test_list_meetings_as_member(
        self, member_client, chama, scheduled_meeting, active_member_in_chama
    ):
        response = member_client.get(meetings_url(chama["id"]))
        assert response.status_code == 200
        assert len(response.data["data"]) >= 1

    def test_update_meeting(self, secretary_client, chama, scheduled_meeting):
        response = secretary_client.patch(
            meeting_detail_url(chama["id"], scheduled_meeting["id"]),
            {"title": "Updated Meeting Title"},
            format="json",
        )
        assert response.status_code == 200
        assert response.data["data"]["title"] == "Updated Meeting Title"

    def test_cancel_meeting(self, secretary_client, chama, scheduled_meeting):
        response = secretary_client.delete(
            meeting_detail_url(chama["id"], scheduled_meeting["id"])
        )
        assert response.status_code == 200
        assert response.data["data"]["status"] == "cancelled"


@pytest.fixture
def all_members_attended(secretary_client, chama, scheduled_meeting, active_member_in_chama):
    from apps.accounts.models import User
    from apps.chamas.models import Chama
    from apps.memberships.models import Membership
    from apps.memberships.constants import ACTIVE

    chama_obj = Chama.objects.get(pk=chama["id"])
    memberships = Membership.objects.filter(chama=chama_obj, status=ACTIVE)
    for membership in memberships:
        secretary_client.post(
            attendance_url(chama["id"], scheduled_meeting["id"]),
            {"member_id": str(membership.user_id), "status": "present"},
            format="json",
        )
    return scheduled_meeting


@pytest.mark.django_db
class TestAttendance:
    def test_record_and_list_attendance(
        self,
        secretary_client,
        chama,
        scheduled_meeting,
        active_member_in_chama,
    ):
        response = secretary_client.post(
            attendance_url(chama["id"], scheduled_meeting["id"]),
            {
                "member_id": str(active_member_in_chama.id),
                "status": "present",
                "arrival_time": "14:05:00",
            },
            format="json",
        )
        assert response.status_code == 201

        list_response = secretary_client.get(
            attendance_url(chama["id"], scheduled_meeting["id"])
        )
        assert list_response.status_code == 200
        recorded = [
            item for item in list_response.data["data"] if item["attendance_id"]
        ]
        assert len(recorded) >= 1

    def test_duplicate_attendance_fails(
        self, secretary_client, chama, scheduled_meeting, active_member_in_chama
    ):
        payload = {
            "member_id": str(active_member_in_chama.id),
            "status": "present",
        }
        secretary_client.post(
            attendance_url(chama["id"], scheduled_meeting["id"]),
            payload,
            format="json",
        )
        response = secretary_client.post(
            attendance_url(chama["id"], scheduled_meeting["id"]),
            payload,
            format="json",
        )
        assert response.status_code == 409

    def test_close_meeting_requires_full_attendance(
        self, secretary_client, chama, scheduled_meeting, active_member_in_chama
    ):
        secretary_client.post(
            attendance_url(chama["id"], scheduled_meeting["id"]),
            {
                "member_id": str(active_member_in_chama.id),
                "status": "present",
            },
            format="json",
        )
        response = secretary_client.post(
            f"{meeting_detail_url(chama['id'], scheduled_meeting['id'])}close/"
        )
        assert response.status_code == 400

    def test_close_meeting_triggers_integration(
        self,
        secretary_client,
        chama,
        all_members_attended,
        active_member_in_chama,
    ):
        meeting_id = all_members_attended["id"]
        response = secretary_client.post(
            f"{meeting_detail_url(chama['id'], meeting_id)}close/"
        )
        assert response.status_code == 200
        assert response.data["data"]["status"] == "completed"
        assert response.data["data"]["attendance_finalized"] is True

        assert AuditLog.objects.filter(action="attendance.finalized").exists()
        assert Notification.objects.filter(
            user=active_member_in_chama, title="Attendance finalized"
        ).exists()
        assert CreditScore.objects.filter(
            member=active_member_in_chama, chama_id=chama["id"]
        ).exists()


@pytest.mark.django_db
class TestMeetingMinutes:
    def test_create_and_approve_minutes(
        self,
        secretary_client,
        auth_client,
        chama,
        all_members_attended,
    ):
        meeting_id = all_members_attended["id"]
        secretary_client.post(
            f"{meeting_detail_url(chama['id'], meeting_id)}close/"
        )

        create = secretary_client.post(
            minutes_url(chama["id"], meeting_id),
            {
                "minutes": "Meeting opened and adjourned.",
                "resolutions": ["Approve budget"],
                "action_items": [{"task": "Collect dues", "owner": "Treasurer"}],
            },
            format="json",
        )
        assert create.status_code == 201
        assert create.data["data"]["approved"] is False

        approve = auth_client.post(
            f"{minutes_url(chama['id'], meeting_id)}approve/"
        )
        assert approve.status_code == 200
        assert approve.data["data"]["approved"] is True

    def test_member_cannot_record_attendance(
        self, member_client, chama, scheduled_meeting, active_member_in_chama
    ):
        response = member_client.post(
            attendance_url(chama["id"], scheduled_meeting["id"]),
            {
                "member_id": str(active_member_in_chama.id),
                "status": "present",
            },
            format="json",
        )
        assert response.status_code == 403


@pytest.mark.django_db
class TestDashboardMeetings:
    def test_dashboard_includes_next_meeting(
        self, member_client, chama, scheduled_meeting, active_member_in_chama
    ):
        response = member_client.get(f"{CHAMAS_URL}{chama['id']}/dashboard/")
        assert response.status_code == 200
        assert response.data["data"]["next_meeting"] is not None
        assert response.data["data"]["next_meeting"]["title"] == MEETING_PAYLOAD["title"]
