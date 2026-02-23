# Database Schema

Owner: Engineering  
Status: Active  
Last Updated: 2026-02-21  
Depends On: `docs/technical/contracts/openapi.yaml`, `docs/specs/onboarding.md`, `docs/specs/matching.md`, `docs/specs/chat.md`, `docs/specs/safety.md`, `docs/specs/notifications.md`, `docs/specs/settings.md`

## Overview

Yoked uses PostgreSQL (via Supabase) with Row Level Security (RLS) for data isolation. This document defines the complete schema for all tables, indexes, and constraints.

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Tables | `snake_case`, plural | `match_offers` |
| Columns | `snake_case` | `created_at` |
| Primary keys | `id` (UUID) | `id UUID PRIMARY KEY` |
| Foreign keys | `{table}_id` | `user_id REFERENCES users(id)` |
| Indexes | `idx_{table}_{columns}` | `idx_messages_match_created` |
| Timestamps | `{action}_at` (timestamptz) | `created_at`, `read_at` |

## Core Tables

### users

Primary user accounts.

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone_hash TEXT NOT NULL UNIQUE,
  phone_last_four TEXT NOT NULL,
  display_name TEXT CHECK (char_length(display_name) >= 2 AND char_length(display_name) <= 50),
  bio TEXT CHECK (char_length(bio) <= 500),
  date_of_birth DATE NOT NULL,
  gender TEXT CHECK (gender IN ('male', 'female', 'non_binary', 'prefer_not_to_say')),
  seeking_gender TEXT[] CHECK (array_length(seeking_gender, 1) >= 1),
  status TEXT NOT NULL DEFAULT 'pending_verification' 
    CHECK (status IN ('active', 'suspended', 'pending_verification', 'non_matching', 'deleted')),
  onboarding_step TEXT NOT NULL DEFAULT 'phone_verify'
    CHECK (onboarding_step IN ('phone_verify', 'profile', 'questionnaire', 'verification', 'complete')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_active_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,

  CONSTRAINT valid_age CHECK (date_of_birth <= CURRENT_DATE - INTERVAL '18 years')
);

CREATE INDEX idx_users_phone_hash ON users(phone_hash);
CREATE INDEX idx_users_status ON users(status);
```

### profiles

Extended profile information including location and preferences.

```sql
CREATE TABLE profiles (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  city TEXT NOT NULL,
  region TEXT,
  country TEXT NOT NULL DEFAULT 'US',
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  max_distance_km INTEGER DEFAULT 50 CHECK (max_distance_km BETWEEN 1 AND 500),
  min_age_preference INTEGER DEFAULT 18 CHECK (min_age_preference >= 18),
  max_age_preference INTEGER DEFAULT 120 CHECK (max_age_preference <= 120),
  relationship_intent TEXT CHECK (relationship_intent IN ('casual', 'serious', 'marriage', 'unsure')),
  physical_preferences JSONB,
  education TEXT,
  occupation TEXT,
  height_cm INTEGER CHECK (height_cm BETWEEN 100 AND 250),
  drinking TEXT CHECK (drinking IN ('never', 'rarely', 'socially', 'often')),
  smoking TEXT CHECK (smoking IN ('never', 'trying_to_quit', 'socially', 'regularly')),
  exercise TEXT CHECK (exercise IN ('never', 'sometimes', 'often', 'daily')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_profiles_location ON profiles 
  USING GIST(point(longitude, latitude));
CREATE INDEX idx_profiles_city ON profiles(city);
```

### photos

User profile photos.

```sql
CREATE TABLE photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  thumbnail_url TEXT,
  is_primary BOOLEAN NOT NULL DEFAULT false,
  position INTEGER NOT NULL DEFAULT 0 CHECK (position BETWEEN 0 AND 5),
  verification_session_id UUID,
  is_verified BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT unique_primary_per_user EXCLUDE (
    user_id WITH =,
    (CASE WHEN is_primary THEN 1 END) WITH =
  ) WHERE (is_primary)
);

CREATE INDEX idx_photos_user ON photos(user_id);
CREATE INDEX idx_photos_primary ON photos(user_id) WHERE is_primary;
```

---

## Authentication Tables

### social_identities

Linked social auth providers.

```sql
CREATE TABLE social_identities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider TEXT NOT NULL CHECK (provider IN ('apple', 'google')),
  provider_user_id TEXT NOT NULL,
  email TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(provider, provider_user_id)
);

CREATE INDEX idx_social_identities_user ON social_identities(user_id);
```

### auth_sessions

Active user sessions.

```sql
CREATE TABLE auth_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id TEXT NOT NULL,
  device_type TEXT CHECK (device_type IN ('ios', 'android', 'web')),
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  last_used_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  revoked_at TIMESTAMPTZ,
  revoked_reason TEXT CHECK (revoked_reason IN ('logout', 'security', 'expired')),
  revoked_by UUID REFERENCES users(id),

  CONSTRAINT valid_expiry CHECK (expires_at > created_at),
  CONSTRAINT valid_revocation_pair CHECK (
    (revoked_at IS NULL AND revoked_reason IS NULL)
    OR (revoked_at IS NOT NULL AND revoked_reason IS NOT NULL)
  )
);

CREATE INDEX idx_sessions_user ON auth_sessions(user_id);
CREATE INDEX idx_sessions_device ON auth_sessions(device_id);
CREATE INDEX idx_sessions_expiry ON auth_sessions(expires_at);
CREATE INDEX idx_sessions_revoked ON auth_sessions(revoked_at);
```

### account_recovery_requests

Account recovery workflow tracking.

```sql
CREATE TABLE account_recovery_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  reason TEXT NOT NULL CHECK (reason IN ('lost_device', 'forgot_pin', 'suspicious_activity', 'other')),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_review', 'approved', 'rejected', 'expired')),
  hold_until TIMESTAMPTZ NOT NULL DEFAULT NOW() + INTERVAL '72 hours',
  reviewed_by UUID,
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX idx_recovery_user ON account_recovery_requests(user_id);
CREATE INDEX idx_recovery_status ON account_recovery_requests(status);
```

---

## Questionnaire Tables

### questionnaire_versions

Versioned question sets.

```sql
CREATE TABLE questionnaire_versions (
  id TEXT PRIMARY KEY,
  description TEXT,
  is_active BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deprecated_at TIMESTAMPTZ
);
```

### questions

Individual questions within versions.

```sql
CREATE TABLE questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  version_id TEXT NOT NULL REFERENCES questionnaire_versions(id),
  category TEXT NOT NULL CHECK (category IN ('values', 'lifestyle', 'communication', 'interests', 'background')),
  type TEXT NOT NULL CHECK (type IN ('single_choice', 'multiple_choice', 'slider', 'text', 'ranking')),
  prompt TEXT NOT NULL,
  description TEXT,
  options JSONB,
  config JSONB,
  position INTEGER NOT NULL,
  is_required BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(version_id, position)
);

CREATE INDEX idx_questions_version ON questions(version_id);
CREATE INDEX idx_questions_category ON questions(category);
```

### compatibility_responses

User answers to questionnaire.

```sql
CREATE TABLE compatibility_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES questions(id),
  version_id TEXT NOT NULL REFERENCES questionnaire_versions(id),
  answer JSONB NOT NULL,
  answered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id, question_id)
);

CREATE INDEX idx_responses_user ON compatibility_responses(user_id);
CREATE INDEX idx_responses_version ON compatibility_responses(version_id);
```

---

## Visual Preference Studio Tables

### visual_reference_images

Reference image pool for pairwise preference tasks.

```sql
CREATE TABLE visual_reference_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_mode TEXT NOT NULL CHECK (source_mode IN ('licensed_synthetic', 'consented_real')),
  url TEXT NOT NULL,
  thumbnail_url TEXT,
  quality_score DECIMAL(3, 2) CHECK (quality_score BETWEEN 0 AND 1),
  style_tags TEXT[] NOT NULL DEFAULT '{}',
  sensitive_audit_tags JSONB,
  consent_artifact_ref TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  retired_at TIMESTAMPTZ
);

CREATE INDEX idx_vri_active ON visual_reference_images(is_active, source_mode);
CREATE INDEX idx_vri_tags ON visual_reference_images USING GIN(style_tags);
```

### visual_preference_sessions

User-level VPS sessions (onboarding or recalibration).

```sql
CREATE TABLE visual_preference_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  mode TEXT NOT NULL CHECK (mode IN ('onboarding', 'recalibration')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'expired', 'cancelled')),
  target_pairs INTEGER NOT NULL DEFAULT 20 CHECK (target_pairs BETWEEN 1 AND 40),
  completed_pairs INTEGER NOT NULL DEFAULT 0 CHECK (completed_pairs >= 0),
  confidence_before DECIMAL(4, 3) CHECK (confidence_before BETWEEN 0 AND 1),
  confidence_after DECIMAL(4, 3) CHECK (confidence_after BETWEEN 0 AND 1),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT NOW() + INTERVAL '24 hours',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX idx_vps_user ON visual_preference_sessions(user_id, created_at DESC);
CREATE INDEX idx_vps_status ON visual_preference_sessions(status, expires_at);
```

### visual_preference_pairs

Pairwise tasks served to users in VPS sessions.

```sql
CREATE TABLE visual_preference_pairs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES visual_preference_sessions(id) ON DELETE CASCADE,
  task_index INTEGER NOT NULL CHECK (task_index >= 1),
  left_image_id UUID NOT NULL REFERENCES visual_reference_images(id),
  right_image_id UUID NOT NULL REFERENCES visual_reference_images(id),
  choice TEXT CHECK (choice IN ('left', 'right', 'neither', 'skip')),
  chosen_image_id UUID REFERENCES visual_reference_images(id),
  response_time_ms INTEGER CHECK (response_time_ms >= 0),
  presented_at TIMESTAMPTZ,
  responded_at TIMESTAMPTZ,
  client_event_id TEXT,
  device_id TEXT,
  skipped_reason TEXT CHECK (skipped_reason IN ('unsure', 'neither_preferred', 'time_limit')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(session_id, task_index),
  CHECK (left_image_id <> right_image_id),
  CHECK (
    choice IS NULL
    OR (choice IN ('left', 'right') AND chosen_image_id IS NOT NULL)
    OR (choice IN ('neither', 'skip') AND chosen_image_id IS NULL)
  )
);

CREATE INDEX idx_vpp_session ON visual_preference_pairs(session_id, task_index);
CREATE INDEX idx_vpp_choice ON visual_preference_pairs(choice);
```

### visual_preference_choice_events

Immutable event log for VPS choice submissions and client telemetry.

```sql
CREATE TABLE visual_preference_choice_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  session_id UUID NOT NULL REFERENCES visual_preference_sessions(id) ON DELETE CASCADE,
  pair_id UUID NOT NULL REFERENCES visual_preference_pairs(id) ON DELETE CASCADE,
  task_index INTEGER NOT NULL CHECK (task_index >= 1),
  left_image_id UUID NOT NULL REFERENCES visual_reference_images(id),
  right_image_id UUID NOT NULL REFERENCES visual_reference_images(id),
  choice TEXT NOT NULL CHECK (choice IN ('left', 'right', 'neither', 'skip')),
  chosen_image_id UUID REFERENCES visual_reference_images(id),
  response_time_ms INTEGER CHECK (response_time_ms >= 0),
  presented_at TIMESTAMPTZ,
  responded_at TIMESTAMPTZ,
  client_event_id TEXT,
  device_id TEXT,
  event_payload JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_vpce_user_created ON visual_preference_choice_events(user_id, created_at DESC);
CREATE INDEX idx_vpce_session ON visual_preference_choice_events(session_id, task_index);
CREATE UNIQUE INDEX idx_vpce_client_event
  ON visual_preference_choice_events(user_id, client_event_id)
  WHERE client_event_id IS NOT NULL;
```

### visual_preference_profiles

Current learned visual preference profile per user.

```sql
CREATE TABLE visual_preference_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'ready', 'stale')),
  confidence DECIMAL(4, 3) NOT NULL DEFAULT 0 CHECK (confidence BETWEEN 0 AND 1),
  completed_pairs INTEGER NOT NULL DEFAULT 0 CHECK (completed_pairs >= 0),
  target_pairs INTEGER NOT NULL DEFAULT 20 CHECK (target_pairs >= 1),
  preference_vector JSONB NOT NULL DEFAULT '{}'::jsonb,
  model_version TEXT NOT NULL DEFAULT 'v1',
  last_session_id UUID REFERENCES visual_preference_sessions(id),
  latest_snapshot_id UUID,
  refresh_recommended BOOLEAN NOT NULL DEFAULT false,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  stale_after TIMESTAMPTZ
);

CREATE INDEX idx_vpprof_status ON visual_preference_profiles(status, updated_at DESC);
```

### visual_preference_profile_snapshots

Historical snapshots of learned visual preference profile state.

```sql
CREATE TABLE visual_preference_profile_snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES visual_preference_profiles(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  session_id UUID REFERENCES visual_preference_sessions(id),
  status TEXT NOT NULL CHECK (status IN ('in_progress', 'ready', 'stale')),
  confidence DECIMAL(4, 3) NOT NULL CHECK (confidence BETWEEN 0 AND 1),
  completed_pairs INTEGER NOT NULL CHECK (completed_pairs >= 0),
  target_pairs INTEGER NOT NULL CHECK (target_pairs >= 1),
  preference_vector JSONB NOT NULL,
  model_version TEXT NOT NULL,
  reason TEXT NOT NULL CHECK (reason IN ('initial_build', 'recalibration', 'model_upgrade', 'manual_recompute')),
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_vpps_user_created ON visual_preference_profile_snapshots(user_id, created_at DESC);
CREATE INDEX idx_vpps_profile_created ON visual_preference_profile_snapshots(profile_id, created_at DESC);

ALTER TABLE visual_preference_profiles
  ADD CONSTRAINT fk_vpp_latest_snapshot
  FOREIGN KEY (latest_snapshot_id) REFERENCES visual_preference_profile_snapshots(id);
```

### photo_recommendation_runs

Execution records for Photo Studio recommendation requests.

```sql
CREATE TABLE photo_recommendation_runs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  input_photo_ids UUID[] NOT NULL,
  include_self_selection BOOLEAN NOT NULL DEFAULT true,
  max_recommendations INTEGER NOT NULL DEFAULT 4 CHECK (max_recommendations BETWEEN 1 AND 6),
  status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('completed', 'failed')),
  model_version TEXT NOT NULL DEFAULT 'v1',
  confidence DECIMAL(4, 3) CHECK (confidence BETWEEN 0 AND 1),
  failure_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,

  CHECK (array_length(input_photo_ids, 1) BETWEEN 3 AND 12)
);

CREATE INDEX idx_prr_user_created ON photo_recommendation_runs(user_id, created_at DESC);
```

### photo_recommendations

Ranked recommended photos output by each run.

```sql
CREATE TABLE photo_recommendations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  run_id UUID NOT NULL REFERENCES photo_recommendation_runs(id) ON DELETE CASCADE,
  photo_id UUID NOT NULL REFERENCES photos(id) ON DELETE CASCADE,
  rank INTEGER NOT NULL CHECK (rank >= 1),
  score DECIMAL(4, 3) NOT NULL CHECK (score BETWEEN 0 AND 1),
  confidence DECIMAL(4, 3) CHECK (confidence BETWEEN 0 AND 1),
  reasons TEXT[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(run_id, rank),
  UNIQUE(run_id, photo_id)
);

CREATE INDEX idx_photo_recs_run_rank ON photo_recommendations(run_id, rank);
```

---

## Verification Tables

### verification_sessions

Photo verification sessions.

```sql
CREATE TABLE verification_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'uploaded', 'processing', 'verified', 'failed', 'manual_review')),
  consent_version TEXT NOT NULL,
  upload_url TEXT,
  raw_photo_key TEXT,
  face_vector_id TEXT,
  age_estimate INTEGER,
  liveness_score DECIMAL(3, 2),
  failure_reason TEXT CHECK (failure_reason IN ('liveness_failed', 'age_verification_failed', 'quality_too_low', 'policy_violation')),
  retry_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ NOT NULL DEFAULT NOW() + INTERVAL '10 minutes'
);

CREATE INDEX idx_verification_user ON verification_sessions(user_id);
CREATE INDEX idx_verification_status ON verification_sessions(status);

ALTER TABLE photos
  ADD CONSTRAINT fk_photos_verification_session
  FOREIGN KEY (verification_session_id) REFERENCES verification_sessions(id);
```

---

## Matching Tables

### matchmaking_jobs

Idempotent scheduler job ledger for daily and anchor offer generation.

```sql
CREATE TABLE matchmaking_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  batch_date DATE NOT NULL,
  timezone TEXT NOT NULL,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  job_type TEXT NOT NULL DEFAULT 'daily_offers'
    CHECK (job_type IN ('daily_offers', 'weekly_anchor')),
  status TEXT NOT NULL DEFAULT 'running'
    CHECK (status IN ('running', 'completed', 'failed')),
  offers JSONB,
  attempt_count INTEGER NOT NULL DEFAULT 1 CHECK (attempt_count >= 1),
  idempotency_key TEXT NOT NULL,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  error_summary TEXT,

  UNIQUE(batch_date, timezone, user_id, job_type),
  UNIQUE(idempotency_key)
);

CREATE INDEX idx_matchmaking_jobs_user_date ON matchmaking_jobs(user_id, batch_date DESC);
CREATE INDEX idx_matchmaking_jobs_status ON matchmaking_jobs(status, started_at DESC);
```

### match_offers

Daily curated match offers.

```sql
CREATE TABLE match_offers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  offered_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  batch_date DATE NOT NULL,
  batch_generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  compatibility_score INTEGER NOT NULL CHECK (compatibility_score BETWEEN 0 AND 100),
  physical_preference_score INTEGER CHECK (physical_preference_score BETWEEN 0 AND 100),
  compatibility_themes TEXT[],
  status TEXT NOT NULL DEFAULT 'offered' CHECK (status IN ('offered', 'accepted', 'passed', 'not_now', 'expired', 'matched')),
  offered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT NOW() + INTERVAL '6 days',
  cooldown_until TIMESTAMPTZ,
  action_at TIMESTAMPTZ,
  action_type TEXT CHECK (action_type IN ('accept', 'pass', 'not_now')),

  UNIQUE(user_id, offered_user_id, batch_date)
);

CREATE INDEX idx_offers_user ON match_offers(user_id);
CREATE INDEX idx_offers_offered_user ON match_offers(offered_user_id);
CREATE INDEX idx_offers_batch ON match_offers(batch_date);
CREATE INDEX idx_offers_status ON match_offers(status);
```

### matches

Mutual matches between users.

```sql
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id_1 UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_id_2 UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'closed')),
  closed_reason TEXT CHECK (closed_reason IN ('unmatched', 'blocked', 'deleted', 'expired')),
  closed_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  closed_at TIMESTAMPTZ,
  last_message_at TIMESTAMPTZ,

  CONSTRAINT unique_match_pair UNIQUE(user_id_1, user_id_2),
  CONSTRAINT ordered_users CHECK (user_id_1 < user_id_2)
);

CREATE INDEX idx_matches_user1 ON matches(user_id_1);
CREATE INDEX idx_matches_user2 ON matches(user_id_2);
CREATE INDEX idx_matches_status ON matches(status);
```

### match_offer_audits

Audit trail for match offer actions.

```sql
CREATE TABLE match_offer_audits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  offer_id UUID NOT NULL REFERENCES match_offers(id),
  user_id UUID NOT NULL,
  action TEXT NOT NULL CHECK (action IN ('accept', 'pass', 'not_now')),
  previous_status TEXT NOT NULL,
  new_status TEXT NOT NULL,
  idempotency_key TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_offer_audits_offer ON match_offer_audits(offer_id);
CREATE INDEX idx_offer_audits_idempotency ON match_offer_audits(idempotency_key);
```

---

## Chat Tables

### messages

Chat messages between matched users.

```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id),
  content TEXT NOT NULL CHECK (char_length(content) <= 2000),
  client_message_id TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'sent' CHECK (status IN ('sent', 'delivered', 'read', 'failed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  read_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,

  UNIQUE(match_id, client_message_id)
);

CREATE INDEX idx_messages_match ON messages(match_id, created_at DESC);
CREATE INDEX idx_messages_sender ON messages(sender_id);
```

### typing_indicators

Ephemeral typing state.

```sql
CREATE TABLE typing_indicators (
  match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  is_typing BOOLEAN NOT NULL DEFAULT true,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  PRIMARY KEY (match_id, user_id)
);
```

---

## Safety Tables

### reports

User-submitted reports.

```sql
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES users(id),
  reported_user_id UUID REFERENCES users(id),
  reported_message_id UUID REFERENCES messages(id),
  reported_match_id UUID REFERENCES matches(id),
  type TEXT NOT NULL CHECK (type IN ('user', 'message', 'match')),
  category TEXT NOT NULL CHECK (category IN ('harassment', 'inappropriate_content', 'scam', 'violence', 'self_harm', 'child_safety', 'other')),
  severity TEXT NOT NULL DEFAULT 'standard' CHECK (severity IN ('critical', 'high', 'standard')),
  description TEXT CHECK (char_length(description) <= 2000),
  evidence_ids UUID[],
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_review', 'resolved', 'dismissed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  resolved_at TIMESTAMPTZ,
  resolution TEXT,
  action_taken TEXT CHECK (action_taken IN ('warning', 'content_removed', 'suspended', 'banned', 'dismissed'))
);

CREATE INDEX idx_reports_reporter ON reports(reporter_id);
CREATE INDEX idx_reports_reported_user ON reports(reported_user_id);
CREATE INDEX idx_reports_status ON reports(status, severity);
CREATE INDEX idx_reports_created ON reports(created_at DESC);
```

### blocks

User blocks.

```sql
CREATE TABLE blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reason TEXT CHECK (reason IN ('inappropriate', 'harassment', 'no_reason')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(blocker_id, blocked_id)
);

CREATE INDEX idx_blocks_blocker ON blocks(blocker_id);
CREATE INDEX idx_blocks_blocked ON blocks(blocked_id);
```

### moderation_queue

Moderator work queue.

```sql
CREATE TABLE moderation_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id UUID REFERENCES reports(id),
  severity TEXT NOT NULL CHECK (severity IN ('critical', 'high', 'standard')),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_review', 'resolved')),
  assigned_to UUID,
  sla_deadline TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  in_review_at TIMESTAMPTZ,
  resolved_at TIMESTAMPTZ,
  resolution_notes TEXT,
  
  CONSTRAINT valid_sla CHECK (sla_deadline > created_at)
);

CREATE INDEX idx_mod_queue_status ON moderation_queue(status, severity);
CREATE INDEX idx_mod_queue_assigned ON moderation_queue(assigned_to);
CREATE INDEX idx_mod_queue_deadline ON moderation_queue(sla_deadline);
```

### enforcement_actions

Record of enforcement actions taken.

```sql
CREATE TABLE enforcement_actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  action_type TEXT NOT NULL CHECK (action_type IN ('warning', 'content_removed', 'temporary_suspension', 'permanent_ban', 'device_ban')),
  duration_days INTEGER,
  reason TEXT NOT NULL,
  report_id UUID REFERENCES reports(id),
  enacted_by UUID NOT NULL,
  enacted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  is_active BOOLEAN NOT NULL DEFAULT true
);

CREATE INDEX idx_enforcement_user ON enforcement_actions(user_id);
CREATE INDEX idx_enforcement_active ON enforcement_actions(user_id) WHERE is_active;
```

---

## System Tables

### system_config

Runtime configuration values.

```sql
CREATE TABLE system_config (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  value_type TEXT NOT NULL DEFAULT 'string' CHECK (value_type IN ('string', 'integer', 'float', 'boolean', 'json')),
  description TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_by TEXT NOT NULL
);

CREATE INDEX idx_config_key ON system_config(key);
```

### feature_flags

Feature toggle flags.

```sql
CREATE TABLE feature_flags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key TEXT NOT NULL UNIQUE,
  description TEXT,
  enabled BOOLEAN NOT NULL DEFAULT false,
  rollout_percentage INTEGER DEFAULT 0 CHECK (rollout_percentage BETWEEN 0 AND 100),
  target_user_ids UUID[],
  target_segments TEXT[],
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_feature_flags_key ON feature_flags(key);
```

### user_segments

User groupings for admin management and targeted configuration.

```sql
CREATE TABLE user_segments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  type TEXT NOT NULL CHECK (type IN ('manual', 'auto_country', 'auto_age', 'auto_activity', 'custom')),
  criteria JSONB,
  is_system BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO user_segments (key, name, type, is_system) VALUES
  ('all_users', 'All Users', 'manual', true),
  ('country_us', 'United States', 'auto_country', true),
  ('country_gb', 'United Kingdom', 'auto_country', true),
  ('country_ca', 'Canada', 'auto_country', true),
  ('country_au', 'Australia', 'auto_country', true),
  ('beta_testers', 'Beta Testers', 'manual', false);
```

### user_segment_members

User membership in segments.

```sql
CREATE TABLE user_segment_members (
  segment_id UUID NOT NULL REFERENCES user_segments(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  added_by UUID,
  
  PRIMARY KEY (segment_id, user_id)
);

CREATE INDEX idx_segment_members_user ON user_segment_members(user_id);
CREATE INDEX idx_segment_members_segment ON user_segment_members(segment_id);
```

### segment_config_overrides

Configuration overrides applied to specific segments.

```sql
CREATE TABLE segment_config_overrides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  segment_id UUID NOT NULL REFERENCES user_segments(id) ON DELETE CASCADE,
  config_key TEXT NOT NULL REFERENCES system_config(key),
  override_value TEXT NOT NULL,
  override_type TEXT NOT NULL DEFAULT 'string' CHECK (override_type IN ('string', 'integer', 'float', 'boolean', 'json')),
  priority INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_by TEXT NOT NULL,
  
  UNIQUE(segment_id, config_key)
);

CREATE INDEX idx_segment_config_segment ON segment_config_overrides(segment_id);
CREATE INDEX idx_segment_config_key ON segment_config_overrides(config_key);
```

### admin_users

Admin users (MVP: single role).

```sql
CREATE TABLE admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_admin_users_user ON admin_users(user_id);
```

### admin_audit_log

Audit trail for admin actions.

```sql
CREATE TABLE admin_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_user_id UUID NOT NULL REFERENCES admin_users(id),
  action TEXT NOT NULL,
  target_type TEXT CHECK (target_type IN ('user', 'segment', 'config', 'report', 'enforcement')),
  target_id UUID,
  old_value JSONB,
  new_value JSONB,
  reason TEXT,
  ip_address INET,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_admin_audit_admin ON admin_audit_log(admin_user_id);
CREATE INDEX idx_admin_audit_target ON admin_audit_log(target_type, target_id);
CREATE INDEX idx_admin_audit_created ON admin_audit_log(created_at DESC);
```

### admin_user_views

Privacy-preserving admin views of user data. Logs every access.

```sql
CREATE TABLE admin_user_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_user_id UUID NOT NULL REFERENCES admin_users(id),
  viewed_user_id UUID NOT NULL REFERENCES users(id),
  view_type TEXT NOT NULL CHECK (view_type IN ('profile', 'messages', 'reports', 'activity')),
  reason TEXT NOT NULL,
  ip_address INET,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_admin_views_admin ON admin_user_views(admin_user_id);
CREATE INDEX idx_admin_views_user ON admin_user_views(viewed_user_id);
CREATE INDEX idx_admin_views_created ON admin_user_views(created_at DESC);
```

### data_export_requests

User data export requests (GDPR compliance).

```sql
CREATE TABLE data_export_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'expired')),
  request_type TEXT NOT NULL CHECK (request_type IN ('full_export', 'partial_export')),
  requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  download_url TEXT,
  expires_at TIMESTAMPTZ,
  ip_address INET
);

CREATE INDEX idx_export_requests_user ON data_export_requests(user_id);
CREATE INDEX idx_export_requests_status ON data_export_requests(status);
```

### data_deletion_requests

User deletion requests (GDPR/CCPA compliance).

```sql
CREATE TABLE data_deletion_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_grace_period', 'processing', 'completed', 'cancelled')),
  request_type TEXT NOT NULL CHECK (request_type IN ('full_deletion', 'account_only')),
  requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  grace_period_ends_at TIMESTAMPTZ NOT NULL DEFAULT NOW() + INTERVAL '30 days',
  processing_started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  cancellation_reason TEXT,
  legal_hold BOOLEAN NOT NULL DEFAULT false
);

CREATE INDEX idx_deletion_requests_user ON data_deletion_requests(user_id);
CREATE INDEX idx_deletion_requests_status ON data_deletion_requests(status);
```

### analytics_events

Raw analytics events.

```sql
CREATE TABLE analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  event_type TEXT NOT NULL,
  event_properties JSONB,
  user_properties JSONB,
  device_id TEXT,
  platform TEXT,
  app_version TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY RANGE (created_at);

CREATE INDEX idx_events_user ON analytics_events(user_id);
CREATE INDEX idx_events_type ON analytics_events(event_type, created_at DESC);
```

### analytics_event_schemas

Registry of allowed analytics event types and required property keys for ingestion validation.

```sql
CREATE TABLE analytics_event_schemas (
  event_type TEXT PRIMARY KEY,
  required_properties TEXT[] NOT NULL DEFAULT '{}',
  optional_properties TEXT[] NOT NULL DEFAULT '{}',
  enum_constraints JSONB,
  is_active BOOLEAN NOT NULL DEFAULT true,
  version TEXT NOT NULL DEFAULT 'v1',
  updated_by TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_aes_active ON analytics_event_schemas(is_active);
```

### matching_metric_runs

Aggregation job run records for matching/cohort metrics.

```sql
CREATE TABLE matching_metric_runs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_type TEXT NOT NULL CHECK (job_type IN ('hourly_incremental', 'daily_finalize', 'weekly_rollup', 'backfill')),
  status TEXT NOT NULL CHECK (status IN ('running', 'succeeded', 'failed', 'partial')),
  metric_version TEXT NOT NULL,
  window_start TIMESTAMPTZ NOT NULL,
  window_end TIMESTAMPTZ NOT NULL,
  row_count BIGINT NOT NULL DEFAULT 0,
  error_summary TEXT,
  triggered_by TEXT NOT NULL DEFAULT 'scheduler',
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX idx_mmr_job_window ON matching_metric_runs(job_type, window_start DESC);
CREATE INDEX idx_mmr_status ON matching_metric_runs(status, started_at DESC);
```

### cohort_metric_daily

Daily cohort-level derived matching and safety metrics.

```sql
CREATE TABLE cohort_metric_daily (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  metric_key TEXT NOT NULL CHECK (
    metric_key IN (
      'too_few_messages_rate',
      'too_many_messages_rate',
      'unwanted_content_report_rate_per_1k',
      'mutual_match_rate',
      'reply_within_24h_rate',
      'unmatch_7d_rate',
      'decision_fatigue_rate',
      'exposure_acceptance_parity_delta'
    )
  ),
  metric_version TEXT NOT NULL,
  cohort_dimension TEXT NOT NULL CHECK (cohort_dimension IN ('gender_identity', 'policy_segment', 'region', 'all')),
  cohort_value TEXT NOT NULL,
  policy_segment TEXT NOT NULL DEFAULT 'all'
    CHECK (policy_segment IN ('all', 'high_inbound_pressure', 'low_inbound_low_response', 'balanced')),
  region TEXT NOT NULL DEFAULT 'all',
  metric_date DATE NOT NULL,
  numerator DECIMAL(20, 6),
  denominator DECIMAL(20, 6),
  metric_value DECIMAL(12, 6),
  sample_size INTEGER NOT NULL DEFAULT 0,
  is_insufficient_data BOOLEAN NOT NULL DEFAULT false,
  freshness_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  run_id UUID REFERENCES matching_metric_runs(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(metric_key, metric_version, cohort_dimension, cohort_value, policy_segment, region, metric_date)
);

CREATE INDEX idx_cmd_metric_date ON cohort_metric_daily(metric_key, metric_date DESC);
CREATE INDEX idx_cmd_cohort ON cohort_metric_daily(cohort_dimension, cohort_value, metric_date DESC);
CREATE INDEX idx_cmd_segment ON cohort_metric_daily(policy_segment, metric_date DESC);
```

### cohort_metric_weekly

Weekly rollups for cohort-level derived metrics.

```sql
CREATE TABLE cohort_metric_weekly (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  metric_key TEXT NOT NULL,
  metric_version TEXT NOT NULL,
  cohort_dimension TEXT NOT NULL CHECK (cohort_dimension IN ('gender_identity', 'policy_segment', 'region', 'all')),
  cohort_value TEXT NOT NULL,
  policy_segment TEXT NOT NULL DEFAULT 'all'
    CHECK (policy_segment IN ('all', 'high_inbound_pressure', 'low_inbound_low_response', 'balanced')),
  region TEXT NOT NULL DEFAULT 'all',
  week_start_date DATE NOT NULL,
  numerator DECIMAL(20, 6),
  denominator DECIMAL(20, 6),
  metric_value DECIMAL(12, 6),
  sample_size INTEGER NOT NULL DEFAULT 0,
  is_insufficient_data BOOLEAN NOT NULL DEFAULT false,
  freshness_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  run_id UUID REFERENCES matching_metric_runs(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(metric_key, metric_version, cohort_dimension, cohort_value, policy_segment, region, week_start_date)
);

CREATE INDEX idx_cmw_metric_week ON cohort_metric_weekly(metric_key, week_start_date DESC);
CREATE INDEX idx_cmw_cohort ON cohort_metric_weekly(cohort_dimension, cohort_value, week_start_date DESC);
```

### cohort_metric_alerts

Monitoring alerts generated from cohort metric thresholds and drift checks.

```sql
CREATE TABLE cohort_metric_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  metric_key TEXT NOT NULL,
  severity TEXT NOT NULL CHECK (severity IN ('critical', 'high', 'medium')),
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'acknowledged', 'resolved', 'muted')),
  cohort_dimension TEXT NOT NULL CHECK (cohort_dimension IN ('gender_identity', 'policy_segment', 'region')),
  cohort_value TEXT NOT NULL,
  policy_segment TEXT NOT NULL DEFAULT 'all'
    CHECK (policy_segment IN ('all', 'high_inbound_pressure', 'low_inbound_low_response', 'balanced')),
  region TEXT NOT NULL DEFAULT 'all',
  observed_value DECIMAL(12, 6) NOT NULL,
  baseline_value DECIMAL(12, 6),
  threshold_value DECIMAL(12, 6) NOT NULL,
  delta_ratio DECIMAL(12, 6),
  run_id UUID REFERENCES matching_metric_runs(id),
  details JSONB,
  detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  acknowledged_at TIMESTAMPTZ,
  resolved_at TIMESTAMPTZ
);

CREATE INDEX idx_cma_status_detected ON cohort_metric_alerts(status, detected_at DESC);
CREATE INDEX idx_cma_severity_detected ON cohort_metric_alerts(severity, detected_at DESC);
CREATE INDEX idx_cma_metric ON cohort_metric_alerts(metric_key, detected_at DESC);
```

---

## Missing Tables (P1 - Before Notifications/Settings Features)

These tables are required for features not yet implemented. Documented here for planning.

### appeals

Appeals for suspended accounts or enforcement actions.

```sql
CREATE TABLE appeals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  enforcement_action_id UUID REFERENCES enforcement_actions(id),
  action_type TEXT NOT NULL CHECK (action_type IN ('suspension', 'warning', 'content_removal')),
  reason TEXT NOT NULL CHECK (char_length(reason) <= 2000),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'approved', 'rejected')),
  reviewed_by UUID REFERENCES admin_users(id),
  reviewed_at TIMESTAMPTZ,
  resolution_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_appeals_user ON appeals(user_id);
CREATE INDEX idx_appeals_status ON appeals(status);
CREATE INDEX idx_appeals_created ON appeals(created_at DESC);
```

### user_preferences

User settings and preferences.

```sql
CREATE TABLE user_preferences (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  notification_push_enabled BOOLEAN NOT NULL DEFAULT true,
  notification_match_enabled BOOLEAN NOT NULL DEFAULT true,
  notification_message_enabled BOOLEAN NOT NULL DEFAULT true,
  notification_marketing_enabled BOOLEAN NOT NULL DEFAULT false,
  privacy_show_online_status BOOLEAN NOT NULL DEFAULT true,
  privacy_show_last_active BOOLEAN NOT NULL DEFAULT true,
  privacy_show_distance BOOLEAN NOT NULL DEFAULT true,
  theme TEXT CHECK (theme IN ('system', 'light', 'dark')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### push_tokens

Device push notification tokens.

```sql
CREATE TABLE push_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id TEXT NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
  token TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  UNIQUE(user_id, device_id)
);

CREATE INDEX idx_push_tokens_user ON push_tokens(user_id);
CREATE INDEX idx_push_tokens_active ON push_tokens(user_id, is_active);
```

### notifications

In-app notification center.

```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('new_match', 'new_message', 'verification_reminder', 'profile_incomplete', 'safety_alert', 'marketing')),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB,
  action_url TEXT,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_unread ON notifications(user_id) WHERE read_at IS NULL;
```

---

## Row Level Security Policies

### Users

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY users_select_own ON users
  FOR SELECT USING (id = auth.uid());

CREATE POLICY users_update_own ON users
  FOR UPDATE USING (id = auth.uid());
```

### Messages

```sql
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY messages_select_participant ON messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM matches 
      WHERE id = match_id 
      AND (user_id_1 = auth.uid() OR user_id_2 = auth.uid())
    )
  );

CREATE POLICY messages_insert_participant ON messages
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM matches 
      WHERE id = match_id 
      AND (user_id_1 = auth.uid() OR user_id_2 = auth.uid())
      AND status = 'active'
    )
  );
```

### Match Offers

```sql
ALTER TABLE match_offers ENABLE ROW LEVEL SECURITY;

CREATE POLICY offers_select_own ON match_offers
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY offers_update_own ON match_offers
  FOR UPDATE USING (user_id = auth.uid());
```

---

## Migrations

Migrations are managed via Supabase CLI.

```bash
# Create new migration
npx supabase migration new add_user_preferences

# Apply migrations locally
npx supabase db reset

# Generate types
npx supabase gen types typescript --local > packages/shared/src/types/database.ts
```

---

## Index Strategy

| Table | Index Type | Purpose |
|-------|------------|---------|
| users | B-tree, GIST | Phone lookup, geo queries |
| messages | B-tree | Match/conversation retrieval |
| match_offers | B-tree | User lookup, batch queries |
| reports | B-tree | Status/severity queues |

---

## Related Documents

- `docs/technical/contracts/openapi.yaml` - API schemas map to DB tables
- `docs/ops/configuration.md` - Configurable parameters
- `docs/specs/*.md` - Feature specifications
