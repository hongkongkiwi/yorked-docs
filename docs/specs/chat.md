# Feature Specification: Chat

Owner: Product + Engineering  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/ux/flows/chat.md`, `docs/technical/contracts/openapi.yaml`, `docs/technical/contracts/asyncapi.yaml`

## Overview

The chat feature enables 1:1 messaging between matched users. It includes real-time messaging, read receipts, typing indicators, and safety controls. In MVP, first message is free-for-all (either user can initiate).

## Scope Clarification

Aligned with `docs/execution/phases/intent-phase-canonical-map.md`:
- MVP chat scope is text-first core messaging. Rich media/edit/reaction ecosystems are post-MVP.
- Advanced per-match date-helper and unmatch-assistant character flows are not required for MVP launch readiness.

## User Stories

### US-001: Send Message

**As a** matched user  
**I want to** send a text message  
**So that** I can start a conversation

**Acceptance Criteria:**
- [ ] User can type message up to 2000 characters
- [ ] Send button enabled when text present
- [ ] Message appears immediately (optimistic UI)
- [ ] Message delivered to recipient in real-time
- [ ] Sender sees delivery status
- [ ] Sender sees read receipt when recipient reads
- [ ] Failed sends show retry option
- [ ] Messages are idempotent (clientMessageId deduplication)

**API Contract:** `POST /matches/{matchId}/messages`

### US-002: Receive Message

**As a** matched user  
**I want to** receive messages in real-time  
**So that** I can respond promptly

**Acceptance Criteria:**
- [ ] Messages delivered via WebSocket
- [ ] Push notification if app backgrounded
- [ ] In-app banner if app foreground (other screen)
- [ ] Message appears in chat if in conversation
- [ ] Typing indicator shown before message
- [ ] Messages ordered by server timestamp
- [ ] Duplicate messages rejected (clientMessageId)

**API Contract:** WebSocket event `message_new`

### US-003: Read Receipts

**As a** user  
**I want to** know when my message is read  
**So that** I know if they're active

**Acceptance Criteria:**
- [ ] Sender sees single checkmark when sent
- [ ] Sender sees double checkmark when delivered
- [ ] Sender sees blue double checkmark when read
- [ ] Read status sent when recipient views message
- [ ] Read status visible for all sent messages
- [ ] Recipient can disable read receipts (future)

**API Contract:** `POST /matches/{matchId}/read`, WebSocket event `message_read`

### US-004: Typing Indicators

**As a** user  
**I want to** see when someone is typing  
**So that** I know to wait for their response

**Acceptance Criteria:**
- [ ] Typing indicator shown when other user types
- [ ] Indicator disappears after 10 seconds of inactivity
- [ ] Indicator disappears when message sent
- [ ] Rate limited: max 1 typing event per 5 seconds
- [ ] Only shown in active conversation

**API Contract:** WebSocket event `typing_indicator`

### US-005: View Message History

**As a** user  
**I want to** see past messages  
**So that** I can catch up on the conversation

**Acceptance Criteria:**
- [ ] Messages loaded in reverse chronological order
- [ ] Pagination: 50 messages per request
- [ ] Scroll to load more (infinite scroll)
- [ ] Timestamps shown between message groups
- [ ] Messages include sender identification
- [ ] Failed loads show retry button

**API Contract:** `GET /matches/{matchId}/messages`

### US-006: Unmatch

**As a** user  
**I want to** unmatch and end the chat  
**So that** I can stop talking to someone

**Acceptance Criteria:**
- [ ] Unmatch option accessible from chat
- [ ] Confirmation dialog required
- [ ] Optional reason selection
- [ ] Chat closed immediately for both users
- [ ] No further messages possible
- [ ] Conversation removed from list
- [ ] Other user notified conversation ended

**API Contract:** `POST /matches/{matchId}/unmatch`

### US-007: Report User

**As a** user  
**I want to** report inappropriate behavior  
**So that** the platform remains safe

**Acceptance Criteria:**
- [ ] Report option accessible from chat
- [ ] Category selection (harassment, inappropriate, scam, etc.)
- [ ] Optional description field
- [ ] Evidence auto-attached (recent messages)
- [ ] Confirmation shown after submit
- [ ] Report sent to moderation queue
- [ ] Optional block after reporting

**API Contract:** `POST /safety/report`

### US-008: Block User

**As a** user  
**I want to** block someone  
**So that** they can't contact me

**Acceptance Criteria:**
- [ ] Block option accessible from chat
- [ ] Confirmation dialog required
- [ ] Chat closed immediately
- [ ] User blocked from future contact
- [ ] Blocked user not shown in future matches
- [ ] Block list manageable in settings

**API Contract:** `POST /safety/block`

## Technical Requirements

### Real-Time Delivery

**WebSocket:**
- Connection per authenticated user
- Subscribe to match channels
- Events: message_new, message_read, typing_indicator
- Acknowledgment required for critical events
- First message policy: either user may send immediately after mutual match

**Fallback:**
- If WebSocket unavailable, poll every 5 seconds
- Queue messages during disconnection
- Sync missed messages on reconnect

### Message Storage

**Schema:**
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID NOT NULL REFERENCES matches(id),
  sender_id UUID NOT NULL REFERENCES users(id),
  content TEXT NOT NULL,
  client_message_id TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  read_at TIMESTAMPTZ,
  
  UNIQUE(match_id, client_message_id)
);
```

**Retention:**
- Active: Retained while match active
- Post-unmatch: 30 days
- Post-account deletion: 30 days
- Backup purge: 90 days

### Performance

- Message delivery: < 100ms
- History load: < 500ms for 50 messages
- Typing indicator latency: < 200ms
- WebSocket reconnection: < 5 seconds

### Rate Limiting

| Action | Limit | Window |
|--------|-------|--------|
| Messages sent | 30 | per minute |
| Typing indicators | 10 | per minute |
| History requests | 60 | per minute |

## Safety Features

### Content Moderation

- Real-time scanning of all messages
- Auto-flag for high-risk content
- Severity classification
- Critical content triggers immediate review

### Proactive Detection

| Pattern | Action |
|---------|--------|
| Self-harm indicators | Crisis resources + T&S alert |
| Violence threats | Immediate T&S escalation |
| Child safety | Immediate T&S escalation + evidence preservation |
| Scam patterns | Flag + user warning |
| Harassment | Flag + T&S review |

### User Controls

- Block: Prevent all contact
- Unmatch: End specific conversation
- Report: Flag for review
- Mute: Disable notifications (future)

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| Simultaneous send | Both messages appear, ordered by server time |
| Send while unmatching | Send cancelled, conversation ended shown |
| Network loss | Queue messages, retry when online |
| Very long message | Truncate with "read more" |
| Rapid messages | Batch notifications |
| Other user deletes account | "User no longer available" |

## Analytics

Track:
- Messages sent/received per match
- Time to first message
- Response time distribution
- Conversation length (messages)
- Unmatch rate and reasons
- Report rate and categories

## Dependencies

- WebSocket gateway (real-time)
- PostgreSQL (message storage)
- Redis (presence, rate limiting)
- Push notification service
- Content moderation AI

## Resolved Questions

| Question | Decision | Notes |
|----------|----------|-------|
| Media messages in MVP | No | Text only for MVP. Add photos/video post-launch. |
| Message editing/deletion | No for MVP | Add post-launch if requested. |
| Disappearing messages | No | Not aligned with safety requirements. |
| Who messages first | Free-for-all for MVP | May become configurable by market/experiment later. |

> See `docs/ops/configuration.md` for all configurable parameters.
