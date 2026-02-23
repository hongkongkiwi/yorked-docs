# Incident Response

Owner: Engineering  
Status: Planned  
Last Updated: 2026-02-20  
Depends On: `docs/ops/slo-sla.md`

## Purpose

Define incident classification, escalation, and response procedures for production incidents.

## Startup Context

Small team = simplified process:

- **On-call rotation** — Engineers rotate; no dedicated ops team
- **Everyone responds** — SEV-1 means all hands on deck
- **Keep it practical** — Light process, focus on fixing
- **Learn and improve** — Postmortems prevent repeats

## Incident Classification

### Severity Levels

| Severity | Description | Response Time | Examples |
|----------|-------------|---------------|----------|
| **SEV-1** | Critical - Service down or data loss | Immediate | API down, database failure |
| **SEV-2** | High - Major feature broken | Same day | Chat broken, matching failing |
| **SEV-3** | Medium - Minor feature impact | Within 48 hours | Push delayed, elevated errors |
| **SEV-4** | Low - Cosmetic issues | Next sprint | Typos, UI glitches |

## Response Process

### 1. Detection
- Automated alerts (PagerDuty)
- User reports
- Monitoring dashboards
- Team observation

### 2. Triage
- Assess severity
- Assign incident commander
- Create incident channel: `#incident-YYYY-MM-DD-brief-description`
- Announce: `@here SEV-X: Brief description`

### 3. Response
- Incident commander coordinates
- Assign roles: investigator, communicator, fixer
- Document timeline in incident channel
- Regular status updates (every 15 min for SEV-1/2)

### 4. Resolution
- Implement fix
- Verify recovery
- Close incident channel
- Schedule postmortem

### 5. Postmortem
- Document within 48 hours
- Blameless analysis
- Action items with owners
- Share learnings

## Escalation

### On-Call Rotation
- Engineers rotate weekly
- SEV-1: All hands on deck
- SEV-2: On-call + available engineers

### Escalation Path (Small Team)
1. On-call engineer
2. All available engineers (for SEV-1)
3. Founder/CTO (if no resolution in 1 hour)

## Communication Templates

### Incident Announcement
```
🚨 SEV-X: [Brief description]
Status: Investigating
Impact: [User impact description]
Incident Commander: @name
Channel: #incident-YYYY-MM-DD-...
```

### Status Update
```
📊 Update #X - [Time]
Status: Investigating / Identified / Monitoring / Resolved
Summary: [What we know]
Next: [What we're doing]
ETA: [If known]
```

### Resolution
```
✅ Resolved - [Time]
Duration: X hours Y minutes
Root Cause: [Brief description]
Fix: [What fixed it]
Postmortem: [Link when available]
```

## Runbook References

- API errors: `runbooks/api-errors.md`
- Database issues: `runbooks/database.md`
- WebSocket issues: `runbooks/websocket.md`
- Match generation: `runbooks/matching.md`

## Metrics

Track for each incident:
- Time to detect (TTD)
- Time to respond (TTR)
- Time to resolve (TTM)
- User impact (affected users, duration)

## Related Documents

- `docs/ops/slo-sla.md` - SLO definitions
- `docs/ops/infrastructure.md` - Infrastructure details
- `docs/trust-safety/legal-escalation-and-evidence.md` - Legal escalation
