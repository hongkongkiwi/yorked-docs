# WebSocket Events Contract

Owner: Engineering  
Status: Superseded  
Last Updated: 2026-02-21  
Depends On: `docs/technical/contracts/asyncapi.yaml`

## Notice

**This document has been superseded by `asyncapi.yaml`.**

The AsyncAPI spec is now the source of truth for WebSocket events. This markdown file is kept for historical reference only.

**Use `asyncapi.yaml` for:**
- Event type definitions
- Payload schemas
- Type generation via Modelina

## Migration

All content from this document has been converted to AsyncAPI format in:
- `docs/technical/contracts/asyncapi.yaml`

## Connection

### Endpoint

```
wss://realtime.yoked.app/v1?token={access_token}
```

### Authentication

Connection requires a valid access token in the query parameter. Tokens expire after 15 minutes; clients must reconnect with a fresh token.

### Connection Lifecycle

```
Client -> Server: CONNECT with token
Server -> Client: connection_ack | connection_error

# Heartbeat every 30 seconds
Client -> Server: ping
Server -> Client: pong

# Reconnection required on token expiry
Server -> Client: token_expired
Client -> Server: DISCONNECT
Client -> Server: CONNECT with new token
```

## Event Structure

All events follow this envelope:

```json
{
  "eventId": "uuid",
  "eventType": "string",
  "timestamp": "2026-02-19T12:00:00Z",
  "payload": {}
}
```

## Client -> Server Events

### subscribe

Subscribe to channels for a specific match or user events.

```json
{
  "eventType": "subscribe",
  "payload": {
    "channels": ["match:{matchId}", "user:{userId}"]
  }
}
```

**Response:** `subscription_ack` or `subscription_error`

### unsubscribe

Unsubscribe from channels.

```json
{
  "eventType": "unsubscribe",
  "payload": {
    "channels": ["match:{matchId}"]
  }
}
```

### typing

Indicate typing status in a match.

```json
{
  "eventType": "typing",
  "payload": {
    "matchId": "uuid",
    "isTyping": true
  }
}
```

### message_read

Mark messages as read (also available via REST for reliability).

```json
{
  "eventType": "message_read",
  "payload": {
    "matchId": "uuid",
    "upToMessageId": "uuid"
  }
}
```

### presence

Update presence status.

```json
{
  "eventType": "presence",
  "payload": {
    "status": "online" | "away" | "offline"
  }
}
```

## Server -> Client Events

### connection_ack

Successful connection.

```json
{
  "eventId": "uuid",
  "eventType": "connection_ack",
  "timestamp": "2026-02-19T12:00:00Z",
  "payload": {
    "connectionId": "uuid",
    "expiresAt": "2026-02-19T12:15:00Z"
  }
}
```

### connection_error

Connection rejected.

```json
{
  "eventId": "uuid",
  "eventType": "connection_error",
  "timestamp": "2026-02-19T12:00:00Z",
  "payload": {
    "code": "invalid_token" | "token_expired" | "rate_limited" | "server_error",
    "message": "Human-readable error",
    "retryAfter": 60
  }
}
```

### token_expired

Token approaching expiry; client should reconnect.

```json
{
  "eventId": "uuid",
  "eventType": "token_expired",
  "timestamp": "2026-02-19T12:14:30Z",
  "payload": {
    "expiresAt": "2026-02-19T12:15:00Z",
    "gracePeriodMs": 30000
  }
}
```

### subscription_ack

Subscription confirmed.

```json
{
  "eventId": "uuid",
  "eventType": "subscription_ack",
  "timestamp": "2026-02-19T12:00:00Z",
  "payload": {
    "channels": ["match:{matchId}", "user:{userId}"]
  }
}
```

### subscription_error

Subscription failed.

```json
{
  "eventId": "uuid",
  "eventType": "subscription_error",
  "timestamp": "2026-02-19T12:00:00Z",
  "payload": {
    "channel": "match:{matchId}",
    "code": "not_found" | "not_authorized" | "server_error",
    "message": "Human-readable error"
  }
}
```

### message_new

New message in a subscribed match.

```json
{
  "eventId": "uuid",
  "eventType": "message_new",
  "timestamp": "2026-02-19T12:00:00Z",
  "payload": {
    "matchId": "uuid",
    "message": {
      "id": "uuid",
      "senderId": "uuid",
      "content": "Hello!",
      "createdAt": "2026-02-19T12:00:00Z",
      "clientMessageId": "client-generated-id"
    }
  }
}
```

**Acknowledgment:** Client should respond with `message_ack` within 5 seconds.

### message_ack

Server acknowledgment of message receipt (echoed back to sender).

```json
{
  "eventId": "uuid",
  "eventType": "message_ack",
  "timestamp": "2026-02-19T12:00:00Z",
  "payload": {
    "clientMessageId": "client-generated-id",
    "messageId": "server-assigned-uuid",
    "status": "delivered"
  }
}
```

### message_read

Messages marked as read by other user.

```json
{
  "eventId": "uuid",
  "eventType": "message_read",
  "timestamp": "2026-02-19T12:00:00Z",
  "payload": {
    "matchId": "uuid",
    "readByUserId": "uuid",
    "upToMessageId": "uuid",
    "readAt": "2026-02-19T12:00:00Z"
  }
}
```

### typing_indicator

Other user is typing.

```json
{
  "eventId": "uuid",
  "eventType": "typing_indicator",
  "timestamp": "2026-02-19T12:00:00Z",
  "payload": {
    "matchId": "uuid",
    "userId": "uuid",
    "isTyping": true
  }
}
```

### match_status_changed

Match status update (new match, unmatch, etc.).

```json
{
  "eventId": "uuid",
  "eventType": "match_status_changed",
  "timestamp": "2026-02-19T12:00:00Z",
  "payload": {
    "matchId": "uuid",
    "status": "active" | "closed",
    "previousStatus": "active" | "closed" | null,
    "reason": "matched" | "unmatched" | "blocked" | "deleted" | "expired" | null,
    "user": {
      "id": "uuid",
      "displayName": "string",
      "photos": []
    }
  }
}
```

### match_offer_new

New daily match offer available.

```json
{
  "eventId": "uuid",
  "eventType": "match_offer_new",
  "timestamp": "2026-02-19T12:00:00Z",
  "payload": {
    "offerId": "uuid",
    "user": {
      "id": "uuid",
      "displayName": "string",
      "age": 28,
      "photos": [],
      "compatibilityScore": 85,
      "compatibilityThemes": ["Shared values", "Lifestyle match"]
    },
    "expiresAt": "2026-02-25T12:00:00Z"
  }
}
```

### match_offer_mutual

Mutual match created (both users accepted).

```json
{
  "eventId": "uuid",
  "eventType": "match_offer_mutual",
  "timestamp": "2026-02-19T12:00:00Z",
  "payload": {
    "offerId": "uuid",
    "matchId": "uuid",
    "user": {
      "id": "uuid",
      "displayName": "string",
      "photos": []
    }
  }
}
```

### visual_preference_profile_updated

User visual preference profile updated after VPS choice processing.

```json
{
  "eventId": "uuid",
  "eventType": "visual_preference_profile_updated",
  "timestamp": "2026-02-19T12:00:00Z",
  "payload": {
    "sessionId": "uuid",
    "status": "in_progress" | "ready" | "stale",
    "completedPairs": 20,
    "targetPairs": 20,
    "confidence": 0.84,
    "profileSnapshotId": "uuid",
    "modelVersion": "v1",
    "nextStep": "continue" | "refine" | "complete" | "matching"
  }
}
```

### photo_recommendations_ready

Photo Studio recommendations are ready for display.

```json
{
  "eventId": "uuid",
  "eventType": "photo_recommendations_ready",
  "timestamp": "2026-02-19T12:00:00Z",
  "payload": {
    "runId": "uuid",
    "recommendations": [
      {
        "photoId": "uuid",
        "rank": 1,
        "score": 0.91
      }
    ],
    "generatedAt": "2026-02-19T12:00:00Z"
  }
}
```

### notification

General notification (not chat-related).

```json
{
  "eventId": "uuid",
  "eventType": "notification",
  "timestamp": "2026-02-19T12:00:00Z",
  "payload": {
    "type": "verification_reminder" | "profile_incomplete" | "safety_alert",
    "title": "Complete your profile",
    "body": "Add photos to start matching",
    "actionUrl": "/profile",
    "dismissible": true
  }
}
```

### presence_update

Other user's presence changed.

```json
{
  "eventId": "uuid",
  "eventType": "presence_update",
  "timestamp": "2026-02-19T12:00:00Z",
  "payload": {
    "userId": "uuid",
    "matchId": "uuid",
    "status": "online" | "away" | "offline",
    "lastActiveAt": "2026-02-19T11:45:00Z"
  }
}
```

### error

General error event.

```json
{
  "eventId": "uuid",
  "eventType": "error",
  "timestamp": "2026-02-19T12:00:00Z",
  "payload": {
    "code": "rate_limited" | "invalid_event" | "server_error",
    "message": "Human-readable error",
    "originalEventId": "uuid"
  }
}
```

## Acknowledgment Semantics

### Client Acknowledgment

Events requiring acknowledgment include `requiresAck: true` and an `ackTimeoutMs`:

```json
{
  "eventId": "uuid",
  "eventType": "message_new",
  "timestamp": "2026-02-19T12:00:00Z",
  "requiresAck": true,
  "ackTimeoutMs": 5000,
  "payload": {...}
}
```

Client must respond:

```json
{
  "eventType": "ack",
  "payload": {
    "eventId": "uuid-of-original-event"
  }
}
```

If acknowledgment is not received within the timeout, the server will:
1. Mark the message as "delivered" (not "read")
2. Retry delivery on next client connection
3. Fall back to push notification

### Server Acknowledgment

Client-sent events that modify state receive acknowledgment:

| Client Event | Server Response | On Timeout |
|--------------|-----------------|------------|
| `typing` | None (fire-and-forget) | N/A |
| `message_read` | `read_ack` | Retry REST API |
| `subscribe` | `subscription_ack` | Retry with backoff |

## Reliability Guarantees

### At-Least-Once Delivery

All events are delivered at least once. Clients must deduplicate using `eventId`.

### Ordering Guarantees

- Messages within a match are delivered in order by `createdAt`
- Match status changes are delivered in causal order
- No ordering guarantee across different matches

### Offline Handling

When a client is disconnected:
1. Events are queued for 7 days
2. On reconnect, client requests missed events via REST (`/matches/{id}/messages?after={lastMessageId}`)
3. WebSocket delivers real-time events only; historical sync via REST

## Error Handling

### Client Errors

| Error Code | Action |
|------------|--------|
| `invalid_token` | Refresh token and reconnect |
| `token_expired` | Refresh token and reconnect |
| `rate_limited` | Back off and retry with exponential delay |
| `not_authorized` | Unsubscribe from channel, may need re-auth |
| `not_found` | Channel doesn't exist, stop subscribing |

### Server Errors

If server sends `error` event:
1. Log the error
2. Continue connection if recoverable
3. Reconnect if connection-level error

## Rate Limits

| Event Type | Limit |
|------------|-------|
| Connection attempts | 10/minute per IP |
| Messages sent | 30/minute per user |
| Typing indicators | 10/minute per match |
| Subscribe/unsubscribe | 60/minute per connection |

Exceeding limits results in `rate_limited` error with `retryAfter` seconds.

## Implementation Notes

### Mobile Clients

- Use platform-native WebSocket libraries
- Implement aggressive reconnection with exponential backoff (max 30s)
- Batch `message_read` events if user scrolls quickly
- Stop typing indicator after 10s of no activity

### Web Clients

- Use native WebSocket API
- Implement page visibility API to pause subscriptions when hidden
- Reconnect immediately when page becomes visible

### Server Implementation

- Use Redis Pub/Sub for multi-server broadcast
- Maintain connection state in Redis with 5-minute TTL
- Validate all subscriptions against database authorization
