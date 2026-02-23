# Idempotency and Retries Contract

Owner: Engineering  
Status: Draft  
Last Updated: 2026-02-20  
Depends On: `docs/technical/contracts/openapi.yaml`, `docs/technical/decisions/ADR-0004-matchmaking-idempotency.md`

## Overview

This document defines idempotency guarantees and retry policies for all Yoked APIs, webhooks, and scheduled jobs. It ensures safe retries and prevents duplicate operations.

## Idempotency Principles

### What is Idempotency?

An operation is idempotent if multiple identical requests have the same effect as a single request. After an idempotent operation completes, subsequent identical requests:
- Return the same result
- Do not modify state further
- Do not trigger side effects

### Idempotency Key

Clients must provide an idempotency key for non-read operations:

```
Idempotency-Key: {uuid}
```

**Key Requirements:**
- UUID v4 format
- Unique per operation attempt
- Reused only when retrying the same operation
- Expires after 24 hours

### Server Behavior

```
IF Idempotency-Key exists in cache:
  IF request matches (same endpoint, same payload):
    RETURN cached response
  ELSE:
    RETURN 409 Conflict (key reuse with different payload)
ELSE:
  EXECUTE operation
  STORE response in cache (24h TTL)
  RETURN response
```

## API Endpoint Idempotency

### Idempotent Endpoints (Safe to Retry)

These endpoints are idempotent with `Idempotency-Key`:

| Endpoint | Method | Idempotency Behavior |
|----------|--------|---------------------|
| `/auth/otp/send` | POST | Same requestId returned for 10 min |
| `/auth/otp/verify` | POST | Same tokens returned for 5 min |
| `/users/me` | PATCH | Last write wins (no key needed) |
| `/users/me/photos` | POST | Same photo returned, duplicate rejected |
| `/compatibility/responses` | POST | Same responses overwrite |
| `/verification/session` | POST | Same session returned for 5 min |
| `/matches/offers/{id}/action` | POST | Same action state returned |
| `/matches/{id}/unmatch` | POST | Idempotent (no-op if already unmatched) |
| `/matches/{id}/messages` | POST | Duplicate rejected via clientMessageId |
| `/matches/{id}/read` | POST | Idempotent (no-op) |
| `/safety/report` | POST | Duplicate rejected for 1 hour |
| `/safety/block` | POST | Idempotent (no-op if already blocked) |
| `/safety/appeal` | POST | Duplicate rejected for 24 hours |

### Non-Idempotent Endpoints

These endpoints are NOT idempotent:

| Endpoint | Method | Behavior |
|----------|--------|----------|
| `/auth/refresh` | POST | Always issues new tokens |
| `/auth/logout` | POST | Always revokes session |
| `/users/me/photos/{id}` | DELETE | One-time deletion |

## Retry Policies

### Client Retry Strategy

**Exponential Backoff with Jitter:**

```typescript
const retryWithBackoff = async (
  operation: () => Promise<T>,
  maxRetries: number = 3
): Promise<T> => {
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await operation();
    } catch (error) {
      if (attempt === maxRetries) throw error;
      if (!isRetryable(error)) throw error;
      
      const delay = Math.min(
        1000 * Math.pow(2, attempt) + Math.random() * 1000,
        30000 // Max 30s
      );
      await sleep(delay);
    }
  }
};
```

### Retryable Errors

| Status | Codes | Retry? | Notes |
|--------|-------|--------|-------|
| 408 | Request Timeout | Yes | Immediate retry |
| 429 | Rate Limited | Yes | Honor Retry-After header |
| 500 | Internal Error | Yes | Backoff retry |
| 502 | Bad Gateway | Yes | Backoff retry |
| 503 | Service Unavailable | Yes | Honor Retry-After |
| 504 | Gateway Timeout | Yes | Backoff retry |
| 400 | Bad Request | No | Fix request |
| 401 | Unauthorized | No | Re-authenticate |
| 403 | Forbidden | No | Check permissions |
| 404 | Not Found | No | Resource doesn't exist |
| 409 | Conflict | No | Resolve conflict |

### Maximum Retry Limits

| Operation Type | Max Retries | Max Total Time |
|----------------|-------------|----------------|
| User-facing API | 3 | 10 seconds |
| Background job | 5 | 5 minutes |
| Webhook delivery | 10 | 24 hours |
| Scheduled task | 3 | 1 hour |

## Matchmaking Scheduler Idempotency

### Daily Batch Generation

The matchmaking scheduler must be idempotent to prevent duplicate offers:

```
Scheduler Job: generate_daily_offers
Idempotency Key: {date}:{timezone}:{userId}

Example: "2026-02-19:America/New_York:user-123"
```

**Idempotency Guarantee:**
- Same user cannot receive multiple offers for same day
- Re-running job for same day returns same results
- Job can safely retry on failure

### Implementation

```sql
-- Idempotency check
INSERT INTO matchmaking_jobs (batch_date, timezone, user_id, job_type, status, offers, idempotency_key)
VALUES ('2026-02-19', 'America/New_York', 'user-123', 'daily_offers', 'running', NULL, '2026-02-19:America/New_York:user-123:daily_offers')
ON CONFLICT (batch_date, timezone, user_id, job_type) DO
  UPDATE SET status = 'running', attempt_count = matchmaking_jobs.attempt_count + 1
  WHERE matchmaking_jobs.status != 'completed';

-- If no rows updated, job already completed (idempotent return)
```

### Offer State Transitions

All state transitions are idempotent:

| Current State | Action | Result | Idempotent? |
|---------------|--------|--------|-------------|
| offered | accept | accepted | Yes (same result) |
| offered | pass | passed | Yes (same result) |
| offered | not_now | not_now | Yes (same result) |
| accepted | mutual accept by counterpart | matched | Yes (same result) |
| matched | unmatch | match record becomes `closed` with reason `unmatched` | Yes (same result) |

## Webhook Delivery

### Webhook Retry Policy

```
Delivery Attempts:
1. Immediate
2. 5 seconds
3. 30 seconds
4. 2 minutes
5. 10 minutes
6. 30 minutes
7. 1 hour
8. 6 hours
9. 12 hours
10. 24 hours

Total window: 24 hours
```

### Webhook Idempotency

Each webhook includes an `eventId` for deduplication:

```json
{
  "eventId": "uuid",
  "eventType": "match.created",
  "timestamp": "2026-02-19T12:00:00Z",
  "data": {...}
}
```

**Consumer Requirements:**
- Store processed `eventId` for 7 days
- Ignore duplicate `eventId` within 7 days
- Return 200 OK for processed events (idempotent acknowledgment)

## Database Operation Idempotency

### Upsert Patterns

Use upsert for idempotent writes:

```sql
-- User preferences (last write wins)
INSERT INTO user_preferences (user_id, preference, value)
VALUES ('user-123', 'notifications', true)
ON CONFLICT (user_id, preference)
DO UPDATE SET value = EXCLUDED.value, updated_at = NOW();
```

### Conditional Updates

Use conditions to ensure idempotency:

```sql
-- Only update if not already in target state
UPDATE match_offers
SET status = 'accepted', accepted_at = NOW()
WHERE id = 'offer-123'
  AND status = 'offered';  -- Condition prevents re-execution
```

## Message Deduplication

### Client-Generated IDs

Chat messages use client-generated IDs for deduplication:

```json
{
  "content": "Hello!",
  "clientMessageId": "client-generated-uuid"
}
```

**Server Behavior:**
1. Check if `clientMessageId` exists (24h window)
2. If exists, return existing message (idempotent)
3. If not, create new message
4. Store `clientMessageId` -> `messageId` mapping

### Duplicate Detection

```sql
-- Check for duplicate
SELECT id FROM messages
WHERE client_message_id = 'client-uuid'
  AND created_at > NOW() - INTERVAL '24 hours';

-- Insert with conflict handling
INSERT INTO messages (id, match_id, sender_id, content, client_message_id)
VALUES (gen_random_uuid(), 'match-123', 'user-123', 'Hello!', 'client-uuid')
ON CONFLICT (client_message_id) DO NOTHING
RETURNING id;
```

## Safety Report Deduplication

### Report Key Generation

Reports are deduplicated by:

```
Key: {reporterId}:{subjectId}:{category}:{timeWindow}
Time Window: 1 hour buckets
```

**Behavior:**
- Same reporter cannot report same subject for same category within 1 hour
- Different categories allowed
- Different reporters always allowed

## Testing Idempotency

### Test Cases

1. **Duplicate Request Test:**
   ```
   1. Send request with Idempotency-Key
   2. Capture response
   3. Send identical request with same key
   4. Assert: Same response, no state change
   ```

2. **Retry After Failure Test:**
   ```
   1. Start operation
   2. Simulate failure mid-operation
   3. Retry with same Idempotency-Key
   4. Assert: Operation completes, no duplicates
   ```

3. **Concurrent Request Test:**
   ```
   1. Send 10 concurrent requests with same Idempotency-Key
   2. Assert: Only one succeeds, 9 return cached response
   ```

## Monitoring

### Metrics to Track

| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| `idempotency_cache_hit` | Cached response returned | N/A |
| `idempotency_key_reuse_conflict` | Key reuse with different payload | > 1% of requests |
| `retry_attempts_total` | Number of retries | N/A |
| `retry_exhausted_total` | Max retries exceeded | > 0.1% of operations |
| `webhook_delivery_success` | Successful webhook delivery | < 95% |
| `scheduler_job_conflict` | Idempotent job skip | N/A |

## Implementation Checklist

- [ ] Idempotency key validation (UUID format)
- [ ] Redis cache for idempotency storage (24h TTL)
- [ ] Conflict detection for key reuse
- [ ] Exponential backoff with jitter
- [ ] Retry-After header support
- [ ] Webhook retry queue with exponential backoff
- [ ] Client message ID deduplication
- [ ] Scheduler job idempotency keys
- [ ] Database upsert patterns
- [ ] Idempotency test suite
