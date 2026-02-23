# Testing Strategy

Owner: Engineering + QA  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/execution/phases/implementation-plan.md`

## Overview

This document defines how Yoked verifies quality before beta and public launch.

Primary goals:
- Prevent regressions on onboarding, matching, chat, and safety flows.
- Catch security and reliability issues before release.
- Keep test feedback fast enough for daily shipping.

## Test Pyramid

| Level | Scope | Tooling | Trigger | Exit Criteria |
|------|------|------|------|------|
| Unit | Pure business logic, helpers, validators | Jest / Vitest | Every PR | >=80% line coverage on changed modules |
| Integration | API routes, DB access, queue/jobs, auth | Jest + test DB | Every PR + nightly | All core API paths pass |
| Contract | Request/response conformance to OpenAPI | Dredd/Schemathesis (or equivalent) | Every PR | Zero contract regressions |
| E2E | Critical user journeys on mobile | Maestro | Every PR (smoke) + nightly (full) | All P0 journeys pass |
| Load/Soak | Matching batch, websocket fanout, API latency | k6 | Weekly + before launch | Meets documented SLO targets |
| Security | Dependency, SAST, secret scan, auth abuse checks | GitHub Advanced Security + scripts | Every PR + weekly deep scan | No open critical findings |

## Critical User Journeys (Must Always Pass)

1. New user signup -> onboarding -> verification complete.
2. Daily matches generated -> offer viewed -> accept/pass recorded.
3. Mutual match -> first message sent/received -> push delivered.
4. Report/block/unmatch flow completes and appears in moderation queue.
5. User session recovery after network interruption.

## Environment Strategy

| Environment | Purpose | Data Policy |
|------------|---------|-------------|
| Local | Fast iteration and unit/integration runs | Synthetic fixtures only |
| CI ephemeral | PR validation, deterministic automation | Seeded deterministic fixtures |
| Staging | Pre-release integration and load tests | Synthetic + anonymized samples |
| Beta production | Real traffic validation with safeguards | Production policy controls |

## CI/CD Quality Gates

### Pull Request Gate (Required)

- Lint, typecheck, unit tests
- Integration tests for changed services
- Contract tests for changed endpoints
- E2E smoke flow (signup + match + message)
- Secret and dependency scanning

### Main Branch Gate

- Full integration suite
- Full E2E suite
- Migration safety checks
- Performance smoke (API p95 and websocket latency)

### Release Gate

- 7-day flake rate <2% on E2E jobs
- No open P0/P1 defects
- Load tests meet targets from `docs/ops/slo-sla.md`
- Rollback plan validated in staging

## Phase-Aligned Test Focus

| Phase | Extra Focus |
|------|-------------|
| Foundation | Auth/session edge cases, migration rollback tests |
| Onboarding + Verification | OTP abuse tests, verification timeout/fallback behavior |
| Matching | Idempotency, duplicate suppression, timezone scheduling |
| Chat | Ordering, deduplication, reconnect replay |
| Safety | Report escalation SLAs, moderation queue integrity |
| Beta Prep | Cross-platform E2E stability, incident drills |

## Test Data Management

- Use factory-driven synthetic users and conversations.
- Keep deterministic seeds for repeatability in CI.
- Never use production PII in test environments.
- Reset integration databases between test runs.

## Defect Triage Policy

| Severity | Definition | SLA |
|---------|------------|-----|
| P0 | Launch blocker, security critical, data loss | Immediate owner assignment, fix same day |
| P1 | Major flow degraded, no safe workaround | Fix within 24 hours |
| P2 | Feature degraded with workaround | Fix in current sprint |
| P3 | Minor defect or polish issue | Backlog |

## Reporting

Weekly quality report includes:
- Pass/fail trend by suite
- Flake rate and top flaky tests
- Escaped defects by severity
- Mean time to detect and mean time to repair

## Ownership

- Engineering owns unit/integration/contract coverage and reliability.
- QA owns E2E suite health, release checklists, and defect verification.
- Product signs off on UAT for phase exits.
- Security reviews P0/P1 security findings before release.

---

This strategy is a living document and should be updated when test tooling or release risk changes.
