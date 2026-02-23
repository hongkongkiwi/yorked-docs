# Epic: Trust & Safety Experience

Owner: Backend + ML  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/execution/epics/E04-chat.md`

## Overview

Trust and safety infrastructure including content moderation, reporting, and enforcement.

**Duration:** 4 weeks (Weeks 17-20)  
**Phase:** Tech Phase 5  
**Priority:** P0 (Committed)

## Specs

- `docs/specs/safety.md`

## Success Metrics

- AI moderation flags 95%+ of policy violations
- False positive rate < 5%
- Critical reports responded to < 15 minutes
- Reports stored with full context

## Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E05-T01 | Integrate OpenAI content moderation API | Backend | 3 | |
| E05-T02 | Build message pre-screen pipeline | Backend | 3 | |
| E05-T03 | Create report submission API | Backend | 3 | |
| E05-T04 | Implement block/unmatch functionality | Backend | 3 | |
| E05-T05 | Build report storage and audit trail | Backend | 2 | |
| E05-T06 | Create basic moderation queue schema | Backend | 2 | |
| E05-T07 | Build report UI (reason selection) | Mobile | 3 | |
| E05-T08 | Implement block/unmatch UI flow | Mobile | 3 | |
| E05-T09 | Create report confirmation screen | Mobile | 2 | |
| E05-T10 | Write safety flow E2E tests | QA | 3 | |

**Total Points:** 27

## Definition of Done

- [ ] AI moderation flags 95%+ of policy violations
- [ ] False positive rate < 5%
- [ ] Reports stored with full context
- [ ] Blocked users cannot message or match
- [ ] Report submission < 3 taps

## Dependencies

- E04: Real-Time Messaging Experience

## Related Documents

- `docs/specs/safety.md`
- `docs/trust-safety/legal-escalation-and-evidence.md`
