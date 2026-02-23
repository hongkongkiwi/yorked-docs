# Epic: Curated Matching Experience

Owner: Backend + Mobile  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/execution/epics/E02-onboarding.md`

## Overview

Daily match generation and offer presentation. The core value proposition of Yoked.

**Duration:** 4 weeks (Weeks 9-12)  
**Phase:** Tech Phase 3  
**Priority:** P0 (Committed)

## Specs

- `docs/specs/matching.md`
- `docs/specs/matching-scoring-engine.md`
- `docs/specs/gender-responsive-matching.md`

## Success Metrics

- Match generation < 5 min per 1000 users
- API response < 200ms for offers
- Zero duplicate offers
- Mutual matches detected within 1 minute

## Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E03-T01 | Design composite scoring algorithm (psych + physical preferences) | Backend | 5 | |
| E03-T02 | Implement hard filter logic (age, location, intent, block/pass state) | Backend | 3 | |
| E03-T03 | Build match candidate query (pool generation) | Backend | 5 | |
| E03-T04 | Create match offer batch generator | Backend | 5 | |
| E03-T05 | Implement idempotent batch creation (9 AM daily) | Backend | 5 | |
| E03-T06 | Build match offer API (GET /offers) | Backend | 3 | |
| E03-T07 | Implement Accept/Pass/Not Now actions | Backend | 3 | |
| E03-T08 | Create mutual match detection job | Backend | 3 | |
| E03-T09 | Set up match generation scheduler (cron/queue) | Backend | 3 | |
| E03-T10 | Design match card UI | Product | 2 | |
| E03-T11 | Build match offer card component | Mobile | 5 | |
| E03-T12 | Build card stack navigation | Mobile | 3 | |
| E03-T13 | Implement swipe gestures (accept/pass) | Mobile | 3 | |
| E03-T14 | Build "Not Now" bottom sheet | Mobile | 2 | |
| E03-T15 | Create empty state (no matches) | Mobile | 2 | |
| E03-T16 | Build mutual match celebration screen | Mobile | 3 | |
| E03-T17 | Implement push notification service (Expo) | Mobile | 3 | |
| E03-T18 | Add daily match notification | Mobile | 2 | |
| E03-T19 | Write matching algorithm unit tests | Backend | 3 | |
| E03-T20 | Write match flow E2E tests | QA | 5 | |

**Total Points:** 68

## Definition of Done

- [ ] Match generation completes in < 5 min per 1000 users
- [ ] API responds in < 200ms for match offers
- [ ] Zero duplicate offers per user
- [ ] Composite score explainability visible
- [ ] Mutual matches detected within 1 minute of second acceptance
- [ ] Push notifications delivered within 30 seconds
- [ ] Swipe gestures feel smooth (60fps)

## Dependencies

- E02: Onboarding & Verification Journey

## Related Documents

- `docs/specs/matching.md`
- `docs/specs/matching-scoring-engine.md`
- `docs/ux/flows/matching.md`
- `docs/technical/decisions/ADR-0004-matchmaking-idempotency.md`
