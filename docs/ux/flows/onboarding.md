# UX Flow: Onboarding

Owner: Product Design  
Status: Draft  
Last Updated: 2026-02-20  
Depends On: `docs/technical/contracts/openapi.yaml`, `docs/specs/onboarding.md`

## Overview

The onboarding flow guides users from first app open to match-ready status. It includes authentication, profile creation, compatibility questionnaire, and verification.

## Entry Points

1. **Cold Start**: User downloads app, opens for first time
2. **Deep Link**: User taps invite link or ad
3. **Return After Logout**: Existing user re-authenticating

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        ONBOARDING FLOW                          │
└─────────────────────────────────────────────────────────────────┘

[Splash Screen]
    │
    ▼
[Welcome Screen]
    │ "Find your person"
    │ Primary: "Get Started"
    │ Secondary: "I already have an account"
    ▼
[Phone Number Entry]
    │ Input: Phone number with country code
    │ Validation: Format check, rate limit
    │ Error: Invalid number, rate limited
    ▼
[OTP Verification]
    │ Input: 6-digit code
    │ Timer: Resend after 60s
    │ Error: Invalid code, expired
    ▼
[Age Gate]
    │ Input: Date of birth
    │ Validation: Must be 18+
    │ Fail: Block with explanation
    ▼
[Profile Basics]
    │ Input: Display name (2-50 chars)
    │ Input: Bio (optional, 0-500 chars)
    │ Validation: Profanity filter
    ▼
[Location Permission]
    │ Request: Location access
    │ Fallback: Manual city selection
    │ Required for matching
    ▼
[Compatibility Questionnaire]
    │ Progressive disclosure: 1 question at a time
    │ Integrated profiling: psych + physical preference prompts
    │ Progress bar: X of Y complete
    │ Skip: Not allowed for required questions
    │ Save: Progress auto-saved
    ▼
[Photo Studio Lite]
    │ Screen 1: Biometric consent
    │   - Clear explanation of use
    │   - Decline = non-matching mode
    │ Screen 2: Camera guidance
    │   - Position face in oval
    │   - Good lighting tips
    │ Screen 3: Capture
    │   - Liveness check (blink, turn head)
    │   - Retake option
    │ Screen 4: Processing
    │   - Spinner while verifying
    │   - Success or retry
    ▼
[Onboarding Complete]
    │ Success animation
    │ "You're ready to meet someone"
    │ CTA: "See today's matches"
    ▼
[Daily Matches Screen]
```

## Screen Specifications

### Splash Screen

**Purpose:** Brand recognition, loading state
**Duration:** 2 seconds max or until ready
**Elements:**
- App logo (centered)
- Loading indicator (subtle)

**Transitions:**
- Auto-advance to Welcome if not authenticated
- Auto-advance to Daily Matches if authenticated + onboarded

### Welcome Screen

**Purpose:** Set tone, primary CTA
**Elements:**
- Hero image/illustration (couples, diverse)
- Headline: "Find your person"
- Subheadline: "Curated matches, meaningful connections"
- Primary CTA: "Get Started" (full width, prominent)
- Secondary CTA: "I already have an account" (text link)
- Terms/Privacy links (small, bottom)

**Interactions:**
- Tap "Get Started" → Phone Number Entry
- Tap "I already have an account" → Phone Number Entry (pre-filled if known)

### Phone Number Entry

**Purpose:** Primary identity verification
**Elements:**
- Back button
- Title: "What's your number?"
- Subtitle: "We'll send you a code to verify"
- Country code selector (default to device locale)
- Phone number input (numeric keyboard)
- "Continue" button (disabled until valid)
- "Use Apple/Google instead" (social options)

**Validation:**
- Real-time format validation
- Country-specific length check
- Rate limit: 1 request/minute

**Error States:**
- Invalid format: "Please enter a valid phone number"
- Rate limited: "Please wait X seconds before retrying"
- Provider error: "Unable to send SMS. Try again?"

**Accessibility:**
- Large touch targets (44x44pt min)
- Clear focus states
- Screen reader labels

### OTP Verification

**Purpose:** Verify phone possession
**Elements:**
- Back button
- Title: "Enter the code"
- Subtitle: "Sent to +1 (***) ***-1234"
- 6-digit code input (auto-advance per digit)
- "Didn't receive it? Resend" (60s countdown)
- "Change number" link

**States:**
- Input: Empty boxes, numeric keyboard
- Typing: Filled boxes
- Verifying: Loading spinner on Continue
- Success: Checkmark, auto-advance
- Error: Shake animation, "Invalid code. Try again."

**Edge Cases:**
- Code expired: "Code expired. Request a new one."
- Max attempts: "Too many attempts. Try again in 15 minutes."
- Auto-fill: Support SMS auto-fill on iOS/Android

### Age Gate

**Purpose:** Legal compliance (18+)
**Elements:**
- Title: "When's your birthday?"
- Date picker (day, month, year wheels)
- "Continue" button

**Validation:**
- Calculate age from DOB
- Block if < 18: "You must be 18 to use Yoked"
- Soft block: Account created but matching disabled

**Error State:**
- Underage: Full-screen modal with explanation
- Option: "Notify me when I'm eligible"

### Profile Basics

**Purpose:** Create basic profile
**Elements:**
- Progress indicator: "Step 1 of 3"
- Title: "What should we call you?"
- Display name input
- Character counter (0/50)
- Title: "Tell us about yourself (optional)"
- Bio textarea
- Character counter (0/500)
- "Continue" button

**Validation:**
- Name: 2-50 characters, no special chars
- Bio: Max 500, profanity filter
- Real-time validation with inline errors

### Location Permission

**Purpose:** Enable location-based matching
**Elements:**
- Illustration (map pin)
- Title: "Where are you?"
- Subtitle: "We use your location to find nearby matches"
- Primary: "Allow Location Access"
- Secondary: "Enter manually"

**Flows:**
1. Allow → System permission dialog → Success → Questionnaire
2. Deny → Manual entry screen → City search → Questionnaire

**Manual Entry:**
- Search input with autocomplete
- Recent/popular cities list
- Required to proceed

### Compatibility Questionnaire

**Purpose:** Build integrated matching profile
**Pattern:** One question per screen
**Elements per screen:**
- Progress bar (top)
- Question prompt (large text)
- Optional: Subtitle with context
- Input (varies by question type)
- "Continue" button (disabled until answered)
- "Save & Exit" (top right, saves progress)

**Question Types:**

1. **Single Choice**
   - Vertical stack of radio buttons
   - Clear selection state
   - Max 6 options

2. **Multiple Choice**
   - Checkboxes
   - "Select all that apply" hint
   - Min/max selection validation

3. **Slider**
   - Continuous or stepped
   - Current value label
   - Min/max labels

4. **Ranking**
   - Draggable list
   - Number indicators (1, 2, 3...)
   - "Most important at top" hint

5. **Preference Prompts**
   - Optional physical preference selections (lightweight tags)
   - Clear "preference, not requirement" language
   - Same save/validation behavior as other profiling questions

**Navigation:**
- Swipe right to go back (if answered)
- Continue advances to next
- Progress saved after each question

**Completion:**
- Last question → "Finish" button
- Completion animation
- Advance to Photo Studio

### Photo Studio Lite

**Purpose:** Verify identity, prevent catfishing
**Flow:**

**Screen 1: Consent**
- Title: "Verify it's you"
- Explanation bullets:
  - "We use AI to verify you're real"
  - "Photos are deleted after verification"
  - "This keeps our community safe"
- "How we protect your data" (expandable)
- Primary: "I agree, continue"
- Secondary: "Not now" (routes to non-matching mode)

**Screen 2: Guidance**
- Illustration: Face in oval frame
- Tips:
  - "Find good lighting"
  - "Remove sunglasses"
  - "Center your face"
- "I'm ready" button

**Screen 3: Capture**
- Camera preview with oval overlay
- Real-time face detection feedback:
  - "Move closer"
  - "Center your face"
  - "Good! Hold still..."
- Liveness prompts:
  - "Blink slowly"
  - "Turn your head left"
- Capture button (auto-captures when ready)
- Retake option

**Screen 4: Processing**
- Loading spinner
- Status messages:
  - "Analyzing..."
  - "Almost done..."
- Timeout: 30 seconds max

**Screen 5: Result**

*Success:*
- Checkmark animation
- "You're verified!"
- "Continue" → Onboarding Complete

*Failure:*
- Specific reason:
  - "We couldn't verify liveness. Try again?"
  - "Photo quality too low. Better lighting?"
  - "Verification inconclusive. Contact support?"
- "Try again" or "Contact support" buttons

*Manual Review:*
- "We're reviewing your photo"
- "This usually takes a few minutes"
- "Continue" (to non-matching mode until approved)

### Onboarding Complete

**Purpose:** Celebrate, set expectations
**Elements:**
- Success animation (confetti, checkmark)
- Title: "You're all set!"
- Subtitle: "We'll find great matches for you daily at 9 AM"
- CTA: "See today's matches" (primary)
- Secondary: "Review my profile"

**Transitions:**
- Auto-advance to Daily Matches after 5 seconds
- Tap CTA immediate advance

## Edge Cases

### Interrupted Onboarding

| Scenario | Behavior |
|----------|----------|
| App killed mid-flow | Resume at last completed step |
| Phone call during capture | Pause, resume after call |
| Background during processing | Continue processing, notify when done |
| Network loss | Queue actions, retry when connected |

### Validation Failures

| Failure | Recovery |
|---------|----------|
| Phone in use | Offer account recovery flow |
| Age under 18 | Soft block, notify when eligible |
| Photo verification fails | 3 retries, then manual review |
| Questionnaire incomplete | Save progress, allow resume |

### Social Login

If user chooses Apple/Google:
1. Authenticate with provider
2. If phone not linked → Phone Number Entry
3. Link phone to social account
4. Continue from Profile Basics

## Analytics Events

| Event | Trigger |
|-------|---------|
| onboarding_started | Tap "Get Started" |
| phone_entered | Valid phone submitted |
| otp_verified | Correct OTP entered |
| age_verified | 18+ confirmed |
| profile_created | Profile basics submitted |
| location_allowed | Location permission granted |
| questionnaire_started | First question shown |
| questionnaire_completed | Last question answered |
| profiling_completed | Psychological + preference profile saved |
| verification_consent_given | Agree to photo verification |
| verification_completed | Photo verified |
| onboarding_completed | Reach Daily Matches |

## Success Metrics

- Completion rate: > 60% within 24 hours
- Drop-off by step: Identify biggest leaks
- Time to complete: Target < 10 minutes
- Verification success rate: > 90%

## Accessibility

- All text minimum 16pt
- Color contrast WCAG AA compliant
- Screen reader optimized
- VoiceOver/TalkBack tested
- Dynamic Type support
- Reduce Motion support
