# Feature Specification: Matching

Owner: Product + Engineering  
Status: Active
Last Updated: 2026-02-20  
Depends On: `docs/ux/flows/matching.md`, `docs/technical/contracts/openapi.yaml`, `docs/technical/decisions/ADR-0004-matchmaking-idempotency.md`, `docs/specs/matching-scoring-engine.md`, `docs/specs/visual-preference-studio.md`, `docs/specs/gender-responsive-matching.md`

## Overview

The matching feature generates daily curated offers plus a weekly anchor offer using integrated profiling signals (psychological compatibility + visual preference affinity) and authenticity confidence signals. It is designed around intentional decisions (not endless swipe loops) and manages the mutual acceptance flow that creates matches.

## Scope Clarification

Aligned with `docs/execution/phases/intent-phase-canonical-map.md`:
- Matching is inclusive and preference-driven; no heterosexual-only lock in core logic.
- Active queue limits are behavior/risk/policy based only; no gender-based caps.
- Attractiveness-band hard filters are not an MVP rule; visual preference affinity is a secondary ranking signal.

## User Stories

### US-001: Daily + Anchor Match Offers

**As a** user  
**I want to** receive curated offers on a predictable cadence
**So that** I can find compatible people without endless swiping

**Acceptance Criteria:**
- [ ] System generates offers once per day at 9 AM local time
- [ ] System generates one weekly anchor offer on a configurable weekly schedule
- [ ] Offers are personalized using integrated profiling signals
- [ ] User receives 1-5 offers per day (based on pool size)
- [ ] Weekly anchor offer is the highest-confidence currently eligible candidate
- [ ] Offers expire after 6 days if no action
- [ ] User can view offer details (photos, bio, compatibility)
- [ ] User sees compatibility score and themes
- [ ] User sees shared questionnaire answers
- [ ] User sees "why this match" rationale and authenticity indicators
- [ ] Full-confidence offers use both psychological and visual preference signals

**API Contract:** `GET /matches/offers`

### US-002: Accept Match

**As a** user  
**I want to** accept a match offer  
**So that** I can express interest in someone

**Acceptance Criteria:**
- [ ] User can accept via button tap (default) or swipe right (optional)
- [ ] Acceptance recorded immediately (optimistic UI)
- [ ] If other user already accepted: mutual match created
- [ ] If not: offer shows "waiting" state
- [ ] User notified when mutual match occurs
- [ ] Acceptance is idempotent (duplicate = no-op)
- [ ] If mutual match is created, optional AI opening moves are prepared

**API Contract:** `POST /matches/offers/{offerId}/action` (action: accept)

### US-003: Pass Match

**As a** user  
**I want to** pass on a match offer  
**So that** I only match with people I'm interested in

**Acceptance Criteria:**
- [ ] User can pass via button tap (default) or swipe left (optional)
- [ ] Pass recorded immediately
- [ ] Pass enters cooldown period before re-offer eligibility
- [ ] Candidate can be resurfaced at most once after cooldown when confidence uplift threshold is met
- [ ] Resurfacing blocked if either user reported/blocked the other
- [ ] Pass is idempotent (duplicate = no-op)
- [ ] No notification sent to other user

**API Contract:** `POST /matches/offers/{offerId}/action` (action: pass)

### US-004: Not Now

**As a** user  
**I want to** defer a decision  
**So that** I can decide later

**Acceptance Criteria:**
- [ ] User can select "Not Now" via button tap (default) or swipe down (optional)
- [ ] Offer soft-closed (can reappear later)
- [ ] 30-day cooldown before re-offer
- [ ] User can still accept if other user accepts first
- [ ] Not Now is idempotent (duplicate = no-op)

**API Contract:** `POST /matches/offers/{offerId}/action` (action: not_now)

### US-005: Review-First Decision Mode

**As a** user
**I want to** make decisions in a deliberate review flow
**So that** matching feels less exhausting than swipe-heavy apps

**Acceptance Criteria:**
- [ ] Offer review defaults to a buttons-first decision tray
- [ ] Swipe gestures are optional, not required
- [ ] Decision flow highlights one offer at a time to reduce choice overload
- [ ] Offer explanation panel is visible before decision actions
- [ ] Accessibility supports full interaction without gestures

**API Contract:** `GET /matches/offers` (review metadata), `POST /matches/offers/{offerId}/action`

### US-006: Mutual Match

**As a** user  
**I want to** know when we both accept  
**So that** we can start chatting

**Acceptance Criteria:**
- [ ] When both users accept, match created
- [ ] Both users receive notification
- [ ] In-app celebration shown
- [ ] Match appears in messages list
- [ ] Chat enabled immediately
- [ ] Either matched user can send the first message (MVP policy)
- [ ] Optional AI opening moves shown at chat entry
- [ ] Match record stored with timestamp

**API Contract:** WebSocket event `match_offer_mutual`

### US-007: View Active Matches

**As a** user  
**I want to** see my active matches  
**So that** I can manage my conversations

**Acceptance Criteria:**
- [ ] User can view list of active matches
- [ ] Matches sorted by recent activity
- [ ] Each match shows other user's photo and name
- [ ] Unread message count displayed
- [ ] User can tap to enter chat
- [ ] List updates in real-time

**API Contract:** `GET /matches`

### US-008: Unmatch

**As a** user  
**I want to** unmatch with someone  
**So that** I can end the connection

**Acceptance Criteria:**
- [ ] User can unmatch from chat or match list
- [ ] Confirmation required with reason (optional)
- [ ] Chat closed for both users
- [ ] Match removed from both users' lists
- [ ] Users won't be matched again
- [ ] Unmatch is idempotent

**API Contract:** `POST /matches/{matchId}/unmatch`

### US-009: Balanced Marketplace Experience

**As a** user
**I want** my matching experience to adapt to my actual app context
**So that** I avoid overload, low-quality loops, and unsafe interactions

**Acceptance Criteria:**
- [ ] Offer pacing adapts by behavioral segment (not by hardcoded gender rules)
- [ ] High-inbound users get stricter quality filtering and bounded active queue
- [ ] Low-inbound users get higher reciprocal-likelihood filtering and profile-improvement prompts
- [ ] Self-described gender is used for monitoring and fairness checks, not direct score boosts/penalties
- [ ] Cohort metrics are tracked for women, men, and other gender identities where sample size supports reliable reporting

**API Contract:** Internal policy layer only (no external contract change required)

## Technical Requirements

### Matchmaking Algorithm

**Eligibility Criteria:**
- Both users verified
- Both users 18+
- Geographic compatibility (same city/region)
- Relationship intent compatibility
- Child-goal compatibility when either user marks it as a hard requirement
- Not blocked
- Not in unmatch exclusion set

**Scoring:**
- Psychological compatibility score from questionnaire (0-100)
- Visual preference affinity score from VPS reciprocal affinity (0-100)
- Authenticity confidence score (0-100) from verification freshness + profile consistency + abuse-risk signals
- Composite ranking score follows `docs/specs/matching-scoring-engine.md`:
  - `questionnaire_total = 0.80 * psychological + 0.20 * visual`
  - `base_score = 0.85 * questionnaire_total + 0.15 * authenticity`
- Hard filters applied first
- Rank by composite score
- Limit: 2 active matches per user (beta)

**Dual-Signal Requirement:**
- Full-confidence ranking requires both users to have:
  - sufficient questionnaire completion
  - VPS profile status `ready`
- If either signal is missing, only provisional offers are allowed (limited count/score cap) until completion.

**Batch Generation:**
- Runs daily at 9 AM per timezone
- Runs weekly anchor offer generation on configured day/time per timezone
- Idempotent: same user/day = same daily offers
- Idempotent: same user/week = same anchor offer
- Parallel processing by user shard
- Job tracking for observability

**Decision Rules:**
- Review-first mode is default; swipe gestures are optional
- Pass cooldown default is 90 days
- Pass resurfacing is capped to one re-offer per pair and requires confidence uplift
- Not Now cooldown default is 30 days

### Gender-Responsive Marketplace Policy

The system should support differences in dating-app behavior patterns across women and men without using stereotype-based hardcoding. Policy must be behavior-responsive and cohort-audited as defined in `docs/specs/gender-responsive-matching.md`.

Core rules:
- Use observed context signals (inbound volume, reply likelihood, safety risk) to adapt pacing and ranking controls.
- Never apply direct score multipliers from `gender_identity`.
- Apply stronger overload and safety controls when users face high inbound pressure.
- Apply stronger reciprocal-likelihood filtering and coaching prompts when users face persistent low inbound outcomes.
- Keep all controls policy-reviewable and configurable.

### Performance

- Offer generation: < 5 minutes per 1000 users
- Anchor generation: < 2 minutes per 1000 users
- API response: < 200ms for offer list
- Real-time notification: < 1 second

### State Machine

```
[Eligible] ──► [OfferedDaily/OfferedAnchor] ──► [AcceptedByUserA]
    ▲                     │                            │
    │                     │                            ▼
    │                     │                      [ActiveMatch] (if mutual)
    │                     │                            │
    │                     ├──► [SoftClosed] (Not Now) │
    │                     │       │                    │
    │                     │       └──► [Eligible] ◄────┘
    │                     │            (cooldown)
    │                     │
    │                     ├──► [PassCooldown]
    │                     │       │
    │                     │       └──► [EligibleOnce] (one optional re-offer)
    │                     │
    │                     └──► [HardClosed] (block/report/unmatch)
    │
    └──────────────────────────────────────────────────────────────
```

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| User deletes account | All offers closed, matches ended |
| User blocks other | Offer removed, no future offers |
| User suspends | Offers paused, resumed on reactivation |
| Geographic change | New location used for next batch |
| Questionnaire updated | New answers used for next batch |
| Algorithm version change | New version used for next batch |
| Anchor candidate unavailable | Fallback to best eligible daily candidate |
| Pass cooldown elapsed | Candidate eligible for one resurfacing if uplift threshold met |

## Analytics

Track:
- Offers generated per day
- Anchor offers generated per week
- Accept/pass/not-now rates
- Mutual match rate
- Time to mutual match
- Match-to-chat conversion
- First message within 24 hours
- Median decisions per user/day
- Decision completion within 24 hours
- Offer explanation open rate
- Unmatch rate and reasons
- Too-few-message indicator rate by cohort
- Too-many-message indicator rate by cohort
- Unwanted sexual content report rate by cohort
- First-reply rate within 24 hours by cohort
- Exposure and acceptance parity by behavioral segment

## Dependencies

- PostgreSQL (offer storage)
- Redis (caching, rate limiting)
- WebSocket gateway (real-time notifications)
- Push notification service
- Cron/job scheduler

## Resolved Questions

| Question | Decision | Config Key |
|----------|----------|------------|
| Offers cadence | 3 daily (configurable) + 1 weekly anchor | `MATCHES_PER_DAY_DEFAULT`, `ANCHOR_MATCHES_PER_WEEK` |
| Show "why matched" | Yes - themes, shared answers, authenticity indicators | `SHOW_MATCH_EXPLANATION` |
| Rematch after passing | One resurfacing after cooldown + uplift threshold | `PASS_RECONSIDERATION_ENABLED`, `PASS_COOLDOWN_DAYS`, `PASS_REOFFER_UPLIFT_THRESHOLD` |
| Not Now cooldown | 30 days | `MATCH_OFFER_COOLDOWN_DAYS` |
| Decision interaction mode | Review-first with optional swipe gestures | `MATCH_DECISION_MODE` |
| First message rule | Free-for-all in MVP with optional AI opening moves | `CHAT_FIRST_MESSAGE_POLICY`, `AI_OPENING_MOVES_ENABLED` |
| Gender handling in matching | Behavior-responsive policy with cohort auditing, no direct gender weights | `MATCH_GENDER_RESPONSIVE_MODE` |

> See `docs/ops/configuration.md` for all configurable parameters.
