# ADR 005: Credit Scoring as Transparent Advisory Recommendation

**Status:** Accepted  
**Date:** 2026-07  
**Deciders:** ChamaPlus engineering team

---

## Context

ChamaPlus supports loan decision-making for informal savings groups. The master specification defines a **credit scoring mechanism** to help committee members evaluate loan applications. Key requirements:

- Transparent, weighted scoring formula
- Historical score snapshots for accountability
- Score is a **recommendation only** — committee makes the final decision
- Weights must not be hardcoded (coding rule: never hardcode business rules)

### Scoring formula (from spec)

| Factor | Weight |
|--------|--------|
| Contribution consistency | 35% |
| Repayment history | 35% |
| Attendance | 15% |
| Membership duration | 15% |

### Risk levels

| Score | Risk band |
|-------|-----------|
| 80–100 | Excellent |
| 60–79 | Good |
| 40–59 | Fair |
| 0–39 | High Risk |

### Governance rule (from spec)

> "The score is only a recommendation. Committee members always make the final decision."

---

## Decision

We will implement credit scoring as a **transparent, configurable, advisory system** with the following architecture:

### 1. Configurable weights

Score weights are loaded from environment/settings, not hardcoded:

```python
# settings/base.py (future)
CREDIT_SCORE_WEIGHTS = {
    "contribution_consistency": env.float("CS_WEIGHT_CONSISTENCY", default=0.35),
    "repayment_history": env.float("CS_WEIGHT_REPAYMENT", default=0.35),
    "attendance": env.float("CS_WEIGHT_ATTENDANCE", default=0.15),
    "membership_duration": env.float("CS_WEIGHT_DURATION", default=0.15),
}
```

### 2. Historical snapshots

Each calculation persists a `CreditScore` record:

```json
{
  "score": 72,
  "risk_level": "good",
  "breakdown": {
    "contribution_consistency": 28,
    "repayment_history": 25,
    "attendance": 12,
    "membership_duration": 7
  },
  "weights": { "...": 0.35 },
  "calculated_at": "2026-07-12T10:00:00+0300"
}
```

Members and officials can see what changed and when — fulfilling the "transparent" requirement.

### 3. Service + repository pattern

```
Trigger event (contribution, repayment, meeting closed)
    → CreditScoringService.calculate(member, chama)
        → CreditScoreRepository (aggregates across contributions, repayments, attendance, memberships)
        → Apply weights from settings
        → Determine risk level band
        → Persist snapshot to credit_scores table
```

- **Service:** `CreditScoringService` — orchestration, weight application, risk band
- **Repository:** `CreditScoreRepository` — complex cross-table aggregations
- **Constants:** `apps/credit_scoring/constants.py` — risk band thresholds (configurable)

### 4. Advisory-only enforcement

- Credit score is displayed on loan applications as read-only context
- Committee votes (`committee_votes` table) are the authoritative decision
- API does not auto-approve or auto-reject loans based on score
- UI must label score as "Recommendation" not "Decision"

### 5. Recalculation triggers

| Event | Recalculate? |
|-------|:------------:|
| Contribution recorded | Yes |
| Repayment recorded | Yes |
| Meeting closed (attendance finalized) | Yes |
| Membership status changed | Yes |
| Manual trigger (Chairperson/Treasurer) | Yes |
| Loan application submitted | Read latest snapshot (no recalc) |

---

## Consequences

### Positive

- Committee governance is preserved — technology supports, not replaces, human judgment
- Transparent breakdown builds member trust in the system
- Configurable weights allow tuning without code changes
- Historical snapshots enable audit and dispute resolution
- Aligns with Kenya informal finance culture where group consensus matters

### Negative

- Cross-table aggregation is computationally heavier than a simple score field
- Sub-formulas for each factor (e.g. how "consistency" is calculated) must be documented and agreed upon before implementation
- New members with sparse data need a defined minimum-data policy

### Neutral

- AI loan prediction is explicitly deferred to future scope
- Score does not integrate with external credit bureaus

---

## Open questions (resolve before Sprint 7)

1. **Contribution consistency formula:** On-time payments / expected? Variance over N cycles?
2. **Minimum data threshold:** How to score a member with < 3 contributions?
3. **Score visibility:** Can members see other members' scores, or only their own?
4. **Weight validation:** Should settings enforce weights sum to 1.0?

These will be documented in `API_SPEC.md` and a `CREDIT_SCORING.md` supplement before implementation.

---

## References

- `Docs/MASTER_PROJECT_SPEC.md` — Credit Score Formula, Coding Rules
- `Docs/API_SPEC.md` — Section 11.13 Credit Scoring
- `Docs/adr/003-service-layer.md` — Service and repository pattern
- `Docs/PERMISSIONS.md` — Who can view and trigger scores
- `Docs/CODING_STANDARDS.md` — No hardcoded business rules
