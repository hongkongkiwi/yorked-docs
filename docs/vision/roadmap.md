# Product Roadmap

Owner: Product
Status: Active
Last Updated: 2026-02-23
Depends On: `docs/vision/product-vision.md`, `docs/execution/epic-plans/intent-phase-canonical-map.md`

## Overview

This roadmap separates **MVP (beta-ready)** scope from **post-MVP expansion** so launch criteria stay clear.

- **MVP scope:** Weeks 1-24 (build and launch a safe, working core product)
- **Post-MVP scope:** Weeks 25+ (expand advanced matching intelligence and Photo Studio vision)

Planning note: while in brainstorming mode, roadmap details are working assumptions unless marked as committed MVP gate requirements.

## Stage Shipping Principle

Each MVP phase is designed to produce a shippable app increment for an intended audience slice (internal, limited beta, or broader beta), not just intermediate technical output.

## Canonical Scope Rule

When older ideation docs conflict with this roadmap, use:
1. `docs/execution/epic-plans/intent-phase-canonical-map.md` for intent and phase mapping.
2. `docs/specs/*` for feature-level acceptance criteria.
3. `docs/technical/contracts/*` + `docs/technical/decisions/*` for final technical authority.

## V2 Product Focus (Fatigue + Authenticity)

V2 focuses on one user outcome: people should feel more certain and less drained after opening the app.

- Reduce decision load: fewer, more intentional match decisions per day so users can decide quickly and move on with their day.
- Increase authenticity confidence: stronger trust signals in ranking and UX so people feel safer engaging.
- Use evidence-based psychological matching methods as the ranking foundation so compatibility is explainable, not opaque.
- Improve match-to-chat conversion: better first-message starts with AI assist so conversations begin with less friction.
- Improve match-to-date conversion: trust and safety support for offline transition so good chats more often become real plans.

---

## MVP Phase 1: Identity & Core Platform

**Timeline:** Weeks 1-4
**Goal:** Core app infrastructure and onboarding basics

| Feature | Description |
|---------|-------------|
| Phone Auth | OTP via Supabase |
| Basic Profile | Name, bio, photos, location, age |
| Photo Upload | Secure upload and moderation-ready pipeline |
| Compatibility Questions v1 | Initial 15-question set |
| Mobile App Shell | Navigation, session handling, analytics baseline |

**Success Metrics:**
- Users can authenticate and complete profile setup
- Team can run full stack locally
- Core onboarding events tracked end-to-end

**Ship Criteria:**
- Primary phase flow works end-to-end in staging.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Release can be safely rolled out to the intended audience slice.

---

## MVP Phase 2: Onboarding & Verification Journey

**Timeline:** Weeks 5-8
**Goal:** Trust and completion quality at signup

| Feature | Description |
|---------|-------------|
| Photo Verification | AWS Rekognition liveness detection |
| Age Gate | Compliance/safety age check with policy controls and fallback review |
| Anti-Bot | Device fingerprinting, OTP throttling, abuse limits |
| Enhanced Questionnaire | Expand to 25 questions |
| Importance Weighting | Rate importance of each answer |
| Physical Preference Profiling | Lightweight user-stated preference prompts in same profiling flow |
| Skip Rules | Allow non-required questions to be skipped |

**Guardrails:**
- Age checks are used for legal/safety gating, not attractiveness scoring.
- High-risk or uncertain age outcomes route to manual review.

**Success Metrics:**
- >90% verification completion rate
- Reduced fake-account indicators
- Onboarding completion <10 minutes median

**Ship Criteria:**
- Onboarding and verification journey works end-to-end in staging.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Release can be safely rolled out to the intended audience slice.

---

## MVP Phase 3: Curated Matching Experience

**Timeline:** Weeks 9-12
**Goal:** Deliver low-fatigue daily decisions with higher-confidence matches

| Feature | Description |
|---------|-------------|
| Daily Match Batch | Idempotent generation at 9 AM local time (1-5 offers) |
| Weekly Anchor Match | One highest-confidence offer per week with richer explanation |
| Composite Scoring | Psychological compatibility + physical preference affinity + authenticity confidence |
| Match Explanation | "Why this match" themes + shared-answer evidence |
| Decision UX (Review-First) | Buttons-first decisions by default; swipe remains optional |
| Offer Actions | Accept / Pass / Not Now with pass reconsideration cooldown |
| Match Notifications | Push delivery for daily and anchor offers |

**Success Metrics:**
- Zero duplicate offers
- Match generation <5 minutes per 1,000 users
- Median decisions per user/day <=3
- 24-hour decision completion rate >80%
- Mutual match rate trending upward week-over-week

**Ship Criteria:**
- Offer generation, decision actions, and match creation work end-to-end in staging.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Release can be safely rolled out to the intended audience slice.

---

## MVP Phase 4: Real-Time Messaging Experience

**Timeline:** Weeks 13-16
**Goal:** Real-time messaging between mutual matches

| Feature | Description |
|---------|-------------|
| WebSocket Messaging | Socket.io chat events with delivery acks |
| Chat UX | Message threads, timestamps, pagination |
| Read Receipts + Typing | Real-time engagement indicators |
| Push for Messages | Notifications when app is backgrounded |
| AI Opening Moves | Optional suggested first messages from shared context |
| First Message Policy | Free-for-all (either user can message first) |

**Success Metrics:**
- p95 delivery latency <100ms
- Message delivery reliability >99.5%
- Messages per match >5 average
- First message sent within 24h >45%

**Ship Criteria:**
- Send/receive/reconnect messaging flows work end-to-end in staging.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Release can be safely rolled out to the intended audience slice.

---

## MVP Phase 5: Trust & Safety Experience

**Timeline:** Weeks 17-20
**Goal:** Operational trust and safety readiness

| Feature | Description |
|---------|-------------|
| Report / Block / Unmatch | User safety controls |
| Moderation Pipeline | AI pre-screen + human queue |
| Incident Workflows | Severity tiers and escalation paths |
| Evidence Retention | Policy-compliant storage and retention windows |
| CSAM Controls | Detection and emergency response path |
| Share Date Plan | In-app date plan sharing with trusted contacts |
| Authenticity Re-Checks | Risk-triggered liveness re-checks and profile consistency flags |

**Success Metrics:**
- Critical reports acknowledged <15 minutes
- False positive rate <5% for automated moderation
- Safety runbooks tested in staging drills
- Safety tool usage increases without retention drop

**Ship Criteria:**
- Report/block/moderation/escalation flows work end-to-end in staging.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Release can be safely rolled out to the intended audience slice.

---

## MVP Phase 6: Reliability & Launch Experience

**Timeline:** Weeks 21-24
**Goal:** Production readiness and controlled beta launch

| Feature | Description |
|---------|-------------|
| Reliability Hardening | Performance, retries, failure handling |
| Monitoring + Alerting | RED metrics, Sentry, on-call setup |
| QA + Release Gates | E2E coverage on critical paths |
| Friend Assist Beta (Optional) | Trusted-friend feedback on candidate profiles (private, read-only), only if MVP gates are already green |
| Fatigue + Authenticity Dashboards | Decision load, response latency, confidence metrics |
| App Store Readiness | Submission, review, rollout checklist |

**Success Metrics:**
- App store approval achieved
- Load test to 10K concurrent users
- All P0 launch blockers closed
- Fatigue and authenticity metrics baselined for GA decisions

**Ship Criteria:**
- Release candidate passes reliability, policy, and app-store readiness checks.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Release can be safely rolled out to the intended audience slice.

---

## Post-MVP Expansion (V1+)

Post-MVP work is prioritized by beta learning and can be shipped incrementally.

### Expansion A: Attraction Signal Foundations (indicative Weeks 25-28)

- Face measurement capture (Photo Studio Lite)
- Preference capture from controlled synthetic sets
- Vector storage and privacy controls
- Cross-language conversation assist methods for match comprehension

### Expansion B: Enhanced Matching (indicative Weeks 29-32)

- Dual-score matching (compatibility + attraction)
- Conditional questionnaire branching
- Admin question editor
- Active match limits based on engagement/risk signals (no gender-specific caps)
- Adaptive cadence tuning (daily offer count + anchor-match frequency)

### Expansion C: Advanced AI Assist + Photo Studio 2.0 (indicative Weeks 33-36+)

- Deeper conversation coach and date-planning assistant
- Unmatch comfort support flows
- Advanced preference learning and face-generation methods
- Controlled rollout with fairness/privacy reviews before broad release

---

## Phase Summary

| Stage | Duration | Cumulative | Outcome |
|-------|----------|:----------:|---------|
| MVP Phase 1 | 4 weeks | 4 weeks | Identity and platform baseline |
| MVP Phase 2 | 4 weeks | 8 weeks | Verified onboarding journey |
| MVP Phase 3 | 4 weeks | 12 weeks | Curated matching experience |
| MVP Phase 4 | 4 weeks | 16 weeks | Real-time messaging experience |
| MVP Phase 5 | 4 weeks | 20 weeks | Trust and safety experience |
| MVP Phase 6 | 4 weeks | 24 weeks | Reliability and launch readiness |
| Post-MVP Expansion | 12+ weeks | 36+ weeks | Full product vision |

---

## Flexible Pacing

Can ship at multiple quality gates:
- **Week 12** -> Matching MVP (no chat)
- **Week 16** -> Social MVP (matching + chat + AI opening moves)
- **Week 24** -> Beta-ready MVP (matching + chat + safety ops + trust transition tooling)
- **Week 36+** -> Expanded V1 capabilities

---

## Related Documents

- `docs/vision/product-vision.md` - Overall vision and business model
- `docs/execution/epic-plans/intent-phase-canonical-map.md` - Canonical intent and Now/Next/Later mapping from V3/V4 PDFs
- `docs/execution/delivery-checklist.md` - DRI ownership, phase exit criteria, and go/no-go checklist
- `docs/vision/competitive.md` - Expanded competitive and adjacency benchmark set
- `docs/execution/epic-plans/implementation-plan.md` - Technical implementation details
- `docs/specs/*.md` - Feature specifications
