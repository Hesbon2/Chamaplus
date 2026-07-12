import logging

from apps.core.integration.events import (
    EVENT_ATTENDANCE_FINALIZED,
    EVENT_COMMITTEE_VOTE_COMPLETED,
    EVENT_CONTRIBUTION_RECORDED,
    EVENT_LOAN_APPLIED,
    EVENT_LOAN_APPROVED,
    EVENT_LOAN_REJECTED,
    EVENT_REPAYMENT_RECORDED,
)

logger = logging.getLogger(__name__)

EVENT_AUDIT_MAP = {
    EVENT_CONTRIBUTION_RECORDED: ("contribution.created", "contribution"),
    EVENT_LOAN_APPLIED: ("loan_application.created", "loan_application"),
    EVENT_LOAN_APPROVED: ("loan_application.approved", "loan_application"),
    EVENT_LOAN_REJECTED: ("loan_application.rejected", "loan_application"),
    EVENT_REPAYMENT_RECORDED: ("repayment.created", "repayment"),
    EVENT_COMMITTEE_VOTE_COMPLETED: ("committee_vote.completed", "committee_vote"),
    EVENT_ATTENDANCE_FINALIZED: ("attendance.finalized", "attendance"),
}


def _run_decision_support_side_effects(
    event_type,
    *,
    actor,
    chama,
    member=None,
    entity_type=None,
    entity_id=None,
    changes=None,
    metadata=None,
    ip_address=None,
):
    changes = changes or {}
    metadata = metadata or {}

    audit_action, default_entity_type = EVENT_AUDIT_MAP.get(
        event_type, (event_type, entity_type or "unknown")
    )
    entity_type = entity_type or default_entity_type

    try:
        from apps.audit.services.audit_service import AuditService

        AuditService.log(
            actor=actor,
            chama=chama,
            action=audit_action,
            entity_type=entity_type,
            entity_id=entity_id,
            changes=changes,
            ip_address=ip_address,
        )
    except Exception:
        logger.exception("Audit logging failed for event %s", event_type)

    try:
        from apps.notifications.services.notification_service import NotificationService

        NotificationService.dispatch_event(
            event_type=event_type,
            actor=actor,
            chama=chama,
            member=member,
            metadata=metadata,
        )
    except Exception:
        logger.exception("Notification dispatch failed for event %s", event_type)

    if member and chama:
        try:
            from apps.credit_scoring.services.credit_scoring_service import (
                CreditScoringService,
            )

            CreditScoringService.recalculate(
                member=member,
                chama=chama,
                triggered_by=actor,
            )
        except Exception:
            logger.exception(
                "Credit score recalculation failed for event %s", event_type
            )


def dispatch_decision_support_event(
    event_type,
    *,
    actor,
    chama,
    member=None,
    entity_type=None,
    entity_id=None,
    changes=None,
    metadata=None,
    ip_address=None,
):
    """
    Orchestrate audit logging, notifications, and credit score recalculation.
    Failures are logged but do not break the calling financial operation.
    """
    _run_decision_support_side_effects(
        event_type,
        actor=actor,
        chama=chama,
        member=member,
        entity_type=entity_type,
        entity_id=entity_id,
        changes=changes,
        metadata=metadata,
        ip_address=ip_address,
    )
