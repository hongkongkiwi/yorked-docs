# UX Flow: Chat

Owner: Product Design  
Status: Draft  
Last Updated: 2026-02-20  
Depends On: `docs/technical/contracts/openapi.yaml`, `docs/technical/contracts/websocket-events.md`, `docs/specs/chat.md`

## Overview

The chat flow enables 1:1 messaging between matched users. It includes message sending, reading, and safety actions. For MVP, first message is free-for-all.

## Entry Points

1. **From Match**: Tap "Send message" on match screen
2. **From Notification**: Tap push notification
3. **From Messages List**: Tap conversation
4. **From Profile**: Tap message button on matched user
5. **From Settings**: Manage blocked users list

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                          CHAT FLOW                              │
└─────────────────────────────────────────────────────────────────┘

[Messages List Screen]
    │
    ├──► [Active Conversations]
    │       ├──► [Unread badge]
    │       ├──► [Last message preview]
    │       └──► [Tap] ──► [Chat Screen]
    │
    └──► [Empty State]
            └──► "No conversations yet"
    │
    └──► [Settings]
            └──► [Blocked Users List]
                    └──► [Unblock Confirmation]

[Chat Screen]
    │
    ├──► [Message List] (scrollable)
    │       ├──► [Sent messages] (right, blue)
    │       ├──► [Received messages] (left, gray)
    │       ├──► [Timestamps] (grouped)
    │       ├──► [Read receipts] (below sent)
    │       └──► [Typing indicator]
    │
    ├──► [Input Area]
    │       ├──► [Text input]
    │       ├──► [Send button]
    │       └──► [Safety actions (⋮)]
    │
    └──► [Safety Actions Menu]
            ├──► [Unmatch]
            ├──► [Report]
            └──► [Block]

[Unmatch Flow]
    │
    ├──► [Confirmation Dialog]
    │       ├──► [Reason selection]
    │       └──► [Confirm / Cancel]
    │
    └──► [Post-Unmatch]
            ├──► [Chat closed]
            └──► [Return to Messages List]

[Report Flow]
    │
    ├──► [Category Selection]
    │       ├──► [Harassment]
    │       ├──► [Inappropriate content]
    │       ├───► [Scam]
    │       └──► [Other]
    │
    ├──► [Details Input]
    │       └──► [Description + Submit]
    │
    └──► [Confirmation]
            └──► [Chat may be suspended]
```

## Screen Specifications

### Messages List Screen

**Purpose:** Overview of all active conversations
**Layout:**
- Header: "Messages" + unread count
- List: Conversations sorted by recent activity
- Empty: "No messages yet" illustration

**Conversation Row:**
```
┌─────────────────────────────────────┐
│ [Photo]  Name              Time     │
│          Last message...   [Badge]  │
└─────────────────────────────────────┘
```

**Elements:**
- Photo: Primary photo of match
- Name: Display name
- Time: Relative time ("2m", "3h", "Yesterday")
- Preview: Last message truncated
- Badge: Unread count (red circle)

**Interactions:**
- Tap: Open chat
- Swipe left: Quick actions (Mute, Unmatch)
- Long press: Preview (peek)

### Chat Screen

**Purpose:** 1:1 messaging
**Layout:**
```
┌─────────────────────────────────────┐
│ ←  [Photo] Name              ⋮      │  ← Header
├─────────────────────────────────────┤
│                                     │
│         [Date: Today]               │  ← Messages
│                           [Sent]    │
│                     [Read 2:30 PM]  │
│   [Received]                        │
│   [Received]                        │
│              [Typing...]            │
│                                     │
├─────────────────────────────────────┤
│ [Input...                 ] [Send]  │  ← Input
└─────────────────────────────────────┘
```

**Header:**
- Back button (←)
- Match photo (tap to view profile)
- Match name
- Status: "Online", "Active 5m ago", or nothing
- Menu (⋮): Safety actions

**Message Bubbles:**

*Sent:*
- Blue background
- Right-aligned
- Timestamp (subtle)
- Read receipt (✓✓ when read)

*Received:*
- Gray background
- Left-aligned
- Timestamp (subtle)
- Sender photo (optional, first in group)

**Timestamps:**
- Show between message groups (5+ min gap)
- Format: "Today, 2:30 PM", "Yesterday", "Monday"

**Typing Indicator:**
- Three animated dots
- Below received messages
- Disappears after 10s or when message sent

**Input Area:**
- Text field: "Message..."
- Send button: Disabled if empty
- Auto-resize: Up to 5 lines
- Character limit: 2000 (with counter)

### Message States

| State | Visual |
|-------|--------|
| Sending | Light opacity, spinner |
| Sent | Full opacity, single ✓ |
| Delivered | Double ✓ (gray) |
| Read | Double ✓ (blue) |
| Failed | Red exclamation, retry button |

### Safety Actions Menu

**Access:** Tap ⋮ in header

**Options:**
1. **View Profile** → Profile screen
2. **Unmatch** → Unmatch flow
3. **Report** → Report flow
4. **Block** → Block confirmation

### Blocked Users List (Settings)

**Purpose:** Let users manage their block list and unblock users.
**Layout:**
- Header: "Blocked Users"
- List: Blocked users with avatar, name, blocked date
- Empty state: "No blocked users"

**Interactions:**
- Tap user row: Open lightweight profile preview
- Tap "Unblock": Show confirmation dialog
- Confirm unblock: Remove user from block list and allow future matching eligibility

**Confirmation Dialog:**
- Title: "Unblock {name}?"
- Subtitle: "You may see each other again in future matches."
- Buttons: "Unblock", "Cancel"

### Unmatch Flow

**Confirmation Dialog:**
- Title: "Unmatch with {name}?"
- Subtitle: "You won't be able to message each other again"
- Reason (optional):
  - Not interested
  - Inappropriate behavior
  - No reason
- Buttons: "Unmatch" (destructive), "Cancel"

**Post-Unmatch:**
- Chat screen closes
- Conversation removed from list
- User won't see each other again

### Report Flow

**Step 1: Category**
- Title: "What's the issue?"
- Options:
  - Harassment or bullying
  - Inappropriate content
  - Scam or spam
  - Violent or threatening
  - Self-harm
  - Child safety concern
  - Something else

**Step 2: Details**
- Title: "Tell us more"
- Text area (optional)
- "Submit report"

**Step 3: Confirmation**
- Title: "Report submitted"
- Subtitle: "We'll review this within 24 hours"
- Option: "Block {name}"
- "Done"

## Interactions

### Sending Messages

1. User types message
2. Tap Send (or keyboard return)
3. Message appears immediately (optimistic)
4. Spinner while sending
5. Checkmark when confirmed
6. Read receipt when other user reads

**Error Handling:**
- Network error: "Message failed to send" with retry
- Rate limit: "Slow down" with countdown
- Blocked: "Cannot send message" (if other user blocked)

### Receiving Messages

1. Push notification (if app backgrounded)
2. In-app banner (if app foreground, other screen)
3. Message appears in chat (if in chat)
4. Typing indicator before message

**Notification:**
- Title: "{Name}"
- Body: Message preview (truncated)
- Action: Open chat

### Scrolling

- Auto-scroll to bottom on new message
- Maintain position if user scrolled up
- "New messages" indicator if not at bottom
- Load more on scroll to top (pagination)

### Media (Future)

- Photo sharing (MVP: text only)
- Gallery picker
- Camera capture
- Preview before send

## Empty States

**New Match (No Messages):**
- Center illustration: Two speech bubbles
- Title: "Start the conversation"
- Subtitle: "Say hello to {name}!"
- Suggested starters (optional):
  - "Hey {name}! How's your week going?"
  - "Hi! I noticed we both like hiking 🥾"

**No Longer Matched:**
- Show if user opens chat after unmatch
- Title: "This conversation has ended"
- Subtitle: "You or {name} unmatched"
- CTA: "Back to messages"

## Edge Cases

### Network Issues

| Scenario | Behavior |
|----------|----------|
| Send fails | Show retry button, preserve input |
| Receive fails | Queue, process when online |
| Intermittent | Optimistic UI, sync on reconnect |

### User Actions

| Scenario | Behavior |
|----------|----------|
| Other user unmatches | Chat closes, "Conversation ended" |
| Other user blocks | Same as unmatch |
| Other user deletes account | "User no longer available" |
| Account suspended | Block input, show suspension notice |

### Concurrent Actions

| Scenario | Behavior |
|----------|----------|
| Both typing | Show both indicators |
| Simultaneous send | Both messages appear (order by server time) |
| Send while unmatching | Cancel send, show ended state |

## Accessibility

### Screen Reader

- Message: "{Name} said: {message}, {time}"
- Sent message: "You said: {message}, delivered"
- Typing: "{Name} is typing"
- Input: "Message input, double tap to type"

### Navigation

- Swipe right: Focus previous message
- Swipe left: Focus next message
- Double tap: Activate (if link)

### Visual

- Minimum contrast: 4.5:1
- Color not only indicator (icons + text)
- Dynamic Type support

## Analytics Events

| Event | Trigger |
|-------|---------|
| chat_opened | Enter chat screen |
| message_sent | Send button tapped |
| message_received | Message received |
| message_read | Read receipt sent |
| typing_started | User starts typing |
| typing_stopped | User stops typing |
| unmatch_initiated | Unmatch tapped |
| unmatch_confirmed | Unmatch confirmed |
| report_initiated | Report tapped |
| report_submitted | Report submitted |
| block_initiated | Block tapped |
| block_confirmed | Block confirmed |

## Success Metrics

- Messages per match: Target > 5
- Response rate: > 60% within 24h
- Time to first message: < 1 hour after match
- Report rate: < 2% of conversations
- Unmatch rate: < 20% of matches
