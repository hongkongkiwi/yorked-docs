# Execution & Delivery

Owner: Product + Engineering
Status: Active
Last Updated: 2026-02-23
Depends On: `docs/vision/`

## Purpose

Epics and delivery tracking. This is where vision becomes actionable work.

## Hierarchy Level

**Level 2: Epics** — Translates vision into execution

## Structure

```
execution/
├── README.md                 # This file
├── delivery-checklist.md     # Epic exit criteria and evidence
├── backlog.md                # Kanban-style task breakdown
├── epic-plans/
│   ├── phase-0-monorepo-setup.md  # Epic 0 scaffolding (legacy filename)
│   ├── implementation-plan.md
│   └── intent-phase-canonical-map.md
└── epics/                    # Epic-level specs
```

## Epic Definitions

| Epic | Focus | Exit Criteria |
|------|-------|---------------|
| Epic 0 | Monorepo scaffolding | All apps runnable, `pnpm build` passes |
| Intent Epic | Validate core matching hypothesis | See `epic-plans/intent-phase-canonical-map.md` |
| MVP Epics | Launch to first users | See `epic-plans/implementation-plan.md` and `delivery-checklist.md` |

## Authority Model

| File | Authority Level |
|------|-----------------|
| `delivery-checklist.md` | Execution Canonical |
| `epic-plans/*.md` | Execution Canonical (epic plans and canonical maps) |
| `backlog.md` | Planning Context |

## Linking to Specs

Each epic should reference its constituent specs:

```
Epic: Matching Engine
├── specs/matching.md
├── specs/matching-scoring-engine.md
└── specs/gender-responsive-matching.md
```
