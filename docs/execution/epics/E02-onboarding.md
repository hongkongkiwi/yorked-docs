# Epic: Onboarding & Verification Journey

Owner: Full Stack
Status: Active
Last Updated: 2026-02-23
Depends On: `docs/execution/epics/E01-identity.md`

## Overview

Complete onboarding flow from download to match-ready. Includes profile creation, questionnaire, and verification.

**Window:** Weeks 3-5
**Epic:** E02
**Priority:** P0 (Committed)

> **Canonical sequencing and scope:** `docs/execution/epic-plans/implementation-plan.md`.
> Task tables below are detailed drafts and may lag; reconcile against the implementation plan before sprint execution.

## Specs

- `docs/specs/onboarding.md`
- `docs/specs/visual-preference-studio.md` (VPS capture portion)
- `docs/specs/science-backed-relationship-question-bank.md`

## Success Metrics

- User can complete onboarding in < 10 minutes
- Photo verification < 10 seconds
- 90%+ verification success rate
- Progress persists across app restarts

## Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E02-T01 | Design integrated profiling schema (psychological + physical preferences) | Backend | 3 | |
| E02-T02 | Build question set versioning system | Backend | 5 | |
| E02-T03 | Create questionnaire response API | Backend | 3 | |
| E02-T04 | Implement progress auto-save (per question) | Backend | 2 | |
| E02-T05 | Build location API (geocode + manual entry) | Backend | 3 | |
| E02-T06 | Create verification session API | Backend | 3 | |
| E02-T07 | Integrate AWS Rekognition liveness verification | Backend | 3 | |
| E02-T08 | Build onboarding state machine (backend) | Backend | 3 | |
| E02-T09 | Design onboarding flow wireframes | Product | 2 | |
| E02-T10 | Build profile creation screens (name, bio, age) | Mobile | 5 | |
| E02-T11 | Build verification UI flow (consent, capture, result) | Mobile | 5 | |
| E02-T12 | Build location permission + manual entry UI | Mobile | 3 | |
| E02-T13 | Build questionnaire screen (single question) | Mobile | 5 | |
| E02-T14 | Implement questionnaire progress indicator | Mobile | 2 | |
| E02-T15 | Build onboarding completion screen | Mobile | 2 | |
| E02-T16 | Implement onboarding state machine (client) | Mobile | 3 | |
| E02-T17 | Add analytics events for onboarding | Mobile | 2 | |
| E02-T18 | Write onboarding + verification E2E tests | QA | 5 | |

**Total Points:** 59

## Definition of Done

- [ ] User can complete full onboarding in < 10 minutes
- [ ] Progress persists across app restarts
- [ ] Integrated profiling questions completed and stored
- [ ] Verification completion rate > 90%
- [ ] Location captured (GPS or manual)
- [ ] Analytics events firing correctly

## Dependencies

- E01: Identity & Core Platform

## Related Documents

- `docs/specs/onboarding.md`
- `docs/ux/flows/onboarding.md`
