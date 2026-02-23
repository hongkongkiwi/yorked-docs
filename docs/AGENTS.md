# AGENTS.md

Scope: applies to everything under `docs/`.

Owner: Engineering  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/README.md`

## Purpose

Enable spec-driven development by ensuring agents work from specifications, not assumptions. Specifications are the source of truth.

## Core Principle: Specs First

**Never implement without a spec.** If a spec doesn't exist, create it first.

## Documentation Hierarchy

| Level | Location | Contains | When to Use |
|-------|----------|----------|-------------|
| **1. Vision** | `vision/` | Product vision, roadmap, competitive | Understanding *why* we're building something |
| **2. Epics** | `execution/` | Phases, epics, delivery tracking | Understanding scope and sequencing |
| **3. Stories** | `specs/` | Feature specs with acceptance criteria | Implementing features |
| **4. Technical** | `technical/` | Contracts, ADRs, schema, architecture | API design, architecture decisions |

### Quick Navigation

```
docs/
├── vision/           # WHAT & WHY (business context)
├── execution/        # WHEN (phases, epics, delivery)
├── specs/            # WHAT (feature requirements)
├── technical/        # HOW (implementation authority)
├── ux/               # User experience flows
├── ops/              # Operations & runbooks
└── trust-safety/     # Safety & compliance
```

## Governance Source

Documentation governance is centralized in `docs/README.md`:

- Source-of-truth ordering
- Document requirements
- Status taxonomy by doc type
- Folder structure reference

Agents should follow `docs/README.md` as policy and use this file for workflow.

## Agent Workflow

### Before Starting Work

1. **Ensure superpowers is installed** — Invoke `.skillshare/superpowers-setup` skill to check/setup
2. **Check for skills** — Invoke relevant skills BEFORE any response or action (even 1% chance)
3. **Read the spec** — Find relevant spec in `docs/specs/`
4. **Check contracts** — Verify API contracts in `docs/technical/contracts/`
5. **Review ADRs** — Check `docs/technical/decisions/` for architectural decisions
6. **Identify dependencies** — Check `Depends On` field

**Important:** The superpowers skill system requires checking for skills first. If a skill might apply to your task, you MUST invoke it. This is not optional.

### During Implementation

1. **Follow contracts exactly** — Don't deviate from API specs
2. **Reference acceptance criteria** — Implement all ACs from specs
3. **Update specs if needed** — Specs change, code follows
4. **Add missing specs** — Create specs for new features

### When Specs Are Missing

If you need to implement something without a spec:

1. Create the spec first in `docs/specs/`
2. Include: user stories, acceptance criteria, API contracts
3. Get review (if process requires)
4. Then implement

## Folder Reference

| Folder | Contains | Authority |
|--------|----------|-----------|
| `docs/vision/` | Product vision, roadmap, competitive analysis | Strategic context |
| `docs/execution/` | Phases, epics, delivery checklists | Execution planning |
| `docs/specs/` | Feature specs with acceptance criteria | Feature requirements |
| `docs/technical/contracts/` | OpenAPI, WebSocket events, auth contracts | Highest technical |
| `docs/technical/decisions/` | ADRs for architecture decisions | Irreversible decisions |
| `docs/technical/schema/` | Database schema | Data structure |
| `docs/technical/architecture/` | System context, boundaries | Design context |
| `docs/technical/ai/` | Model routing, evaluations | AI requirements |
| `docs/ux/` | User flows, screen specs | UX requirements |
| `docs/ops/` | SLO/SLA, runbooks | Operational requirements |
| `docs/trust-safety/` | Moderation, legal escalation | Compliance |

## Key File Locations

| Need | Location |
|------|----------|
| Product Vision | `docs/vision/product-vision.md` |
| Product Roadmap | `docs/vision/roadmap.md` |
| Phase Status | `docs/execution/delivery-checklist.md` |
| API Contracts | `docs/technical/contracts/openapi.yaml` |
| WebSocket Events | `docs/technical/contracts/websocket-events.md` |
| ADRs | `docs/technical/decisions/` |
| Database Schema | `docs/technical/schema/database.md` |
| Feature Specs | `docs/specs/` |
| UX Flows | `docs/ux/flows/` |

## Editing Rules

- **Specs over code** — If code and spec conflict, spec is correct
- **Version specs** — Major changes create new versions
- **Update metadata** — Always update `Last Updated` when editing
- **Link dependencies** — Use `Depends On` to link related docs
- **No orphaned specs** — Specs must be referenced by implementation

## Creating New Docs

### Feature Specification Template

```markdown
# Feature Specification: [Name]

Owner: [Team]  
Status: Draft  
Last Updated: YYYY-MM-DD  
Depends On: [dependencies]

## Overview

Brief description of the feature.

## User Stories

### US-001: [Title]

**As a** [role]  
**I want to** [goal]  
**So that** [benefit]

**Acceptance Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2

**API Contract:** [endpoint reference]

## Technical Requirements

### Performance
- Metric: Target

### Security
- Requirement

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| Case | Handling |

## Dependencies

- [List]

## Open Questions

1. Question?
```

### ADR Template

Use `docs/technical/decisions/ADR-0000-template.md` as base.

### Epic Template

Use `docs/execution/epics/README.md` for epic template.

## Consistency Checklist

Before finalizing any work:

- [ ] No contradictions with contracts
- [ ] All acceptance criteria addressed
- [ ] API contracts match implementation
- [ ] ADRs referenced for architectural decisions
- [ ] Dependencies documented
- [ ] Metadata complete (Owner, Status, Last Updated)

## Common Tasks

### Adding a New API Endpoint

1. Update `docs/technical/contracts/openapi.yaml`
2. Add tests for contract compliance
3. Update relevant feature spec in `docs/specs/`
4. Document in ADR if architectural

### Changing an API

1. Update spec first
2. Consider backward compatibility
3. Update version if breaking
4. Notify consumers
5. Update implementation

### Adding a Feature

1. Create spec in `docs/specs/`
2. Define acceptance criteria
3. Identify API contract needs
4. Create/update contracts in `docs/technical/contracts/`
5. Document UX flow in `docs/ux/flows/` if needed
6. Link from epic in `docs/execution/epics/`
7. Implement

### Making Architecture Decisions

1. Write ADR in `docs/technical/decisions/`
2. Use format: `ADR-XXXX-short-name.md`
3. Include context, decision, rationale, consequences
4. Reference from relevant specs
5. Get review if required

### Starting a New Phase

1. Create phase doc in `docs/execution/phases/`
2. Define exit criteria
3. Link to epics in `docs/execution/epics/`
4. Update `docs/execution/delivery-checklist.md`

## Skill System

This repository uses the skill system. Agents MUST follow these rules:

### Skill Invocation Rules

- **Invoke before acting** — Check for skills before any response or action
- **1% rule** — If there's even a 1% chance a skill applies, invoke it
- **No rationalizing** — Don't skip skills because "this is simple" or "I know this"
- **Follow exactly** — Rigid skills (TDD, debugging) must be followed exactly
- **Process first** — Use process skills (brainstorming, debugging) before implementation skills

### Project-Specific Skills

| Skill | Location | When to Use |
|-------|----------|-------------|
| `superpowers-setup` | `.skillshare/superpowers-setup/` | At start of every session |

### Superpowers Skills (External)

| Skill | When to Use |
|-------|-------------|
| `brainstorming` | Before any creative work or feature design |
| `debugging` | When investigating bugs or unexpected behavior |
| `test-driven-development` | Before implementing features or fixes |
| `verification-before-completion` | Before claiming work is done |
| `frontend-design` | When building UI components or pages |
| `writing-plans` | When creating implementation plans |

### Skill Priority

1. **Process skills first** — Determine HOW to approach the task
2. **Implementation skills second** — Guide execution

Example: "Build a feature" → brainstorming first, then implementation.

## Questions?

If unclear on process:
1. Check this file
2. Check `docs/README.md`
3. Check for relevant skills
4. Follow existing patterns in repo
5. When in doubt, create/update specs first
