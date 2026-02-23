# ADR-0003: Auth and Recovery Policy

Date: 2026-02-19
Status: Accepted
Owner: Engineering
Last Updated: 2026-02-20
Depends On: `docs/technical/contracts/auth-session-contract.md`, `docs/specs/onboarding.md`

## Context

Yoked requires authentication that balances security with user experience. Key requirements:
- Phone number as primary identifier
- Social login (Apple/Google) as convenience option
- Account recovery for lost devices
- Protection against account takeover

## Decision

Implement **phone-centric authentication** with:
1. Phone OTP as primary auth method
2. Social login requires phone linking
3. Multi-factor account recovery with hold period
4. Step-up authentication for high-risk actions

## Rationale

### Why Phone-Centric

1. **Identity Verification**
   - Phone numbers are harder to mass-create than emails
   - SMS OTP provides possession factor
   - Reduces fake account creation

2. **Dating App Norms**
   - Users expect phone-based auth
   - Enables SMS notifications
   - Matches competitor UX

3. **Recovery**
   - Phone is durable identifier
   - Users rarely change phone numbers
   - Enables assisted recovery flow

### Why Social Login Requires Phone

1. **Single Identity**
   - Prevents multiple accounts per person
   - Phone is canonical identifier
   - Social is just convenience layer

2. **Safety**
   - All users have verified contact
   - Enables abuse reporting/traceability
   - Required for legal compliance

### Why Assisted Recovery with Hold

1. **Security**
   - 72-hour hold allows device owners to dispute
   - Prevents immediate account takeover
   - Time for manual verification

2. **UX Compromise**
   - Lost device is edge case
   - Hold is acceptable for security gain
   - Manual review ensures legitimacy

## Policy Details

### Authentication Flow

```
New User:
  Phone OTP -> Profile Creation -> Done

Existing User (known device):
  Phone OTP -> Access granted

Existing User (new device):
  Phone OTP -> Step-up check -> Access granted

Social Login (new):
  Apple/Google -> Phone linking required -> Phone OTP -> Done
```

### Step-Up Authentication

Triggered when:
- New device + no login for 30 days
- New device + first time login
- Account recovery request
- High-risk location (different country)

Step-up method:
- Phone OTP (possession factor)
- Optional: Email verification (if email on file)

### Account Recovery

**Assisted Recovery Flow:**

```
1. User requests recovery
2. Server creates recovery record (72-hour hold)
3. Server notifies all known devices
4. If no dispute within 72 hours:
   a. User completes identity verification
   b. Trust & Safety approves
   c. Account access restored
5. If device disputes:
   a. Recovery cancelled
   b. Account locked
   c. Manual review required
```

**Identity Verification Options:**
- Government ID upload
- Video call with T&S
- Knowledge-based questions (account history)

### Session Management

| Token Type | Lifetime | Rotation |
|------------|----------|----------|
| Access Token | 15 minutes | No |
| Refresh Token | 30 days inactive / 90 days max | Yes (new on each use) |
| Session | 90 days max | N/A |

### Device Management

- Up to 5 concurrent sessions per user
- Device fingerprint stored (OS, model, approximate location)
- New device notification sent to existing devices
- User can revoke devices remotely

## Security Measures

### Rate Limiting

| Action | Limit | Window |
|--------|-------|--------|
| OTP send | 1 | 1 minute |
| OTP send | 5 | 1 hour |
| OTP verify | 3 | per request |
| Login attempts | 10 | 1 hour per IP |

### Fraud Detection

- Velocity checks (multiple accounts from same device)
- Location anomaly detection
- Phone number reputation (Twilio Lookup)
- Device fingerprinting

### Account Takeover Prevention

- New device notification
- Email notification for security changes
- Option to lock account if suspicious activity
- Forced logout on password/phone change

## Consequences

### Positive

- Strong identity verification
- Clear recovery path
- Protection against takeover
- Audit trail for all auth events

### Tradeoffs

- Phone required (some users won't provide)
- SMS delivery issues in some regions
- 72-hour hold may frustrate users
- Cost of SMS OTP

### Risks

| Risk | Mitigation |
|------|------------|
| SMS interception | Monitor for suspicious patterns, offer app-based 2FA later |
| SIM swap attacks | Step-up auth for new devices, device binding |
| Phone number recycling | Verify number ownership on login, notification to old owner |
| Recovery abuse | 72-hour hold, manual review, device dispute |

## Implementation

### Supabase Auth Configuration

- Phone provider enabled
- OTP length: 6 digits
- OTP expiry: 5 minutes
- Apple/Google providers enabled
- Custom claims for device ID

### Custom Components

- Device fingerprinting service
- Recovery workflow engine
- Fraud detection rules
- Notification service

## Validation

Success metrics:
- Onboarding completion rate > 60%
- Account recovery success rate > 80%
- Account takeover rate < 0.1%
- False positive fraud rate < 1%

## Related Docs

- `docs/technical/contracts/auth-session-contract.md`
- `docs/technical/contracts/openapi.yaml`
