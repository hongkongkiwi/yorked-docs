# Database Schema Documentation

Owner: Engineering  
Status: Active  
Last Updated: 2026-02-21
Depends On: `docs/technical/contracts/openapi.yaml`, `docs/specs/`

## Documents

| File | Description |
|------|-------------|
| [database.md](database.md) | Complete PostgreSQL schema with all tables, indexes, and RLS policies |

## Table Summary

| Category | Tables | Status |
|----------|--------|--------|
| Core | `users`, `profiles`, `photos` | ✅ MVP |
| Auth | `social_identities`, `auth_sessions`, `account_recovery_requests` | ✅ MVP |
| Questionnaire | `questionnaire_versions`, `questions`, `compatibility_responses` | ✅ MVP |
| Visual Preference | `visual_reference_images`, `visual_preference_sessions`, `visual_preference_pairs`, `visual_preference_choice_events`, `visual_preference_profiles`, `visual_preference_profile_snapshots`, `photo_recommendation_runs`, `photo_recommendations` | ✅ MVP |
| Verification | `verification_sessions` | ✅ MVP |
| Matching | `matchmaking_jobs`, `match_offers`, `matches`, `match_offer_audits` | ✅ MVP |
| Chat | `messages`, `typing_indicators` | ✅ MVP |
| Safety | `reports`, `blocks`, `moderation_queue`, `enforcement_actions` | ✅ MVP |
| Admin & Config | `system_config`, `feature_flags`, `user_segments`, `user_segment_members`, `segment_config_overrides`, `admin_users`, `admin_audit_log`, `admin_user_views` | ✅ MVP |
| Compliance | `data_export_requests`, `data_deletion_requests` | ✅ MVP |
| Analytics | `analytics_events`, `analytics_event_schemas`, `matching_metric_runs`, `cohort_metric_daily`, `cohort_metric_weekly`, `cohort_metric_alerts` | ✅ MVP |
| **Notifications** | `push_tokens`, `notifications` | 📋 P1 |
| **Settings** | `user_preferences` | 📋 P1 |
| **Appeals** | `appeals` | 📋 P1 |

**Total: 48 tables (45 MVP + 3 P1)**

## Migrations

```bash
# Create migration
npx supabase migration new <name>

# Apply locally
npx supabase db reset

# Generate types
npx supabase gen types typescript --local > packages/shared/src/types/database.ts
```

## Related

- `docs/technical/contracts/openapi.yaml` - API schemas
- `docs/ops/configuration.md` - Configurable parameters
