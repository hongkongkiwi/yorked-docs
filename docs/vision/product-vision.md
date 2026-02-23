# Yoked: Overall Idea Plan

Owner: Product + Engineering
Status: Active
Last Updated: 2026-02-23
Depends On: `docs/vision/roadmap.md`, `docs/execution/epic-plans/intent-phase-canonical-map.md`

## MVP Phased Approach

See `docs/vision/roadmap.md` for full phase details.
Use `docs/execution/epic-plans/intent-phase-canonical-map.md` as the interpretation layer when legacy idea docs differ from current MVP scope.
Use `docs/execution/delivery-checklist.md` as the source for per-phase owners and exit gates.

| Phase | Timeline | Key Features |
|-------|----------|--------------|
| **MVP Phase 1** | Weeks 1-4 | Identity & core platform (auth, profile, onboarding baseline) |
| **MVP Phase 2** | Weeks 5-8 | Onboarding & verification journey |
| **MVP Phase 3** | Weeks 9-12 | Curated matching experience |
| **MVP Phase 4** | Weeks 13-16 | Real-time messaging experience |
| **MVP Phase 5** | Weeks 17-20 | Trust & safety experience |
| **MVP Phase 6** | Weeks 21-24 | Reliability & launch experience |

**MVP (beta-ready):** ~6 months (24 weeks).
**Full vision (post-MVP expansions):** ~9+ months.

---

## Vision

Yoked is an AI-first dating app designed for people who are tired of spending energy on low-quality swiping loops. The product bet is simple: meaningful connections come from better curation and clearer compatibility, not from endless volume.

## Problem Statement

Most users do not open a dating app because they want another "session." They open it because they want to meet someone real. Instead, many end up spending 30-60 minutes making shallow decisions, then leave feeling less confident than when they started.

**What current dating apps often optimize for:**
- **Swipe fatigue**: Users burn out from endless swiping with low match rates
- **Paradox of choice**: Too many options lead to decision paralysis
- **Low-quality matches**: Algorithms prioritize engagement over compatibility
- **Trust issues**: Catfishing, fake profiles, and safety concerns
- **Conversation decay**: Matches rarely lead to meaningful conversations

**What users keep telling us:**
1. "I spend an hour swiping and get maybe 2 matches"
2. "I match with people but we have nothing in common"
3. "I'm tired of fake profiles and catfishers"
4. "Conversations go nowhere - just small talk"
5. "Dating apps feel like a game, not a way to meet someone"

## Solution

Yoked is built to reduce that drain and raise confidence in each decision. We do that by narrowing daily choice, improving match quality, and making trust signals visible early.

**Yoked's approach:**

1. **Curated Daily Matches**: 1-5 highly compatible matches delivered at 9 AM daily
2. **Integrated Profiling**: One profiling flow captures psychological compatibility signals and user-stated physical preferences
3. **Photo Verification**: AI-powered liveness detection ensures users are real
4. **Quality Over Quantity**: Limited daily matches encourage thoughtful decisions
5. **AI-Assisted Chat**: Future feature to help conversation flow naturally

**Key Differentiators:**

| Feature | Yoked | Tinder/Bumble | Hinge |
|---------|-------|---------------|-------|
| Daily matches | 3 curated (configurable) | Unlimited swiping | ~10-15 likes/day |
| Matching model | Psych + physical preference model | Location + photos | Social graph + prompts |
| Verification | AI liveness required | Optional photo verify | Optional photo verify |
| Time investment | 5-10 min/day | 30+ min/day | 15-20 min/day |
| Focus | Quality connections | Volume/engagement | Relationship-oriented |

## Target Market

**Primary Audience:**
- Age: 25-35
- Location: Urban/suburban areas
- Relationship goal: Serious dating leading to relationships
- Tech comfort: High (smartphone-native)
- Pain point: Burned out on existing dating apps

**Initial Launch Markets:**
1. **Wave 1 (Closed Beta, Month 6)**: San Francisco Bay Area
   - Tech-savvy early adopters
   - High dating app usage
   - Dense population

2. **Wave 2 (Public Launch, Month 10)**: Los Angeles, New York, Austin
   - Expand to major metros
   - Similar demographics

3. **Wave 3 (Post-MVP Scale-out)**: Top 20 US metros
   - National expansion

**Market Size:**
- US dating app market: ~$2.5B (2025)
- Target demographic: ~15M users
- Serviceable obtainable market (SOM): 500K users Year 1

## Business Model

**MVP (Beta - Free):**
- Completely free during beta and MVP
- Goal: Learn, iterate, build word-of-mouth
- Duration: Until product-market fit achieved
- All features available to all users

**Post-MVP Monetization (Future):**

| Tier | Price | Features |
|------|-------|----------|
| Free | $0 | 3 matches/day, basic filters |
| Premium | $19.99/mo | Unlimited matches, see who liked you, priority matching |
| Premium+ | $29.99/mo | All Premium + AI conversation coach, video dates, profile boost |

> **Note:** Monetization is post-MVP. All pricing is configurable. See `docs/ops/configuration.md`.

**Additional Revenue Streams (Future):**
- In-app gifts/experiences
- Date planning partnerships
- Premium verification (background checks)

## Success Metrics

**MVP Success Criteria (Beta):**

| Metric | Target | Measurement |
|--------|--------|-------------|
| Onboarding completion | > 60% | Phone → First match viewed |
| Daily active users (DAU) | 600 | By month 6 (beta cohort) |
| Registered beta users | 5,000 | By month 7 |
| Retention (Day 7) | > 40% | Users returning after 7 days |
| Retention (Day 30) | > 25% | Users returning after 30 days |
| Mutual match rate | > 15% | Both users accept |
| Messages per match | > 5 | Average conversation length |
| Photo verification rate | > 90% | Users completing verification |
| NPS | > 40 | User satisfaction |

**Post-MVP Metrics:**

| Metric | Year 1 Target |
|--------|---------------|
| Monthly active users (MAU) | 100,000 |
| Retention (Day 30) | > 25% |
| NPS | > 40 |
| Mutual match rate | > 20% |

> Revenue targets apply post-MVP when monetization is enabled.

## Competitive Positioning

**Direct Competitors (expanded set):**
1. **Hinge**, **Bumble**, **Tinder** - large-scale mainstream dating behavior benchmarks
2. **Grindr**, **eharmony**, **Match.com**, **Coffee Meets Bagel**, **Happn**, **Tantan**, **Raya** - model variants across intent, cadence, and discovery mechanics
3. **Heymandi** - emerging text-first/anonymous interaction pattern to study with safety caveats

**Specialized/Niche Benchmarks:**
- **Lunch Actually** (assisted/professional matchmaking)
- **SweetRing** (serious dating/marriage framing)
- **AsianDating** (community-focused matching)

**Friendship/Adjacency Benchmarks:**
- **BeFriend**, **Bumble BFF**, **Friendchise**, **Timeleft**, **Slowly**, **Wyzr**
- Used for lower-pressure social design ideas, not as direct dating substitutes

**Primary Differentiation Direction:**
- Yoked optimizes for **low decision load + high-confidence authenticity + compatibility clarity**, not endless feed engagement.
- Matching methods are grounded in validated psychological research and relationship-outcome evidence.

See `docs/vision/competitive.md` for the detailed landscape and product implications.

**Positioning Statement:**
> For relationship-minded singles tired of swiping, Yoked is the dating app that delivers curated, compatible matches daily so you can spend less time searching and more time connecting.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Low user acquisition | Medium | High | Strong launch marketing, referral incentives |
| Poor match quality | Medium | High | Iterate algorithm, user feedback loops |
| Safety incidents | Low | Critical | Robust T&S, verification, escalation procedures |
| Technical scaling issues | Medium | Medium | Cloud-native architecture, load testing |
| User churn post-beta | High | High | Build habit loops, premium features worth paying for |
| Competition copies features | High | Medium | Build brand, community, continuous innovation |

## Timeline

### Phase 1: MVP Build + Beta Readiness (Months 1-6)
- Month 1: Identity & core platform (infra, auth, profile)
- Month 2: Onboarding & verification journey
- Month 3: Curated matching experience
- Month 4: Real-time messaging experience
- Month 5: Trust & safety experience
- Month 6: Reliability & launch experience + closed beta launch (1,000 users)

### Phase 2: Beta Expansion (Months 7-8)
- Month 7: Expand closed beta to 5,000 users
- Month 8: Reliability hardening and scale validation

### Phase 3: Public Launch + Post-MVP Expansion (Months 9-12)
- Month 9: Public launch (free tier)
- Month 10: Expand to LA + NYC + Austin
- Month 11: Start post-MVP feature packs based on beta data
- Month 12: Monetization go/no-go based on PMF metrics

## Team Requirements

**Current Team:**
- 2 Founders (Product + Engineering)
- 1 Mobile Engineer (React Native)
- 1 Backend Engineer

**Hiring Plan:**

| Role | When | Priority |
|------|------|----------|
| Senior Backend Engineer | Month 2 | Critical |
| ML/AI Engineer | Month 3 | High |
| Trust & Safety Lead | Month 4 | High |
| Growth/Marketing Lead | Month 5 | Medium |
| Customer Success | Month 6 | Medium |

## Key Milestones

| Date | Milestone | Success Criteria |
|------|-----------|------------------|
| Month 2 | Alpha internal | Team can onboard + verify |
| Month 4 | Chat complete | Matches can message reliably |
| Month 6 | Closed beta launch | 1,000 users in SF |
| Month 7 | Beta expansion | 5,000 registered users |
| Month 8 | Scale ready | Load tested to 10K concurrent users |
| Month 9 | Public launch | App store launch |
| Month 12 | Growth milestone | PMF metrics sustained; monetization decision made |

## Working Assumptions (Brainstorming)

These are current assumptions used for planning and estimation. They are reversible until promoted through spec/contract updates.

| Topic | Current Assumption | Promotion Trigger |
|-------|--------------------|-------------------|
| Optimal daily matches | 3 per day (configurable) | Beta fatigue and decision-completion metrics support the default |
| Rematch after passing | Disabled in MVP | Re-enable only if resurfacing improves outcomes without safety regressions |
| Video/chat before meeting | Post-MVP | Promote only after text-chat stability and safety baseline are met |
| Premium price point | $19.99/mo placeholder (post-MVP) | PMF and willingness-to-pay validation complete |
| Same-sex matching | Supported day 1 with same core algorithm | Keep unless fairness/safety data requires scoped adjustments |
| Age verification policy | Safety/compliance gate only | Change only if legal policy changes; never as attractiveness input |
| Active match limits | Behavior/risk based and configurable | Keep unless cohort outcomes require policy updates |
| Profiling model | Integrated psych + user-stated physical preferences | Keep unless data shows completion or quality degradation |
| First message rule | Free-for-all in MVP | Change only if conversion/safety metrics justify gating |
| MVP pricing | Free | Revisit after beta metrics and PMF assessment |

> **All business parameters are configurable.** See `docs/ops/configuration.md` for the complete configuration reference.

## Appendix

### User Research Summary

**Interviews conducted:** 25
**Key findings:**
- 80% report "swipe fatigue" on current apps
- 70% would pay for better quality matches
- 90% want photo verification to reduce catfishing
- 60% prefer fewer, better matches over many options

### Competitive Feature Matrix

| Feature | Yoked | Hinge | Bumble | Tinder |
|---------|-------|-------|--------|--------|
| Daily curated matches | Yes | No | No | No |
| Compatibility score | Yes | Partial | No | No |
| Photo verification required | Yes | Optional | Optional | Optional |
| Limited daily matches | Yes | No | Partial | No |
| AI conversation assistance | Future | No | No | No |
| Video profiles | Future | Yes | No | No |
| Group dates | No | No | Yes | No |

---

*This document is a living plan. Update as we learn from beta users and market conditions change.*
