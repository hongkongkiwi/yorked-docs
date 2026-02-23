# Epics

Owner: Product + Engineering
Status: Active
Last Updated: 2026-02-23
Depends On: `docs/execution/README.md`

## Purpose

Epic-level specifications grouped by capability. This index is a roll-up view of execution.

## Canonical Source

For sequencing, timing windows, and dependency order, use:

`docs/execution/epic-plans/implementation-plan.md`

If an individual epic doc conflicts with the implementation plan, the implementation plan wins.

## MVP Epic Index (Committed)

| Epic | Name | Window | Status | Canonical Plan |
|------|------|----------|--------|--------|
| [Epic 0](../epic-plans/phase-0-monorepo-setup.md) | Monorepo Setup | 1-2 days | Planned | [`phase-0-monorepo-setup.md`](../epic-plans/phase-0-monorepo-setup.md) |
| [E01](E01-identity.md) | Identity & Core Platform | Weeks 1-2 | Active | [`implementation-plan.md`](../epic-plans/implementation-plan.md) |
| [E02](E02-onboarding.md) | Onboarding & Verification Journey | Weeks 3-5 | Active | [`implementation-plan.md`](../epic-plans/implementation-plan.md) |
| [E03](E03-matching.md) | Curated Matching Experience | Weeks 6-8 | Active | [`implementation-plan.md`](../epic-plans/implementation-plan.md) |
| [E04](E04-chat.md) | Messaging Core (Polling + Push) | Weeks 9-10 | Active | [`implementation-plan.md`](../epic-plans/implementation-plan.md) |
| [E05](E05-safety.md) | Trust & Safety Experience | Weeks 11-12 | Active | [`implementation-plan.md`](../epic-plans/implementation-plan.md) |
| [E06](E06-launch.md) | Reliability & Launch Experience | Weeks 13-14 | Active | [`implementation-plan.md`](../epic-plans/implementation-plan.md) |
| Epic 7 | Real-Time Messaging Upgrade (Post-launch) | Post-launch / Next | Planned | [`implementation-plan.md`](../epic-plans/implementation-plan.md) |

## Post-MVP Epics (Exploratory)

| Epic | Name | Duration | Points | Status |
|------|------|----------|--------|--------|
| E07 | Attraction Signal Foundations | 4 weeks | 26 | Exploratory |
| E08 | Photo Studio Lite | 6 weeks | 58 | Exploratory |
| E09 | Enhanced Matching | 4 weeks | 52 | Exploratory |
| E10 | AI Questionnaire Assistant | 3 weeks | 33 | Exploratory |
| E11 | AI Conversation Coach | 3 weeks | 32 | Exploratory |
| E12 | AI Comfort Bot | 2 weeks | 17 | Exploratory |
| E13 | Face Generation | 4 weeks | 40 | Exploratory |
| E14 | Preference Learning | 3 weeks | 37 | Exploratory |
| E15 | Mutual Attraction Matching | 3 weeks | 32 | Exploratory |

**Total Exploratory Points:** 327

## Epic to Spec Mapping

| Epic | Specs |
|------|-------|
| E01: Identity | `specs/onboarding.md` (auth portion) |
| E02: Onboarding | `specs/onboarding.md`, `specs/visual-preference-studio.md`, `specs/science-backed-relationship-question-bank.md` |
| E03: Matching | `specs/matching.md`, `specs/matching-scoring-engine.md`, `specs/gender-responsive-matching.md` |
| E04: Chat | `specs/chat.md` |
| E05: Safety | `specs/safety.md` |
| E06: Launch | `ops/slo-sla.md`, `ops/testing-strategy.md` |

## Maintenance Rule

Detailed task breakdowns in individual epic docs are planning drafts and may lag.
Before sprint planning, reconcile each active epic doc against:

1. `docs/execution/epic-plans/implementation-plan.md`
2. `docs/execution/delivery-checklist.md`
