# Feature Specifications

Owner: Product + Engineering  
Status: Active  
Last Updated: 2026-02-20
Depends On: `docs/vision/`, `docs/execution/`

## Purpose

Feature specifications define WHAT we're building. Each spec contains user stories, acceptance criteria, and technical requirements. Specs are the contract between product and engineering.

## Spec Index

### Core Features (MVP)

| Spec | Status | Description | Epic |
|------|--------|-------------|------|
| [onboarding.md](onboarding.md) | Active | Authentication, profile creation, questionnaire, verification | E02 |
| [matching.md](matching.md) | Active | Daily offers, accept/pass, mutual matches | E03 |
| [matching-scoring-engine.md](matching-scoring-engine.md) | Active | Compatibility algorithm, scoring pipeline | E03 |
| [gender-responsive-matching.md](gender-responsive-matching.md) | Active | Behavioral segment policy, fairness auditing | E03 |
| [visual-preference-studio.md](visual-preference-studio.md) | Active | Attraction preference capture via pairwise comparisons | E07 |
| [chat.md](chat.md) | Active | Real-time messaging, read receipts, typing indicators | E04 |
| [safety.md](safety.md) | Active | Reporting, blocking, moderation, evidence preservation | E05 |

### Supporting Features (MVP)

| Spec | Status | Description | Epic |
|------|--------|-------------|------|
| [notifications.md](notifications.md) | Planned | Push notifications, in-app notifications | E04, E05 |
| [settings.md](settings.md) | Planned | User preferences, account management, data export | E01 |

### Post-MVP Features

Monetization and other future features are captured in `docs/vision/ideas.md`, not as specs. Create specs only when ready to plan implementation.

### Question Banks

| Spec | Status | Description |
|------|--------|-------------|
| [science-backed-relationship-question-bank.md](science-backed-relationship-question-bank.md) | Active | Current production question set |
| ~~initial-stage-question-bank.md~~ | Deprecated | Superseded by science-backed version |

## Spec Template

```markdown
# Feature Specification: [Name]

Owner: [Team]  
Status: Draft | Active | Deprecated  
Last Updated: YYYY-MM-DD  
Depends On: [dependencies]

## Overview
Brief description.

## User Stories

### US-001: [Title]
**As a** [role]  
**I want to** [goal]  
**So that** [benefit]

**Acceptance Criteria:**
- [ ] Criterion 1

**API Contract:** [endpoint reference]

## Technical Requirements
### Performance
### Security

## Edge Cases
| Scenario | Behavior |

## Dependencies

## Open Questions
```

## Spec Quality Checklist

Before marking a spec as `Active`:
- [ ] All user stories have acceptance criteria
- [ ] API contracts referenced or defined
- [ ] Edge cases documented
- [ ] Performance requirements specified
- [ ] Security considerations addressed
- [ ] Dependencies listed
- [ ] Linked to epic in `execution/epics/`

## Relationship to Other Docs

```
vision/          → Why we're building this
execution/epics/ → Which epic owns this feature
specs/           → What we're building (THIS FOLDER)
technical/       → How we implement it
ux/flows/        → How users experience it
```

## Status Definitions

| Status | Meaning |
|--------|---------|
| Draft | Work in progress, not ready for implementation |
| Active | Approved and implementation-ready |
| Deprecated | Superseded, do not use for new work |
| Planned | Placeholder, not yet started |
