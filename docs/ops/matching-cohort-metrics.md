# Matching Cohort Metrics Spec

Owner: Product + Data Science + Trust & Safety + Engineering  
Status: Draft  
Last Updated: 2026-02-20  
Depends On: `docs/specs/gender-responsive-matching.md`, `docs/specs/matching-scoring-engine.md`, `docs/technical/schema/database.md`, `docs/technical/contracts/openapi.yaml`, `docs/ops/slo-sla.md`

## Overview

This document defines the metrics layer used to evaluate gender-responsive matching outcomes. It standardizes:
- event-level inputs
- metric formulas
- cohort/segment breakdown rules
- admin dashboard API contracts
- alert thresholds and escalation paths

This metrics stack is for product quality and safety governance, not experimentation.

## Scope

### In Scope

- Cohort metrics for women, men, and other gender identities where sample size is reliable.
- Behavioral segment metrics (`high_inbound_pressure`, `low_inbound_low_response`, `balanced`).
- Daily and weekly aggregations for matching outcomes, messaging outcomes, and safety outcomes.
- Read-only admin access to metrics and alerts.

### Out of Scope

- Direct gender-based ranking logic.
- Public-facing user analytics.
- Monetization analytics.

## Canonical Cohort Dimensions

- `gender_identity`: `female`, `male`, `non_binary`, `prefer_not_to_say`, `other`
- `policy_segment`: `high_inbound_pressure`, `low_inbound_low_response`, `balanced`
- `region`: ISO country code (optional for rollups)

Rules:
- Metrics must support `all` rollups for each dimension.
- Hide cohort slices that do not meet minimum sample threshold (`n < 50`) and mark as insufficient.
- Any use of `gender_identity` is analytics-only.

## Event Inputs (Canonical)

Primary sources:
- `analytics_events`
- `match_offers`
- `matches`
- `messages`
- `reports`
- `blocks`

Required event names in `analytics_events.event_type`:
- `match_offer_presented`
- `match_offer_action` (properties include `action=accept|pass|not_now`)
- `match_mutual_created`
- `message_sent`
- `message_replied`
- `message_flagged_unwanted_content`
- `user_queue_fatigue_signal`
- `policy_segment_assigned`

### Event Schema Contract (Required Properties)

All events must include:
- `event_type`
- `user_id` (nullable only for system events)
- `created_at`
- `event_properties` (JSON object, required keys by event type)

| Event Type | Required `event_properties` | Optional `event_properties` | Notes |
|---|---|---|---|
| `match_offer_presented` | `offer_id`, `candidate_user_id`, `policy_segment` | `score`, `is_anchor`, `reason_codes` | Emitted once per shown offer |
| `match_offer_action` | `offer_id`, `action`, `policy_segment` | `previous_status`, `score` | `action` in `accept|pass|not_now` |
| `match_mutual_created` | `match_id`, `offer_id`, `policy_segment` | `time_to_mutual_seconds` | Emitted when mutual acceptance is created |
| `message_sent` | `match_id`, `message_id`, `sender_role` | `contains_media`, `client_message_id` | `sender_role` in `initiator|receiver` |
| `message_replied` | `match_id`, `message_id`, `reply_latency_seconds` | `sender_role` | Used for reply-within-24h computations |
| `message_flagged_unwanted_content` | `match_id`, `report_id`, `content_category` | `severity` | `content_category` aligns with safety taxonomy |
| `user_queue_fatigue_signal` | `signal_type`, `policy_segment` | `pending_offer_count`, `decision_latency_seconds` | `signal_type` in `high_backlog|rapid_passes|timeout_pattern` |
| `policy_segment_assigned` | `policy_segment`, `assignment_reason` | `previous_segment` | Emitted on assignment and segment transitions |

Validation rules:
- Unknown keys are allowed but ignored by aggregation jobs unless added to this contract.
- Missing required keys route event to a dead-letter stream and fail conformance checks.
- `policy_segment` value must be one of: `high_inbound_pressure`, `low_inbound_low_response`, `balanced`.

## Metric Dictionary

| Metric Key | Definition | Numerator | Denominator | Granularity |
|---|---|---|---|---|
| `too_few_messages_rate` | Share of active users with low inbound message count | users with inbound messages < configured floor | active users in cohort | daily, weekly |
| `too_many_messages_rate` | Share of active users with high inbound message count | users with inbound messages > configured ceiling | active users in cohort | daily, weekly |
| `unwanted_content_report_rate_per_1k` | Unwanted content reports normalized by match volume | unwanted content reports | mutual matches / 1000 | daily, weekly |
| `mutual_match_rate` | Match offer mutual acceptance quality | mutual matches | offers shown | daily, weekly |
| `reply_within_24h_rate` | Conversation start quality | matched pairs with reply <=24h | new matches | daily, weekly |
| `unmatch_7d_rate` | Early quality breakdown signal | matches unmatched within 7 days | new matches | daily, weekly |
| `decision_fatigue_rate` | Share of users with fatigue indicator | users emitting fatigue signal | active users in cohort | daily, weekly |
| `exposure_acceptance_parity_delta` | Outcome parity delta across cohorts | max-min acceptance rates across cohorts | n/a | weekly |

## Aggregation and Freshness

- Aggregation cadence: hourly incremental, daily finalized by `06:00 UTC`.
- Weekly rollups: ISO week, materialized after daily finalization.
- Backfill window: 30 days for late-arriving events.
- Version all metric formulas with `metric_version`.

## Storage Model

Derived storage (see `docs/technical/schema/database.md`):
- `analytics_event_schemas`
- `cohort_metric_daily`
- `cohort_metric_weekly`
- `cohort_metric_alerts`
- `matching_metric_runs`

Retention:
- Derived aggregates: 24 months
- Run/audit records: 24 months

## Dashboard Requirements (Admin)

Required dashboard panels:
- Cohort health summary cards:
  - `too_few_messages_rate`
  - `too_many_messages_rate`
  - `unwanted_content_report_rate_per_1k`
  - `reply_within_24h_rate`
- Trend charts by cohort and segment (daily and weekly)
- Alert feed for parity and safety drift
- Metric metadata panel showing formula version and data freshness

### SQL Examples (PostgreSQL)

1. Cohort health summary cards (latest daily value per metric/cohort):

```sql
SELECT DISTINCT ON (metric_key, cohort_dimension, cohort_value, policy_segment, region)
  metric_key,
  cohort_dimension,
  cohort_value,
  policy_segment,
  region,
  metric_date,
  metric_value,
  sample_size,
  is_insufficient_data,
  metric_version
FROM cohort_metric_daily
WHERE metric_key IN (
  'too_few_messages_rate',
  'too_many_messages_rate',
  'unwanted_content_report_rate_per_1k',
  'reply_within_24h_rate'
)
ORDER BY metric_key, cohort_dimension, cohort_value, policy_segment, region, metric_date DESC;
```

2. Trend chart series by cohort (daily):

```sql
SELECT
  metric_date AS period_start,
  cohort_dimension,
  cohort_value,
  policy_segment,
  region,
  metric_value,
  numerator,
  denominator,
  sample_size,
  is_insufficient_data
FROM cohort_metric_daily
WHERE metric_key = 'mutual_match_rate'
  AND metric_date BETWEEN $1::date AND $2::date
  AND cohort_dimension = COALESCE($3, cohort_dimension)
  AND cohort_value = COALESCE($4, cohort_value)
  AND policy_segment = COALESCE($5, policy_segment)
  AND region = COALESCE($6, region)
ORDER BY metric_date ASC;
```

3. Alert feed:

```sql
SELECT
  id,
  metric_key,
  severity,
  status,
  cohort_dimension,
  cohort_value,
  policy_segment,
  region,
  observed_value,
  baseline_value,
  threshold_value,
  delta_ratio,
  detected_at,
  resolved_at
FROM cohort_metric_alerts
WHERE ($1::text IS NULL OR severity = $1)
  AND ($2::text IS NULL OR status = $2)
  AND ($3::date IS NULL OR detected_at::date >= $3)
  AND ($4::date IS NULL OR detected_at::date <= $4)
ORDER BY detected_at DESC
LIMIT $5 OFFSET $6;
```

4. Metric metadata panel (freshness + run status):

```sql
SELECT
  d.metric_key,
  d.metric_version,
  MAX(d.freshness_at) AS latest_freshness_at,
  r.id AS latest_run_id,
  r.status AS latest_run_status,
  r.completed_at AS latest_run_completed_at
FROM cohort_metric_daily d
LEFT JOIN LATERAL (
  SELECT id, status, completed_at
  FROM matching_metric_runs
  WHERE metric_version = d.metric_version
  ORDER BY completed_at DESC NULLS LAST, started_at DESC
  LIMIT 1
) r ON TRUE
GROUP BY d.metric_key, d.metric_version, r.id, r.status, r.completed_at
ORDER BY d.metric_key, d.metric_version;
```

## Alerting and Escalation

Default alert rules:
- Critical: `unwanted_content_report_rate_per_1k` increases >20% week-over-week for any cohort.
- High: `reply_within_24h_rate` drops >10% week-over-week for any cohort.
- High: `exposure_acceptance_parity_delta` exceeds `MATCH_COHORT_PARITY_ALERT_THRESHOLD`.
- Medium: `decision_fatigue_rate` exceeds threshold for 3 consecutive days.

Escalation targets:
- Critical/High: Trust & Safety + Product + Data Science
- Medium: Product + Data Science

## Data Quality Rules

- Reject rows with missing required dimensions.
- Enforce denominator > 0 for rate metrics; otherwise mark value as null with `insufficient_data`.
- Validate event schema conformance before aggregation.
- Track job failures and stale data via `matching_metric_runs`.

## API Contract Requirements

The admin API must provide:
- Timeseries query endpoint for a metric with cohort breakdown.
- Summary endpoint for latest values and deltas.
- Alert feed endpoint with severity/status filters.

All endpoints are read-only and admin-authenticated.

## Related Config Keys

- `MATCH_COHORT_PARITY_ALERT_THRESHOLD`
- `MATCH_COHORT_MIN_SAMPLE_SIZE`
- `MATCH_METRIC_TOO_FEW_MESSAGES_FLOOR`
- `MATCH_METRIC_TOO_MANY_MESSAGES_CEILING`
- `MATCH_GENDER_RESPONSIVE_MODE`
- `MATCH_HIGH_INBOUND_QUEUE_CAP`
- `MATCH_LOW_INBOUND_MIN_RECIPROCITY`
