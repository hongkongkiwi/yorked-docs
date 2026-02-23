# Yoked: Competitive Landscape Addendum

Owner: Product + Strategy
Status: Active
Last Updated: 2026-02-20
Depends On: `docs/vision/product-vision.md`

## Purpose

Capture the expanded benchmark set requested by product planning and convert market patterns into actionable Yoked product decisions.

## Scope: Expanded Benchmark Set

### Mainstream Dating Apps

| App | Primary Interaction Model | What To Borrow | What To Avoid |
|-----|---------------------------|----------------|---------------|
| Hinge | Prompt-driven profiles and thoughtful likes | Rich context before liking; stronger profile prompts | Reintroducing high-volume browsing loops |
| Grindr | Proximity-first grid and fast chat | Efficient local discovery controls for users who value immediacy | Pure proximity ranking overpowering compatibility |
| eharmony | Long-form compatibility framing | Serious-intent onboarding and expectation setting | Excessive onboarding friction without clear payoff |
| Match.com | Search-oriented, profile depth, mature demographic | Better controls for older demographics and intent filters | Complex UI that increases cognitive load |
| Coffee Meets Bagel | Limited daily "bagels" | Daily scarcity and intentional review cadence | Too little flexibility when pool depth is low |
| Raya | Membership curation and social proof positioning | Strong trust framing and community norms | Exclusivity gates that conflict with inclusive positioning |
| Happn | Crossed-paths location model | Optional serendipity layer with clear consent and privacy controls | Over-reliance on constant location for core ranking |
| Tantan | Swipe-forward social discovery, young audience scale | Lightweight onboarding and fast first interactions | Engagement loops that optimize session time over outcomes |
| Heymandi | Text-first and anonymous pre-match conversation | Low-pressure icebreaker phase for hesitant users | Anonymous channels without strict abuse and identity controls |

### Specialized and Niche Dating Apps

| App | Segment Signal | What To Borrow For Yoked |
|-----|----------------|--------------------------|
| Lunch Actually | Busy professionals, assisted matching | Concierge-style scheduling and date readiness workflows |
| SweetRing | Marriage-oriented intent | Explicit intent tiers and long-term compatibility framing |
| AsianDating | Community-specific preference support | Better cultural/language preference controls and localization |
| Grindr (segment view) | LGBTQ+ focused product depth | Segment-specific UX tuning without fragmenting core safety model |

### Friendship and Adjacent Social Apps

| App | Core Pattern | Potential Yoked Use |
|-----|--------------|---------------------|
| BeFriend | Teen/Gen Z friend discovery | Optional social warm-up layer for younger cohorts (safety-gated) |
| Bumble BFF | Swipe-based friendship matching | Friend confidence loops and wingperson mechanics |
| Friendchise | Local meetup-style friend matching | Local activity prompts and small-group first interactions |
| Timeleft | Group dinners with curated seating | Group date or double-date onboarding for lower-pressure first meetups |
| Slowly | Slower, letter-style asynchronous messaging | Pace controls to reduce chat burnout and ghosting |
| Wyzr | 40+ friendship positioning | Age-specific onboarding tone and UX variants |

## Product Decisions From This Landscape

The competitive review reinforced a clear pattern: products that reduce cognitive load and increase trust create better relationship outcomes than products that maximize sessions.

### Psychological Evidence Base (Integration Principles)

These principles translate that pattern into the matching model and user experience.

- Value alignment and long-term intent compatibility are weighted above novelty/recency.
- Communication-style compatibility is treated as a first-class matching signal.
- Progressive self-disclosure is encouraged through guided prompts and low-pressure starters.
- Decision load is intentionally constrained to reduce fatigue and improve judgment quality.
- Safety and authenticity trust signals are integrated into ranking and UX, not treated as separate add-ons.

### Keep and Strengthen (already in Yoked v2)

These are already aligned with the direction and should stay central to MVP execution.

- Daily curation with limited decisions
- Weekly anchor match with richer "why this match" explanation
- Review-first decision UX with optional swipe gestures
- AI opening moves to reduce blank-screen chat starts
- Share-date safety flow and trust tooling

### Integrate as Evidence-Based Methods

These are strong follow-on candidates once MVP learning confirms demand and safety readiness.

1. Optional serendipity mode (Happn-style crossed-path signal) with explicit opt-in and strict privacy boundaries.
2. Low-pressure pre-match text icebreakers (Heymandi-inspired) with identity linkage, abuse detection, and rate limits.
3. Friend-assisted confidence flows (Bumble BFF/Friendship adjacency) without granting message access.
4. Group-first social entries (Timeleft-style dinners or double-date structures) as an anxiety-reduction method.
5. Age-aware onboarding variants (inspired by Match.com and Wyzr insights) for 40+ cohorts.
6. Slower conversation mode (Slowly-inspired pacing controls) to improve response quality and reduce burnout.

### Guardrails

- No anonymous mode without robust moderation, abuse prevention, and verified identity binding.
- No location-first ranking without consent transparency and easy user controls.
- No exclusivity or elitist admissions model.
- No engagement KPI optimization that degrades match-to-date outcomes.

## Roadmap Impact (Planning Input)

- MVP: no scope expansion beyond current v2 commitments.
- Post-MVP: prioritize opt-in serendipity and friend-assisted confidence methods.
- Growth stage: evaluate cohort-specific tracks (40+ and language/culture-aware flows).

## Notes

- Happn appears in both mainstream and specialized lists in planning inputs; treated as mainstream with optional niche implications.
- The TechCrunch friendship roundup used for this pass is dated 2025-12-26.
- Some newer apps (for example Heymandi and Friendchise) have less mature public documentation; assumptions should be validated with user research interviews before implementation commitment.
