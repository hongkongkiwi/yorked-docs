# Feature Specification: Matching Scoring Engine

Owner: Product + Engineering + Data Science  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/specs/science-backed-relationship-question-bank.md`, `docs/specs/visual-preference-studio.md`, `docs/specs/gender-responsive-matching.md`, `docs/technical/contracts/openapi.yaml`, `docs/technical/schema/database.md`, `docs/ops/configuration.md`

## Overview

This spec defines a comprehensive method to turn questionnaire responses into ranked match offers.

The engine is intentionally hybrid:
- Hard-constraint gating (must be compatible)
- Science-backed compatibility scoring (questionnaire constructs)
- Explicit visual preference scoring from user-chosen photo comparisons
- Deterministic quality ranking
- Diversity-aware reranking (avoid near-duplicate offers)

## Goals

- Improve mutual match and healthy-conversation rates.
- Preserve user agency through transparent rationale.
- Reduce bad matches by enforcing hard incompatibilities early.
- Keep the model anchored to psychological research and explicit policy.

## Non-Goals

- This spec does not define UI copy.
- This spec does not replace trust/safety policy rules.
- This spec does not require immediate contract changes; fields can be phased.

## Inputs

### User Profile Inputs

- Age, location, relationship intent, relationship structure openness, child preference.
- Verification/authenticity signals.
- Safety state (block/report/unmatch exclusion sets).
- Self-described gender identity for fairness monitoring/auditing only (never direct score boosts/penalties).

### Questionnaire Inputs

Question metadata per item:
- `question_id`
- `construct` (intent, structure, family, attachment, communication, sexual, values, lifestyle)
- `role` (`hard_constraint` | `core_score` | `exploratory`)
- `evidence_strength` (`H` | `M` | `L`)
- `direction` (`similarity`, `directional_fit`, `risk_boundary`)

User response record per item:
- `answer_raw`
- `answer_normalized` in `[0,1]`
- `answered_at`
- `is_skipped`

### Behavioral Inputs

- Historical accept/pass/not-now actions (for analytics and monitoring only).
- Message start/reply outcomes (for quality checks).
- Unmatch/report outcomes (for safety controls).

## AI Architecture

AI is used as constrained scoring components inside a deterministic pipeline.

### AI Role Boundaries

- AI **must not** override hard constraints.
- AI provides bounded scores used by deterministic ranking formulas.
- Final eligibility and policy checks remain rule-based.

### Components

1. `Psychological Compatibility Model`
- Purpose: estimate `psych_fit` in `[0,1]`.
- Inputs: construct-level questionnaire signals (attachment, communication, values, sexual, family, lifestyle, structure, availability), missingness indicators.
- Output:
  - `psych_fit`
  - `psych_confidence`
  - top reason codes (machine-readable only)

2. `Visual Preference Model`
- Purpose: estimate directional visual affinity from explicit VPS choices.
- Inputs: user VPS profile vector, candidate visual feature vector, quality/authenticity flags.
- Outputs:
  - `visual_affinity(A->B)`
  - `visual_affinity(B->A)`
  - `visual_confidence`

3. `Reason Generator` (templated, grounded)
- Purpose: user-facing “why this match” copy.
- Inputs: deterministic reason codes + strengths from scoring pipeline.
- Constraint: no free-form inference beyond provided reasons.

### Internal Service Interfaces

These interfaces are internal-only and intentionally excluded from `docs/technical/contracts/openapi.yaml` (public client API contract).

`POST /internal/ai/psych-fit`
- Request: `{ userAId, userBId, questionnaireFeatures, modelVersion }`
- Response: `{ psychFit, confidence, reasonCodes, modelVersion }`

`POST /internal/ai/visual-affinity`
- Request: `{ userAId, userBId, vpsProfileA, vpsProfileB, visualFeaturesA, visualFeaturesB, modelVersion }`
- Response: `{ affinityAB, affinityBA, confidence, modelVersion }`

`POST /internal/ai/reason-codes/render`
- Request: `{ locale, reasonCodes, reasonStrengths }`
- Response: `{ title, bullets }`

### Inference-Time Safeguards

- Clamp all model outputs to `[0,1]`.
- Reject or downweight model output when confidence is below threshold.
- Never score users lacking mandatory policy prerequisites as `full` mode.
- Use model version pinning in production batches.
- Log model version, confidence, and input hash for auditability.

### Failure and Fallback Policy

- If psych model fails: skip candidate for that batch and log `scoring_failure_psych`.
- If visual model fails and VPS is required: downgrade candidate to `provisional` mode.
- If reason generator fails: fall back to deterministic default reason templates.
- If repeated model errors exceed threshold: disable affected model via feature flag and continue with conservative fallback.

## Stage 1: Eligibility and Hard Constraints

Hard constraints are evaluated before ranking.

A pair is `ineligible` if any true:
- Relationship intent conflict (for configured strict intents).
- Relationship structure conflict (exclusive-only vs CNM-only mismatch).
- Child-goal conflict when both users mark this as hard requirement.
- Out of geo distance cap.
- In block/report/unmatch exclusion set.
- User unavailable (suspended/deleted/inactive threshold).

Unknown-answer policy:
- If a hard-constraint answer is missing for either side, mark as `defer` (not permanent reject).
- `defer` pairs can enter low-priority pool until data is completed.

Dual-signal policy:
- `full` matching requires both users to have:
  - psychological profile status: sufficient questionnaire completion
  - visual profile status: VPS profile status `ready`
- if either side lacks VPS readiness, pair can only enter `provisional` ranking mode.

## Stage 2: Construct Scoring

### 2.1 Normalization

For 1-7 sliders:

`norm(x) = (x - 1) / 6`

### 2.2 Pairwise Item Similarity

For similarity-style items:

`sim_i(a,b) = 1 - abs(norm(a_i) - norm(b_i))`

### 2.3 Directional Fit

For preference vs attribute items:

`fit_i(a_pref, b_attr) = 1 - abs(norm(a_pref) - norm(b_attr))`

Use reciprocal fit:

`mutual_fit_i = (fit_i(a->b) + fit_i(b->a)) / 2`

### 2.4 Evidence-Weighted Item Weight

Map evidence strength to prior reliability:
- `H = 1.0`
- `M = 0.7`
- `L = 0.4`

Item weight:

`w_i = evidence_prior_i * freshness_decay_i * completeness_i`

Where:
- `freshness_decay_i = exp(-age_days / HALF_LIFE_DAYS)`
- `completeness_i = 0` if unanswered, else `1`

### 2.5 Construct Score

For construct `c` with items `I_c`:

`score_c = sum(w_i * s_i) / sum(w_i)`

Where `s_i` is `sim_i` or `mutual_fit_i` by item direction.

### 2.6 Attachment Composite

Attachment items combine similarity and absolute risk:

`attachment_similarity = mean(sim_i for attachment items)`

`attachment_risk = mean(norm(anxiety/avoidance items for both users))`

`attachment_score = 0.6 * attachment_similarity + 0.4 * (1 - attachment_risk)`

## Stage 3: Questionnaire Compatibility Score

Recommended initial construct weights (sum = 1.0):
- `communication`: 0.22
- `attachment`: 0.20
- `sexual`: 0.18
- `values`: 0.16
- `family`: 0.10
- `structure`: 0.07
- `lifestyle`: 0.05
- `availability`: 0.02

`questionnaire_fit = sum(weight_c * score_c)`

Visual-affinity integration is defined in `docs/specs/visual-preference-studio.md` and should remain capped so psychological compatibility is primary.

Default:

`questionnaire_total = 0.80 * questionnaire_fit + 0.20 * visual_affinity_mutual`

Provisional fallback (temporary only):

`questionnaire_total_provisional = 0.80 * questionnaire_fit + 0.20 * visual_prior`

Where `visual_prior` is a neutral baseline (default `0.50`), used only until VPS completion.

## Stage 4: Final Ranking Score

Top-level score:

`base_score = 0.85 * questionnaire_total + 0.15 * authenticity_confidence`

Penalties:
- `uncertainty_penalty = 0.12 * missing_signal_ratio`
- `risk_penalty = trust_safety_risk_penalty`

`final_score = base_score - uncertainty_penalty - risk_penalty`

Mutuality guard:
- Compute directional scores `score_ab`, `score_ba` from each side's importance profile.
- Use harmonic mean as final mutual adjustment:

`mutuality = 2 * score_ab * score_ba / (score_ab + score_ba + 1e-9)`

`final_score = 0.7 * final_score + 0.3 * mutuality`

## Stage 5: Re-Ranking for Diversity

### 5.1 Diversity Re-Rank (MMR)

To avoid near-duplicate offers:

`mmr(candidate) = lambda * final_score - (1 - lambda) * max_similarity_to_selected`

Default `lambda = 0.82`.

Weekly anchor offer:
- Always highest-confidence eligible candidate.

## Stage 5B: Gender-Responsive Policy Layer (Behavior-Based)

This stage adapts marketplace behavior for users who experience very different app conditions (for example, high inbound pressure vs persistent low inbound results), without using direct gender-based ranking rules.

Policy inputs per user:
- inbound message/like volume (rolling windows)
- accept/reply outcomes
- unwanted-content and safety risk signals
- queue completion and decision fatigue indicators

Policy constraints:
- `gender_identity` cannot be a direct feature in pairwise compatibility scoring.
- `gender_identity` can be used only for cohort-level monitoring and fairness alerts.

Operational logic:
1. classify user into behavioral policy segment (e.g., `high_inbound`, `low_inbound`, `balanced`).
2. apply segment policy:
   - high inbound: tighten quality threshold and cap queue pressure.
   - low inbound: require stronger reciprocal-likelihood floor and prioritize high-confidence opportunities.
3. enforce fairness guardrails by cohort before final offer assembly.

This layer is mandatory for production and defined by `docs/specs/gender-responsive-matching.md`.

## Stage 6: Offer Assembly

1. Build eligible candidate pool.
2. Compute scores.
3. Apply minimum thresholds.
4. Re-rank with diversity.
5. Select `MATCHES_PER_DAY_DEFAULT` offers.
6. Select weekly anchor from top confidence candidate.
7. Persist explanation features and audit trail.

## Explanation Strategy (User-Facing)

Store top rationale dimensions per offer:
- `reason_codes` (e.g., `shared_family_goals`, `compatible_conflict_style`, `strong_value_alignment`)
- `reason_strength` per code

Rules:
- Do not expose sensitive protected-attribute reasoning.
- Explanations should use constructs, not raw personal labels.

## Cold-Start and Sparse Data Strategy

For users with < `QUESTIONNAIRE_MIN_QUESTIONS` answered:
- Restrict to hard constraints + high-confidence constructs only.
- Increase uncertainty penalty.
- Trigger adaptive question completion prompts.

For brand-new users:
- compute `provisional` ranking only.
- cap max score and max daily offers until VPS reaches `ready`.
- prioritize completion prompts for both questionnaire and VPS.

## Monitoring and Guardrails

### Primary Metrics

- Mutual match rate
- First reply within 48h
- Conversation retention at day 14
- Unmatch rate in 7 days
- Report rate per 1k matches

### Quality/Fairness Metrics

- Exposure concentration (Gini-like index)
- Long-tail exposure share
- Outcome parity by protected/proxy cohorts (policy compliant)
- Too-few-message indicator rate by cohort
- Too-many-message indicator rate by cohort
- Reply-within-24h parity by cohort
- Unwanted-content report rate by cohort
- Violations of direct gender weighting policy (must remain zero)

### Alert Thresholds

- Report rate +20% week-over-week
- Mutual match rate -10% week-over-week

## Research Governance and Review

This model is research-anchored and policy-driven.

Review cadence:
- Quarterly literature review of relationship/matching psychology.
- Quarterly policy review of hard constraints and sensitive-item handling.
- Monthly audit of production metrics and safety outcomes.

Change control:
- Any weight or rule change requires documented rationale tied to:
  - peer-reviewed research, or
  - safety/compliance requirement, or
  - clear operational defect.
- All changes must update this spec and `docs/ops/configuration.md` keys.

## Configuration Keys (Proposed)

| Key | Default | Description |
|---|---|---|
| `MATCH_SCORE_QUESTIONNAIRE_WEIGHT` | 0.85 | Final score weight |
| `MATCH_SCORE_AUTHENTICITY_WEIGHT` | 0.15 | Final score weight |
| `MATCH_SCORE_UNCERTAINTY_PENALTY_MAX` | 0.12 | Max missingness penalty |
| `MATCH_SCORE_DIVERSITY_LAMBDA` | 0.82 | MMR tradeoff |
| `MATCH_MIN_QUALITY_THRESHOLD` | 0.50 | Minimum eligible final score |
| `MATCH_ANCHOR_MIN_CONFIDENCE` | 0.70 | Weekly anchor floor |
| `MATCH_REQUIRE_VISUAL_SIGNAL` | true | Require VPS `ready` for full ranking |
| `MATCH_PROVISIONAL_VISUAL_PRIOR` | 0.50 | Neutral fallback visual prior |
| `MATCH_PROVISIONAL_SCORE_CAP` | 0.72 | Max score when visual signal missing |
| `MATCH_PROVISIONAL_MAX_OFFERS` | 1 | Max daily offers in provisional mode |
| `MATCH_ANSWER_HALF_LIFE_DAYS` | 180 | Response freshness decay |
| `MATCH_EVIDENCE_WEIGHT_H` | 1.00 | Evidence prior |
| `MATCH_EVIDENCE_WEIGHT_M` | 0.70 | Evidence prior |
| `MATCH_EVIDENCE_WEIGHT_L` | 0.40 | Evidence prior |
| `MATCH_GENDER_RESPONSIVE_MODE` | `behavioral_segments` | Enables behavior-based cohort policy layer |
| `MATCH_HIGH_INBOUND_QUEUE_CAP` | 3 | Max active offers for high inbound segment |
| `MATCH_LOW_INBOUND_MIN_RECIPROCITY` | 0.55 | Minimum reciprocal-likelihood floor for low inbound segment |
| `MATCH_COHORT_PARITY_ALERT_THRESHOLD` | 0.10 | Alert when cohort outcome delta exceeds threshold |

## Pseudocode

```text
for user in active_users:
  pool = load_candidates(user)
  eligible = apply_hard_constraints(user, pool)

  scored = []
  for candidate in eligible:
    construct_scores = compute_construct_scores(user, candidate)
    if has_ready_vps(user) and has_ready_vps(candidate):
      questionnaire_total = aggregate_questionnaire_with_visual(construct_scores, user, candidate)
      provisional = False
    else:
      questionnaire_total = aggregate_questionnaire_provisional(construct_scores, visual_prior=0.50)
      provisional = True
    authenticity = get_authenticity_confidence(candidate)

    base = 0.85*questionnaire_total + 0.15*authenticity
    penalty = uncertainty_penalty(user, candidate) + risk_penalty(user, candidate)
    directional = mutuality_adjustment(user, candidate)

    final = 0.7*(base - penalty) + 0.3*directional
    if provisional:
      final = min(final, MATCH_PROVISIONAL_SCORE_CAP)
    if final >= MATCH_MIN_QUALITY_THRESHOLD:
      scored.append((candidate, final, construct_scores, provisional))

  reranked = mmr_rerank(scored, lambda=MATCH_SCORE_DIVERSITY_LAMBDA)
  offers = select_top_k(reranked, k=MATCHES_PER_DAY_DEFAULT, provisional_max=MATCH_PROVISIONAL_MAX_OFFERS)
  anchor = select_anchor(reranked, min_conf=MATCH_ANCHOR_MIN_CONFIDENCE)
  persist_offers(user, offers, anchor)
```

## Acceptance Criteria

- [ ] Engine supports hard constraints, scoring, and reranking as separate stages.
- [ ] All question items can be mapped to constructs and evidence strengths.
- [ ] Full ranking requires both psychological and visual signals by policy.
- [ ] Missing data is handled with explicit uncertainty penalty.
- [ ] Daily and anchor offers use the same scoring core with different policies.
- [ ] Explanations are generated from stored construct-level reasons.
- [ ] Research governance and review cadence is defined and operational.
- [ ] Safety and fairness guardrails are monitored with alert thresholds.

## Resolved Questions

| Question | Decision | Rationale |
|----------|----------|-----------|
| Child-goal mismatch: hard constraint or soft penalty? | **Configurable soft penalty** with `MATCH_CHILD_GOAL_MISMATCH_PENALTY` | Hard constraint too restrictive for MVP; allows tuning based on user feedback. Users who mark child goals as "important" get stronger penalty. |
| Enforce reciprocity minimum before ranking? | **Yes** - `MATCH_MIN_RECIPROCITY = 0.35` | Prevents highly one-sided matches that lead to poor experience. Harmonic mean of directional scores must exceed threshold. |
| Which construct weights need policy review? | **Sexual, Family, Values** | These touch on sensitive/protected domains. Any weight changes require product + policy sign-off before deployment. |

## Configuration Keys (Resolved)

| Key | Default | Description |
|---|---|---|
| `MATCH_CHILD_GOAL_MISMATCH_PENALTY` | 0.15 | Soft penalty when child goals conflict |
| `MATCH_MIN_RECIPROCITY` | 0.35 | Minimum harmonic mean of directional scores |
| `MATCH_SEXUAL_WEIGHT_REVIEW_REQUIRED` | true | Require policy review for sexual construct weight changes |
| `MATCH_FAMILY_WEIGHT_REVIEW_REQUIRED` | true | Require policy review for family construct weight changes |
| `MATCH_VALUES_WEIGHT_REVIEW_REQUIRED` | true | Require policy review for values construct weight changes |
