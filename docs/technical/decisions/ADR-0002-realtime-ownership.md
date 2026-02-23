# ADR-0002: Realtime Ownership Model

Date: 2026-02-19
Status: Accepted
Owner: Engineering
Last Updated: 2026-02-23
Depends On: `docs/technical/contracts/asyncapi.yaml`, `docs/execution/epic-plans/implementation-plan.md`, `docs/technical/decisions/ADR-0013-hono-api-framework.md`

## Context

Yoked requires real-time capabilities for:
- Chat messaging (1:1 conversations)
- Match status updates
- Typing indicators
- Presence (online/offline status)
- Notifications

We must decide which technology owns which real-time use case.

## Decision

Use a **hybrid model** with explicit ownership boundaries:

| Use Case | Technology | Ownership |
|----------|------------|-----------|
| Chat messages | Custom WebSocket Gateway | Application |
| Typing indicators | Custom WebSocket Gateway | Application |
| Presence | Custom WebSocket Gateway | Application |
| Match status updates | Custom WebSocket Gateway | Application |
| Database change notifications | Supabase Realtime | Platform |

## Rationale

### Why WebSocket Gateway for Chat

1. **Control**
   - Full control over message delivery semantics
   - Custom acknowledgment protocols
   - Rate limiting per user
   - Message persistence guarantees

2. **Scalability**
   - Horizontal scaling independent of database
   - Redis Pub/Sub for multi-server broadcast
   - Connection state isolated from database

3. **Security**
   - Authentication at connection time
   - Authorization per channel
   - Message validation before delivery

4. **Performance**
   - Sub-100ms message delivery
   - No database polling
   - Efficient binary framing

### Why Supabase Realtime for Notifications

1. **Simplicity**
   - Database-driven, no application code needed
   - Automatic change detection
   - Built-in filtering

2. **Appropriate Use Cases**
   - Profile update notifications
   - Settings changes
   - Non-critical UI updates

### Why Not Supabase Realtime for Chat

1. **Scaling Limits**
   - Supabase Realtime has connection and throughput limits
   - Chat requires high-frequency, low-latency delivery
   - Risk of hitting platform limits

2. **Delivery Guarantees**
   - Chat requires at-least-once delivery with acknowledgment
   - Custom WebSocket allows explicit ack/nack protocol
   - Easier to implement offline handling

3. **Message History**
   - WebSocket gateway can handle historical sync
   - Cleaner separation of real-time vs historical data

## Architecture

```
┌─────────────────┐
│  React Native   │
│     Client      │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    v         v
┌───────┐  ┌─────────────────┐
│ REST  │  │ WebSocket       │
│ API   │  │ Gateway         │
└───┬───┘  │ (Chat, Presence)│
    │      └────────┬────────┘
    │               │
    │          ┌────┴────┐
    │          │         │
    v          v         v
┌─────────────────────────────────┐
│      Supabase Platform          │
│  ┌─────────┐  ┌─────────────┐  │
│  │  Auth   │  │   Postgres  │  │
│  └─────────┘  └──────┬──────┘  │
│                      │         │
│               ┌──────┴──────┐  │
│               │  Realtime   │  │
│               │ (DB changes)│  │
│               └─────────────┘  │
└─────────────────────────────────┘
```

## Implementation Details

### WebSocket Gateway

**Technology:** ws (Node.js WebSocket library)
**Framework:** Hono with WebSocket support (per ADR-0013)
**Deployment:** Fly.io/Railway (same as API)
**Scaling:** Redis Pub/Sub for multi-instance broadcast
**Authentication:** JWT validation on connection

### Why ws over Socket.io

| Factor | ws | Socket.io |
|--------|----|-----------|
| Bundle size | ~50KB | ~200KB |
| Protocol | Standard WebSocket | Custom with fallbacks |
| Edge support | ✅ Works everywhere | ❌ Node.js only |
| Overhead | Minimal | Higher (heartbeat, rooms) |
| Learning curve | Simple | More features = more complexity |

We choose `ws` for:
- Standard WebSocket protocol (no Socket.io-specific client needed)
- Works with Hono's built-in WebSocket support
- Lighter weight for mobile clients
- Edge-compatible if needed in future

### Connection Flow

```
1. Client authenticates via REST API
2. Client receives access token
3. Client opens WebSocket with token
4. Gateway validates token
5. Client subscribes to channels (matches)
6. Messages flow through WebSocket
```

### Fallback Behavior

If WebSocket unavailable:
1. Client polls REST API for new messages (5s interval)
2. Client shows "connecting..." indicator
3. On reconnection, sync missed messages
4. Resume WebSocket when available

## Consequences

### Positive

- Clear ownership boundaries
- Chat can scale independently
- Full control over messaging semantics
- Platform limits don't constrain chat

### Tradeoffs

- Two real-time technologies to maintain
- More complex client implementation
- WebSocket gateway is custom code (more bugs)

### Risks

| Risk | Mitigation |
|------|------------|
| WebSocket gateway downtime | Fallback to polling, redundant instances |
| Connection scaling | Load balancer with sticky sessions, horizontal scaling |
| Message ordering | Sequence numbers, client-side deduplication |

## Validation

Success metrics:
- Message delivery latency < 100ms p95
- WebSocket uptime > 99.5%
- Client reconnection < 5 seconds
- Zero message loss during reconnection

## Related Docs

- `docs/technical/contracts/websocket-events.md`
- `docs/technical/decisions/ADR-0001-supabase-over-convex.md`
