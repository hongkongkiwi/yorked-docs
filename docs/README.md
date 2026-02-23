# Documentation Guide

Owner: Engineering  
Status: Active  
Last Updated: 2026-02-20  
Depends On: N/A

This directory is the shared product and engineering source of truth for Yoked. Use this file as the map for where decisions live and what to trust when docs disagree.

## Philosophy: Spec-Driven Development

Specs lead implementation, not the other way around.

**Golden Rule:** Never implement without a spec. If a spec doesn't exist, create it first.

## Team Context

We're a small team in startup mode. What this means for docs:

- **No separate teams** — Everyone contributes across domains (product, engineering, ops, safety)
- **Lightweight process** — Docs should be practical, not bureaucratic
- **Owner = accountable person** — May be same person wearing multiple hats
- **Iterate fast** — Docs can be drafts; ship first, refine later
- **Avoid premature abstraction** — Don't over-organize for a team we don't have yet

## Documentation Hierarchy

| Level | Location | Contains | Purpose |
|-------|----------|----------|---------|
| **1. Vision** | `vision/` | Product vision, roadmap, competitive | *What & Why* |
| **2. Epics** | `execution/` | Phases, epics, delivery tracking | *Sequencing & Scope* |
| **3. Stories** | `specs/` | Feature specs with acceptance criteria | *Requirements* |
| **4. Technical** | `technical/` | Contracts, ADRs, schema, architecture | *Implementation Authority* |

## Source of Truth Priority

When information conflicts, follow this order:

1. **`technical/contracts/`** — API, WebSocket, and integration contracts (highest technical authority)
2. **`technical/decisions/`** — Architecture Decision Records (ADRs) — irreversible decisions
3. **`specs/`** — Feature specifications with acceptance criteria
4. **`ux/`** — User flow and experience specifications
5. **`ops/`** — Operational requirements (SLO/SLA, runbooks)
6. **`trust-safety/`** — Safety and compliance requirements
7. **`execution/`** — Planning artifacts and sequencing (informative)
8. **`vision/`** — Strategic direction (contextual)

## Folder Structure

```
docs/
├── AGENTS.md              # Agent workflow guide (START HERE for AI assistants)
├── README.md              # This file
│
├── vision/                # Level 1: Vision & Strategy
│   ├── README.md
│   ├── product-vision.md  # Overall idea, business model
│   ├── roadmap.md         # Product roadmap
│   ├── competitive.md     # Competitive landscape
│   └── ideas.md           # Future ideas (not committed)
│
├── execution/             # Level 2: Epics & Phases
│   ├── README.md
│   ├── delivery-checklist.md
│   ├── backlog.md
│   ├── phases/
│   │   ├── README.md
│   │   ├── implementation-plan.md
│   │   └── intent-phase-canonical-map.md
│   └── epics/
│       └── README.md
│
├── specs/                 # Level 3: Feature Stories
│   ├── onboarding.md
│   ├── matching.md
│   ├── matching-scoring-engine.md
│   ├── gender-responsive-matching.md
│   ├── visual-preference-studio.md
│   ├── chat.md
│   └── safety.md
│
├── technical/             # Level 4: Technical Authority
│   ├── README.md
│   ├── contracts/         # API contracts (HIGHEST AUTHORITY)
│   │   ├── openapi.yaml
│   │   ├── events.md
│   │   ├── websocket-events.md
│   │   ├── auth-session-contract.md
│   │   └── idempotency-and-retries.md
│   ├── decisions/         # ADRs
│   │   ├── ADR-0000-template.md
│   │   ├── ADR-0001-supabase-over-convex.md
│   │   └── ...
│   ├── schema/            # Database schema
│   ├── architecture/      # System architecture
│   └── ai/                # AI/ML specifications
│
├── ux/                    # User Experience
│   └── flows/
│       ├── matching.md
│       ├── chat.md
│       └── onboarding.md
│
├── ops/                   # Operations
│   ├── configuration.md
│   ├── infrastructure.md
│   ├── admin-operations.md
│   ├── matching-cohort-metrics.md
│   ├── privacy-security.md
│   ├── slo-sla.md
│   └── testing-strategy.md
│
└── trust-safety/          # Safety & Compliance
    ├── README.md
    └── legal-escalation-and-evidence.md
```

## Document Requirements

Every document must include:

- **Owner**: Team or person responsible
- **Status**: Must use the status taxonomy below
- **Last Updated**: YYYY-MM-DD
- **Depends On**: List of dependencies

## Status Taxonomy

| Doc Type | Allowed Status |
|----------|----------------|
| Specs, Contracts, UX, Ops, Schema, READMEs | Draft \| Planned \| Active \| Deprecated |
| ADRs (`technical/decisions/ADR-*.md`) | Proposed \| Accepted \| Superseded \| Deprecated |
| Execution docs (`execution/*.md`) | Draft \| Active \| Archived |
| Vision docs (`vision/*.md`) | Draft \| Active \| Archived |

**Status Definitions:**
- **Draft**: Work in progress, not ready for implementation
- **Planned**: Placeholder, not yet started (for future specs)
- **Active**: Current source of truth, ready for implementation
- **Deprecated**: Replaced or no longer relevant
- **Archived**: Historical record only

## Workflow Rules

1. **Specs first** — start with a spec before writing implementation code
2. **Contracts are law** — API contracts have the highest technical authority
3. **ADRs for irreversible decisions** — use ADRs for choices that are expensive to unwind
4. **Version everything** — reference spec versions in implementation work
5. **Update docs first** — change the spec before changing the code

## Change Process

1. Propose change as PR to relevant spec
2. Review for contract compatibility
3. Update dependent specs
4. Merge, then implement

## For AI Assistants

See **`AGENTS.md`** for detailed workflow instructions.

## Quick Links

| Need | Location |
|------|----------|
| Getting Started | `AGENTS.md` |
| Product Vision | `vision/product-vision.md` |
| Roadmap | `vision/roadmap.md` |
| Phase Status | `execution/delivery-checklist.md` |
| API Reference | `technical/contracts/openapi.yaml` |
| Feature Specs | `specs/` |
| Architecture Decisions | `technical/decisions/` |
| Database Schema | `technical/schema/database.md` |
