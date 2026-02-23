# ADR-0010: Background Jobs

Date: 2026-02-20
Status: Accepted
Owner: Engineering
Last Updated: 2026-02-20
Depends On: `docs/technical/decisions/ADR-0009-api-hosting.md`

## Context

We need to handle background jobs for:

| Job | Type | Frequency | Duration |
|-----|------|-----------|----------|
| Daily match generation | Scheduled | Daily per timezone | 1-5 min |
| Match expiration cleanup | Scheduled | Hourly | < 1 min |
| Content moderation queue | Event-driven | Real-time | < 30 sec |
| Notification batching | Scheduled | Every 5 min | < 1 min |
| Analytics aggregation | Scheduled | Daily | 1-5 min |

## Decision

Use **Trigger.dev** for background jobs. Start with free tier, add reliability when needed.

Alternative: For MVP simplicity, start with in-process scheduling (node-cron) and migrate to Trigger.dev when jobs become complex.

## Rationale

### Why Trigger.dev

1. **Long-Running Jobs**
   - No timeout limits (unlike serverless functions)
   - Handles jobs that take minutes

2. **Reliability**
   - Built-in retries
   - Job history and debugging
   - Deduplication

3. **TypeScript Native**
   - Type-safe job definitions
   - Integrates with existing codebase

4. **Simple Integration**
   - Works with any hosting (Railway, Fly.io)
   - SDK is lightweight

5. **Generous Free Tier**
   - 10K runs/month free
   - Sufficient for MVP

### Why Not Alternatives

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| Trigger.dev | Managed, reliable, TypeScript | External service | **Selected** |
| In-process (node-cron) | Simple, no vendor | Jobs lost on restart | Alternative for MVP |
| BullMQ + Redis | Powerful, self-hosted | Need Redis, more ops | Rejected |
| Temporal | Enterprise-grade | Overkill for MVP | Rejected |
| Supabase Edge Functions | Integrated | 2 min timeout | Rejected |

## Architecture

```
┌─────────────────┐
│   API Server    │
│   (Railway/Fly) │
└────────┬────────┘
         │
         │ Trigger
         ▼
┌─────────────────┐
│   Trigger.dev   │
│                 │
│  ┌───────────┐  │
│  │ Scheduled │  │
│  │   Jobs    │  │
│  └───────────┘  │
│                 │
│  ┌───────────┐  │
│  │  Event    │  │
│  │  Triggers │  │
│  └───────────┘  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Supabase     │
│    Postgres     │
└─────────────────┘
```

## Job Definitions

### Daily Match Generation

```typescript
import { client } from "@trigger.dev/sdk";
import { z } from "zod";

// Scheduled: Daily at 9 AM per timezone
client.defineJob({
  id: "daily-match-generation",
  name: "Daily Match Generation",
  version: "1.0.0",
  trigger: scheduledTrigger({
    cron: "0 9 * * *", // 9 AM daily
  }),
  run: async (payload, io, ctx) => {
    const timezones = ["America/New_York", "America/Los_Angeles", "Europe/London"];
    
    for (const tz of timezones) {
      await io.runTask(`generate-matches-${tz}`, async () => {
        await generateDailyMatches(tz);
      });
    }
  },
});
```

### Content Moderation (Event-Driven)

```typescript
// Triggered when message is sent
client.defineJob({
  id: "content-moderation",
  name: "Content Moderation",
  version: "1.0.0",
  trigger: eventTrigger({
    name: "message.sent",
    schema: z.object({
      messageId: z.string(),
      content: z.string(),
      senderId: z.string(),
    }),
  }),
  run: async (payload, io, ctx) => {
    const result = await io.runTask("moderate", async () => {
      return await moderateContent(payload.content);
    });

    if (!result.safe) {
      await io.runTask("flag-message", async () => {
        await flagMessage(payload.messageId, result);
      });
    }
  },
});
```

### Match Expiration Cleanup

```typescript
// Scheduled: Every hour
client.defineJob({
  id: "match-expiration-cleanup",
  name: "Match Expiration Cleanup",
  version: "1.0.0",
  trigger: scheduledTrigger({
    cron: "0 * * * *", // Every hour
  }),
  run: async (payload, io, ctx) => {
    await io.runTask("expire-matches", async () => {
      const expired = await expireOldMatchOffers();
      return { expired: expired.length };
    });
  },
});
```

## MVP Alternative: In-Process

For maximum simplicity during MVP, start with in-process scheduling:

```typescript
// Simple node-cron for MVP
import cron from "node-cron";

// Daily at 9 AM
cron.schedule("0 9 * * *", async () => {
  await generateDailyMatches();
});

// Every hour
cron.schedule("0 * * * *", async () => {
  await expireOldMatchOffers();
});
```

**Trade-offs:**
- ✅ No external service
- ✅ Simpler deployment
- ❌ Jobs lost on server restart
- ❌ No retry logic
- ❌ No observability

**Migration trigger:** Move to Trigger.dev when job reliability matters.

## Costs

### Trigger.dev Pricing

| Tier | Runs/month | Cost |
|------|------------|------|
| Free | 10,000 | $0 |
| Pro | 100,000 | $29/mo |
| Scale | 500,000+ | $99+/mo |

### MVP Estimate

| Job | Runs/day | Runs/month |
|-----|----------|------------|
| Daily matching | ~24 (per timezone) | ~720 |
| Cleanup | 24 | ~720 |
| Moderation | ~100 | ~3,000 |
| Notifications | ~288 | ~8,640 |
| **Total** | | **~13,000** |

**MVP Cost:** Free tier → $0/mo

If we exceed free tier: $29/mo (Pro)

## Setup

### 1. Create Trigger.dev Project

```bash
# Go to trigger.dev
# Create new project
# Get API key
```

### 2. Install SDK

```bash
npm install @trigger.dev/sdk
```

### 3. Configure

```typescript
// src/trigger.ts
import { TriggerClient } from "@trigger.dev/sdk";

export const client = new TriggerClient({
  id: "yoked",
  apiKey: process.env.TRIGGER_SECRET_KEY,
});
```

### 4. Add to API Server

```typescript
// Express middleware
app.use("/api/trigger", client.createExpressMiddleware());
```

### 5. Set Environment Variable

```bash
# Railway
railway variables set TRIGGER_SECRET_KEY=xxx

# Fly.io
fly secrets set TRIGGER_SECRET_KEY=xxx
```

## Monitoring

Trigger.dev provides:
- Job history
- Success/failure rates
- Duration metrics
- Error logs
- Retry status

## Related Documents

- `docs/technical/decisions/ADR-0009-api-hosting.md`
- `docs/specs/matching.md`
- `docs/specs/safety.md`
- `docs/ops/infrastructure.md`
