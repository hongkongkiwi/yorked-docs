# Feature Specification: Notifications

Owner: Mobile + Backend  
Status: Planned  
Last Updated: 2026-02-20  
Depends On: `docs/technical/contracts/openapi.yaml`, `docs/specs/matching.md`, `docs/specs/chat.md`

## Overview

Push notifications and in-app notification center for user engagement and re-engagement.

## User Stories

### US-001: Push Notification Registration

**As a** user  
**I want to** receive push notifications  
**So that** I'm notified of important events

**Acceptance Criteria:**
- [ ] User can grant notification permission
- [ ] Device token registered with backend
- [ ] User can disable notifications in settings
- [ ] Token refreshed on app updates

**API Contract:** `POST /users/me/devices/push`

### US-002: Match Notifications

**As a** user  
**I want to** be notified of new matches  
**So that** I don't miss opportunities

**Acceptance Criteria:**
- [ ] Notification sent when new daily offers available
- [ ] Notification sent on mutual match
- [ ] Deep link to relevant screen
- [ ] Quiet hours respected

**API Contract:** Push via Expo/FCM/APNs

### US-003: Chat Notifications

**As a** user  
**I want to** be notified of new messages  
**So that** I can respond promptly

**Acceptance Criteria:**
- [ ] Notification sent for new messages
- [ ] Sender name and message preview shown
- [ ] Notification cleared when message read
- [ ] Mute option per conversation

### US-004: In-App Notification Center

**As a** user  
**I want to** see all my notifications in one place  
**So that** I can review them later

**Acceptance Criteria:**
- [ ] Notification list with timestamps
- [ ] Mark as read functionality
- [ ] Clear all option
- [ ] Deep link to relevant content

**API Contract:** `GET /notifications`, `POST /notifications/{id}/read`

## Technical Requirements

### Push Providers
- iOS: Apple Push Notification service (APNs) via Expo
- Android: Firebase Cloud Messaging (FCM) via Expo

### Notification Types

| Type | Priority | Sound | Deep Link |
|------|----------|-------|-----------|
| New match offer | High | Default | `/matches` |
| Mutual match | High | Celebratory | `/matches/{id}` |
| New message | Medium | Default | `/chat/{id}` |
| Match expiring | Low | None | `/matches` |
| System | Variable | None | Varies |

### Quiet Hours
- Default: 10 PM - 8 AM local time
- Configurable in settings
- Critical safety notifications exempt

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| Token invalid | Remove from database, retry registration |
| User uninstalls | Detect bounce, remove token |
| Multiple devices | Send to all, dedupe in-app |
| Rate limiting | Batch notifications within 5 min window |

## Resolved Questions

| Question | Decision | Rationale |
|----------|----------|-----------|
| Rich notification support (images, actions)? | **Not for MVP** - Text only | Simpler implementation, reliable delivery. Add rich notifications post-MVP based on engagement data. |
| Notification grouping strategy? | **Group by type** (all messages in one thread) | Reduces notification spam, clearer inbox. Platform-level grouping where supported. |
| A/B testing notification copy? | **Not for MVP** - Use consistent copy | Focus on core features first. Add A/B testing framework post-MVP. |

## MVP Notification Scope

- Text notifications only (no images, no action buttons)
- Grouped by type (messages, matches, system)
- Consistent copy across users
- Quiet hours enforced server-side
