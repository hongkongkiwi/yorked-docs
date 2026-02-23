# Decision Records (ADR)

Owner: Engineering  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/README.md`, `docs/specs/`, `docs/technical/contracts/`

## Purpose

Capture irreversible or expensive-to-change decisions.

## Brainstorming Policy

While the team is in brainstorming mode:

- Prefer documenting **assumptions** in planning docs over creating new ADRs.
- Create an ADR only when:
  - the decision is hard to reverse,
  - implementation is active or imminent,
  - alternatives were compared,
  - and downstream contracts/specs are impacted.
- Do not create ADRs for exploratory product ideas, tentative sequencing, or experiments.

Practical rule: if we can safely change it next week with low cost, keep it in planning docs for now.

## Naming

- `ADR-0001-<short-name>.md`
- `ADR-0002-<short-name>.md`

## ADR Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-0001](ADR-0001-supabase-over-convex.md) | Backend Platform (Supabase + S3/GCS) | Accepted | 2026-02-19 |
| [ADR-0002](ADR-0002-realtime-ownership.md) | Realtime Ownership Model | Accepted | 2026-02-19 |
| [ADR-0003](ADR-0003-auth-recovery-policy.md) | Auth and Recovery Policy | Accepted | 2026-02-19 |
| [ADR-0004](ADR-0004-matchmaking-idempotency.md) | Matchmaking Scheduler Idempotency | Accepted | 2026-02-19 |
| [ADR-0005](ADR-0005-ai-model-routing.md) | AI Model Routing and Fallback | Accepted | 2026-02-19 |
| [ADR-0006](ADR-0006-modular-monolith-and-two-phase-matching.md) | Modular Monolith Architecture | Accepted | 2026-02-19 |
| [ADR-0007](ADR-0007-api-gateway-security-architecture.md) | API Gateway Security Architecture | Accepted | 2026-02-20 |
| [ADR-0009](ADR-0009-api-hosting.md) | API Hosting (Railway/Fly.io) | Accepted | 2026-02-20 |
| [ADR-0010](ADR-0010-background-jobs.md) | Background Jobs (Trigger.dev) | Accepted | 2026-02-20 |
| [ADR-0011](ADR-0011-monorepo-project-structure.md) | Monorepo Project Structure | Accepted | 2026-02-20 |
| [ADR-0012](ADR-0012-expo-for-mobile.md) | Expo for Mobile Development | Accepted | 2026-02-21 |
| [ADR-0013](ADR-0013-hono-api-framework.md) | Hono for API Framework | Accepted | 2026-02-21 |
| [ADR-0013](ADR-0013-hono-api-framework.md) | Hono API Framework | Accepted | 2026-02-21 |

**Note:** ADR-0008 is unassigned. Numbering preserved for existing references.

## Templates

- [ADR-0000-template.md](ADR-0000-template.md) - Use for new ADRs

## Decision Areas

### Platform & Infrastructure
- ADR-0001: Backend platform choice
- ADR-0007: Security architecture
- ADR-0009: API hosting

### Real-time & WebSockets
- ADR-0002: Realtime ownership model

### Auth & Security
- ADR-0003: Auth recovery policy
- ADR-0007: API gateway security

### Matching & Algorithms
- ADR-0004: Matchmaking idempotency
- ADR-0006: Modular monolith for matching

### AI & ML
- ADR-0005: AI model routing

### Background Processing
- ADR-0010: Background jobs

## Decisions Not Requiring ADRs

Some decisions are documented in specs or ops docs rather than ADRs:

| Decision | Where Documented |
|----------|------------------|
| No Redis needed for MVP | `docs/ops/infrastructure.md` |
| Rate limiting approach | `docs/ops/configuration.md` |
| CDN choice | `docs/ops/infrastructure.md` |
