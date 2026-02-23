# Domain Events Contract

Owner: Engineering  
Status: Draft  
Last Updated: 2026-02-20  
Depends On: `docs/technical/contracts/openapi.yaml`, `docs/technical/contracts/websocket-events.md`, `docs/technical/contracts/idempotency-and-retries.md`, `docs/technical/decisions/ADR-0002-realtime-ownership.md`, `docs/technical/decisions/ADR-0004-matchmaking-idempotency.md`, `docs/technical/decisions/ADR-0006-modular-monolith-and-two-phase-matching.md`

## Overview

This document defines internal domain events published through the transactional outbox. It is the source of truth for:
- event naming
- payload contracts
- delivery and idempotency guarantees
- consumer expectations

This contract governs **server-side domain events**, not client WebSocket envelopes. Client-facing events remain in `docs/technical/contracts/websocket-events.md`.

## Event Envelope

All events use this envelope:

```json
{
  "event_id": "uuid",
  "event_name": "match.offer_generated",
  "event_version": 1,
  "occurred_at": "2026-02-19T12:00:00Z",
  "producer": "matching",
  "trace_id": "uuid",
  "idempotency_key": "string",
  "payload": {}
}
```

### Field Requirements

| Field | Type | Required | Notes |
|------|------|----------|-------|
| `event_id` | UUID | Yes | Unique immutable identifier |
| `event_name` | string | Yes | Dot-delimited, domain scoped |
| `event_version` | int | Yes | Starts at 1, increment on breaking payload change |
| `occurred_at` | ISO-8601 UTC | Yes | Domain event time |
| `producer` | string | Yes | Producing module name |
| `trace_id` | UUID | Yes | Request/job correlation |
| `idempotency_key` | string | Yes | Stable key for deduplication |
| `payload` | object | Yes | Event-specific contract |

## Delivery Semantics

- Outbox publication is **at-least-once**.
- Consumers must be idempotent.
- Ordering is guaranteed only per aggregate key:
  - `user_id` streams for user-level events
  - `match_id` streams for match/chat events
- Cross-aggregate global ordering is not guaranteed.

## Idempotency Rules

- Consumers must persist processed `event_id` for at least 7 days.
- Duplicate `event_id` must be acknowledged as success (no-op).
- `idempotency_key` must be deterministic from business identity:
  - offer generation: `{date}:{user_id}:{offer_type}`
  - match action: `{offer_id}:{actor_user_id}:{action}`
  - message send: `{match_id}:{client_message_id}`

## Event Catalog (MVP)

### `match.offer_generated` (v1)

Producer: `matching`  
When emitted: A daily or anchor offer is materialized.

Payload:

```json
{
  "offer_id": "uuid",
  "user_id": "uuid",
  "candidate_user_id": "uuid",
  "offer_type": "daily",
  "batch_date": "2026-02-19",
  "score": {
    "composite": 87.2,
    "psychological": 84.0,
    "visual": 90.5,
    "authenticity": 82.1
  },
  "expires_at": "2026-02-25T09:00:00Z"
}
```

Primary consumers:
- `notifications` (new offer notifications)
- `analytics` (offer funnel metrics)

### `match.accepted` (v1)

Producer: `matching`  
When emitted: A user accepts an offer.

Payload:

```json
{
  "offer_id": "uuid",
  "match_id": "uuid",
  "actor_user_id": "uuid",
  "counterparty_user_id": "uuid",
  "mutual": true,
  "accepted_at": "2026-02-19T12:10:00Z"
}
```

Primary consumers:
- `notifications` (counterparty and mutual notifications)
- `chat` (provision chat room on `mutual=true`)
- `analytics` (acceptance conversion)

### `chat.message_sent` (v1)

Producer: `chat`  
When emitted: A message is persisted.

Payload:

```json
{
  "message_id": "uuid",
  "match_id": "uuid",
  "sender_user_id": "uuid",
  "recipient_user_id": "uuid",
  "client_message_id": "uuid",
  "created_at": "2026-02-19T12:11:00Z"
}
```

Primary consumers:
- `notifications` (push/in-app badges)
- `trust_safety` (abuse signal pipeline)
- `analytics` (chat engagement metrics)

### `safety.report_submitted` (v1)

Producer: `trust_safety`  
When emitted: A user report is recorded.

Payload:

```json
{
  "report_id": "uuid",
  "reporter_user_id": "uuid",
  "subject_user_id": "uuid",
  "match_id": "uuid",
  "category": "harassment",
  "submitted_at": "2026-02-19T12:12:00Z",
  "priority": "high"
}
```

Primary consumers:
- `trust_safety` workers (moderation routing)
- `analytics` (safety incident metrics)

### `safety.moderation_decided` (v1)

Producer: `trust_safety`  
When emitted: A moderation decision is finalized.

Payload:

```json
{
  "decision_id": "uuid",
  "report_id": "uuid",
  "subject_user_id": "uuid",
  "decision": "suspend",
  "reason_code": "abusive_language",
  "effective_at": "2026-02-19T12:20:00Z",
  "expires_at": null
}
```

Primary consumers:
- `auth` (session revocation if needed)
- `matching` (exclude subject from eligibility)
- `chat` (enforce block/closure actions)

## Producer Responsibilities

- Validate payload schema before outbox write.
- Include deterministic `idempotency_key`.
- Publish only after business transaction commits.
- Never mutate previously published event records.

## Consumer Responsibilities

- Validate event schema and version.
- Implement idempotent handling keyed by `event_id`.
- Treat unknown future fields as non-breaking.
- Send failed events to dead-letter stream after retry budget.

## Versioning Policy

- Additive payload changes: keep same `event_version`.
- Breaking payload changes: bump `event_version`, dual-publish during migration.
- Deprecation window: minimum 30 days before removing old version.

## Retry and DLQ Policy

- Retry schedule: 5s, 30s, 2m, 10m, 30m.
- Max attempts: 5.
- After max attempts, move to DLQ with full envelope and error metadata.
- DLQ entries must be queryable by `event_id`, `event_name`, and `trace_id`.

## Validation

Success checks:
- 100% of outbox records map to a valid catalog event.
- Duplicate delivery causes zero duplicate side effects.
- All consumers pass contract tests for required fields and versions.
- DLQ rate stays below agreed threshold in `docs/ops/slo-sla.md`.

