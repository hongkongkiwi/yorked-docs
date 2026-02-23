# Epic: Identity & Core Platform

Owner: Backend + Mobile
Status: Active
Last Updated: 2026-02-23
Depends On: `docs/technical/decisions/ADR-0001-supabase-over-convex.md`, `docs/technical/decisions/ADR-0011-monorepo-project-structure.md`, `docs/technical/decisions/ADR-0012-expo-for-mobile.md`, `docs/execution/epic-plans/phase-0-monorepo-setup.md`

## Overview

Core infrastructure, authentication, and user management. Foundation for all other features.

**Window:** Weeks 1-2
**Epic:** E01
**Priority:** P0 (Committed)
**Prerequisite:** Epic 0 (Monorepo Setup) must be complete

> **Canonical sequencing and scope:** `docs/execution/epic-plans/implementation-plan.md`.
> Task tables below are detailed drafts and may lag; reconcile against the implementation plan before sprint execution.

## Specs

- `docs/specs/onboarding.md` (authentication portion)

## Success Metrics

- Full stack runs locally with single command
- User can authenticate via phone OTP
- User profile can be created/updated via API
- Mobile app persists auth state across restarts
- CI passes on all PRs

## Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E01-T01 | Copy OpenAPI/AsyncAPI specs to apps/api/ | Backend | 1 | |
| E01-T02 | Generate initial API client types | Backend | 1 | |
| E01-T03 | Configure Supabase project with local development | Backend | 2 | |
| E01-T04 | Create database migration system (Supabase CLI) | Backend | 2 | |
| E01-T05 | Implement core schema migrations (users, profiles) | Backend | 5 | |
| E01-T06 | Implement phone OTP authentication endpoint | Backend | 5 | |
| E01-T07 | Create user profile CRUD API | Backend | 3 | |
| E01-T08 | Set up API error handling and response standards | Backend | 2 | |
| E01-T09 | Configure request validation with Zod | Backend | 2 | |
| E01-T10 | Set up React Navigation structure | Mobile | 3 | |
| E01-T11 | Create API client with auth token handling | Mobile | 3 | |
| E01-T12 | Implement auth state management (Zustand) | Mobile | 2 | |
| E01-T13 | Build phone number input screen | Mobile | 3 | |
| E01-T14 | Build OTP verification screen | Mobile | 3 | |
| E01-T15 | Write auth flow E2E tests (Maestro) | QA | 3 | |
| E01-T16 | Set up CI/CD pipeline | Backend | 3 | |

**Total Points:** 43

## Definition of Done

- [ ] Full stack runs locally with single command
- [ ] User can authenticate via phone OTP
- [ ] User profile can be created/updated via API
- [ ] Mobile app persists auth state across restarts
- [ ] CI passes on all PRs

## Dependencies

- Epic 0 (Monorepo Setup) - must be complete
- Supabase project created

## Related Documents

- `docs/technical/decisions/ADR-0001-supabase-over-convex.md`
- `docs/technical/decisions/ADR-0011-monorepo-project-structure.md`
- `docs/technical/decisions/ADR-0012-expo-for-mobile.md`
- `docs/execution/epic-plans/phase-0-monorepo-setup.md`
- `docs/technical/schema/database.md`
- `docs/technical/contracts/openapi.yaml`
