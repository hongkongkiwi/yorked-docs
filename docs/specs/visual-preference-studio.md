# Feature Specification: Visual Preference Studio

Owner: Product + Engineering + Research  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/specs/onboarding.md`, `docs/specs/matching-scoring-engine.md`, `docs/technical/contracts/openapi.yaml`, `docs/trust-safety/legal-escalation-and-evidence.md`

## Overview

Visual Preference Studio (VPS) captures attraction preferences through **explicit user choices** over photo examples, rather than inferring preferences from demographics or guessing from profile text.

Core principle:
- Do not guess what users like.
- Show reference photos (licensed/generated or consented real examples).
- Ask users to choose which examples they are more drawn to.
- Learn preference signals from choices.

## Why This Approach (Research Basis)

1. Stated ideals only partially predict real partner outcomes and are context-sensitive, so direct behavior signals are necessary. [V1][V2]
2. Online dating behavior shows preference-choice gaps and market constraints; observed choices are more informative than static stated traits alone. [V2][V3][V4]
3. Photos strongly shape first impressions, but those impressions can be biased/noisy; they should be measured carefully and not treated as ground truth character judgments. [V5][V6][V7]
4. People are often not optimal at selecting their own best photos; structured selection and external-choice methods improve signal quality. [V8][V9]
5. Pairwise/best-worst preference elicitation is statistically robust and better behaved than simple ratings for subjective impressions. [V10][V11]

## Product Principles

- Psychological compatibility remains the primary matching signal.
- Visual preference is a secondary signal, capped by policy.
- Full-confidence matching requires both psychological and visual signals.
- Use reciprocal attraction modeling (A->B and B->A), not one-sided desirability.
- Never expose or optimize a public "attractiveness score".
- Avoid protected-trait targeting and discriminatory filters.
- Never apply default visual priors by gender; visual modeling uses only explicit user choices.

## Data Inputs

### 1) Reference Image Pool

Two supported modes:
- `licensed_synthetic`: generated references with usage rights.
- `consented_real`: real photos with explicit research/product consent.

Each reference image must have metadata:
- image_id
- source_mode
- quality flags (lighting, blur, occlusion)
- style tags (expression, framing, context, grooming, attire, vibe)
- sensitive-attribute tags for fairness auditing only (not user-visible filters)

### 2) User Choice Events

For each task:
- user_id
- session_id
- left_image_id
- right_image_id
- choice (`left` | `right` | `neither` | `skip`)
- response_time_ms
- timestamp

### 3) Candidate Profile Visual Features

For each candidate profile photo set:
- standardized photo-quality checks
- non-sensitive style embeddings/tags
- authenticity/freshness indicators

## Elicitation Flow (Onboarding)

### Stage A: Fast Preference Capture (Required)

- Show 20 pairwise comparisons (`A` vs `B`).
- Include `Neither` option to reduce forced error.
- Randomize order and side placement.
- Enforce broad diversity in reference set exposure.

### Stage B: Optional Refinement

- Add 10-20 extra comparisons if confidence is low.
- Ask 3-5 style-level preference confirmations (e.g., "more candid vs more polished").

### Stage C: Recalibration

- Lightweight refresh every 30-60 days or after major profile edits.

## Modeling Method

### 1) Pairwise Preference Estimation

Use Bradley-Terry-Luce style estimation on pairwise outcomes.

For items `i,j`:

`P(i preferred over j) = exp(theta_i) / (exp(theta_i) + exp(theta_j))`

Where `theta` values are latent preference utilities.

### 2) User Preference Vector

Map chosen image utilities into a user-level vector over style dimensions:
- fit to learned embedding basis
- regularize to prevent overfitting from sparse responses

### 3) Candidate Visual Affinity

Compute directional affinity:

`visual_affinity(A->B) in [0,1]`

Then reciprocal:

`visual_affinity_mutual = sqrt(visual_affinity(A->B) * visual_affinity(B->A))`

## Integration with Matching Score

In `matching-scoring-engine`:

- psychological score remains primary.
- visual affinity is secondary and capped.
- both signals are required for full-confidence ranking.

Recommended combination:

`questionnaire_total = 0.80 * psych_fit + 0.20 * visual_affinity_mutual`

If VPS data is missing:

- use provisional fallback only:
  - `questionnaire_total_provisional = 0.80 * psych_fit + 0.20 * visual_prior`
  - cap ranking score and daily offer count until VPS status becomes `ready`.
- never treat provisional mode as equivalent to full-confidence matching.

## Safety, Fairness, and Compliance Controls

- Do not provide explicit race/ethnicity/religion/body-type exclusion filters by default.
- Do not infer sensitive attributes for targeting.
- Use sensitive tags only for fairness auditing and bias detection.
- Apply anti-objectification copy and consent language in VPS screens.
- Maintain age gating and legal content controls.

Bias-reduction UX requirement:
- In candidate review UI, show substantive profile context before or alongside photos to reduce photo-first bias amplification. [V12]

### Gender-Responsive Guardrails (Behavior-Aware, Not Stereotype-Aware)

- Do not pre-seed VPS with assumptions about women or men.
- Keep reference-image diversity balanced across gender presentation styles.
- Monitor VPS calibration error by cohort (women, men, and other identities where sample size allows).
- If calibration drift is detected for any cohort, reduce visual-weight contribution until recalibration is complete.
- Route all cohort drift incidents to joint review by Research + Data Science + Trust & Safety.

## Photo Studio (User’s Own Photos)

Separate from VPS preferences, Photo Studio helps users pick better photos for their profile.

Flow:
- user uploads 6-12 photos
- run quality checks (blur, lighting, occlusion)
- run pairwise selection flow (self + optional external raters or model proxy)
- recommend top 3-4 photos

Rationale:
- users often choose weaker self-images than other-selectors. [V8]

## Performance Targets

- VPS fast capture completion: < 3 minutes median
- Pairwise model update latency: < 1 second per choice event (online)
- Daily visual-affinity refresh batch: < 5 minutes per 10k users

## Analytics

Track:
- VPS completion rate
- median response time per pairwise task
- `Neither` rate
- confidence score of learned visual profile
- contribution of visual signal to accepted matches
- safety outcomes (report/unmatch rate shifts)

## Acceptance Criteria

- [ ] Users can complete required pairwise preference capture during onboarding.
- [ ] Pairwise choices are converted into a stable user visual preference vector.
- [ ] Reciprocal visual affinity is computed for candidate pairs.
- [ ] Full-confidence matching path requires VPS `ready` for both users.
- [ ] Visual affinity is capped and combined with psychological compatibility.
- [ ] Missing VPS data degrades gracefully without blocking matching.
- [ ] Fairness and safety audits run on visual-signal outcomes.
- [ ] Photo Studio can recommend best-performing user photos from uploaded sets.

## Open Questions

1. Should VPS be mandatory for all users or mandatory only for users who opt into visual-priority matching?
2. What is the maximum allowed visual-affinity weight under policy (e.g., 0.15 vs 0.20)?
3. Do we allow generated reference faces in all regions, or only licensed real references where legal risk is lower?

## References

- [V1] Eastwick PW, Luchies LB, Finkel EJ, Hunt LL (2014). *The predictive validity of ideal partner preferences: A review and meta-analysis*. Psychological Bulletin. [https://pubmed.ncbi.nlm.nih.gov/23586697/](https://pubmed.ncbi.nlm.nih.gov/23586697/)
- [V2] Whyte S, Torgler B (2017). *Preference Versus Choice in Online Dating*. Cyberpsychology, Behavior, and Social Networking. [https://pubmed.ncbi.nlm.nih.gov/28263677/](https://pubmed.ncbi.nlm.nih.gov/28263677/)
- [V3] Bruch EE, Newman MEJ (2018). *Aspirational pursuit of mates in online dating markets*. Science Advances. [https://pmc.ncbi.nlm.nih.gov/articles/PMC6082652/](https://pmc.ncbi.nlm.nih.gov/articles/PMC6082652/)
- [V4] Topinkova R, Diviak T (2025). *It takes two to tango: A directed two-mode network approach to desirability on a mobile dating app*. PLOS ONE. [https://doi.org/10.1371/journal.pone.0327477](https://doi.org/10.1371/journal.pone.0327477)
- [V5] Willis J, Todorov A (2006). *First impressions: Making up your mind after a 100-ms exposure to a face*. Psychological Science. [https://doi.org/10.1111/j.1467-9280.2006.01750.x](https://doi.org/10.1111/j.1467-9280.2006.01750.x)
- [V6] Zebrowitz LA (2017). *First Impressions From Faces*. Current Directions in Psychological Science. [https://pmc.ncbi.nlm.nih.gov/articles/PMC5473630/](https://pmc.ncbi.nlm.nih.gov/articles/PMC5473630/)
- [V7] Hancock JT, Toma CL (2009). *Putting Your Best Face Forward: The Accuracy of Online Dating Photographs*. Journal of Communication. [https://doi.org/10.1111/j.1460-2466.2009.01420.x](https://doi.org/10.1111/j.1460-2466.2009.01420.x)
- [V8] White D, Sutherland CAM, Burton AL (2017). *Choosing face: The curse of self in profile image selection*. Cognitive Research: Principles and Implications. [https://doi.org/10.1186/s41235-017-0058-3](https://doi.org/10.1186/s41235-017-0058-3)
- [V9] Re DE, Wang SA, He JC, Rule NO (2016). *Selfie indulgence: Self-favoring biases in perceptions of selfies*. Social Psychological and Personality Science. [https://doi.org/10.1177/1948550616644299](https://doi.org/10.1177/1948550616644299)
- [V10] Bradley RA, Terry ME (1952). *Rank analysis of incomplete block designs: The method of paired comparisons*. Biometrika. [https://doi.org/10.1093/biomet/39.3-4.324](https://doi.org/10.1093/biomet/39.3-4.324)
- [V11] Burton N, Burton M, Rigby D, Sutherland CAM, Rhodes G (2019). *Best-worst scaling improves measurement of first impressions*. Cognitive Research: Principles and Implications. [https://doi.org/10.1186/s41235-019-0183-2](https://doi.org/10.1186/s41235-019-0183-2)
- [V12] Ma Z, Gajos KZ (2022). *Not Just a Preference: Reducing Biased Decision-Making on Dating Websites*. CHI Conference on Human Factors in Computing Systems. [https://doi.org/10.1145/3491102.3517587](https://doi.org/10.1145/3491102.3517587)
