# Execution & Delivery

Owner: Product + Engineering  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/vision/`

## Purpose

Epics, phases, and delivery tracking. This is where vision becomes actionable work.

## Hierarchy Level

**Level 2: Epics/Phases** — Translates vision into execution

## Structure

```
execution/
├── README.md                 # This file
├── delivery-checklist.md     # Phase exit criteria and evidence
├── backlog.md                # Kanban-style task breakdown
├── phases/
│   ├── phase-0-monorepo-setup.md  # Initial scaffolding (before E01)
│   ├── implementation-plan.md
│   └── intent-phase-canonical-map.md
└── epics/                    # Epic-level specs
```

## Phase Definitions

| Phase | Focus | Exit Criteria |
|-------|-------|---------------|
| Phase 0 | Monorepo scaffolding | All apps runnable, `pnpm build` passes |
| Intent | Validate core matching hypothesis | See `phases/intent-phase-canonical-map.md` |
| MVP | Launch to first users | See `delivery-checklist.md` |

## Authority Model

| File | Authority Level |
|------|-----------------|
| `delivery-checklist.md` | Execution Canonical |
| `phases/*.md` | Execution Canonical |
| `backlog.md` | Planning Context |

## Linking to Specs

Each epic should reference its constituent specs:

```
Epic: Matching Engine
├── specs/matching.md
├── specs/matching-scoring-engine.md
└── specs/gender-responsive-matching.md
```
