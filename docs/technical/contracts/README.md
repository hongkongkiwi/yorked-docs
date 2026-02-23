# Contracts Docs

Owner: Engineering  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/technical/architecture/`

## Purpose

Define integration contracts as the highest-priority technical source of truth.

## Two Spec Standards

| Standard | Purpose | Generation |
|----------|---------|------------|
| **OpenAPI** | REST APIs (HTTP) | Full SDK via `openapi-typescript` |
| **AsyncAPI** | WebSocket events | Types via Modelina; client hand-written |

## API Surfaces

Per `docs/technical/decisions/ADR-0011-monorepo-project-structure.md`:

| API | Spec | Location | Package | Output |
|-----|------|----------|---------|--------|
| **Public REST** | OpenAPI | `apps/api/openapi.yaml` | `packages/api-client/` | Full SDK |
| **WebSocket** | AsyncAPI | `apps/api/asyncapi.yaml` | `packages/ws-client/` | Types only |
| **Admin REST** | OpenAPI | `apps/admin-api/openapi.yaml` | `packages/admin-api-client/` | Full SDK |

## Contract Files

| File | Spec Type | Status | Description |
|------|-----------|--------|-------------|
| [openapi.yaml](openapi.yaml) | OpenAPI | Active | Public REST API |
| [asyncapi.yaml](asyncapi.yaml) | AsyncAPI | Active | WebSocket events |
| [events.md](events.md) | - | Draft | Internal domain events |
| [auth-session-contract.md](auth-session-contract.md) | - | Active | Token/session lifecycle |
| [idempotency-and-retries.md](idempotency-and-retries.md) | - | Active | Scheduler/webhook safety |

**Deprecated:** `websocket-events.md` has been superseded by `asyncapi.yaml`.

## Authority

Per `docs/README.md`, contracts have the **highest technical authority**:

1. Contracts → Specs → Code
2. If code conflicts with contract, contract is correct
3. Breaking changes require version bump and migration plan

## SDK Generation

### REST SDKs (Full Generation)

```bash
# Generate all REST SDKs
pnpm generate:clients

# Or individually
pnpm --filter api-client generate
pnpm --filter admin-api-client generate
```

Generated features:
- Full TypeScript types for requests/responses
- Runtime validation
- Auth token injection
- Retry logic and error handling

### WebSocket Client (Types + Hand-written)

AsyncAPI doesn't have mature WebSocket client generators. Pragmatic approach:

```bash
# Generate types only from AsyncAPI spec
pnpm --filter ws-client generate:types
```

This uses **Modelina** to generate TypeScript types from AsyncAPI payloads. The WebSocket client is hand-written in `packages/ws-client/src/client.ts`.

**Why this approach:**
- AsyncAPI ecosystem lacks mature WebSocket client generators
- Hand-written client gives control over reconnection, auth, subscriptions
- Types are still generated from spec (type safety)
- Lower maintenance than building a custom AsyncAPI template

## AsyncAPI Example

```yaml
# apps/api/asyncapi.yaml
asyncapi: '3.0.0'
info:
  title: Yoked WebSocket API
  version: '1.0.0'

servers:
  production:
    host: realtime.yoked.app
    pathname: /v1
    protocol: wss

channels:
  match/{matchId}/messages:
    parameters:
      matchId:
        description: Match ID
        schema:
          type: string
          format: uuid
    messages:
      message.new:
        $ref: '#/components/messages/NewMessage'

components:
  messages:
    NewMessage:
      name: message.new
      title: New chat message
      payload:
        type: object
        required:
          - messageId
          - senderId
          - content
          - createdAt
        properties:
          messageId:
            type: string
            format: uuid
          senderId:
            type: string
            format: uuid
          content:
            type: string
            maxLength: 5000
          createdAt:
            type: string
            format: date-time
```

Modelina generates:

```typescript
// packages/ws-client/src/generated/events.ts
export interface MessageNewEvent {
  messageId: string;
  senderId: string;
  content: string;
  createdAt: string;
}
```

Hand-written client uses generated types:

```typescript
// packages/ws-client/src/client.ts
import type { MessageNewEvent, TypingStartEvent } from './generated/events';

export class WebSocketClient {
  on<T>(event: string, handler: (payload: T) => void): void { ... }
  subscribe(channel: string): Promise<void> { ... }
}

// Usage in mobile app:
ws.on<MessageNewEvent>('message:new', (event) => {
  // Fully typed!
  console.log(event.messageId, event.content);
});
```
