# ADR-0013: Hono for API Framework

Date: 2026-02-21  
Status: Accepted  
Owner: Engineering  
Last Updated: 2026-02-21  
Depends On: `docs/technical/decisions/ADR-0009-api-hosting.md`, `docs/technical/decisions/ADR-0011-monorepo-project-structure.md`

## Context

Yoked needs an API framework for:
- `apps/api/` - Public REST API + WebSocket
- `apps/admin-api/` - Admin-only REST API

Options considered:
- **Hono** - Lightweight, edge-first web framework
- **Fastify** - High-performance Node.js framework
- **Express** - Traditional Node.js framework

## Decision

**Use Hono for both APIs.**

## Rationale

### Why Hono

| Factor | Hono | Fastify | Express |
|--------|------|---------|---------|
| Bundle size | ~14KB | ~80KB | ~200KB |
| Edge runtime | ✅ Native | ❌ Node only | ❌ Node only |
| TypeScript | ✅ First-class | ✅ Good | ⚠️ Requires types |
| Performance | Excellent | Excellent | Good |
| WebSocket | Built-in | Plugin | Library |
| OpenAPI | `@hono/zod-openapi` | `fastify-swagger` | Libraries |
| Learning curve | Low | Medium | Low |

### Key Reasons

1. **Edge-compatible** - Deploys to Cloudflare Workers, Deno, Bun, and Node.js
2. **Lightweight** - Small bundle, fast cold starts (important for serverless)
3. **TypeScript-native** - Types inferred from routes automatically
4. **WebSocket built-in** - No additional libraries needed
5. **Host-agnostic** - Works on Fly.io, Railway, Vercel Edge, Cloudflare
6. **Zod integration** - First-class validation with `@hono/zod-openapi`

### Why Not Fastify

- Node.js only (no edge runtime)
- Slightly more boilerplate
- WebSocket requires plugin (`@fastify/websocket`)
- Larger bundle size

### Why Not Express

- Older architecture, slower performance
- Less TypeScript support
- More middleware complexity
- No edge support

## Alternatives Considered

### Fastify

Good choice for traditional Node.js deployments, but Hono's edge support and lighter weight make it better for our hosting flexibility (Fly.io/Railway could use edge runtimes in the future).

## Consequences

### Positive

- Single framework for both APIs
- Edge-ready if we need it
- Smaller bundles, faster cold starts
- TypeScript types inferred from routes
- Built-in WebSocket support

### Tradeoffs

- Smaller ecosystem than Express
- Fewer middleware options
- Newer framework (started 2021)

### Risks

| Risk | Mitigation |
|------|------------|
| Ecosystem maturity | Core features stable; community growing fast |
| Edge compatibility issues | Can run in standard Node.js mode on Fly.io/Railway |

## Implementation Notes

### Basic Structure

```typescript
// apps/api/src/index.ts
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { prettyJSON } from 'hono/pretty-json';

const app = new Hono();

app.use('*', cors());
app.use('*', logger());
app.use('*', prettyJSON());

// Health check
app.get('/health', (c) => c.json({ status: 'ok' }));

// Routes
import authRoutes from './routes/auth';
import usersRoutes from './routes/users';
import matchesRoutes from './routes/matches';

app.route('/auth', authRoutes);
app.route('/users', usersRoutes);
app.route('/matches', matchesRoutes);

export default app;
```

### With Zod Validation

```typescript
import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';

const app = new Hono();

const createUserSchema = z.object({
  displayName: z.string().min(2).max(50),
  dateOfBirth: z.string().datetime(),
});

app.post('/users', zValidator('json', createUserSchema), async (c) => {
  const body = c.req.valid('json');
  // body is typed!
  return c.json({ success: true });
});
```

### WebSocket Support

```typescript
import { Hono } from 'hono';
import { createNodeWebSocket } from '@hono/node-ws';

const app = new Hono();
const { injectWebSocket, upgradeWebSocket } = createNodeWebSocket({ app });

app.get(
  '/ws',
  upgradeWebSocket((c) => ({
    onOpen(event, ws) {
      console.log('Connection opened');
    },
    onMessage(event, ws) {
      ws.send('Hello from server');
    },
  }))
);
```

### OpenAPI Integration

```typescript
import { createRoute, OpenAPIHono, z } from '@hono/zod-openapi';

const app = new OpenAPIHono();

const createUserRoute = createRoute({
  method: 'post',
  path: '/users',
  request: {
    body: {
      content: {
        'application/json': {
          schema: z.object({
            displayName: z.string().openapi({ example: 'John' }),
          }),
        },
      },
    },
  },
  responses: {
    200: {
      content: {
        'application/json': {
          schema: z.object({ id: z.string() }),
        },
      },
      description: 'User created',
    },
  },
});

app.openapi(createUserRoute, async (c) => {
  const { displayName } = c.req.valid('json');
  return c.json({ id: '123' });
});

// OpenAPI spec at /doc
app.doc('/doc', {
  openapi: '3.1.0',
  info: { title: 'Yoked API', version: '1.0.0' },
});
```

## Validation

Success metrics:
- API starts in < 1 second
- TypeScript compilation catches route mismatches
- WebSocket connections stable
- OpenAPI spec generated from routes

## Related Docs

- `docs/technical/decisions/ADR-0009-api-hosting.md`
- `docs/technical/decisions/ADR-0011-monorepo-project-structure.md`
- `docs/technical/contracts/openapi.yaml`
