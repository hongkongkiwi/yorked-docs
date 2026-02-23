# System Configuration

Owner: Engineering  
Status: Active  
Last Updated: 2026-02-20  
Depends On: N/A

## Overview

This document defines all configurable parameters for the Yoked platform. **All values should be configurable at runtime** via environment variables, database settings, or feature flags. No business logic values should be hardcoded.

## Configuration Sources

| Source | Use Case | Examples |
|--------|----------|----------|
| Environment Variables | Infrastructure, secrets | `DATABASE_URL`, `REDIS_URL` |
| Database (`system_config` table) | Business parameters | Daily match count, expiry days |
| Feature Flags | Rollout control | `enable_video_chat`, `enable_ai_coach` |
| Remote Config | A/B testing, hot fixes | Question set version, UI variants |

---

## Matching Configuration

### Daily Match Generation

| Parameter | Default | Min | Max | Description |
|-----------|---------|-----|-----|-------------|
| `MATCHES_PER_DAY_DEFAULT` | 3 | 1 | 10 | Daily match offers per user |
| `MATCHES_PER_DAY_PREMIUM` | 10 | 1 | 20 | Daily matches for premium users |
| `MATCH_BATCH_TIME` | "09:00" | - | - | Local time for batch generation |
| `MATCH_BATCH_TIMEZONE_FIELD` | `user.timezone` | - | - | Field to read user timezone from |

### Match Offers

| Parameter | Default | Min | Max | Description |
|-----------|---------|-----|-----|-------------|
| `MATCH_OFFER_EXPIRY_DAYS` | 6 | 1 | 14 | Days before offer expires |
| `MATCH_OFFER_COOLDOWN_DAYS` | 30 | 7 | 90 | Days before "Not Now" can reappear |
| `MAX_ACTIVE_MATCHES_BETA` | 2 | 1 | 10 | Concurrent active matches (beta) |
| `MAX_ACTIVE_MATCHES_LIVE` | 5 | 1 | 20 | Concurrent active matches (live) |

### Matching Algorithm

| Parameter | Default | Description |
|-----------|---------|-------------|
| `COMPATIBILITY_MIN_SCORE` | 50 | Minimum compatibility score to offer |
| `COMPATIBILITY_WEIGHT_*` | Various | Weights for different question categories |
| `MATCH_SCORE_COMPATIBILITY_WEIGHT` | 0.80 | Weight for psychological compatibility score |
| `MATCH_SCORE_PHYSICAL_WEIGHT` | 0.20 | Weight for physical-preference affinity score |
| `MATCH_SCORE_QUESTIONNAIRE_WEIGHT` | 0.85 | Final ranking weight for questionnaire total |
| `MATCH_SCORE_AUTHENTICITY_WEIGHT` | 0.15 | Final ranking weight for authenticity confidence |
| `MATCH_SCORE_UNCERTAINTY_PENALTY_MAX` | 0.12 | Max penalty for missing/sparse signals |
| `MATCH_SCORE_DIVERSITY_LAMBDA` | 0.82 | Diversity re-rank tradeoff parameter |
| `MATCH_MIN_QUALITY_THRESHOLD` | 0.50 | Minimum final score for offer eligibility |
| `MATCH_ANCHOR_MIN_CONFIDENCE` | 0.70 | Minimum confidence for weekly anchor offer |
| `MATCH_REQUIRE_VISUAL_SIGNAL` | true | Require VPS readiness for full-confidence ranking |
| `MATCH_PROVISIONAL_VISUAL_PRIOR` | 0.50 | Neutral visual prior used in provisional mode |
| `MATCH_PROVISIONAL_SCORE_CAP` | 0.72 | Score cap when VPS is not ready |
| `MATCH_PROVISIONAL_MAX_OFFERS` | 1 | Max provisional offers per day |
| `MATCH_ANSWER_HALF_LIFE_DAYS` | 180 | Response freshness decay half-life |
| `MATCH_EVIDENCE_WEIGHT_H` | 1.00 | Evidence prior for high-strength items |
| `MATCH_EVIDENCE_WEIGHT_M` | 0.70 | Evidence prior for medium-strength items |
| `MATCH_EVIDENCE_WEIGHT_L` | 0.40 | Evidence prior for low-strength items |
| `MATCH_GENDER_RESPONSIVE_MODE` | `behavioral_segments` | Enables behavior-based gender-responsive policy layer |
| `MATCH_HIGH_INBOUND_QUEUE_CAP` | 3 | Queue cap for high inbound pressure segment |
| `MATCH_LOW_INBOUND_MIN_RECIPROCITY` | 0.55 | Reciprocity floor for low inbound segment |
| `MATCH_COHORT_PARITY_ALERT_THRESHOLD` | 0.10 | Alert threshold for cohort metric deltas |
| `MATCH_COHORT_MIN_SAMPLE_SIZE` | 50 | Minimum cohort sample size for reportable metrics |
| `MATCH_METRIC_TOO_FEW_MESSAGES_FLOOR` | 2 | Inbound message floor used for too-few-message indicator |
| `MATCH_METRIC_TOO_MANY_MESSAGES_CEILING` | 30 | Inbound message ceiling used for too-many-message indicator |
| `PHYSICAL_PREFERENCES_ENABLED` | true | Enable explicit physical preference capture |
| `PHYSICAL_PREFERENCES_MAX_SELECTED` | 5 | Max selected physical preference tags |
| `GEO_MAX_DISTANCE_KM` | 50 | Maximum distance for matches |
| `GEO_PRIORITY_LOCAL` | true | Prefer same-city matches first |
| `AGE_RANGE_DEFAULT_MIN` | -5 | Default min age offset from user |
| `AGE_RANGE_DEFAULT_MAX` | +5 | Default max age offset from user |
| `SAME_SEX_MATCHING_ENABLED` | true | Enable same-sex matching |
| `SAME_SEX_ALGORITHM_VERSION` | "default" | Algorithm version (default = same pool) |

### Pass/Rematch Behavior

| Parameter | Default | Description |
|-----------|---------|-------------|
| `ALLOW_REMATCH_AFTER_PASS` | false | Can passed users reappear |
| `REMATCH_COOLDOWN_DAYS` | 90 | Days before passed user could reappear |
| `HARD_PASS_IS_PERMANENT` | true | Pass means never show again |
| `PASS_RECONSIDERATION_ENABLED` | true | Allow one resurfacing after cooldown |
| `PASS_COOLDOWN_DAYS` | 90 | Default pass cooldown window |
| `PASS_REOFFER_UPLIFT_THRESHOLD` | 0.08 | Required score uplift before resurfacing |

---

## Onboarding Configuration

### Phone Authentication

| Parameter | Default | Description |
|-----------|---------|-------------|
| `OTP_LENGTH` | 6 | Digits in OTP code |
| `OTP_EXPIRY_SECONDS` | 300 | OTP validity duration |
| `OTP_MAX_ATTEMPTS` | 3 | Max verification attempts |
| `OTP_RESEND_COOLDOWN_SECONDS` | 60 | Wait before resend |
| `OTP_RATE_LIMIT_PER_MINUTE` | 1 | Max OTP requests per minute |
| `OTP_RATE_LIMIT_PER_HOUR` | 5 | Max OTP requests per hour |
| `OTP_RATE_LIMIT_PER_DAY` | 10 | Max OTP requests per day |

### Profile, Age & Integrated Preferences

| Parameter | Default | Description |
|-----------|---------|-------------|
| `MIN_AGE` | 18 | Minimum age to use app |
| `DISPLAY_NAME_MIN_LENGTH` | 2 | Min characters for name |
| `DISPLAY_NAME_MAX_LENGTH` | 50 | Max characters for name |
| `BIO_MAX_LENGTH` | 500 | Max characters for bio |
| `PROFANITY_CHECK_ENABLED` | true | Check for profanity in profile |
| `DISCOVERY_PREFS_REQUIRED` | true | Require integrated profiling preferences before matching |
| `DISCOVERY_DEFAULT_DISTANCE_KM` | 50 | Default max distance in integrated profiling preferences |
| `DISCOVERY_DEFAULT_INTENT` | "serious" | Default relationship intent in integrated profiling preferences |

### Questionnaire

| Parameter | Default | Description |
|-----------|---------|-------------|
| `QUESTIONNAIRE_VERSION` | "v1" | Active question set version |
| `QUESTIONNAIRE_MIN_QUESTIONS` | 10 | Required questions |
| `QUESTIONNAIRE_TOTAL_QUESTIONS` | 25 | Total questions in set |
| `QUESTIONNAIRE_AUTO_SAVE` | true | Save after each answer |
| `QUESTIONNAIRE_ALLOW_SKIP` | false | Allow skipping non-required |

### Photo Verification

| Parameter | Default | Description |
|-----------|---------|-------------|
| `VERIFICATION_MAX_RETRIES` | 3 | Liveness check retries |
| `VERIFICATION_SESSION_TIMEOUT_MINUTES` | 10 | Session expiry |
| `VERIFICATION_RAW_PHOTO_RETENTION_HOURS` | 24 | Before deletion |
| `VERIFICATION_FACE_VECTOR_ENABLED` | true | Store verification vectors (trust/safety only in MVP) |
| `VERIFICATION_AGE_CHECK_ENABLED` | true | Optional age-consistency risk signal (not ranking input) |
| `VERIFICATION_AGE_TOLERANCE_YEARS` | 2 | Allowed variance |

---

## Chat Configuration

### Messaging

| Parameter | Default | Description |
|-----------|---------|-------------|
| `MESSAGE_MAX_LENGTH` | 2000 | Max characters per message |
| `MESSAGE_HISTORY_PAGE_SIZE` | 50 | Messages per pagination request |
| `MESSAGE_HISTORY_MAX_PAGES` | 100 | Max pages retrievable |
| `MESSAGE_RETENTION_DAYS_ACTIVE` | -1 | Days to keep (active match) |
| `MESSAGE_RETENTION_DAYS_CLOSED` | 30 | Days to keep (closed match) |
| `MESSAGE_DEDUP_WINDOW_SECONDS` | 60 | ClientMessageId dedup window |
| `CHAT_FIRST_MESSAGE_POLICY` | "free_for_all" | Who can send first message after match |

### Real-Time

| Parameter | Default | Description |
|-----------|---------|-------------|
| `WEBSOCKET_HEARTBEAT_SECONDS` | 30 | Ping interval |
| `WEBSOCKET_IDLE_TIMEOUT_SECONDS` | 300 | Connection timeout |
| `TYPING_INDICATOR_TIMEOUT_SECONDS` | 10 | Hide typing after inactivity |
| `TYPING_INDICATOR_RATE_LIMIT` | 10 | Max typing events per minute |
| `FALLBACK_POLLING_INTERVAL_SECONDS` | 5 | Poll interval if WS unavailable |

### Rate Limits

| Parameter | Default | Window | Description |
|-----------|---------|--------|-------------|
| `RATE_LIMIT_MESSAGES_PER_MINUTE` | 30 | 60s | Max messages sent |
| `RATE_LIMIT_MESSAGES_PER_HOUR` | 200 | 3600s | Hourly message cap |

---

## Safety Configuration

### Reporting

| Parameter | Default | Description |
|-----------|---------|-------------|
| `REPORT_MAX_DESCRIPTION_LENGTH` | 2000 | Max chars in report |
| `REPORT_EVIDENCE_AUTO_ATTACH_COUNT` | 10 | Recent messages attached |
| `REPORT_ALLOW_ANONYMOUS` | false | Anonymous reporting |

### Moderation SLA

| Parameter | Default | Description |
|-----------|---------|-------------|
| `SLA_CRITICAL_MEDIAN_MINUTES` | 15 | Median response for critical |
| `SLA_CRITICAL_P95_MINUTES` | 60 | P95 response for critical |
| `SLA_HIGH_MEDIAN_HOURS` | 4 | Median response for high |
| `SLA_STANDARD_MEDIAN_HOURS` | 24 | Median response for standard |

### AI Moderation

| Parameter | Default | Description |
|-----------|---------|-------------|
| `MODERATION_AI_ENABLED` | true | Enable AI scanning |
| `MODERATION_AI_SCAN_ALL_MESSAGES` | true | Scan all chat messages |
| `MODERATION_AI_MAX_LATENCY_MS` | 500 | Max processing time |
| `MODERATION_FALSE_POSITIVE_TARGET` | 0.05 | Target false positive rate |

### AI/LLM Providers

| Parameter | Default | Description |
|-----------|---------|-------------|
| `AI_LLM_PRIMARY_PROVIDER` | "openrouter" | Primary LLM provider (openrouter, vertex) |
| `AI_LLM_FALLBACK_PROVIDER` | "vertex" | Fallback LLM provider |
| `AI_OPENROUTER_API_KEY` | - | OpenRouter API key (from Infisical) |
| `AI_OPENROUTER_DEFAULT_MODEL` | "anthropic/claude-3-sonnet" | Default model for OpenRouter |
| `AI_VERTEX_PROJECT_ID` | - | GCP project ID for Vertex AI |
| `AI_VERTEX_LOCATION` | "us-central1" | Vertex AI region |
| `AI_LLM_MAX_LATENCY_MS` | 2000 | Max LLM response time |
| `AI_LLM_DAILY_BUDGET_USD` | 50 | Daily budget for LLM calls |
| `AI_LLM_CACHE_TTL_SECONDS` | 3600 | Cache TTL for LLM responses |

### Matching Engine AI

| Parameter | Default | Description |
|-----------|---------|-------------|
| `AI_PSYCH_MODEL_VERSION` | "v1" | Pinned psych model version |
| `AI_VISUAL_MODEL_VERSION` | "v1" | Pinned visual model version |
| `AI_REASON_MODEL_VERSION` | "v1" | Pinned reason generator version |
| `AI_CONFIDENCE_MIN_THRESHOLD` | 0.50 | Minimum confidence to accept |
| `AI_ENABLE_BATCH_CACHING` | true | Cache LLM results within batch |

### Evidence & Retention

| Parameter | Default | Description |
|-----------|---------|-------------|
| `EVIDENCE_RETENTION_DAYS` | 90 | Minimum retention |
| `EVIDENCE_LEGAL_HOLD_EXTENDS_TO_DAYS` | 365 | Extended retention on hold |
| `ACCOUNT_DELETION_GRACE_DAYS` | 30 | Before permanent deletion |

---

## Notification Configuration

### Push Notifications

| Parameter | Default | Description |
|-----------|---------|-------------|
| `PUSH_ENABLED` | true | Enable push notifications |
| `PUSH_DAILY_MATCH_ENABLED` | true | Notify on new matches |
| `PUSH_NEW_MESSAGE_ENABLED` | true | Notify on new messages |
| `PUSH_MUTUAL_MATCH_ENABLED` | true | Notify on mutual match |
| `PUSH_QUIET_HOURS_START` | "22:00" | No notifications after |
| `PUSH_QUIET_HOURS_END` | "08:00" | Resume notifications |
| `PUSH_RATE_LIMIT_PER_MINUTE` | 5 | Max pushes per user |

---

## Monetization Configuration

> **MVP Note:** Monetization is disabled for MVP. All features are free. These settings apply post-MVP.

### Monetization Toggle

| Parameter | Default | Description |
|-----------|---------|-------------|
| `MONETIZATION_ENABLED` | false | Enable paid tiers (post-MVP) |
| `ALL_FEATURES_FREE` | true | Grant all features to all users (MVP mode) |

### Tiers (Post-MVP)

| Parameter | Default | Description |
|-----------|---------|-------------|
| `TIER_FREE_MATCHES_PER_DAY` | 3 | Daily matches for free tier |
| `TIER_FREE_SEE_WHO_LIKED_YOU` | false | Free tier feature |
| `TIER_PREMIUM_PRICE_MONTHLY` | 19.99 | Premium monthly price (USD) |
| `TIER_PREMIUM_PRICE_YEARLY` | 149.99 | Premium yearly price (USD) |
| `TIER_PREMIUM_PLUS_PRICE_MONTHLY` | 29.99 | Premium+ monthly price |
| `TIER_PREMIUM_PLUS_PRICE_YEARLY` | 249.99 | Premium+ yearly price |

### Trials & Promotions

| Parameter | Default | Description |
|-----------|---------|-------------|
| `TRIAL_PREMIUM_DAYS` | 7 | Free trial length |
| `TRIAL_ENABLED` | true | Enable free trials |
| `REFERRAL_BONUS_DAYS` | 7 | Premium days for referral |

---

## Infrastructure Configuration

### Database

| Parameter | Default | Description |
|-----------|---------|-------------|
| `DB_POOL_MIN` | 5 | Min connection pool |
| `DB_POOL_MAX` | 20 | Max connection pool |
| `DB_STATEMENT_TIMEOUT_MS` | 30000 | Query timeout |
| `DB_SLOW_QUERY_LOG_MS` | 1000 | Log queries slower than |

### Redis

| Parameter | Default | Description |
|-----------|---------|-------------|
| `REDIS_POOL_SIZE` | 10 | Connection pool size |
| `REDIS_KEY_PREFIX` | "yoked:" | Key namespace |
| `SESSION_TTL_SECONDS` | 86400 | Session expiry (24h) |

### Backup & Recovery

| Parameter | Default | Description |
|-----------|---------|-------------|
| `BACKUP_FREQUENCY` | "daily" | Backup schedule |
| `BACKUP_RETENTION_DAYS` | 30 | Backup retention |
| `DISASTER_RECOVERY_RTO_HOURS` | 4 | Recovery time objective |
| `DISASTER_RECOVERY_RPO_HOURS` | 24 | Recovery point objective |

---

## Feature Flags

All feature flags default to `false` unless specified.

| Flag | Default | Description |
|------|---------|-------------|
| `ENABLE_VIDEO_CHAT` | false | Video calling feature |
| `ENABLE_AI_COACH` | false | AI conversation assistant (opening lines, coaching) |
| `ENABLE_AI_COACH_OPENING_LINES` | false | AI-generated opening line suggestions |
| `ENABLE_AI_MATCH_REASONS` | true | AI-enhanced match explanations |
| `ENABLE_VOICE_MESSAGES` | false | Voice message support |
| `ENABLE_PHOTO_COMMENTS` | false | Comment on profile photos |
| `ENABLE_DATE_PLANNING` | false | Integrated date booking |
| `ENABLE_PROFILE_BOOST` | false | Profile visibility boost |
| `ENABLE_READ_RECEIPTS_DISABLE` | false | Let users hide read status |

---

## Configuration Access Patterns

### Configuration Resolution Order

When reading configuration, values are resolved in this priority (highest wins):

1. **User-specific override** (per-user, rare)
2. **Segment override** (group-based)
3. **Database default** (`system_config` table)
4. **Environment variable** (deployment-level)
5. **Code default** (hardcoded fallback)

```
┌─────────────────────────────────────────────────────────┐
│                    Config Request                        │
│                  (user_id, config_key)                   │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│  1. Check user-specific override                        │
│     → If found: RETURN                                  │
└─────────────────────┬───────────────────────────────────┘
                      │ Not found
                      ▼
┌─────────────────────────────────────────────────────────┐
│  2. Check segment overrides (by priority)               │
│     → Get user's segments                               │
│     → Check segment_config_overrides                    │
│     → If found: RETURN highest priority                 │
└─────────────────────┬───────────────────────────────────┘
                      │ Not found
                      ▼
┌─────────────────────────────────────────────────────────┐
│  3. Check system_config (global default)                │
│     → If found: RETURN                                  │
└─────────────────────┬───────────────────────────────────┘
                      │ Not found
                      ▼
┌─────────────────────────────────────────────────────────┐
│  4. Check environment variable                          │
│     → If found: RETURN                                  │
└─────────────────────┬───────────────────────────────────┘
                      │ Not found
                      ▼
┌─────────────────────────────────────────────────────────┐
│  5. Return code default                                 │
└─────────────────────────────────────────────────────────┘
```

### Reading Configuration

```typescript
// In application code
import { config } from '@yoked/config';

const matchesPerDay = config.getInt('MATCHES_PER_DAY_DEFAULT', 3);
const batchTime = config.getString('MATCH_BATCH_TIME', '09:00');
const featureEnabled = config.getBool('ENABLE_VIDEO_CHAT', false);
```

### Updating Configuration

```sql
-- Runtime updates via database
INSERT INTO system_config (key, value, updated_by) 
VALUES ('MATCHES_PER_DAY_DEFAULT', '5', 'admin@yoked.app');

-- Changes take effect within 60 seconds (cache refresh)
```

### Environment Variable Override

```bash
# Environment variables override database settings
export MATCHES_PER_DAY_DEFAULT=5
export ENABLE_VIDEO_CHAT=true
```

---

## Segment Management

### Built-in Segments

| Segment | Key | Type | Description |
|---------|-----|------|-------------|
| All Users | `all_users` | manual | Every user (system) |
| United States | `country_us` | auto_country | Users with US location |
| United Kingdom | `country_gb` | auto_country | Users with UK location |
| Canada | `country_ca` | auto_country | Users with Canada location |
| Australia | `country_au` | auto_country | Users with Australia location |
| Beta Testers | `beta_testers` | manual | Manually assigned beta group |

### Creating Custom Segments

```sql
-- Create a new segment
INSERT INTO user_segments (key, name, type, description, criteria)
VALUES ('high_engagement', 'High Engagement Users', 'custom', 'Users with >10 matches', 
        '{"min_matches": 10, "days_active": 30}');

-- Add users to segment manually
INSERT INTO user_segment_members (segment_id, user_id, added_by)
SELECT 'segment-uuid', id, 'admin-uuid'
FROM users WHERE id IN ('user-1', 'user-2');
```

### Segment Types

| Type | Behavior | Criteria Example |
|------|----------|------------------|
| `manual` | Admin assigns users | N/A |
| `auto_country` | Auto-assigned by profile location | `{"country": "US"}` |
| `auto_age` | Auto-assigned by age range | `{"min_age": 25, "max_age": 35}` |
| `auto_activity` | Auto-assigned by engagement | `{"min_logins": 10, "days": 30}` |
| `custom` | Custom SQL criteria | `{"sql_condition": "matches_count > 5"}` |

### Applying Config to Segments

```sql
-- Apply custom config to a segment
INSERT INTO segment_config_overrides (segment_id, config_key, override_value, override_type, priority, updated_by)
VALUES (
  'beta-testers-uuid',
  'MATCHES_PER_DAY_DEFAULT',
  '10',
  'integer',
  100,
  'admin@yoked.app'
);

-- Multiple segments can have different values
-- Higher priority wins when user is in multiple segments
INSERT INTO segment_config_overrides (segment_id, config_key, override_value, priority, updated_by)
VALUES 
  ('us-users-uuid', 'GEO_MAX_DISTANCE_KM', '50', 10, 'admin@yoked.app'),
  ('uk-users-uuid', 'GEO_MAX_DISTANCE_KM', '30', 10, 'admin@yoked.app');
```

### Resetting Segment Config

```sql
-- Remove override (fall back to global default)
DELETE FROM segment_config_overrides 
WHERE segment_id = 'segment-uuid' 
AND config_key = 'MATCHES_PER_DAY_DEFAULT';

-- Reset all overrides for a segment
DELETE FROM segment_config_overrides 
WHERE segment_id = 'segment-uuid';
```

### Viewing Effective Config for User

```sql
-- Get all effective config values for a user
SELECT * FROM get_user_config('user-uuid');

-- Returns resolved values considering:
-- 1. User-specific overrides
-- 2. Segment memberships (by priority)
-- 3. Global defaults
```

---

## Admin Operations

### User Management

```sql
-- View user's segments
SELECT s.key, s.name, m.added_at
FROM user_segment_members m
JOIN user_segments s ON s.id = m.segment_id
WHERE m.user_id = 'user-uuid';

-- Add user to segment
INSERT INTO user_segment_members (segment_id, user_id, added_by)
VALUES ('segment-uuid', 'user-uuid', 'admin-uuid');

-- Remove user from segment
DELETE FROM user_segment_members 
WHERE segment_id = 'segment-uuid' 
AND user_id = 'user-uuid';

-- Bulk add users to segment
INSERT INTO user_segment_members (segment_id, user_id, added_by)
SELECT 'segment-uuid', id, 'admin-uuid'
FROM users WHERE country = 'US';
```

### Configuration Management

```sql
-- Update global config
UPDATE system_config 
SET value = '5', updated_at = NOW(), updated_by = 'admin@yoked.app'
WHERE key = 'MATCHES_PER_DAY_DEFAULT';

-- View all segment overrides for a config key
SELECT s.key as segment, sco.override_value, sco.priority
FROM segment_config_overrides sco
JOIN user_segments s ON s.id = sco.segment_id
WHERE sco.config_key = 'MATCHES_PER_DAY_DEFAULT'
ORDER BY sco.priority DESC;

-- Audit trail for config changes
SELECT * FROM admin_audit_log 
WHERE target_type = 'config' 
ORDER BY created_at DESC 
LIMIT 50;
```

### Authentication (Supabase Auth)

Supabase Auth handles:
- Phone OTP verification
- Social login (Apple, Google)
- Session management
- JWT token generation/validation

```typescript
// Client-side auth
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Phone OTP
await supabase.auth.signInWithOtp({ phone: '+1234567890' });

// Verify OTP
await supabase.auth.verifyOtp({ 
  phone: '+1234567890', 
  token: '123456' 
});

// Social login
await supabase.auth.signInWithOAuth({ provider: 'google' });
```

---

## Configuration Change Log

| Date | Parameter | Old | New | Reason |
|------|-----------|-----|-----|--------|
| 2026-02-19 | Initial | - | - | Initial configuration documented |

---

## Related Documents

- `docs/ops/slo-sla.md` - Service level objectives
- `docs/technical/decisions/ADR-0004-matchmaking-idempotency.md` - Idempotency patterns
- `docs/technical/contracts/openapi.yaml` - API specifications
