# UX Flow: Matching

Owner: Product Design  
Status: Draft  
Last Updated: 2026-02-20  
Depends On: `docs/technical/contracts/openapi.yaml`, `docs/specs/matching.md`

## Overview

The matching flow presents daily curated offers plus a weekly anchor offer and guides users through deliberate, low-fatigue decisions. It is the core value proposition of Yoked.

## Entry Points

1. **Daily Notification**: "Your daily matches are ready"
2. **Weekly Anchor Notification**: "Your anchor match is ready"
3. **App Open**: User opens app, sees review queue
4. **Empty State**: First-time user after onboarding
5. **Return Visit**: User already saw today's matches

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        MATCHING FLOW                            │
└─────────────────────────────────────────────────────────────────┘

[Daily Review Screen]
    │
    ├──► [Offer Detail + Why Match Panel] ──► [Decision Tray]
    │                │                              │
    │                │                              ├──► [Accept]
    │                │                              │       │
    │                │                              │       ├──► [Mutual?]
    │                │                              │       │       ├──► Yes ──► [Match Created]
    │                │                              │       │       └──► No ──► [Awaiting Response]
    │                │                              │       │
    │                │                              ├──► [Pass]
    │                │                              │       └──► [Cooldown]
    │                │                              │
    │                │                              └──► [Not Now]
    │                │                                      └──► [Short Cooldown]
    │
    ├──► [Weekly Anchor Offer]
    │        └──► [Same decision flow, richer explanation]
    │
    └──► [No More Offers] ──► [Empty State]

[Match Created]
    │
    ├──► [Celebration Modal]
    │
    ├──► [Start Chat CTA]
    │       └──► [Chat Screen]
    │
    └──► [Keep Browsing CTA]
            └──► [Daily Review Screen]

[Awaiting Response]
    │
    └──► [Offer Shows "Waiting"] ──► [Notification on Mutual]
```

## Screen Specifications

### Daily Review Screen

**Purpose:** Present daily curated offers
**Layout:**
- Header: "Today's Matches" + date + remaining decisions count
- Primary pane: offer detail + why-match panel
- Secondary pane: queue preview (today + anchor)
- Decision tray fixed at bottom (Pass, Not Now, Accept)
- Bottom: Navigation (Matches, Messages, Profile)

**Queue Model:**
- One active offer shown at a time
- Remaining offers shown as compact queue chips
- Weekly anchor is pinned and labeled
- Empty: "Check back tomorrow"

**Pull-to-Refresh:**
- Only if no pending decisions
- Shows loading state
- Rarely needed (push updates)

### Match Offer Card

**Purpose:** Present a potential match
**Structure:**

```
┌─────────────────────────────┐
│  [Photo Carousel]           │
│  ○ ○ ○ (pagination)         │
│                             │
│  Name, Age                  │
│  📍 Location                │
│                             │
│  "Compatibility: 85%"       │
│  [Values] [Lifestyle]       │  ← Compatibility themes
│  [Verified] [Fresh Check]   │  ← Authenticity indicators
│                             │
│  Bio text...                │
│                             │
│  ┌─────────────────────┐    │
│  │ "You both value..." │    │  ← Shared answers
│  └─────────────────────┘    │
│  ┌─────────────────────┐    │
│  │ Why this match now  │    │  ← Ranking rationale
│  └─────────────────────┘    │
│                             │
│  [❌ Pass]  [⏸ Not Now]  [✓ Accept] │
└─────────────────────────────┘
```

**Photo Carousel:**
- Swipe left/right for photos
- Max 6 photos
- Pinch to zoom (optional)
- Double-tap to like (optional)

**Compatibility Display:**
- Score: 0-100 (only if > 60)
- Themes: "Shared values", "Lifestyle match", "Communication style"
- Preference fit: "Matches your stated physical preferences" (when applicable)
- Shared answers: "You both want kids"

**Actions:**

| Action | Gesture | Button | Result |
|--------|---------|--------|--------|
| Accept | Optional swipe right | ✓ (default) | Offer advances to next item |
| Pass | Optional swipe left | ❌ (default) | Offer enters pass cooldown |
| Not Now | Optional swipe down | ⏸ (default) | Offer enters short cooldown |
| View Profile | Tap card | N/A | Expand to full profile |
| Report | Long press | ⋮ menu | Report flow |

**Gesture Behavior (Optional):**
- Threshold: 100pt horizontal, 50pt vertical
- Velocity-sensitive (fast swipe = quick exit)
- Rubber-band if not past threshold
- Haptic feedback on threshold

### Weekly Anchor Offer

**Purpose:** Present one highest-confidence candidate with richer context
**Differences from regular offer:**
- Pinned at top of queue when available
- Expanded "why this match" explanation by default
- Explicit context tags (shared priorities, intent alignment, lifestyle fit)
- Same actions (Accept / Pass / Not Now)

### Match Created Screen

**Purpose:** Celebrate mutual match, encourage chat
**Elements:**
- Animation: Hearts, confetti
- Title: "It's a match!"
- Subtitle: "You and {name} both said yes"
- Both users' photos (side by side)

**CTAs:**
- Primary: "Send a message" → Chat screen
- Secondary: "Keep browsing" → Back to matches

**Messaging Rule (MVP):**
- Either matched user can send the first message.

**Auto-dismiss:**
- After 10 seconds if no interaction
- Swipe down to dismiss

### Awaiting Response State

**Purpose:** Show pending status
**Visual:**
- Offer dimmed slightly
- Badge: "Waiting for {name}"
- Decision tray remains available (can still change decision)

**Behavior:**
- If user changes to Pass: Remove from waiting
- If other user accepts: Immediate notification
- Expires after 6 days

### Empty States

**No Matches Today:**
- Illustration: Empty calendar
- Title: "No matches today"
- Subtitle: "We couldn't find anyone new in your area. Check back tomorrow!"
- CTA: "Adjust preferences" (optional)

**All Decisions Made:**
- Illustration: Checkmark
- Title: "You're all caught up!"
- Subtitle: "Come back tomorrow for new matches"
- CTA: "Review your matches" → Active matches list

**Non-Matching Mode:**
- Illustration: Lock
- Title: "Complete verification to start matching"
- Subtitle: "Finish verification to receive matches. Complete Visual Preference Studio for full-confidence recommendations."
- CTA: "Continue onboarding"

## Decision States

### Accept

**Immediate:**
- Offer transitions to waiting or next queue item
- Haptic feedback (success)
- Next offer loads with preserved scroll position

**Async Result:**
- If mutual: Push notification + in-app celebration
- If not mutual: Offer shows "Waiting" badge

### Pass

**Immediate:**
- Offer exits active queue
- Haptic feedback (light)
- Next offer loads

**Result:**
- Pass cooldown starts (long cooldown)
- Candidate may resurface once after cooldown if confidence improves enough

### Not Now

**Immediate:**
- Offer exits active queue
- Haptic feedback (neutral)
- Next offer loads

**Result:**
- Soft close (can rematch after cooldown)
- User may see again in future batches

## Notifications

### Push Notifications

| Trigger | Message | Action |
|---------|---------|--------|
| Daily matches ready | "Your daily matches are ready" | Open app to matches |
| Weekly anchor ready | "Your anchor match is ready" | Open app to anchor offer |
| Mutual match | "You matched with {name}" | Open chat |
| Match accepted you | "{name} said yes to you!" | Open matches |
| Match expiring soon | "{name}'s match expires tomorrow" | Open matches |

### In-App Notifications

- Banner at top (auto-dismiss 5s)
- Badge on Messages tab
- In-match "New match" indicator

## Edge Cases

### Network Issues

| Scenario | Behavior |
|----------|----------|
| Decision fails to send | Show "Retry" button on offer |
| Slow connection | Optimistic UI, sync in background |
| Offline | Queue decisions, process when online |

### Expired Offers

- Offer shows "Expired" badge
- Dismiss via action button or swipe
- No action possible

### Blocked/Muted Users

- Don't show in matches
- If already matched: Show "Unavailable"

### Account Suspension

- Show suspension modal
- Block all matching actions
- Appeal CTA

## Accessibility

### Screen Reader

- Offer: "{Name}, {Age}, {Compatibility}% match. Why this match: {summary}. Use Accept, Pass, or Not Now."
- Buttons: Clear labels ("Accept Sarah", "Pass on Sarah")
- Focus: Decision tray and explanation panel are both keyboard/screen-reader reachable

### Motor Impairments

- Buttons always available (not just gestures)
- Large touch targets (44x44pt min)
- No time-limited actions

### Cognitive

- Clear action labels
- No ambiguous icons alone
- Undo available (within 5 seconds)
- Progress indicator shows remaining decisions for today

## Analytics Events

| Event | Trigger |
|-------|---------|
| matches_viewed | Screen appears |
| match_offer_viewed | Offer becomes active |
| match_anchor_viewed | Weekly anchor offer opened |
| match_explanation_opened | Why-match panel expanded |
| match_accepted | Swipe right / tap accept |
| match_passed | Swipe left / tap pass |
| match_not_now | Swipe down / tap not now |
| match_mutual | Both accept |
| match_expired | Offer expires |
| match_profile_expanded | Tap card |
| match_photo_viewed | Swipe photo |
| match_reported | Report flow started |
| match_decision_completed | Any decision action succeeds |

## Success Metrics

- Daily match open rate: > 70%
- Weekly anchor open rate: > 80%
- Accept rate: > 20%
- Mutual match rate: > 5%
- Median decisions per user/day: <= 3
- Decision completion within 24h: > 80%
- Time per decision: < 20 seconds (deliberate, low-fatigue target)
- Report rate: < 2%
