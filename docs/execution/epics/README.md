# Epics

Owner: Product + Engineering  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/execution/README.md`

## Purpose

Epic-level specifications that group related features. Each epic represents a major capability with clear deliverables and success metrics.

## Epic Index

### MVP Epics (Committed)

| Epic | Name | Duration | Points | Status |
|------|------|----------|--------|--------|
| [Phase 0](phases/phase-0-monorepo-setup.md) | Monorepo Setup | 1-2 days | 17 | Planned |
| [E01](E01-identity.md) | Identity & Core Platform | 4 weeks | 43 | Active |
| [E02](E02-onboarding.md) | Onboarding & Verification Journey | 4 weeks | 59 | Active |
| [E03](E03-matching.md) | Curated Matching Experience | 4 weeks | 68 | Active |
| [E04](E04-chat.md) | Real-Time Messaging Experience | 4 weeks | 70 | Active |
| [E05](E05-safety.md) | Trust & Safety Experience | 4 weeks | 27 | Active |
| [E06](E06-launch.md) | Reliability & Launch Experience | 4 weeks | 48 | Active |

**Total MVP Points:** 315 (excluding Phase 0: 17)  
**Total MVP Duration:** 24 weeks

### Post-MVP Epics (Exploratory)

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

## Epic → Spec Mapping

| Epic | Specs |
|------|-------|
| E01: Identity | `specs/onboarding.md` (auth portion) |
| E02: Onboarding | `specs/onboarding.md`, `specs/visual-preference-studio.md`, `specs/science-backed-relationship-question-bank.md` |
| E03: Matching | `specs/matching.md`, `specs/matching-scoring-engine.md`, `specs/gender-responsive-matching.md` |
| E04: Chat | `specs/chat.md` |
| E05: Safety | `specs/safety.md` |
| E06: Launch | `ops/slo-sla.md`, `ops/testing-strategy.md` |

## Epic Template

When creating a new epic:

```markdown
# Epic: [Name]

Owner: [Team]
Status: Draft | Active | Complete
Last Updated: YYYY-MM-DD
Depends On: [Other epic or dependency]

## Overview
Brief description of the epic capability.

## Specs
- [spec-name.md](../specs/spec-name.md)

## Success Metrics
- Metric 1: Target
- Metric 2: Target

## Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| EXX-T01 | Task description | Team | X | |

**Total Points:** X

## Definition of Done
- [ ] Criterion 1
- [ ] Criterion 2

## Dependencies
- [List]

## Related Documents
- [Links to specs, ADRs, etc.]
```

## Adding New Epics

1. Create epic doc in this directory using template
2. Link to constituent specs in `docs/specs/`
3. Reference from relevant phase in `phases/`
4. Update this README index

## Task Status

| Status | Meaning |
|--------|---------|
| (empty) | Not started |
| In Progress | Currently being worked on |
| Done | Completed |
| Blocked | Waiting on dependency |
