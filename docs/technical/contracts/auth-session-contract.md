# Auth and Session Contract

Owner: Engineering  
Status: Draft  
Last Updated: 2026-02-20  
Depends On: `docs/technical/contracts/openapi.yaml`, `docs/technical/decisions/ADR-0003-auth-recovery-policy.md`

## Overview

This document defines the authentication and session management contract, including token lifecycle, revocation rules, and security boundaries.

## Authentication Flows

### Phone OTP Flow

```
┌─────────┐     POST /auth/otp/send     ┌─────────┐
│  Client │ ───────────────────────────> │  Server │
│         │ <─────────────────────────── │         │
│         │     {requestId, expiresAt}    │         │
│         │                               │         │
│         │     POST /auth/otp/verify     │         │
│         │ ───────────────────────────> │         │
│         │ <─────────────────────────── │         │
│         │     {accessToken, refreshToken, user}   │
└─────────┘                               └─────────┘
```

**Security Requirements:**
- OTP is 6 digits, expires in 10 minutes
- Max 3 verification attempts per request
- Rate limit: 1 OTP request per phone number per minute
- Rate limit: 5 OTP requests per phone number per hour
- Device ID required for fraud detection

### Social Login Flow

```
┌─────────┐     POST /auth/social/{provider}    ┌─────────┐
│  Client │ ──────────────────────────────────> │  Server │
│         │ <────────────────────────────────── │         │
│         │     {tokens, user} OR {requiresPhoneLink, socialAuthId} │
└─────────┘                                      └─────────┘
```

**Phone Linking Required:**
- Social login must link to verified phone number
- If phone not linked, return `requiresPhoneLink: true`
- Client completes phone OTP flow with `socialAuthId`
- Server merges social identity with phone identity

## Token Specification

### Access Token

| Attribute | Value |
|-----------|-------|
| Type | JWT |
| Algorithm | RS256 |
| Expiry | 15 minutes |
| Contains | userId, sessionId, scopes, issuedAt, expiresAt |
| Signing Key | Rotated every 90 days |

**Access Token Payload:**

```json
{
  "sub": "user-uuid",
  "sid": "session-uuid",
  "scope": ["user", "matching", "chat"],
  "iat": 1708348800,
  "exp": 1708349700,
  "iss": "yoked.app",
  "aud": "yoked.api"
}
```

### Refresh Token

| Attribute | Value |
|-----------|-------|
| Type | Opaque string (256-bit random) |
| Storage | Hashed in database |
| Expiry | 30 days inactive, 90 days max |
| Rotation | New refresh token issued on each use |
| Revocation | Immediate on logout or security event |

**Refresh Token Lifecycle:**

```
Client -> Server: POST /auth/refresh {refreshToken}
Server: Validate refresh token hash
Server: Check token not revoked
Server: Generate new access token + new refresh token
Server: Store new refresh token hash, mark old as revoked
Server -> Client: {accessToken, refreshToken, expiresIn}
```

## Session Management

### Session Record

```typescript
interface Session {
  id: string;                    // UUID
  userId: string;                // UUID
  deviceId: string;              // Client-provided device identifier
  deviceType: 'ios' | 'android' | 'web';
  deviceName?: string;           // e.g., "iPhone 15 Pro"
  ipAddress: string;             // Hashed for privacy
  createdAt: DateTime;
  lastActiveAt: DateTime;
  expiresAt: DateTime;           // 90 days from creation
  revokedAt?: DateTime;
  revokedReason?: 'logout' | 'security' | 'expired';
}
```

### Session Lifecycle

**Creation:**
- Created on successful authentication
- Tied to device ID
- 90-day maximum lifetime

**Activity:**
- `lastActiveAt` updated on each API request
- Sessions inactive for 30 days are eligible for cleanup

**Revocation:**
- Immediate on explicit logout
- Immediate on security event (password change, suspicious activity)
- Cascading: refresh token revocation invalidates all access tokens

**Expiry:**
- Access tokens: 15 minutes
- Refresh tokens: 30 days inactive OR 90 days max
- Sessions: 90 days max regardless of activity

## Security Boundaries

### Step-Up Authentication

Required for high-risk operations:

| Operation | Risk Signal | Step-Up Required |
|-----------|-------------|------------------|
| Account recovery | New device + no recent activity | Phone OTP + 72h hold |
| Delete account | Any | Phone OTP |
| Change phone number | Any | Phone OTP to old number |
| Access chat history | New device + first login | Phone OTP |

### New Device Detection

```
IF deviceId NOT IN user's known devices:
  IF lastLogin > 30 days ago OR no previous logins:
    REQUIRE step-up authentication
    SEND new device notification to all known devices
  ELSE:
    ALLOW with notification
  ADD device to known devices
```

### Suspicious Activity Detection

Triggers session revocation and requires re-auth:

- Login from unusual location (different country)
- Multiple failed OTP attempts
- Rapid successive logins from different IPs
- Concurrent sessions exceeding limit (5 per user)

## Token Revocation

### Revocation Events

| Event | Action | Propagation |
|-------|--------|-------------|
| User logout | Revoke current session | Immediate |
| Logout all devices | Revoke all user sessions | Within 60s |
| Security incident | Revoke specific session | Immediate |
| Password change | Revoke all sessions except current | Within 60s |
| Account suspension | Revoke all sessions | Immediate |

### Revocation Implementation

**Redis Revocation List:**
- Key: `revoked:{tokenJti}`
- TTL: Token remaining expiry + buffer
- Checked on every API request

**Session Table:**
- `revokedAt` timestamp
- `revokedReason` enum
- Queried on refresh token use

## Recovery Flow

### Assisted Recovery

For users who cannot access their phone:

```
1. User requests recovery via /auth/recovery/request
2. Server creates recovery record with 72-hour hold
3. Server sends notification to all known devices
4. If no device disputes within 72 hours:
   - Recovery approved
   - User completes identity verification
   - Account access restored
5. If device disputes:
   - Recovery cancelled
   - Account locked pending manual review
```

**Recovery Requirements:**
- Must know phone number
- 72-hour mandatory hold
- Identity verification (document or video call)
- Approval from trust & safety team

## API Security

### Authentication Header

```
Authorization: Bearer {access_token}
```

### Unauthenticated Endpoints

The following endpoints do not require authentication:

- `POST /auth/otp/send`
- `POST /auth/otp/verify`
- `POST /auth/social/apple`
- `POST /auth/social/google`
- `POST /auth/refresh`
- `GET /health`

All other endpoints require valid access token.

### CORS Policy

```
Allowed Origins:
- https://yoked.app
- https://admin.yoked.app
- https://localhost:* (development only)

Allowed Methods: GET, POST, PATCH, DELETE, OPTIONS
Allowed Headers: Authorization, Content-Type, X-Request-ID
Credentials: true
Max Age: 86400
```

## Error Responses

### Authentication Errors

| Status | Code | Description | Client Action |
|--------|------|-------------|---------------|
| 401 | `token_expired` | Access token expired | Refresh token |
| 401 | `token_invalid` | Token malformed or signature invalid | Re-authenticate |
| 401 | `token_revoked` | Token has been revoked | Re-authenticate |
| 401 | `session_expired` | Session lifetime exceeded | Re-authenticate |
| 403 | `insufficient_scope` | Token lacks required scope | Request higher scope |
| 429 | `rate_limited` | Too many requests | Back off and retry |

### Token Refresh Errors

| Status | Code | Description | Client Action |
|--------|------|-------------|---------------|
| 401 | `refresh_token_expired` | Refresh token expired | Re-authenticate |
| 401 | `refresh_token_revoked` | Refresh token revoked | Re-authenticate |
| 401 | `refresh_token_reused` | Token already used (rotation) | Re-authenticate |
| 401 | `session_revoked` | Session no longer valid | Re-authenticate |

## Implementation Checklist

- [ ] JWT signing key management (rotation, secure storage)
- [ ] Refresh token hashing (bcrypt or Argon2)
- [ ] Redis revocation list with TTL
- [ ] Device fingerprinting
- [ ] Rate limiting per IP and per phone
- [ ] Audit logging for all auth events
- [ ] New device notification
- [ ] Recovery flow automation
- [ ] Session cleanup job (daily)
- [ ] Token metrics (issuance, refresh, revocation rates)
