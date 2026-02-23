# Yoked: Execution Backlog (Rolled Up)

Owner: Product + Engineering
Status: Active
Last Updated: 2026-02-23
Depends On:
- `docs/execution/epic-plans/implementation-plan.md`
- `docs/execution/delivery-checklist.md`
- `docs/vision/roadmap.md`

## Purpose

Single backlog view for prioritization and sprint intake.
This file intentionally avoids deep duplicate task lists to reduce drift.

## Canonical Planning Sources

1. Sequencing and scope: `docs/execution/epic-plans/implementation-plan.md`
2. Exit gates and evidence: `docs/execution/delivery-checklist.md`
3. Epic-level feature detail: `docs/execution/epics/`

## Committed MVP Queue

| Order | Epic | Window | Dependency | Focus | Status |
|------|------|--------|------------|-------|--------|
| 0 | Epic 0: Monorepo Setup | 1-2 days | None | Repo and app scaffolding | Planned |
| 1 | E01: Identity & Core Platform | Weeks 1-2 | Epic 0 | Auth, profile, platform baseline | Active |
| 2 | E02: Onboarding & Verification Journey | Weeks 3-5 | E01 | Onboarding flow + verification | Active |
| 3 | E03: Curated Matching Experience | Weeks 6-8 | E02 | Offer generation + decisions | Active |
| 4 | E04: Messaging Core (Polling + Push) | Weeks 9-10 | E03 | Chat core without realtime infra | Active |
| 5 | E05: Trust & Safety Experience | Weeks 11-12 | E04 | Moderation and enforcement | Active |
| 6 | E06: Reliability & Launch Experience | Weeks 13-14 | E05 | Hardening and launch readiness | Active |

## Deferred Next Queue

| Order | Epic | Window | Dependency | Focus | Status |
|------|------|--------|------------|-------|--------|
| 7 | Epic 7: Real-Time Messaging Upgrade | Post-launch / Next | E06 | WebSocket transport, typing, presence | Planned |

## Exploratory Backlog (Not Committed)

| Epic | Theme | Priority | Status |
|------|-------|----------|--------|
| E07 | Attraction Signal Foundations | P1 | Exploratory |
| E08 | Photo Studio Lite | P1 | Exploratory |
| E09 | Enhanced Matching | P1 | Exploratory |
| E10 | AI Questionnaire Assistant | P2 | Exploratory |
| E11 | AI Conversation Coach | P2 | Exploratory |
| E12 | AI Comfort Bot | P2 | Exploratory |
| E13 | Face Generation | P2 | Exploratory |
| E14 | Preference Learning | P2 | Exploratory |
| E15 | Mutual Attraction Matching | P2 | Exploratory |

## Working Agreement

- Move items between queues only via changes to `implementation-plan.md`.
- Keep per-epic deep task lists inside `docs/execution/epics/E*.md`.
- If an epic changes scope, update this backlog and the delivery checklist in the same PR.
