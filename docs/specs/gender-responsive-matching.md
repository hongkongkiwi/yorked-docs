# Feature Specification: Gender-Responsive Matching

Owner: Product + Research + Data Science  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/specs/matching.md`, `docs/specs/matching-scoring-engine.md`, `docs/specs/visual-preference-studio.md`, `docs/specs/safety.md`, `docs/technical/contracts/openapi.yaml`

## Overview

This spec defines how Yoked supports different dating-app behavior patterns observed across women and men while avoiding stereotype-based product logic.

Core policy:
- adapt by observed user context (inbound volume, safety risk, response outcomes), not by hardcoded gender assumptions.
- use gender identity for monitoring and fairness audits, not direct compatibility scoring.
- keep the experience inclusive of all gender identities.

## Why This Matters (Research Summary)

Evidence shows meaningful marketplace differences that must be handled at system level:
- Women report more unwanted sexual content and continued contact after non-response; men more often report too few messages. [G1]
- Women initiate fewer first contacts, while men send more outreach and pursue higher-desirability targets, creating asymmetric response pressure. [G2]
- Desirability hierarchies are not neutral and may differ by gendered marketplace structure. [G3]
- Sexual and relational preference differences exist on average, but idealized preferences are imperfect predictors of relationship outcomes; hardcoded sex stereotypes are not defensible. [G4][G8]
- Online sexual violence on dating apps is a documented risk and requires explicit safeguards in product design. [G5][G6]
- UI framing can reduce attractiveness-driven bias without reducing matching success, which helps both women and men receive more substantive evaluation. [G7]

## Design Principles

1. `Behavior before demographics`: adapt to user conditions, not presumed traits.
2. `Reciprocity over volume`: optimize for mutuality and healthy conversation, not raw likes.
3. `Safety first`: protect users in high-risk contexts with stronger controls.
4. `Transparency`: expose clear reason codes and user controls.
5. `Fairness with accountability`: monitor outcomes by cohort and trigger interventions when drift appears.

## Behavioral Segments (Policy Layer)

Users are assigned to policy segments from rolling behavioral signals:

- `high_inbound_pressure`
  - Signals: high inbound volume, high decision fatigue, elevated unwanted-content risk.
  - Typical need: filtering, pacing, safety controls.

- `low_inbound_low_response`
  - Signals: low inbound visibility, low response probability, repeated low-quality loops.
  - Typical need: higher reciprocal-likelihood matching, profile feedback, lower-noise exposure.

- `balanced`
  - Signals: stable inbound and response outcomes with acceptable safety profile.
  - Typical need: default policy.

Segmenting is independent of gender. Cohort composition is monitored for fairness.

## Product Requirements

### 1) Offer Generation and Pacing

- High-inbound segment:
  - apply stricter quality threshold before offer generation.
  - cap active queue and daily decisions to reduce overload.
  - prioritize candidates with stronger reciprocity + trust signals.

- Low-inbound segment:
  - require minimum reciprocal-likelihood floor.
  - suppress low-probability filler offers.
  - provide profile and opener coaching prompts.

- All segments:
  - preserve hard constraints and trust/safety gating.
  - keep psychological + visual dual-signal policy unchanged.

### 2) Decision UX

- Default to review-first decisions (already required in matching spec).
- Ensure substantive profile context appears before purely visual judgments.
- Show clear controls: `Pass`, `Not Now`, `Accept`, `Block`, `Report`.
- Provide queue-load controls when decision fatigue is detected.

### 3) Messaging and Safety

- Expand anti-harassment interventions for high-risk contexts:
  - pre-send warnings for sexual/aggressive content.
  - fast block/report affordances in first-message window.
  - tighter rate limits for repeated low-quality outreach patterns.
- Keep interventions behavior-triggered, not gender-triggered.

## AI and Ranking Constraints

- `gender_identity` must not be a direct scoring feature in compatibility or attractiveness models.
- AI can optimize multi-objective ranking with these targets:
  - mutual acceptance probability
  - reply-within-24h probability
  - safety-risk minimization
  - queue fatigue minimization
- Enforce cohort fairness constraints as post-model policy checks.
- If fairness or safety drift exceeds threshold, auto-fallback to conservative ranking profile.

## Cohort Monitoring (Required)

Track weekly by cohort (women, men, and other gender identities where sample size is reliable):
- too-few-message indicator rate
- too-many-message indicator rate
- unwanted-content report rate
- mutual match rate
- first reply within 24h
- 7-day unmatch rate
- decision fatigue indicators

Escalation rule:
- if any critical safety metric worsens >20% week-over-week for a cohort, trigger policy review and conservative rollback.

## Acceptance Criteria

- [ ] System uses behavior segments for policy adaptation.
- [ ] No direct gender-based boosts/penalties are used in pair scoring.
- [ ] Cohort outcome dashboards are available and reviewed regularly.
- [ ] Safety interventions are behavior-triggered and measurable.
- [ ] Offer pacing controls reduce overload without harming overall mutual match quality.
- [ ] Profile/evaluation UX reduces photo-only bias and preserves conversion quality.

## References

- [G1] Pew Research Center (2023). *Key findings about online dating in the U.S.* [https://www.pewresearch.org/short-reads/2023/02/02/key-findings-about-online-dating-in-the-u-s/](https://www.pewresearch.org/short-reads/2023/02/02/key-findings-about-online-dating-in-the-u-s/)
- [G2] Bruch EE, Newman MEJ (2018). *Aspirational pursuit of mates in online dating markets*. Science Advances. [https://pmc.ncbi.nlm.nih.gov/articles/PMC6082652/](https://pmc.ncbi.nlm.nih.gov/articles/PMC6082652/)
- [G3] Topinkova R, Diviak T (2025). *It takes two to tango: A directed two-mode network approach to desirability on a mobile dating app*. PLOS ONE. [https://doi.org/10.1371/journal.pone.0327477](https://doi.org/10.1371/journal.pone.0327477)
- [G4] Eastwick PW, Luchies LB, Finkel EJ, Hunt LL (2014). *The predictive validity of ideal partner preferences: A review and meta-analysis*. Psychological Bulletin. [https://pubmed.ncbi.nlm.nih.gov/23586697/](https://pubmed.ncbi.nlm.nih.gov/23586697/)
- [G5] Lopes M et al. (2023). *Online Sexual Violence in Digital Dating: A Scoping Review*. Trauma, Violence, & Abuse. [https://doi.org/10.1177/15248380231203640](https://doi.org/10.1177/15248380231203640)
- [G6] Challacombe FL et al. (2024). *Improving online dating safety by understanding user profile threat sensitivity and warning intervention effectiveness*. Computers in Human Behavior. [https://pubmed.ncbi.nlm.nih.gov/39725776/](https://pubmed.ncbi.nlm.nih.gov/39725776/)
- [G7] Ma Z, Gajos KZ (2022). *Not Just a Preference: Reducing Biased Decision-Making on Dating Websites*. CHI Conference on Human Factors in Computing Systems. [https://doi.org/10.1145/3491102.3517587](https://doi.org/10.1145/3491102.3517587)
- [G8] Sumter SR, Vandenbosch L, Ligtenberg L (2017). *Love me Tinder: Untangling emerging adults' motivations for using the dating application Tinder*. Telematics and Informatics. [https://doi.org/10.1016/j.tele.2016.04.009](https://doi.org/10.1016/j.tele.2016.04.009)
