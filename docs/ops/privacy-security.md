# Privacy & Data Protection

Owner: Engineering + Security  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/technical/schema/database.md`, `docs/ops/admin-operations.md`

## Overview

Privacy-by-design approach for Yoked MVP. User data is protected through encryption, pseudonymization, and access controls that prevent direct identification.

## Privacy Principles

1. **Data Minimization** - Collect only what's needed
2. **Pseudonymization** - Replace identifiers with tokens where possible
3. **Encryption at Rest** - All sensitive data encrypted in database
4. **Encryption in Transit** - TLS 1.3 everywhere
5. **Access Control** - RLS policies limit data exposure
6. **Separation** - Identity data separated from behavioral data

---

## Data Classification

| Data Type | Classification | Storage | Encryption |
|-----------|---------------|---------|------------|
| Phone number | PII - High | Hashed only | Argon2id |
| Display name | PII - Low | Plaintext | N/A |
| Bio | PII - Low | Plaintext | N/A |
| Date of birth | PII - Medium | Encrypted | AES-256-GCM |
| Location (coords) | PII - High | Encrypted | AES-256-GCM |
| Messages | Private | Encrypted | AES-256-GCM |
| Match preferences | Behavioral | Plaintext | N/A |
| Compatibility answers | Behavioral | Plaintext | N/A |
| Face vectors | Biometric | Encrypted + separate | AES-256-GCM |

---

## Identity Protection

### Phone Numbers

Phone numbers are **never stored in plaintext**. Only a cryptographic hash is stored.

```sql
-- users table
phone_hash TEXT NOT NULL UNIQUE,  -- Argon2id hash
phone_last_four TEXT NOT NULL,     -- Last 4 digits for display
```

**Hashing approach:**
```typescript
import { hash, verify } from 'argon2';

// Hash phone number (one-way)
const phoneHash = await hash(phoneNumber, {
  type: argon2id,
  memoryCost: 65536,    // 64 MB
  timeCost: 3,
  parallelism: 4,
  salt: Buffer.from(SUPABASE_PROJECT_ID),  // Deterministic salt for uniqueness
});

// Verify (login)
const isValid = await verify(storedHash, inputPhone);
```

**Why Argon2id:**
- Resistant to GPU/ASIC attacks
- Memory-hard (slows brute force)
- Industry standard for password/credential hashing

### User IDs

User IDs are UUIDs that are **cryptographically random** - not derived from any user data.

```typescript
// Generate user ID (server-side only)
import { randomUUID } from 'crypto';
const userId = randomUUID(); // e.g., "550e8400-e29b-41d4-a716-446655440000"
```

User IDs are:
- Not sequential (can't enumerate users)
- Not derived from phone/email
- Not predictable

---

## Sensitive Data Encryption

### Encryption Strategy

Use **AES-256-GCM** for encrypting sensitive fields at rest.

```sql
-- Encrypted columns stored as base64
location_encrypted TEXT,  -- {lat, lng} encrypted
dob_encrypted TEXT,       -- Date of birth encrypted
```

**Encryption utility:**
```typescript
import { createCipheriv, createDecipheriv, randomBytes } from 'crypto';

const ALGORITHM = 'aes-256-gcm';
const KEY = Buffer.from(process.env.ENCRYPTION_KEY, 'base64'); // 32 bytes

function encrypt(plaintext: string): string {
  const iv = randomBytes(12);
  const cipher = createCipheriv(ALGORITHM, KEY, iv);
  
  let encrypted = cipher.update(plaintext, 'utf8', 'base64');
  encrypted += cipher.final('base64');
  
  const authTag = cipher.getAuthTag();
  
  // Format: iv:authTag:ciphertext (all base64)
  return `${iv.toString('base64')}:${authTag.toString('base64')}:${encrypted}`;
}

function decrypt(encrypted: string): string {
  const [ivB64, authTagB64, ciphertext] = encrypted.split(':');
  
  const iv = Buffer.from(ivB64, 'base64');
  const authTag = Buffer.from(authTagB64, 'base64');
  
  const decipher = createDecipheriv(ALGORITHM, KEY, iv);
  decipher.setAuthTag(authTag);
  
  let decrypted = decipher.update(ciphertext, 'base64', 'utf8');
  decrypted += decipher.final('utf8');
  
  return decrypted;
}
```

### What Gets Encrypted

```typescript
// Before storing location
const locationData = JSON.stringify({ 
  lat: 37.7749, 
  lng: -122.4194 
});
await db.profiles.update(userId, {
  location_encrypted: encrypt(locationData),
  city: 'San Francisco',  // Unencrypted for queries
  country: 'US'
});

// Before storing DOB
await db.users.update(userId, {
  dob_encrypted: encrypt(dateOfBirth.toISOString()),
  age: calculateAge(dateOfBirth)  // Derived, unencrypted for queries
});
```

### Key Management

```yaml
# AWS Secrets Manager / Supabase Vault
ENCRYPTION_KEY: "base64-encoded-32-byte-key"

# Key rotation:
# 1. Generate new key
# 2. Decrypt with old key, re-encrypt with new key (background job)
# 3. Update secret reference
# 4. Old key retained for 30 days for any missed records
```

---

## Matching Privacy

### Match Offers - Pseudonymized

Match offers reference user IDs but don't store identifying information:

```sql
CREATE TABLE match_offers (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,           -- Who received the offer
  offered_user_id UUID NOT NULL,   -- Who was offered
  compatibility_score INTEGER,      -- Just a number
  compatibility_themes TEXT[],     -- ["values", "lifestyle"]
  -- NO names, photos, or profile data
);
```

**Privacy properties:**
- Only stores UUIDs (random identifiers)
- Profile data fetched separately at display time
- Scores computed, not raw answers
- Expired offers are deleted

### Compatibility Data - Aggregated

User answers are stored but **match computation uses derived scores**:

```sql
-- Raw answers (user's own data)
CREATE TABLE compatibility_responses (
  user_id UUID,
  question_id UUID,
  answer JSONB,  -- Encrypted if sensitive
);

-- For matching, we compute in-memory or use derived data
-- Never expose raw answers to other users
```

**What users see about matches:**
- Compatibility score (0-100)
- Themes ("You both value adventure")
- NOT: Individual answers, raw responses

### Match Visibility

Users only see match data for **their own matches**:

```sql
-- RLS Policy: Users only see their own offers
CREATE POLICY offers_select_own ON match_offers
  FOR SELECT USING (user_id = auth.uid());

-- Match details only visible to participants
CREATE POLICY matches_select_participant ON matches
  FOR SELECT USING (
    user_id_1 = auth.uid() OR user_id_2 = auth.uid()
  );
```

---

## Message Privacy

### End-to-End Encryption Consideration

For MVP: **Transport encryption + at-rest encryption** (not E2E)

E2E encryption is complex and prevents:
- Content moderation (safety)
- Message search
- Cross-device sync

**MVP approach:**
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY,
  match_id UUID NOT NULL,
  sender_id UUID NOT NULL,
  content TEXT NOT NULL,  -- Encrypted at rest with AES-256-GCM
  created_at TIMESTAMPTZ NOT NULL,
);
```

**Message encryption (application-level):**
```typescript
// Encrypt before storing
const encryptedContent = encrypt(messageContent);
await db.messages.create({
  match_id: matchId,
  sender_id: senderId,
  content: encryptedContent,
});

// Decrypt when retrieving
const messages = await db.messages.findByMatch(matchId);
const decrypted = messages.map(m => ({
  ...m,
  content: decrypt(m.content),
}));
```

**Post-MVP:** Consider Signal Protocol for true E2E encryption if users demand it.

---

## Face Verification Privacy

Face vectors are **highly sensitive biometric data**:

### Storage Separation

```sql
-- verification_sessions (main DB)
face_vector_id TEXT,  -- Reference ONLY, not the actual vector

-- face_vectors (separate encrypted storage)
-- Could be:
-- 1. Separate table with restricted access
-- 2. Separate database entirely
-- 3. External service (AWS Rekognition stores it)
```

**MVP approach with AWS Rekognition:**
- AWS stores the face vector in their infrastructure
- We only store a reference ID
- Raw photos deleted within 24 hours
- Vectors used only for duplicate detection

```typescript
// Liveness check with Rekognition
const result = await rekognition.detectLiveness({
  Video: { S3Object: { Bucket: bucket, Key: key } },
});

// Store only the reference, not biometric data
await db.verification_sessions.update(sessionId, {
  face_vector_id: result.FaceId,  // AWS-managed
  status: 'verified',
});

// Delete raw photo
await s3.deleteObject({ Bucket: bucket, Key: key });
```

---

## Row Level Security (RLS)

Every table has RLS enabled with strict policies:

```sql
-- Users: Only see own row
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY users_select_own ON users
  FOR SELECT USING (id = auth.uid());

CREATE POLICY users_update_own ON users
  FOR UPDATE USING (id = auth.uid());

-- Profiles: Only see own + matches' public data
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY profiles_select_own ON profiles
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY profiles_select_matches ON profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM matches 
      WHERE status = 'active'
      AND (user_id_1 = auth.uid() AND user_id_2 = profiles.user_id)
         OR (user_id_2 = auth.uid() AND user_id_1 = profiles.user_id)
    )
  );

-- Messages: Only participants
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY messages_select_participant ON messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM matches
      WHERE id = messages.match_id
      AND (user_id_1 = auth.uid() OR user_id_2 = auth.uid())
    )
  );
```

---

## API Privacy

### Response Filtering

APIs never expose more than needed:

```typescript
// User profile response (for matches)
function formatMatchProfile(user: User, profile: Profile) {
  return {
    id: user.id,
    displayName: user.display_name,
    age: calculateAge(user.dob_encrypted),  // Derived, not DOB
    bio: profile.bio,
    city: profile.city,  // City only, not coordinates
    photos: profile.photos.map(formatPhoto),
    compatibilityScore: computeScore(user.id, currentUser.id),
  };
  // NOT included: phone, email, exact location, DOB
}

// Own profile response (full access)
function formatOwnProfile(user: User, profile: Profile) {
  return {
    id: user.id,
    displayName: user.display_name,
    phoneLastFour: user.phone_last_four,
    // ... more fields
  };
}
```

### No Enumeration

APIs prevent user enumeration:

```typescript
// Bad: Reveals if phone exists
if (await findUserByPhone(phone)) {
  return { error: 'Phone already registered' };
}

// Good: Same response either way
await sendOTP(phone);
return { message: 'If this phone is registered, you will receive an OTP' };

// Bad: Sequential IDs allow enumeration
GET /users/1
GET /users/2

// Good: UUIDs, RLS prevents access
GET /users/550e8400-e29b-41d4-a716-446655440000
// Returns 404 if not own ID or match
```

---

## Data Retention

| Data Type | Retention | Deletion Method |
|-----------|-----------|-----------------|
| Account data | Until deletion + 30 days | Hard delete |
| Messages | While match active + 30 days | Hard delete |
| Match offers | 6 days (expiry) | Hard delete |
| Face verification | Vector: 90 days, Photo: 24 hours | Hard delete |
| Logs (non-PII) | 90 days | Automatic purge |
| Audit logs | 1 year | Anonymized after |

---

## Implementation Checklist

### Database
- [ ] Enable RLS on all tables
- [ ] Create encryption key in AWS Secrets Manager
- [ ] Implement encrypt/decrypt utility functions
- [ ] Hash phone numbers with Argon2id
- [ ] Encrypt location coordinates
- [ ] Encrypt messages at rest

### API
- [ ] Filter responses based on requester
- [ ] Use UUIDs everywhere (no sequential IDs)
- [ ] Rate limit to prevent enumeration
- [ ] Log access without logging PII

### Infrastructure
- [ ] TLS 1.3 enforced
- [ ] Database encryption at rest (Supabase default)
- [ ] Secrets in AWS Secrets Manager
- [ ] VPC for internal services
- [ ] WAF for API protection

---

## Related Documents

- `docs/technical/schema/database.md` - Schema with RLS policies
- `docs/ops/admin-operations.md` - Admin privacy controls
- `docs/technical/contracts/auth-session-contract.md` - Auth security
