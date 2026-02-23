# Feature Specification: Settings

Owner: Mobile  
Status: Planned  
Last Updated: 2026-02-20  
Depends On: `docs/technical/contracts/openapi.yaml`

## Overview

User preferences, account management, and app settings.

## User Stories

### US-001: Account Settings

**As a** user  
**I want to** manage my account settings  
**So that** I can control my experience

**Acceptance Criteria:**
- [ ] View and edit profile
- [ ] Change notification preferences
- [ ] Manage privacy settings
- [ ] View linked accounts (Apple, Google)

**API Contract:** `GET /users/me`, `PATCH /users/me`

### US-002: Discovery Preferences

**As a** user  
**I want to** set my matching preferences  
**So that** I get relevant matches

**Acceptance Criteria:**
- [ ] Set age range preference
- [ ] Set distance preference
- [ ] Set relationship intent
- [ ] Changes apply to next match batch

**API Contract:** `GET /users/me/preferences`, `PATCH /users/me/preferences`

### US-003: Blocked Users

**As a** user  
**I want to** manage my blocked users  
**So that** I control who can contact me

**Acceptance Criteria:**
- [ ] View blocked users list
- [ ] Unblock users
- [ ] Blocked users not shown in matches

**API Contract:** `GET /users/me/blocks`, `DELETE /users/me/blocks/{userId}`

### US-004: Account Deletion

**As a** user  
**I want to** delete my account  
**So that** my data is removed

**Acceptance Criteria:**
- [ ] Clear deletion confirmation flow
- [ ] 30-day grace period for recovery
- [ ] Data purge after grace period
- [ ] Email confirmation required

**API Contract:** `POST /users/me/delete`

### US-005: Notification Settings

**As a** user  
**I want to** control my notifications  
**So that** I'm not disturbed unnecessarily

**Acceptance Criteria:**
- [ ] Toggle push notifications
- [ ] Set quiet hours
- [ ] Per-notification-type toggles
- [ ] Mute specific chats

## Technical Requirements

### Settings Categories

| Category | Settings |
|----------|----------|
| Account | Profile, email, phone, linked accounts |
| Discovery | Age range, distance, intent, gender preferences |
| Notifications | Push toggle, quiet hours, per-type toggles |
| Privacy | Profile visibility, read receipts, online status |
| Safety | Blocked users, report history |
| Support | Help, FAQ, contact |

### Data Storage
- Settings stored in `user_preferences` table
- Changes logged for audit
- Default values documented in `docs/ops/configuration.md`

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| Invalid age range | Show validation error |
| Distance > max | Cap at maximum (100 mi) |
| Account recovery after delete | Restore if within 30 days |
| Linked account disconnected | Require password set |

## Resolved Questions

| Question | Decision | Rationale |
|----------|----------|-----------|
| Export data feature (GDPR)? | **Yes, required** | Legal requirement for EU users. Add to MVP scope. |
| Theme/appearance settings? | **Not for MVP** | System theme (light/dark) only. Custom themes post-MVP. |
| Language preferences? | **Not for MVP** - English only | Start with English. Add localization post-MVP. |

## MVP Settings Scope

**In MVP:**
- Account management (edit profile, delete account)
- Discovery preferences (age, distance, intent)
- Notification controls (on/off, quiet hours)
- Privacy (profile visibility, read receipts)
- Blocked users
- Data export (GDPR requirement)

**Post-MVP:**
- Theme/appearance
- Language selection
- Advanced notification controls
