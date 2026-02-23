# Epic: Messaging Core Experience (Polling + Push)

Owner: Full Stack
Status: Active
Last Updated: 2026-02-23
Depends On: `docs/execution/epics/E03-matching.md`

## Overview

Messaging between matches using REST + push + polling in MVP.

**Window:** Weeks 9-10
**Epic:** E04
**Priority:** P0 (Committed)

> **Canonical sequencing and scope:** `docs/execution/epic-plans/implementation-plan.md`.
> Task tables below are detailed drafts and may lag; reconcile against the implementation plan before sprint execution.

## Specs

- `docs/specs/chat.md`

## Success Metrics

- Message delivery < 100ms p95
- WebSocket uptime > 99.5%
- Typing indicators update in < 500ms
- 50+ messages load in < 500ms

## Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E04-T01 | Set up WebSocket gateway (Socket.io) | Backend | 5 | |
| E04-T02 | Configure Redis adapter for WebSocket scaling | Backend | 3 | |
| E04-T03 | Implement connection auth middleware | Backend | 3 | |
| E04-T04 | Build message persistence layer | Backend | 3 | |
| E04-T05 | Create message send/receive handlers | Backend | 5 | |
| E04-T06 | Implement read receipts logic | Backend | 3 | |
| E04-T07 | Build typing indicator broadcast | Backend | 2 | |
| E04-T08 | Create message history API (pagination) | Backend | 3 | |
| E04-T09 | Implement message rate limiting | Backend | 2 | |
| E04-T10 | Build Socket.io client integration | Mobile | 3 | |
| E04-T11 | Create WebSocket connection management | Mobile | 3 | |
| E04-T12 | Build messages list screen | Mobile | 5 | |
| E04-T13 | Build chat screen UI | Mobile | 5 | |
| E04-T14 | Implement message bubbles component | Mobile | 3 | |
| E04-T15 | Build message input with send button | Mobile | 2 | |
| E04-T16 | Implement typing indicator UI | Mobile | 2 | |
| E04-T17 | Add read receipts UI (checkmarks) | Mobile | 2 | |
| E04-T18 | Implement message pagination (infinite scroll) | Mobile | 3 | |
| E04-T19 | Add push notifications for new messages | Mobile | 2 | |
| E04-T20 | Implement REST polling fallback | Mobile | 3 | |
| E04-T21 | Write chat E2E tests | QA | 5 | |
| E04-T22 | Load test WebSocket (k6) | QA | 3 | |

**Total Points:** 70

## Definition of Done

- [ ] Message delivery < 100ms p95
- [ ] WebSocket uptime > 99.5%
- [ ] Typing indicators update in < 500ms
- [ ] Read receipts accurate within 1 second
- [ ] REST fallback activates on WebSocket failure
- [ ] 50+ messages load in < 500ms

## Dependencies

- E03: Curated Matching Experience

## Related Documents

- `docs/specs/chat.md`
- `docs/ux/flows/chat.md`
- `docs/technical/contracts/websocket-events.md`
- `docs/technical/decisions/ADR-0002-realtime-ownership.md`
