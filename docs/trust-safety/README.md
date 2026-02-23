# Trust and Safety Docs

Owner: Engineering  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/technical/contracts/`, `docs/ops/`

## Purpose

Define safety and compliance operations. In our startup phase, everyone contributes to safety.

## Startup Context

- **No dedicated T&S team** — Engineers handle moderation tools and response
- **Automate first** — AI moderation handles bulk; humans review edge cases
- **Clear escalation** — Legal/safety issues escalate to founders immediately
- **Stay compliant** — CSAM reporting and legal obligations are non-negotiable

## Doc Index

### Core Policies

| Doc | Status | Description |
|-----|--------|-------------|
| [moderation-policy.md](moderation-policy.md) | Planned | Content standards, enforcement actions, appeal process |
| [csam-response-procedure.md](csam-response-procedure.md) | Planned | Mandatory CSAM response and NCMEC reporting |
| [legal-escalation-and-evidence.md](legal-escalation-and-evidence.md) | Draft | Law enforcement requests and evidence preservation |

### Planned Docs

| Doc | Description |
|-----|-------------|
| `enforcement-guidelines.md` | Detailed enforcement decision trees |
| `appeals-process.md` | User appeal workflow and SLAs |

## Response SLAs

| Severity | Response Time | Examples |
|----------|---------------|----------|
| Critical (CSAM, violence) | Immediate | Child safety, threats |
| High (harassment, hate) | < 4 hours | Targeted harassment |
| Medium (spam, inappropriate) | < 24 hours | Minor violations |
| Low (general reports) | < 48 hours | Minor complaints |

## Key Contacts

| Role | Responsibility |
|------|----------------|
| On-call engineer | First response to reports |
| Founders | Legal/safety escalations |
| Legal counsel (external) | Law enforcement requests |

## Related Documents

- `docs/specs/safety.md` - Safety feature specification
- `docs/ops/incident-response.md` - Incident response procedures
- `docs/ops/privacy-security.md` - Privacy and data protection
