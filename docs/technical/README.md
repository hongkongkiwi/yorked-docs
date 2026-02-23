# Technical Documentation

Owner: Engineering  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/specs/`

## Purpose

Technical contracts, architecture decisions, and implementation details. These are the highest technical authority documents.

## Hierarchy Level

**Level 4: Technical Details** — Implementation authority

## Structure

```
technical/
├── README.md                 # This file
├── contracts/                # API & integration contracts (HIGHEST AUTHORITY)
│   ├── openapi.yaml          # Public API spec
│   ├── events.md
│   ├── websocket-events.md
│   ├── auth-session-contract.md
│   └── idempotency-and-retries.md
├── decisions/                # Architecture Decision Records (ADRs)
│   ├── ADR-0000-template.md
│   ├── ADR-0001-supabase-over-convex.md
│   ├── ADR-0011-monorepo-project-structure.md
│   └── ...
├── schema/                   # Database schema
│   ├── database.md
│   └── README.md
├── architecture/             # System architecture
│   ├── README.md
│   └── module-boundary-enforcement-checklist.md
└── ai/                       # AI/ML specifications
    └── README.md
```

## Projects

Per `ADR-0011-monorepo-project-structure.md`, Yoked has four apps:

| App | Location | Tech | Purpose |
|-----|----------|------|---------|
| Public API | `apps/api/` | Hono | User-facing REST + WebSocket |
| Admin API | `apps/admin-api/` | Hono | Admin-only REST API |
| Admin UI | `apps/admin/` | TanStack Start | Admin interface |
| Mobile | `apps/mobile/` | React Native | iOS app |

## API Specs & SDKs

Two spec standards with different generation approaches:

| Spec | Purpose | Location | Generation |
|------|---------|----------|------------|
| **OpenAPI** | REST APIs | `apps/*/openapi.yaml` | Full SDK via `openapi-typescript` |
| **AsyncAPI** | WebSocket | `apps/api/asyncapi.yaml` | Types via Modelina; client hand-written |

**Packages:**
- `packages/api-client/` - Public REST SDK (full generation)
- `packages/ws-client/` - WebSocket client (generated types + hand-written client)
- `packages/admin-api-client/` - Admin REST SDK (full generation)

## Source of Truth Priority

Within technical docs:

1. **`contracts/`** — API contracts are law
2. **`decisions/`** — ADRs for irreversible decisions
3. **`schema/`** — Database structure
4. **`architecture/`** — System design patterns

## When to Create Technical Docs

| Doc Type | When to Create |
|----------|----------------|
| Contract | Before implementing any API |
| ADR | Before making expensive-to-reverse decisions |
| Schema | When adding/modifying tables |
| Architecture | When designing system boundaries |

## Cross-References

Technical docs should reference:
- Related `specs/` for feature requirements
- Related `execution/epics/` for context
