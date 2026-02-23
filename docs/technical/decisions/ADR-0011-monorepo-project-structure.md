# ADR-0011: Monorepo Project Structure

Date: 2026-02-20  
Status: Accepted  
Owner: Engineering  
Last Updated: 2026-02-20  
Depends On: `docs/technical/decisions/ADR-0001-supabase-over-convex.md`, `docs/technical/decisions/ADR-0009-api-hosting.md`

## Context

Yoked requires three distinct applications:

1. **Backend API** - REST API, WebSocket server, background jobs
2. **Admin Interface** - Internal tools for moderation, user management, analytics
3. **Mobile Client** - iOS app (React Native), Android later

We need a repository structure that:
- Enables code sharing between projects
- Supports independent deployment
- Maintains clear boundaries
- Works well with our chosen stack (Supabase, Railway/Fly.io, TanStack Start)

## Decision

Adopt a **monorepo structure** with three apps and shared packages:

```
yoked/
├── apps/
│   ├── api/                 # Public API (Hono/Fastify)
│   │   ├── src/
│   │   ├── openapi.yaml     # REST API spec (source of truth)
│   │   ├── asyncapi.yaml    # WebSocket spec (source of truth)
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── admin-api/           # Admin API (Hono/Fastify)
│   │   ├── src/
│   │   ├── openapi.yaml     # Admin API spec (source of truth)
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── admin/               # Admin interface (TanStack Start)
│   │   ├── src/
│   │   ├── app.config.ts
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   └── mobile/              # React Native iOS app
│       ├── src/
│       ├── ios/
│       ├── app.json
│       ├── package.json
│       └── tsconfig.json
│
├── packages/
│   ├── shared/              # Shared types, constants, utilities
│   │   ├── src/
│   │   │   ├── types/       # Domain types
│   │   │   ├── constants/   # Shared constants
│   │   │   └── utils/       # Shared utilities
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── api-client/          # Generated SDK for public REST API
│   │   ├── src/
│   │   │   └── generated/   # Auto-generated from apps/api/openapi.yaml
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── ws-client/           # WebSocket client (types generated, client hand-written)
│   │   ├── src/
│   │   │   ├── generated/   # Types from apps/api/asyncapi.yaml (Modelina)
│   │   │   ├── client.ts    # Hand-written WebSocket client
│   │   │   └── index.ts
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── admin-api-client/    # Generated SDK for admin API
│   │   ├── src/
│   │   │   └── generated/   # Auto-generated from apps/admin-api/openapi.yaml
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   └── eslint-config/       # Shared ESLint config
│       ├── package.json
│       └── index.js
│
├── infra/                   # Infrastructure as code
│   ├── tofu/
│   └── infisical/
│
├── docs/                    # Documentation (this repo)
│
├── package.json             # Root package.json (workspaces)
├── pnpm-workspace.yaml
├── turbo.json               # Turborepo config
└── tsconfig.base.json
```

## Rationale

### Why Monorepo

1. **Code Sharing**
   - Shared types between API, mobile, and admin
   - Single source of truth for API contracts
   - Consistent domain models across projects

2. **Simplified Development**
   - Single clone for full-stack development
   - Atomic commits across projects
   - Easier refactoring across boundaries

3. **Team Size**
   - Small team doesn't need repo overhead
   - Single CI/CD pipeline
   - Shared tooling

### Why This Structure

| Directory | Purpose | Tech Stack |
|-----------|---------|------------|
| `apps/api/` | Public REST API + WebSocket | Hono/Fastify, TypeScript |
| `apps/admin-api/` | Admin-only REST API | Hono/Fastify, TypeScript |
| `apps/admin/` | Internal admin tools | TanStack Start, React, Tailwind |
| `apps/mobile/` | iOS app | React Native, Expo |
| `packages/shared/` | Shared types/constants | TypeScript |
| `packages/api-client/` | Public REST SDK (generated) | OpenAPI → TypeScript (full SDK) |
| `packages/ws-client/` | WebSocket client | AsyncAPI → TypeScript (types) + hand-written client |
| `packages/admin-api-client/` | Admin API SDK (generated) | OpenAPI → TypeScript (full SDK) |

### Why Separate Admin API

1. **Security Isolation**
   - Admin API on separate domain/subdomain
   - Different auth requirements (admin users only)
   - Different rate limits and access controls

2. **Independent Scaling**
   - Admin traffic patterns differ from user traffic
   - Can deploy independently

3. **Clear Boundaries**
   - Admin operations are distinct from user operations
   - Separate OpenAPI specs per audience
   - Easier to audit admin-only endpoints

### Why TanStack Start for Admin

1. **Full-stack React** - Server functions for admin operations
2. **Type safety** - End-to-end types from API to UI
3. **Simple deployment** - Single deploy to Vercel/Fly
4. **Not user-facing** - SEO not needed, simpler requirements
5. **Team familiarity** - React ecosystem

### Why React Native for Mobile

1. **Single codebase** - iOS now, Android later with minimal changes
2. **Expo** - Simplified build and deployment
3. **Hot reload** - Fast development iteration
4. **Native modules** - Camera, notifications, biometrics

### SDK Generation Flow

**Two spec standards with different maturity levels:**

| Spec | Purpose | Generation |
|------|---------|------------|
| **OpenAPI** | REST APIs | Full SDK generated via `openapi-typescript` |
| **AsyncAPI** | WebSocket events | Types generated via Modelina; client hand-written |

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        API Specs (Source of Truth)                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  REST APIs (OpenAPI)                 WebSocket (AsyncAPI)               │
│  ───────────────────                 ──────────────────                │
│  Mature ecosystem                    Types only, client hand-written   │
│                                                                         │
│  apps/api/openapi.yaml                apps/api/asyncapi.yaml            │
│         │                                    │                          │
│         ▼                                    ▼                          │
│  ┌──────────────┐                    ┌──────────────┐                  │
│  │ openapi-     │                    │  Modelina    │                  │
│  │ typescript   │                    │  (types only)│                  │
│  └──────────────┘                    └──────────────┘                  │
│         │                                    │                          │
│         ▼                                    ▼                          │
│  packages/api-client/                packages/ws-client/                │
│  └── src/generated/                  ├── src/generated/ (types)        │
│  (full SDK)                          └── src/client.ts (hand-written)  │
│                                                                         │
│  apps/admin-api/openapi.yaml                                            │
│         │                                                               │
│         ▼                                                               │
│  packages/admin-api-client/                                             │
│  └── src/generated/ (full SDK)                                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

**Why hand-write WebSocket client?**

AsyncAPI's ecosystem doesn't have mature WebSocket client generators like OpenAPI has for REST. The pragmatic approach:
1. Use AsyncAPI to define events (documentation + source of truth)
2. Use Modelina to generate TypeScript types from payloads
3. Hand-write the WebSocket client using those types

This gives us type safety without the complexity of building/maintaining a custom AsyncAPI template.

**Generation workflow:**
```bash
# Generate REST SDKs (full clients)
pnpm --filter api-client generate
pnpm --filter admin-api-client generate

# Generate WebSocket types only
pnpm --filter ws-client generate:types
```

**SDK features:**

REST SDKs (generated):
- Full TypeScript types for requests/responses
- Runtime validation
- Auth token injection
- Retry logic and error handling

WebSocket client (hand-written with generated types):
- Typed event payloads from AsyncAPI
- Connection lifecycle management
- Auto-reconnect with backoff
- Subscription management

## Alternatives Considered

### Separate Repositories

**Pros:**
- Independent versioning
- Separate CI/CD pipelines
- Clear ownership boundaries

**Cons:**
- Code sharing complexity
- Coordination overhead
- Duplicate tooling setup

**Decision:** Rejected - overhead doesn't match team size

### Nx vs Turborepo

**Turborepo chosen because:**
- Simpler configuration
- Better pnpm integration
- Sufficient for 3 apps + packages

## Consequences

### Positive

- Single clone for full development environment
- Shared types eliminate drift between API and clients
- Atomic commits for cross-project changes
- Simplified CI/CD

### Tradeoffs

- Larger repository size
- All projects share git history
- CI runs for all apps on any change (mitigated with Turborepo caching)

### Risks

| Risk | Mitigation |
|------|------------|
| Boundary leakage | Enforce via TypeScript paths, lint rules |
| Build coupling | Turborepo caching, parallel builds |
| Deployment coupling | Each app deploys independently |

## Implementation Notes

### Tooling

```json
// package.json
{
  "workspaces": ["apps/*", "packages/*"],
  "devDependencies": {
    "turbo": "^2.0.0",
    "typescript": "^5.0.0"
  }
}
```

```yaml
# pnpm-workspace.yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

### Commands

```bash
# Install all dependencies
pnpm install

# Run APIs in development
pnpm --filter api dev           # Public API
pnpm --filter admin-api dev     # Admin API

# Run admin UI in development
pnpm --filter admin dev

# Run mobile in development
pnpm --filter mobile start

# Generate SDKs from specs
pnpm generate:clients           # Generate all REST SDKs
pnpm --filter api-client generate
pnpm --filter admin-api-client generate

# Generate WebSocket types
pnpm --filter ws-client generate:types

# Run all tests
pnpm test

# Build all
pnpm build

# Deploy API
pnpm --filter api deploy
```

### Shared Package Usage

```typescript
// In apps/mobile/src/api/rest-client.ts - using generated REST SDK
import { ApiClient } from '@yoked/api-client';

const client = new ApiClient({ baseUrl: 'https://api.yoked.app' });
const user = await client.users.getMe();
const matches = await client.matches.getOffers();

// In apps/mobile/src/api/ws-client.ts - hand-written client with generated types
import { WebSocketClient } from '@yoked/ws-client';
import type { 
  MessageNewEvent, 
  TypingStartEvent, 
  TypingStopEvent 
} from '@yoked/ws-client/generated';

const ws = new WebSocketClient({ url: 'wss://realtime.yoked.app/v1' });

// Event handlers use generated types
ws.on<MessageNewEvent>('message:new', (event) => {
  console.log('New message:', event.payload.messageId, event.payload.content);
});

ws.on<TypingStartEvent>('typing:start', (event) => {
  console.log('User typing:', event.payload.userId);
});

await ws.subscribe(`match:${matchId}`);

// In apps/admin/src/api/client.ts - using generated admin SDK
import { AdminApiClient } from '@yoked/admin-api-client';

const adminClient = new AdminApiClient({ baseUrl: 'https://admin-api.yoked.app' });
const pendingReviews = await adminClient.moderation.getPendingQueue();
await adminClient.users.suspend('user-uuid', { reason: 'Policy violation' });

// In packages/shared/src/types/index.ts - shared domain types
export interface User {
  id: string;
  displayName: string;
  status: UserStatus;
}

// In apps/api/src/routes/users.ts - API implementation
import type { User } from '@yoked/shared/types';
```

## Validation

Success metrics:
- Single `pnpm install` sets up all projects
- Type changes in `shared` propagate to all apps
- SDK generation produces type-safe clients from OpenAPI specs
- Mobile/admin compile errors when API contract changes
- CI runs < 5 minutes with Turborepo caching
- Each app can be deployed independently

## Related Docs

- `docs/technical/decisions/ADR-0001-supabase-over-convex.md`
- `docs/technical/decisions/ADR-0009-api-hosting.md`
- `docs/ops/infrastructure.md`
- `docs/ops/admin-operations.md`
