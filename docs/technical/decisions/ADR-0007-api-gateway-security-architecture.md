# ADR-0007: API Gateway Security Architecture

Date: 2026-02-20
Status: Accepted
Owner: Engineering
Last Updated: 2026-02-20
Depends On: `docs/technical/decisions/ADR-0001-supabase-over-convex.md`, `docs/technical/decisions/ADR-0002-realtime-ownership.md`

## Context

With Supabase as our backend platform, we have two architectural options for client data access:

1. **Direct access**: Client → Supabase (security via Row Level Security)
2. **API gateway**: Client → Our API → Supabase (security via application code)

We need to balance security, development velocity, and real-time capabilities.

## Decision

Use a **hybrid architecture** with API gateway as the primary path and controlled direct access for specific use cases.

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    React Native App                         │
└─────────────────────────────────────────────────────────────┘
                    │                       │
        ┌───────────┘                       └──────────┐
        ▼                                              ▼
┌───────────────────┐                      ┌──────────────────┐
│   Your API Server │                      │  Supabase Direct │
│   (primary path)  │                      │  (limited scope) │
│                   │                      │                  │
│  - All writes     │                      │  - Real-time sub │
│  - Sensitive ops  │                      │  - File uploads  │
│  - Business logic │                      │  - Signed URLs   │
└───────────────────┘                      └──────────────────┘
        │                                              │
        │ service role key (secret)                    │ anon key + JWT
        ▼                                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Supabase                               │
│  - Auth, Database, Storage                                  │
│  - RLS policies (defense-in-depth)                          │
└─────────────────────────────────────────────────────────────┘
```

## Rationale

### Why API Gateway as Primary Path

1. **Security Control**
   - All writes go through our code
   - Input validation before data hits database
   - Content moderation integration
   - Rate limiting and abuse prevention

2. **Business Logic**
   - Matching algorithm execution
   - Scoring calculations
   - Complex authorization rules
   - Audit logging

3. **API Contract**
   - Explicit OpenAPI contract
   - Version control over API surface
   - Easier to evolve independently of schema

4. **Observability**
   - Centralized logging
   - Request tracing
   - Error monitoring

### Why Limited Direct Access

1. **File Uploads**
   - Large files shouldn't route through API
   - Signed URLs for secure direct uploads
   - Storage bucket policies for access control

2. **Non-Critical Real-time (Future)**
   - Supabase Realtime for non-chat subscriptions (settings changes, profile updates)
   - Chat messages use Custom WebSocket Gateway per ADR-0002

## Access Patterns

### Must Go Through API (Secure)

| Operation | Reason |
|-----------|--------|
| Profile updates | Validation, content moderation |
| Match actions (accept/pass) | Business logic, state management |
| Sending messages | Content moderation, rate limiting |
| Reports/blocks | Safety logic, evidence capture |
| Onboarding questionnaire | Validation, scoring |
| Settings changes | Validation, audit |

### Can Access Directly (With RLS)

| Operation | Security |
|-----------|----------|
| Reading own messages | RLS: `sender_id = auth.uid() OR receiver_id = auth.uid()` |
| Loading match offers | RLS: `user_id = auth.uid()` |
| Profile photo upload | Signed URLs + storage policies |

### Real-time Architecture (Per ADR-0002)

| Real-time Feature | Technology | Rationale |
|-------------------|------------|-----------|
| Chat messages | Custom WebSocket Gateway | Control, scalability, delivery guarantees |
| Typing indicators | Custom WebSocket Gateway | Low latency, high frequency |
| Presence | Custom WebSocket Gateway | Connection state management |
| Match status updates | Custom WebSocket Gateway | Business logic integration |
| DB change notifications | Supabase Realtime (future) | Non-critical UI updates only |

**Important:** Per ADR-0002, all chat-related real-time goes through the Custom WebSocket Gateway, not Supabase Realtime.

## Security Model

### API Server

```typescript
// Server-side: Uses service role key (NEVER exposed to client)
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY  // Secret, server-only
);

// API endpoint with validation
app.post('/api/messages', authenticate, async (req, res) => {
  // 1. Validate user is part of match
  const match = await validateMatchAccess(req.user.id, req.body.matchId);
  if (!match) return res.status(403).json({ error: 'Forbidden' });

  // 2. Content moderation
  const moderation = await moderateContent(req.body.content);
  if (!moderation.safe) return res.status(400).json({ error: 'Content flagged' });

  // 3. Store message (service role bypasses RLS for writes)
  const { data, error } = await supabase
    .from('messages')
    .insert({
      match_id: req.body.matchId,
      sender_id: req.user.id,
      content: req.body.content,
      client_message_id: req.body.clientMessageId
    });

  // 4. Return result
  res.json({ data, error });
});
```

### Direct Client Access (with RLS)

```typescript
// Client-side: Uses anon key (public) + JWT
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  SUPABASE_URL,
  SUPABASE_ANON_KEY  // Public, protected by RLS
);

// Real-time subscription for chat (RLS enforced)
supabase
  .channel('messages')
  .on('postgres_changes', 
    { event: 'INSERT', schema: 'public', table: 'messages', filter: `match_id=eq.${matchId}` },
    (payload) => handleNewMessage(payload.new)
  )
  .subscribe();
```

### RLS Policy Examples

```sql
-- Messages: Users can only see messages in their matches
CREATE POLICY "Users read own messages" ON messages
  FOR SELECT USING (
    match_id IN (
      SELECT id FROM matches 
      WHERE user_a = auth.uid() OR user_b = auth.uid()
    )
  );

-- Match offers: Users can only see their own offers
CREATE POLICY "Users read own offers" ON match_offers
  FOR SELECT USING (user_id = auth.uid());

-- Profiles: Users can read all profiles, update own only
CREATE POLICY "Profiles are public" ON profiles
  FOR SELECT USING (true);

CREATE POLICY "Users update own profile" ON profiles
  FOR UPDATE USING (user_id = auth.uid());

-- Storage: Profile photos
CREATE POLICY "Profile photos are public" ON storage.objects
  FOR SELECT USING (bucket_id = 'profile-photos');

CREATE POLICY "Users upload own photos" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'profile-photos' 
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
```

## Key Management

| Key | Location | Purpose |
|-----|----------|---------|
| `SUPABASE_URL` | Client + Server | Public, identifies project |
| `SUPABASE_ANON_KEY` | Client + Server | Public, RLS-protected access |
| `SUPABASE_SERVICE_ROLE_KEY` | Server ONLY | Bypasses RLS, full access |

**Critical:** `SERVICE_ROLE_KEY` must NEVER be in client code, environment variables exposed to client, or committed to repository.

## Consequences

### Positive

- Security logic in TypeScript (easier to reason about)
- Explicit API contract (OpenAPI)
- Centralized logging and monitoring
- Rate limiting and abuse prevention
- Can still use Supabase real-time capabilities

### Tradeoffs

- Additional latency hop for API-routed operations
- More code to maintain than direct-only approach
- Need to keep RLS policies in sync with API logic (defense-in-depth)

### Risks

| Risk | Mitigation |
|------|------------|
| Service role key leaked | Environment variables only, rotate if compromised |
| RLS policy misconfiguration | Test coverage, security review |
| Direct access bypasses API validation | Limit direct access scope, validate in RLS |

## Validation

Success metrics:
- All writes go through API (enforced by architecture)
- Direct reads only for documented use cases
- RLS policies tested in CI
- No service role key exposure in client bundles

## Related Documents

- `docs/technical/decisions/ADR-0001-supabase-over-convex.md`
- `docs/technical/decisions/ADR-0002-realtime-ownership.md`
- `docs/technical/contracts/auth-session-contract.md`
- `docs/ops/privacy-security.md`
