# Admin Operations (MVP)

Owner: Engineering + Trust & Safety  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/technical/schema/database.md`, `docs/ops/configuration.md`, `docs/ops/matching-cohort-metrics.md`, `docs/technical/contracts/openapi.yaml`

## Overview

MVP admin panel with minimal but essential capabilities. Privacy-first: only what's needed to operate safely.

## MVP Admin Features

| Feature | Purpose | Priority |
|---------|---------|:--------:|
| User lookup | Find users by ID, view status | P0 |
| User status management | Suspend/activate accounts | P0 |
| Segment management | Group users, apply config | P0 |
| Configuration editor | View/edit global config | P0 |
| Report queue | Safety moderation | P0 |
| Basic audit log | Who did what | P1 |

**Out of MVP scope:**
- Detailed analytics dashboards
- Complex role hierarchies (single admin role)
- Data export/deletion UI (handled via support)
- Message viewing (except for reports)
- Advanced user search

## Post-MVP Extension: Cohort Metrics Console

After MVP, admin operations include a read-only cohort metrics console for governance of gender-responsive matching policy.

Scope:
- trend views for cohort and behavioral-segment metrics
- parity/safety alert feed with acknowledgment workflow
- metric freshness and formula-version metadata

APIs:
- `GET /admin/metrics/cohorts`
- `GET /admin/metrics/cohorts/summary`
- `GET /admin/metrics/alerts`

Constraints:
- no user-level raw analytics access in this console
- admin-only access with full audit logging

---

## Admin Roles (MVP)

Single admin role for MVP. Role-based permissions post-launch.

| Action | Admin |
|--------|:-----:|
| View user profile | ✓ |
| Change user status | ✓ |
| Manage segments | ✓ |
| Edit configuration | ✓ |
| View/handle reports | ✓ |
| View audit log | ✓ |

---

## User Management (MVP)

### User Lookup

Find users by:
- User ID (last 4+ characters)
- No search by name/phone for privacy

### User Status

| Status | Effect |
|--------|--------|
| `active` | Normal access |
| `suspended` | Cannot login |
| `deleted` | Soft delete |

### Admin Actions

```sql
-- Suspend user
UPDATE users SET status = 'suspended' WHERE id = 'user-uuid';

-- Log action
INSERT INTO admin_audit_log (admin_user_id, action, target_type, target_id, reason)
VALUES ('admin-uuid', 'suspend_user', 'user', 'user-uuid', 'Reason here');
```

---

## Segment Management (MVP)

### Built-in Segments

- `all_users` - Everyone
- `country_*` - Auto-assigned by location

### Custom Segments

Create arbitrary groups:

```sql
-- Create segment
INSERT INTO user_segments (key, name, type)
VALUES ('beta_testers', 'Beta Testers', 'manual');

-- Add users
INSERT INTO user_segment_members (segment_id, user_id)
VALUES ('segment-uuid', 'user-uuid');
```

### Apply Config to Segment

```sql
-- Override config for segment
INSERT INTO segment_config_overrides (segment_id, config_key, override_value, updated_by)
VALUES ('segment-uuid', 'MATCHES_PER_DAY_DEFAULT', '10', 'admin@yoked.app');

-- Reset to default
DELETE FROM segment_config_overrides 
WHERE segment_id = 'segment-uuid' AND config_key = 'MATCHES_PER_DAY_DEFAULT';
```

---

## Configuration (MVP)

View and edit config values in `system_config` table. Changes take effect within 60 seconds.

```sql
-- Update config
UPDATE system_config 
SET value = '5', updated_by = 'admin@yoked.app'
WHERE key = 'MATCHES_PER_DAY_DEFAULT';
```

---

## Safety Reports (MVP)

Basic report queue from `reports` table. View report details, take action (warn/suspend/dismiss).

See `docs/specs/safety.md` for full moderation workflow.

---

## Audit Log (MVP)

Simple log of admin actions:

```sql
SELECT * FROM admin_audit_log ORDER BY created_at DESC LIMIT 100;
```

---

## Database Tables (MVP)

```sql
-- Admin users (simplified)
CREATE TABLE admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Audit log
CREATE TABLE admin_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_user_id UUID NOT NULL REFERENCES admin_users(id),
  action TEXT NOT NULL,
  target_type TEXT,
  target_id UUID,
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Segments
CREATE TABLE user_segments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'manual',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_segment_members (
  segment_id UUID REFERENCES user_segments(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (segment_id, user_id)
);

CREATE TABLE segment_config_overrides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  segment_id UUID NOT NULL REFERENCES user_segments(id) ON DELETE CASCADE,
  config_key TEXT NOT NULL,
  override_value TEXT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(segment_id, config_key)
);
```

---

## Related Documents

- `docs/ops/configuration.md` - All config parameters
- `docs/specs/safety.md` - Moderation workflow
- `docs/technical/schema/database.md` - Full schema
