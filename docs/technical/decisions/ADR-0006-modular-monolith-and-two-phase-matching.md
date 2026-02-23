# ADR-0006: Modular Monolith and Two-Phase Matching Architecture

Date: 2026-02-19
Status: Accepted
Owner: Engineering
Last Updated: 2026-02-20
Depends On: `docs/technical/decisions/ADR-0001-supabase-over-convex.md`, `docs/technical/decisions/ADR-0002-realtime-ownership.md`, `docs/technical/decisions/ADR-0004-matchmaking-idempotency.md`, `docs/technical/contracts/openapi.yaml`, `docs/technical/contracts/websocket-events.md`, `docs/specs/matching.md`, `docs/specs/chat.md`, `docs/specs/safety.md`

## Context

Yoked is defining MVP architecture for:
- Curated daily match offers
- Trust-first onboarding and safety controls
- Real-time chat with reliable delivery
- Fast iteration without early platform over-complexity

A comparative review of open dating app repositories showed:
- Useful modularization and domain separation patterns in mobile and backend projects
- Practical real-time and Supabase integration patterns
- Strong production operations patterns (health, metrics, async processing)
- Frequent anti-patterns (hardcoded secrets, demo-only architecture, premature microservices)

The question is how to capture the useful patterns while staying aligned with Yoked's current stack and velocity.

## Decision

Adopt a **modular monolith + async workers** reference architecture for MVP, with a **two-phase matching pipeline**:

1. **Single deployable backend** (TypeScript) with strict domain module boundaries.
2. **Two-phase matching flow**:
   - Phase A: deterministic candidate generation
   - Phase B: deterministic compatibility scoring and ranking
3. **Hybrid realtime stays in place** (per ADR-0002):
   - WebSocket gateway for chat/presence/typing
   - Supabase Realtime for non-chat updates
4. **Outbox + queue workers** for side effects:
   - moderation, notifications, profile enrichment, analytics projections
5. **Production minimums from day one**:
   - `/health`, `/metrics`, structured logs, trace IDs, idempotency keys
6. **Explicit deferment of microservices** until scale/organizational triggers are met.

## Rationale

### Why Modular Monolith First

- Preserves delivery speed for MVP while preventing "big ball of mud" coupling.
- Fits current Yoked platform choices (Supabase + TypeScript API + WebSocket gateway).
- Keeps domain seams explicit so service extraction remains possible later.

### Why Two-Phase Matching

- Candidate generation and ranking have different scaling and explainability needs.
- Deterministic boundaries improve reproducibility, debugging, and fairness audits.
- Aligns with ADR-0004 idempotency and daily-offer guarantees.

### Why Async Outbox + Workers

- Safety and notification side effects should not block user-facing request paths.
- Outbox removes dual-write risk between database state and event publication.
- Gives a clear path to future decomposition without changing domain contracts.

### Why Not Microservices Now

- Increases operational and cognitive cost before product-market fit.
- Requires stronger platform maturity (service ownership, SRE processes, schema governance).
- Delays user-facing iteration on onboarding, matching quality, and trust features.

## Alternatives Considered

1. Full microservices from day one (polyglot services + queue mesh + k8s).
2. BaaS-heavy architecture with business logic primarily in clients.
3. UI-first prototype architecture with mock-driven backend kept indefinitely.

## Consequences

### Positive Outcomes

- Faster MVP delivery with disciplined boundaries.
- Clear ownership per domain module.
- Deterministic, testable matching flow.
- Better operational visibility early.
- Lower migration risk if services are later extracted.

### Tradeoffs

- Some up-front design work for module contracts and event schemas.
- More backend infrastructure than a pure demo architecture.
- Requires architectural discipline to keep module boundaries strict.

### Risks

| Risk | Mitigation |
|------|------------|
| Module boundary erosion | Enforce architecture tests and package layering checks |
| Queue/event complexity drift | Version event contracts and keep a single event catalog |
| Matching quality regressions | Offline replay harness and deterministic snapshot tests |
| Operational blind spots | SLO dashboards for matching jobs, chat latency, moderation lag |

## Implementation Notes

### Backend Module Boundaries

- `auth`
- `onboarding`
- `profile`
- `matching`
- `chat`
- `trust_safety`
- `notifications`
- `ai_assistant`

Rules:
- Modules own their write paths and invariants.
- Cross-module interactions use explicit service interfaces and domain events.
- No direct table mutation across module boundaries.

### Two-Phase Matching Pipeline

1. Candidate Generation
- Inputs: eligibility rules, hard constraints, safety exclusions, recency controls.
- Output: bounded candidate set with deterministic ordering key.

2. Scoring and Ranking
- Inputs: candidate set + scoring features + explainability metadata.
- Output: top-N daily offers with deterministic tie-breakers.

3. Offer Materialization
- Idempotent upsert keyed by `{date}:{userId}` as defined in ADR-0004.
- Persist score components for explainability and model evaluation.

### Async/Event Model

Primary events:
- `match.offer_generated`
- `match.accepted`
- `chat.message_sent`
- `safety.report_submitted`
- `safety.moderation_decided`

Pattern:
- Transactional outbox in primary DB.
- Worker publishes to queue/topics.
- Consumers are idempotent and replay-safe.

### Realtime Model

- Keep ADR-0002 ownership boundaries unchanged.
- WebSocket events remain contract-driven in `docs/technical/contracts/websocket-events.md`.
- Non-chat notifications may fan out via Supabase Realtime projections.

### Security and Operations Baseline

- No secrets in client source or committed server code.
- Central secret management for service credentials.
- Required endpoints and signals:
  - `/health` liveness/readiness
  - `/metrics` Prometheus format
  - request IDs and trace propagation
  - module-level error budgets and alerts

### Deferments (Not in MVP)

- Polyglot service decomposition.
- Kubernetes-first deployment model.
- Independent persistence per microservice.

### Service Extraction Triggers

Consider extracting a module only when at least two apply:
- Sustained p95 latency/SLO breaches isolated to one domain
- Team ownership requires independent deploy cadence
- Queue/event throughput for one domain exceeds monolith capacity
- Security/compliance isolation requires independent blast-radius control

## Validation

Success criteria:
- Daily offer generation completes within SLO with zero duplicate offers.
- Matching output is deterministic in replay tests for fixed inputs.
- Chat delivery meets latency and reliability targets in `docs/specs/chat.md`.
- Safety workflows meet response-time targets in `docs/specs/safety.md`.
- No client-exposed privileged credentials in security checks.
- New features can be added within one module without cross-module schema edits.

## Related Docs

- `docs/technical/decisions/ADR-0001-supabase-over-convex.md`
- `docs/technical/decisions/ADR-0002-realtime-ownership.md`
- `docs/technical/decisions/ADR-0004-matchmaking-idempotency.md`
- `docs/technical/contracts/openapi.yaml`
- `docs/technical/contracts/events.md`
- `docs/technical/contracts/websocket-events.md`
- `docs/technical/contracts/idempotency-and-retries.md`
- `docs/technical/architecture/module-boundary-enforcement-checklist.md`
- `docs/specs/matching.md`
- `docs/specs/chat.md`
- `docs/specs/safety.md`
