# ADR-0004: Matchmaking Scheduler Idempotency

Date: 2026-02-19
Status: Accepted
Owner: Engineering
Last Updated: 2026-02-20
Depends On: `docs/technical/contracts/idempotency-and-retries.md`, `docs/specs/matching.md`

## Context

Yoked generates daily match offers for users. The matchmaking scheduler:
- Runs once per day per timezone
- Generates curated match offers
- Must not create duplicate offers
- Must be recoverable from failures

## Decision

Implement **deterministic, idempotent matchmaking** with:
1. Composite key: `{date}:{timezone}:{userId}`
2. Upsert semantics for job execution
3. Immutable offer generation (same inputs = same outputs)
4. At-least-once delivery with deduplication

## Rationale

### Why Idempotency is Critical

1. **No Duplicate Offers**
   - Users must never receive multiple offers for same day
   - Duplicate offers would break trust
   - Hard to undo once sent

2. **Failure Recovery**
   - Jobs may fail mid-execution
   - Must be safe to retry
   - No partial state corruption

3. **Operational Safety**
   - Manual re-runs must be safe
   - Debugging requires reproducibility
   - Testing requires determinism

### Why Deterministic Generation

Same inputs must produce same outputs:
- Same user pool
- Same compatibility scores
- Same random seed (if any randomness)

This ensures:
- Reproducible bugs
- Testable logic
- Safe retries

## Implementation

### Job Record Schema

```sql
CREATE TABLE matchmaking_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL,
  timezone TEXT NOT NULL,
  user_id UUID NOT NULL REFERENCES users(id),
  status TEXT NOT NULL CHECK (status IN ('pending', 'running', 'completed', 'failed')),
  offers JSONB DEFAULT NULL,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  error_message TEXT,
  retry_count INT DEFAULT 0,
  
  UNIQUE(date, user_id)
);

CREATE INDEX idx_matchmaking_jobs_status ON matchmaking_jobs(status);
CREATE INDEX idx_matchmaking_jobs_date_timezone ON matchmaking_jobs(date, timezone);
```

### Idempotent Job Execution

```typescript
async function generateOffers(
  date: string,
  timezone: string,
  userId: string
): Promise<MatchOffer[]> {
  const jobKey = `${date}:${timezone}:${userId}`;
  
  // Try to acquire job lock
  const job = await db.query(`
    INSERT INTO matchmaking_jobs (date, timezone, user_id, status, started_at)
    VALUES ($1, $2, $3, 'running', NOW())
    ON CONFLICT (date, user_id) DO
      UPDATE SET 
        status = 'running',
        started_at = NOW(),
        retry_count = matchmaking_jobs.retry_count + 1
      WHERE matchmaking_jobs.status != 'completed'
    RETURNING *
  `, [date, timezone, userId]);
  
  // If no row returned, job already completed (idempotent return)
  if (!job) {
    const completed = await db.query(`
      SELECT offers FROM matchmaking_jobs
      WHERE date = $1 AND user_id = $2 AND status = 'completed'
    `, [date, userId]);
    return completed.offers;
  }
  
  try {
    // Generate offers (deterministic)
    const offers = await computeOffers(date, timezone, userId);
    
    // Store completed job
    await db.query(`
      UPDATE matchmaking_jobs
      SET status = 'completed',
          offers = $1::jsonb,
          completed_at = NOW()
      WHERE date = $2 AND user_id = $3
    `, [JSON.stringify(offers), date, userId]);
    
    return offers;
  } catch (error) {
    // Mark failed for retry
    await db.query(`
      UPDATE matchmaking_jobs
      SET status = 'failed',
          error_message = $1
      WHERE date = $2 AND user_id = $3
    `, [error.message, date, userId]);
    throw error;
  }
}
```

### Deterministic Offer Computation

```typescript
async function computeOffers(
  date: string,
  timezone: string,
  userId: string
): Promise<MatchOffer[]> {
  // 1. Get eligible candidates (deterministic query)
  const candidates = await getEligibleCandidates(userId, date);
  
  // 2. Compute compatibility scores (deterministic algorithm)
  const scored = candidates.map(c => ({
    ...c,
    score: computeCompatibility(userId, c.id)
  }));
  
  // 3. Sort by score (deterministic)
  scored.sort((a, b) => b.score - a.score);
  
  // 4. Select top N (deterministic)
  const selected = scored.slice(0, DAILY_OFFER_COUNT);
  
  // 5. Create offers (deterministic IDs)
  return selected.map((c, index) => ({
    id: generateDeterministicId(date, userId, c.id), // Hash-based
    userId: c.id,
    compatibilityScore: c.score,
    offeredAt: new Date().toISOString(),
    expiresAt: computeExpiry(date, timezone)
  }));
}

function generateDeterministicId(date: string, user1: string, user2: string): string {
  // Deterministic UUID v5 based on inputs
  const input = `${date}:${user1}:${user2}`;
  return uuidv5(input, MATCHMAKING_NAMESPACE);
}
```

### Scheduler Orchestration

```typescript
// Runs every hour, processes timezones at 9 AM local time
async function scheduleMatchmaking(): Promise<void> {
  const now = new Date();
  const timezones = getTimezonesAtHour(now, 9); // 9 AM local
  
  for (const timezone of timezones) {
    const users = await getEligibleUsers(timezone);
    
    // Queue jobs (idempotent - safe to re-queue)
    for (const userId of users) {
      await queueJob('generate-offers', {
        date: formatDate(now),
        timezone,
        userId
      });
    }
  }
}
```

## Failure Handling

### Retry Policy

| Failure Type | Retry Count | Backoff | Action |
|--------------|-------------|---------|--------|
| Transient DB error | 3 | 30s, 2min, 5min | Retry |
| Timeout | 3 | 30s, 2min, 5min | Retry |
| Logic error | 0 | N/A | Alert, manual fix |
| Data inconsistency | 0 | N/A | Alert, manual fix |

### Dead Letter Queue

Failed jobs after max retries:
1. Moved to dead letter queue
2. Alert sent to on-call
3. Manual investigation required
4. Can be manually requeued after fix

### Monitoring

| Metric | Alert Threshold |
|--------|-----------------|
| Job failure rate | > 1% |
| Job duration | > 5 minutes p95 |
| Queue depth | > 1000 jobs |
| Duplicate offers created | > 0 |

## Consequences

### Positive

- Safe to retry jobs
- No duplicate offers
- Reproducible for debugging
- Testable in isolation

### Tradeoffs

- Slightly more complex implementation
- Database storage for job state
- Deterministic IDs limit flexibility

### Risks

| Risk | Mitigation |
|------|------------|
| Clock skew | Use UTC for all timestamps |
| Timezone changes | Handle DST transitions explicitly |
| Large user batches | Shard by user ID, parallel processing |
| Algorithm changes | Version the scoring algorithm |

## Validation

Success metrics:
- Zero duplicate offers per user per day
- 99.9% job completion rate
- < 30 seconds per user job p95
- Deterministic output verified in tests

## Related Docs

- `docs/technical/contracts/idempotency-and-retries.md`
- `docs/specs/matching.md`
