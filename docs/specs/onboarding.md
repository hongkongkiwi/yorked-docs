# Feature Specification: Onboarding

Owner: Product + Engineering  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/ux/flows/onboarding.md`, `docs/technical/contracts/openapi.yaml`, `docs/specs/visual-preference-studio.md`

## Overview

The onboarding feature enables users to create accounts, complete profiles, and become eligible for matching. It includes authentication, profile creation, integrated profiling (psychological + visual/physical preferences), and identity verification.

Onboarding supports two matching readiness modes:
- `provisional`: questionnaire complete + verification complete + VPS not ready
- `full-confidence`: questionnaire complete + verification complete + VPS ready

## Scope Clarification

Aligned with `docs/execution/phases/intent-phase-canonical-map.md`:
- MVP social auth providers are Apple + Google (with phone OTP requirement). Facebook is out of MVP scope.
- Verification artifacts are trust/safety inputs and policy gates, not attractiveness-ranking inputs in MVP.
- VPS supports explicit preference capture for ranking quality; advanced generated-face pipelines are post-MVP.

## User Stories

### US-001: Phone Authentication

**As a** new user  
**I want to** sign up with my phone number  
**So that** I can create an account quickly and securely

**Acceptance Criteria:**
- [ ] User can enter phone number with country code
- [ ] System validates phone format in real-time
- [ ] System sends 6-digit OTP via SMS within 30 seconds
- [ ] User can request resend after 60 seconds
- [ ] System validates OTP within 3 attempts
- [ ] User is authenticated and account created on success
- [ ] Rate limiting: 1 request/minute, 5/hour per phone

**API Contract:** `POST /auth/otp/send`, `POST /auth/otp/verify`

### US-002: Social Login

**As a** new user  
**I want to** sign up with Apple or Google  
**So that** I don't need to remember another password

**Acceptance Criteria:**
- [ ] User can initiate Apple Sign In
- [ ] User can initiate Google Sign In
- [ ] System validates identity token with provider
- [ ] If phone not linked, user must verify phone number
- [ ] Social identity linked to phone-based account
- [ ] User can login with social on subsequent visits

**API Contract:** `POST /auth/social/apple`, `POST /auth/social/google`

### US-003: Age Verification

**As a** user  
**I want to** confirm I am 18 or older  
**So that** I can use a dating app legally

**Acceptance Criteria:**
- [ ] User must enter date of birth
- [ ] System calculates age from DOB
- [ ] Users under 18 are blocked from matching
- [ ] Blocked users see "waitlist" message with eligibility date
- [ ] Age stored securely and not displayed publicly

**API Contract:** Part of profile creation

### US-004: Profile Creation

**As a** user  
**I want to** create a basic profile  
**So that** others can learn about me

**Acceptance Criteria:**
- [ ] User can enter display name (2-50 characters)
- [ ] User can enter optional bio (0-500 characters)
- [ ] System validates against profanity
- [ ] User can grant location permission
- [ ] Fallback: manual city selection if permission denied
- [ ] Profile saved and can be edited later

**API Contract:** `PATCH /users/me`

### US-005: Integrated Profiling Questionnaire

**As a** user  
**I want to** answer psychological and preference questions in one flow  
**So that** I get better match recommendations

**Acceptance Criteria:**
- [ ] System presents questions one at a time
- [ ] Questions include: single choice, multiple choice, slider, ranking
- [ ] Profiling includes psychological dimensions (values, lifestyle, communication)
- [ ] Profiling includes physical preference signals (user-stated preferred characteristics)
- [ ] Progress is auto-saved after each question
- [ ] User can exit and resume later
- [ ] Required questions must be answered to complete
- [ ] Question set is versioned
- [ ] Answers used for psychological compatibility + physical-preference affinity scoring

**API Contract:** `GET /compatibility/questions`, `POST /compatibility/responses`

### US-006: Visual Preference Studio Capture

**As a** user
**I want to** quickly teach the system my visual preferences
**So that** recommendations can use explicit attraction signals instead of guesses

**Acceptance Criteria:**
- [ ] System presents required VPS fast-capture tasks during onboarding
- [ ] Fast capture uses 20 pairwise comparisons with optional `Neither`
- [ ] Pair order and side placement are randomized
- [ ] User may defer VPS capture and continue onboarding
- [ ] Deferred users are explicitly marked `provisional` for matching
- [ ] Full-confidence matching requires VPS profile status `ready`
- [ ] Deferred users are prompted to complete VPS before full-confidence mode

**API Contract:** `GET /visual-preferences/session`, `POST /visual-preferences/choices`, `GET /visual-preferences/profile`

### US-007: Photo Verification

**As a** user  
**I want to** verify my identity with a selfie  
**So that** others know I'm real

**Acceptance Criteria:**
- [ ] User sees clear explanation of biometric use
- [ ] User must explicitly consent before capture
- [ ] System guides user through liveness check (blink, turn)
- [ ] System verifies photo quality (lighting, clarity)
- [ ] System performs liveness detection
- [ ] System may run additional checks for policy/safety validation
- [ ] Raw photo deleted within 24 hours
- [ ] Verification artifacts are used for trust/safety only, not attractiveness ranking in MVP
- [ ] User can retry up to 3 times on failure
- [ ] Failed verifications go to manual review

**API Contract:** `POST /verification/session`, `POST /verification/session/{sessionId}/complete`

### US-008: Account Recovery

**As a** user who lost access  
**I want to** recover my account  
**So that** I don't lose my matches and messages

**Acceptance Criteria:**
- [ ] User can initiate recovery from login screen
- [ ] System requires phone number verification
- [ ] 72-hour mandatory hold period
- [ ] Notification sent to all known devices
- [ ] If no dispute, user completes identity verification
- [ ] Trust & Safety reviews and approves
- [ ] Account access restored

**API Contract:** `POST /auth/recovery/request`

## Technical Requirements

### Performance

- OTP delivery: < 30 seconds
- Photo verification: < 10 seconds
- Questionnaire load: < 2 seconds
- VPS fast capture completion: < 3 minutes median
- Total onboarding time: < 10 minutes

### Security

- Phone numbers hashed at rest
- OTPs not logged
- Biometric data encrypted in transit
- Raw photos deleted within 24 hours
- Rate limiting on all endpoints

### Analytics

Track funnel:
- App open → Phone entered
- Phone entered → OTP verified
- OTP verified → Profile complete
- Profile complete → Questionnaire complete
- Questionnaire complete → VPS ready or VPS deferred
- Questionnaire complete → Verification complete
- Verification complete → First match viewed

## Error Handling

| Error | User Message | Recovery |
|-------|--------------|----------|
| Invalid phone | "Please enter a valid phone number" | Retry input |
| Rate limited | "Please wait X seconds" | Auto-countdown |
| Invalid OTP | "Code incorrect. X attempts remaining" | Retry |
| OTP expired | "Code expired. Request new one?" | Resend |
| Underage | "You must be 18 to use Yoked" | Waitlist signup |
| Photo quality | "Photo unclear. Try better lighting?" | Retake |
| Liveness fail | "We couldn't verify you're real. Try again?" | Retake |
| Network error | "Connection issue. Try again?" | Retry button |

## State Machine

```
[Created] ──► [Phone Verified] ──► [Profile Complete]
                                           │
                    ┌──────────────────────┘
                    ▼
           [Questionnaire Complete]
              ┌─────┴──────────┐
              │                │
              ▼                ▼
         [VPS Ready]      [VPS Deferred]
              │                │
              └─────┬──────────┘
                    ▼
           [Verification Pending] ──► [Verification Failed]
                    │                           │
                    ▼                           │
           [Verification Complete] ◄────────────┘ (retry)
               ┌────┴─────┐
               │          │
               ▼          ▼
     [Match Eligible: Full] [Match Eligible: Provisional]
```

## Onboarding Status Mapping (Contracted)

API `onboardingStatus` is a derived field, mapped from persisted state.

| Priority | Condition | API onboardingStatus |
|---|---|---|
| 1 | `users.status IN ('non_matching','suspended','deleted')` | `blocked` |
| 2 | `users.onboarding_step IN ('phone_verify','profile','questionnaire')` | `questionnaire_pending` |
| 3 | `users.onboarding_step = 'verification'` AND VPS profile status is not `ready` | `vps_pending` |
| 4 | `users.onboarding_step = 'verification'` AND VPS profile status is `ready` | `verification_pending` |
| 5 | `users.onboarding_step = 'complete'` AND VPS profile status is `ready` AND `users.status = 'active'` | `complete` |

VPS profile status source: `visual_preference_profiles.status`. Missing profile is treated as not ready.

## Dependencies

- Supabase Auth (phone OTP)
- Apple/Google OAuth providers
- AWS Rekognition (liveness)
- PostgreSQL (profile storage)
- Redis (rate limiting)

## Resolved Questions

| Question | Decision | Config Key |
|----------|----------|------------|
| Email as backup contact | No for MVP | - |
| Questionnaire size | 25 questions, 10 required | `QUESTIONNAIRE_TOTAL_QUESTIONS` |
| Skip photo verification | No - required for matching | - |
| VPS requirement for matching | Provisional path allowed; VPS required for full-confidence matching | `MATCH_REQUIRE_VISUAL_SIGNAL`, `MATCH_PROVISIONAL_MAX_OFFERS` |

> See `docs/ops/configuration.md` for all configurable parameters.
