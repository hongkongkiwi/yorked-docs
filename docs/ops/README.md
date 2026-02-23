# Operations Documentation

Owner: Engineering  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/technical/architecture/`, `docs/technical/contracts/`

## Purpose

Operational runbooks, configuration, and reliability documentation. These docs define HOW we run the system in production.

## Startup Context

We're a small team — there's no separate ops/SRE team. Engineers own their code in production:

- **You build it, you run it** — Same people writing code are on-call for it
- **Keep it simple** — Avoid complex ops tooling until we need it
- **Document what matters** — Focus on runbooks for things that break
- **Automate incrementally** — Add automation as patterns emerge

## Doc Index

### Configuration & Infrastructure

| Doc | Status | Description |
|-----|--------|-------------|
| [configuration.md](configuration.md) | Active | All configurable parameters and their defaults |
| [infrastructure.md](infrastructure.md) | Active | OpenTofu/IaC setup, environments, deployment |
| [admin-operations.md](admin-operations.md) | Active | Admin panel features and operational procedures |

### Reliability & Monitoring

| Doc | Status | Description |
|-----|--------|-------------|
| [slo-sla.md](slo-sla.md) | Draft | Service level objectives and agreements |
| [matching-cohort-metrics.md](matching-cohort-metrics.md) | Draft | Fairness and quality metrics by cohort |
| [testing-strategy.md](testing-strategy.md) | Active | Testing levels, coverage targets, E2E strategy |

### Security & Privacy

| Doc | Status | Description |
|-----|--------|-------------|
| [privacy-security.md](privacy-security.md) | Active | Data protection, encryption, access controls |

### Incident Response (Planned)

| Doc | Status | Description |
|-----|--------|-------------|
| incident-response.md | Planned | Incident classification, escalation, postmortem process |
| runbook-template.md | Planned | Template for service-specific runbooks |

## Operational Principles

1. **Observability first** — Every service has metrics, logs, and traces
2. **Document before deploy** — Runbooks exist before production
3. **Automate recovery** — Self-healing where possible, clear playbooks where not
4. **Blameless postmortems** — Focus on systems, not individuals

## On-Call Resources

### Quick Links
- **SLO Dashboard**: [Link to monitoring]
- **Alerts**: [Link to PagerDuty]
- **Runbooks**: This directory

### Incident Severity

| Severity | Response Time | Example |
|----------|---------------|---------|
| SEV-1 (Critical) | Immediate | Production down, data loss |
| SEV-2 (High) | Same day | Feature degraded, elevated errors |
| SEV-3 (Medium) | Within 48 hours | Minor impact, workaround exists |
| SEV-4 (Low) | Next sprint | Cosmetic, no user impact |

## Configuration Management

All configuration should be:
- Stored in `system_config` table or environment variables
- Documented in [configuration.md](configuration.md)
- Changeable at runtime without deployment

## Deployment Process

1. PR approved and merged
2. CI passes (tests, lint, typecheck)
3. Deploy to staging
4. Smoke tests pass
5. Deploy to production
6. Monitor for 30 minutes

## Related Documents

- `docs/technical/contracts/openapi.yaml` — API contracts
- `docs/technical/architecture/` — System architecture
- `docs/trust-safety/` — Safety operations
