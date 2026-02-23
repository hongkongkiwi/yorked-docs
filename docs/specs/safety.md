# Feature Specification: Safety

Owner: Trust & Safety + Engineering  
Status: Active  
Last Updated: 2026-02-21  
Depends On: `docs/trust-safety/legal-escalation-and-evidence.md`, `docs/ops/slo-sla.md`, `docs/technical/contracts/openapi.yaml`

## Overview

The safety feature ensures user protection through content moderation, reporting, enforcement actions, and compliance with legal requirements.

## Scope Clarification

Aligned with `docs/execution/phases/intent-phase-canonical-map.md`:
- MVP moderation is proactive (AI pre-screen + human queue), not passive-only scoring.
- Evidence and content retention windows are controlled by current safety/privacy policy docs and legal holds, not legacy fixed multi-year defaults.

## User Stories

### US-001: Report Content

**As a** user  
**I want to** report inappropriate content or behavior  
**So that** the platform can take action

**Acceptance Criteria:**
- [ ] Report option available from chat and profiles
- [ ] Category selection: harassment, inappropriate content, scam, violence, self-harm, child safety, other
- [ ] Optional description field (2000 chars max)
- [ ] Recent messages auto-attached as evidence
- [ ] Submit confirmation shown
- [ ] Report ID provided for follow-up
- [ ] Report logged with timestamp and metadata

**API Contract:** `POST /safety/report`

### US-002: Block User

**As a** user  
**I want to** block another user  
**So that** they cannot contact me

**Acceptance Criteria:**
- [ ] Block option available from chat and profile
- [ ] Confirmation required
- [ ] Immediate effect: no further contact possible
- [ ] Existing match/chat closed
- [ ] Blocked user not shown in future matches
- [ ] Block list viewable in settings
- [ ] User can unblock later

**API Contract:** `POST /safety/block`, `GET /users/me/blocks`, `DELETE /users/me/blocks/{userId}`

### US-003: Appeal Suspension

**As a** suspended user  
**I want to** appeal the decision  
**So that** I can restore my account if wrongly suspended

**Acceptance Criteria:**
- [ ] Appeal option shown on suspension screen
- [ ] User can submit explanation
- [ ] One appeal per enforcement action
- [ ] Acknowledgment shown
- [ ] Review by Trust & Safety team
- [ ] Decision communicated within 48 hours
- [ ] If approved, account restored

**API Contract:** `POST /safety/appeal`

### US-004: Moderation Queue

**As a** moderator  
**I want to** review reported content  
**So that** I can enforce policies

**Acceptance Criteria:**
- [ ] Queue organized by severity (critical, high, standard)
- [ ] SLA indicators visible (time remaining)
- [ ] Report details: category, description, evidence
- [ ] User history accessible
- [ ] Actions: warn, suspend, ban, dismiss
- [ ] Notes field for decision rationale
- [ ] Actions logged with moderator ID

**SLA Targets:**
- Critical: median ≤ 15 min, p95 ≤ 60 min
- High: median ≤ 4 hours
- Standard: median ≤ 24 hours

### US-005: Automated Moderation

**As a** the system  
**I want to** automatically detect violations  
**So that** we can respond quickly

**Acceptance Criteria:**
- [ ] All chat messages scanned in real-time
- [ ] High-risk patterns auto-flagged
- [ ] Critical severity auto-escalated to top of queue
- [ ] User warned for borderline content
- [ ] False positive rate < 5%
- [ ] Detection coverage > 95% of known patterns

**Detection Categories:**
- Self-harm/suicide indicators
- Violence/threats
- Child safety (CSAM hashes)
- Harassment patterns
- Scam/spam patterns
- Hate speech

### US-006: Evidence Preservation

**As a** Trust & Safety  
**I want to** preserve evidence for legal cases  
**So that** we can comply with law enforcement requests

**Acceptance Criteria:**
- [ ] Evidence auto-preserved on report
- [ ] Preservation includes: messages, photos, metadata
- [ ] 90-day minimum retention
- [ ] Legal hold extends retention
- [ ] Chain of custody maintained
- [ ] Secure access logging

**API Contract:** Internal (T&S tools)

### US-007: Law Enforcement Response

**As a** legal team member  
**I want to** respond to law enforcement requests  
**So that** we comply with legal obligations

**Acceptance Criteria:**
- [ ] Request intake form (legal@yoked.app)
- [ ] Verification of request authenticity
- [ ] Tracking system for all requests
- [ ] Response within legal deadlines
- [ ] Data production in specified format
- [ ] User notification (unless prohibited)

**Response Times:**
- Emergency: 1 hour
- Preservation: 24 hours
- Subpoena: 14 days or challenge
- Warrant: Per warrant terms

## Technical Requirements

### Content Moderation Pipeline

```
[Message Sent]
    │
    ▼
[AI Scanning] ──► [Auto-Flag?] ──► [Moderation Queue]
    │                   │
    │ No                │ Yes
    │                   ▼
    │            [Severity Check]
    │                   │
    ▼                   ▼
[Delivered]      [Critical?] ──► [Immediate T&S Alert]
                        │
                        │ No
                        ▼
                   [Queue by Priority]
```

### Severity Classification

| Severity | Criteria | Response Time |
|----------|----------|---------------|
| Critical | Child safety, violence, self-harm | ≤ 15 min |
| High | Harassment, threats, scam | ≤ 4 hours |
| Standard | Inappropriate content, spam | ≤ 24 hours |

### Enforcement Actions

| Action | Effect | Duration | Appeal? |
|--------|--------|----------|---------|
| Warning | Notification only | N/A | No |
| Content removal | Specific content deleted | Permanent | Yes |
| Temporary suspension | Account locked | 7-30 days | Yes |
| Permanent ban | Account terminated | Permanent | Yes (once) |
| Device ban | Device blacklisted | Permanent | No |

### Moderation Queue Schema

```sql
CREATE TABLE moderation_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id UUID REFERENCES reports(id),
  severity TEXT NOT NULL CHECK (severity IN ('critical', 'high', 'standard')),
  status TEXT NOT NULL CHECK (status IN ('pending', 'in_review', 'resolved')),
  assigned_to UUID REFERENCES admin_users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  sla_deadline TIMESTAMPTZ NOT NULL,
  resolved_at TIMESTAMPTZ,
  resolution_notes TEXT,
  in_review_at TIMESTAMPTZ
);
```

**Note:** Moderators are stored in `admin_users` table. See `docs/technical/schema/database.md`.

## Performance

- Report submission: < 2 seconds
- Queue assignment: < 1 minute
- AI scanning: < 500ms per message
- Evidence preservation: < 5 seconds

## Monitoring

### Metrics

| Metric | Target | Alert |
|--------|--------|-------|
| Critical queue median time | ≤ 15 min | > 20 min |
| High queue median time | ≤ 4 hours | > 5 hours |
| Standard queue median time | ≤ 24 hours | > 30 hours |
| AI false positive rate | < 5% | > 10% |
| Report volume | Baseline | > 200% spike |
| Appeal success rate | 10-20% | < 5% or > 30% |

### Dashboards

- Real-time queue status
- SLA compliance by severity
- Moderator workload
- Report trends by category
- Enforcement action distribution

## Compliance

### CSAM Handling

- NCMEC CyberTipline reporting
- Hash matching against known CSAM
- Immediate content removal
- Account suspension
- Law enforcement notification
- Evidence preservation

### GDPR/CCPA

- User data export (upon request)
- Right to deletion (with legal hold exceptions)
- Consent tracking
- Data retention policies
- Privacy impact assessments

### Transparency

- Annual transparency report
- Law enforcement request statistics
- Content moderation policies public
- Appeal process documented

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| False report | Dismiss, track reporter pattern |
| Retaliatory report | Flag, may suspend reporter |
| Report spam | Rate limit reporter |
| Coordinated abuse | Escalate to security team |
| Legal hold | Suspend all deletions for user |

## Dependencies

- AI moderation service
- Moderation queue infrastructure
- Evidence storage (S3 with legal hold)
- NCMEC reporting integration
- Legal team workflow tools

## Resolved Questions

| Question | Decision | Notes |
|----------|----------|-------|
| Moderation model | Hybrid | AI pre-screen + in-house review for beta, consider outsourced at scale |
| Public moderation log | No | Privacy concerns. Transparency report instead. |
| User reputation | No for MVP | May add if abuse patterns emerge. |

> See `docs/ops/configuration.md` for all configurable parameters.
