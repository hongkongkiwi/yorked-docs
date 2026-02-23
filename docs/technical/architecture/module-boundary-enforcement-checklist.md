# Module Boundary Enforcement Checklist

Owner: Engineering  
Status: Draft  
Last Updated: 2026-02-20  
Depends On: `docs/technical/decisions/ADR-0006-modular-monolith-and-two-phase-matching.md`, `docs/technical/contracts/events.md`, `docs/technical/contracts/openapi.yaml`

## Purpose

Define concrete guardrails that keep Yoked's modular monolith boundaries intact during MVP and early scale.

Target modules:
- `auth`
- `onboarding`
- `profile`
- `matching`
- `chat`
- `trust_safety`
- `notifications`
- `ai_assistant`

## Boundary Rules

### Rule 1: Write Ownership

- A module can write only its owned aggregates/tables.
- Cross-module data changes must happen via:
  - module service interface, or
  - domain event consumer.

Pass condition:
- No direct cross-module repository/table writes in code review.

### Rule 2: API Ownership

- Each endpoint must map to one owning module.
- Endpoints may orchestrate other modules only through explicit interfaces.

Pass condition:
- Endpoint-to-module map is documented and unchanged by unrelated PRs.

### Rule 3: Event-Driven Side Effects

- Non-critical side effects must be async via outbox events.
- No dual-write patterns (DB commit + direct queue publish in same request path).

Pass condition:
- Side-effect-producing commands emit outbox entries, not direct broker calls.

### Rule 4: Read Models

- Cross-module reads should use:
  - dedicated read models/projections, or
  - module query interfaces.
- Avoid ad hoc joins across multiple module-owned write tables in request paths.

Pass condition:
- Query plans for high-traffic endpoints use owned tables or projections only.

### Rule 5: Contract Discipline

- External API contracts live in `docs/technical/contracts/openapi.yaml`.
- Domain event contracts live in `docs/technical/contracts/events.md`.
- WebSocket contract lives in `docs/technical/contracts/websocket-events.md`.

Pass condition:
- Contract-impacting PRs update docs and contract tests in same change.

## PR Checklist (Required)

- [ ] Change scoped to one primary module owner.
- [ ] No direct write to another module's persistence model.
- [ ] New side effects use outbox event with schema in `docs/technical/contracts/events.md`.
- [ ] Any new endpoint/event updates corresponding contract docs.
- [ ] Idempotency behavior documented for non-read operations.
- [ ] Trace IDs and structured logs included for new critical paths.
- [ ] Security review done for auth/session, safety, and privileged operations.

## CI Guardrails

### 1) Layering and Import Rules

- Enforce module import boundaries with static checks.
- Disallow forbidden imports between module internals.

Minimum gate:
- CI fails on forbidden module dependency edges.

### 2) Contract Tests

- Validate OpenAPI compatibility for changed endpoints.
- Validate event schema fixtures for changed/new events.
- Validate WebSocket payload schemas for changed/new events.

Minimum gate:
- CI fails if schema validation or compatibility checks fail.

### 3) Architecture Drift Report

- Generate module dependency graph on each PR.
- Highlight new cross-module edges.

Minimum gate:
- PR blocked until new cross-module edges are approved explicitly.

### 4) Idempotency Tests

- Required for:
  - match offer actions
  - message send
  - report submission

Minimum gate:
- Duplicate request test must pass for each idempotent operation.

## Operational Checks

- `/health` exposes per-module readiness for critical dependencies.
- `/metrics` includes:
  - command failure rate by module
  - event publish/consume lag by module
  - dead-letter rate by event name
- Alerts route to owning module.

## Exception Process

If a boundary violation is temporarily required:

1. Open a short-lived exception record in PR description:
   - violated rule
   - reason
   - rollback/remediation date
2. Link a follow-up task that removes the exception.
3. Require engineering lead approval before merge.

## Validation

The checklist is effective when:
- Cross-module write violations trend to zero.
- Contract-breaking changes are caught in CI before merge.
- Event consumers remain idempotent under replay/duplicate tests.
- New engineers can correctly place changes by module without rework.

