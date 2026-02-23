# Feature Specification: Science-Backed Relationship Question Bank (2026)

Owner: Product + Research  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/specs/onboarding.md`, `docs/archive/initial-stage-question-bank.md`, `docs/technical/contracts/openapi.yaml`, `docs/technical/schema/database.md`

## Overview

This document translates current relationship, dating, and matching research into a practical question set for initial onboarding.

Goals:
- Maximize predictive signal for compatibility with minimal user burden.
- Ground each question domain in peer-reviewed evidence.
- Separate hard constraints (must-match) from soft preference scoring.

## Evidence Scope

- Time focus: 2020-2026 (with landmark prior work where needed).
- Priority: meta-analyses, systematic reviews, dyadic/longitudinal studies, and large online-dating market studies.
- Evidence quality caveat: most studies rely on self-report and WEIRD-heavy samples; models should be recalibrated with product outcomes.

## Key Findings (Actionable)

1. Assortative mating is real and broad; partner similarity is common across attitudes, education, religion, and many traits. Median partner correlation is moderate (around `r=0.21`). [R1]
2. Values and personality similarity effects exist, but effect sizes are typically modest; avoid over-weighting single preference items. [R4]
3. Attachment insecurity (anxiety/avoidance) is strongly linked to lower relationship quality in dyads and should be measured with multiple items. [R2]
4. Sexual communication has one of the clearest and most replicable associations with sexual and relationship satisfaction. [R5]
5. Perspective-taking/empathic responding is consistently associated with higher relationship satisfaction. [R6]
6. Demand-withdraw conflict patterns are reliably associated with poorer relational outcomes and should be measured directly. [R14][R15]
7. Relationship structure itself (monogamous vs consensually non-monogamous) does not show inherent superiority; expectation alignment matters more. [R7]
8. Political and broader worldview incongruence can be a friction source for many couples; collect both identity and dealbreaker intensity. [R11][R12]
9. In online dating environments, stated preferences and market dynamics do not fully predict actual partner choices; models should combine self-report with observed behavior. [R8][R9][R10]
10. Substance-use concordance/discordance can matter for relationship stability; capture tolerance and boundaries explicitly. [R13]

## Design Principles For Questionnaire

- Use 3-6 items per latent construct (single items are noisy).
- Ask both identity and importance (example: political identity + how much it matters).
- Capture hard constraints separately from ranking features.
- Use neutral wording and support "prefer not to answer" for sensitive items.
- Avoid using protected-class preferences as hard filters by default.

## Recommended Question Bank

### Tier 1: Initial Stage (12 Required)

| ID | Question | Type | Construct |
|---|---|---|---|
| Q001 | What relationship are you looking for right now? (casual, long-term, marriage, unsure) | single_choice | Intent alignment |
| Q002 | Which relationship structure are you open to? (exclusive, consensually non-monogamous, either) | single_choice | Structure alignment |
| Q003 | Do you want children? (yes, no, unsure) | single_choice | Family-goal alignment |
| Q004 | How important is it that your partner shares your political values? | slider 1-7 | Value salience |
| Q005 | How important is it that your partner shares your religion/spirituality? | slider 1-7 | Value salience |
| Q006 | I worry that a partner may lose interest in me. | slider 1-7 | Attachment anxiety |
| Q007 | I need frequent reassurance in relationships. | slider 1-7 | Attachment anxiety |
| Q008 | I get uncomfortable when someone gets very emotionally close. | slider 1-7 | Attachment avoidance |
| Q009 | I prefer not to rely too much on a partner. | slider 1-7 | Attachment avoidance |
| Q010 | After conflict, I try to repair and reconnect quickly. | slider 1-7 | Conflict repair |
| Q011 | When someone vents, I first offer empathy vs advice. (1 = empathy first, 7 = advice first) | slider 1-7 | Communication style |
| Q012 | I can openly discuss sexual needs and boundaries with a partner. | slider 1-7 | Sexual communication |

### Tier 2: Early Follow-Up (Optional But High Signal)

| ID | Question | Type | Construct |
|---|---|---|---|
| Q013 | How do you identify politically? | single_choice | Identity (for homophily modeling) |
| Q014 | How do you identify religiously/spiritually? | single_choice | Identity (for homophily modeling) |
| Q015 | How important is sex to you in a relationship? | slider 1-7 | Sexual priority |
| Q016 | Sex without love is meaningless to me. | slider 1-7 | Sexual values |
| Q017 | It is okay if my partner drinks alcohol. | slider 1-7 | Lifestyle tolerance |
| Q018 | It is okay if my partner uses cannabis. | slider 1-7 | Lifestyle tolerance |
| Q019 | It is okay if my partner uses hard drugs. | slider 1-7 | Risk tolerance |
| Q020 | I can understand my partner's perspective before reacting. | slider 1-7 | Perspective-taking |
| Q021 | I stay respectful when conflicts get intense. | slider 1-7 | Conflict behavior |
| Q022 | I tend to withdraw instead of discussing conflict. | slider 1-7 | Demand-withdraw tendency |
| Q023 | I want a partner who plans meticulously vs goes with the flow. (1 = plans, 7 = flow) | slider 1-7 | Planning-style fit |
| Q024 | Exercising is an important part of my lifestyle. | slider 1-7 | Lifestyle fit |
| Q025 | I track spending very closely. | slider 1-7 | Financial style |
| Q026 | I believe in a higher power. | slider 1-7 | Core worldview |
| Q027 | I would end a close relationship over major political differences. | slider 1-7 | Dealbreaker intensity |
| Q028 | How single are you right now? (1 = very single, 7 = in a relationship) | slider 1-7 | Availability state |

## Question-to-Evidence Traceability

`H = high confidence`, `M = moderate confidence`, `L = low confidence / proxy evidence`

Each question can map to multiple studies. `Evidence Notes` shows what each cited source contributes.

| Question ID | Primary References | Evidence Strength | Evidence Notes (multi-source) |
|---|---|---|---|
| Q001 | [R1], [R8], [R10] | M | R1: people pair assortatively across values/attitudes.<br>R8: stated ideals only partly predict eventual partner choice.<br>R10: market structure constrains who can match. |
| Q002 | [R7], [R1] | H | R7: no inherent satisfaction advantage for monogamy vs CNM; alignment matters.<br>R1: assortative pairing logic supports matching on structure preference. |
| Q003 | [R16], [R1] | M | R16: family ideals remain salient and variable across populations.<br>R1: broad assortative mating supports collecting shared family-goal preferences. |
| Q004 | [R11], [R12] | H | R11: political dissimilarity predicts relational friction in dyads.<br>R12: broader value-attitude incongruence relates to satisfaction gaps. |
| Q005 | [R1] | M | R1: religion/spirituality are common assortative dimensions in partner selection. |
| Q006 | [R2] | H | R2: attachment-anxiety patterns predict lower satisfaction and stability risks. |
| Q007 | [R2] | H | R2: reassurance-seeking maps to anxiety-linked attachment processes. |
| Q008 | [R2] | H | R2: emotional-distance discomfort/avoidance predicts poorer dyadic outcomes. |
| Q009 | [R2] | H | R2: reliance-avoidance is a core avoidant-attachment marker. |
| Q010 | [R14], [R15] | H | R15: demand-withdraw harms relational outcomes.<br>R14: daily-process evidence shows conflict dynamics matter in close relationships. |
| Q011 | [R6] | H | R6: perspective-taking and empathic stance associate with higher relationship satisfaction. |
| Q012 | [R5], [R14] | H | R5: sexual communication is strongly associated with sexual/relationship satisfaction.<br>R14: conflict-process evidence supports communication quality measurement. |
| Q013 | [R11], [R12] | H | R11: direct political dissimilarity evidence.<br>R12: identity-level congruence on attitudes relates to outcomes. |
| Q014 | [R1] | M | R1: religious identity similarity is a recurrent partner-sorting dimension. |
| Q015 | [R5] | M | R5: sexual topic salience and communication patterns relate to satisfaction outcomes. |
| Q016 | [R5] | L | R5: indirect support via sexual-values communication; this item is more belief-framing than direct predictor. |
| Q017 | [R13] | M | R13: discordant alcohol use in couples predicts higher dissolution risk. |
| Q018 | [R13] | L | R13: substance-use concordance logic used as proxy; cannabis-specific dyadic evidence is thinner. |
| Q019 | [R13] | L | R13: substance discordance as proxy plus safety/risk boundary capture. |
| Q020 | [R6] | H | R6: perspective-taking consistently links to relationship quality. |
| Q021 | [R14], [R15] | H | R15: conflict style predicts relational outcomes.<br>R14: daily conflict-process findings support respectful-conflict measurement. |
| Q022 | [R14], [R15] | H | R15: direct demand-withdraw evidence base.<br>R14: prospective daily evidence supports withdrawal measurement. |
| Q023 | [R4], [R1] | M | R4: personality/values similarity effects are real but modest.<br>R1: assortative pairing supports planning-style preference capture. |
| Q024 | [R1] | L | R1: lifestyle similarity proxy; direct exercise-specific dyadic prediction evidence is limited. |
| Q025 | [R1], [R4] | L | R1: assortative tendencies justify style matching proxies.<br>R4: similarity effects exist but are modest and construct-dependent. |
| Q026 | [R1] | M | R1: worldview similarity appears in broad assortative mating dimensions. |
| Q027 | [R11], [R12] | H | R11: political incongruence predicts friction.<br>R12: value-attitude incongruence supports dealbreaker-intensity measurement. |
| Q028 | [R9], [R10] | M | R9: app outcomes are shaped by desirability dynamics and behavior.<br>R10: matching-market structure supports tracking current availability state. |

## Scoring and Matching Guidance

- Create separate sub-scores: `intent`, `structure`, `family`, `attachment`, `communication`, `sexual`, `values`, `lifestyle`.
- Hard constraints should gate candidates before ranking (examples: incompatible intent, incompatible relationship structure, incompatible child goals).
- Rank remaining candidates using weighted distance/similarity on sub-scores.
- Start weights from evidence strength, then retrain on product outcomes (conversation starts, mutual likes, retention, date conversion).

## What To De-Prioritize In Initial Stage

- Single-item novelty prompts with weak construct validity.
- Highly campus-specific wording (example: institution-specific intelligence comparisons).
- Sensitive demographic preferences as default hard filters.

## References

- [R1] Horwitz et al. (2023). *A meta-analysis of human assortative mating*. Nature Human Behaviour. [https://www.nature.com/articles/s41562-022-01500-w](https://www.nature.com/articles/s41562-022-01500-w)
- [R2] Conradi et al. (2021). *Actor, partner, and similarity effects of attachment on relationship satisfaction and unstable romantic relationships*. Personality and Social Psychology Bulletin. [https://psycnet.apa.org/record/2021-53938-003](https://psycnet.apa.org/record/2021-53938-003)
- [R3] Bühler & Orth (2022). *Development of satisfaction with a romantic relationship in adulthood: A meta-analysis*. Journal of Personality and Social Psychology. [https://pubmed.ncbi.nlm.nih.gov/36751762/](https://pubmed.ncbi.nlm.nih.gov/36751762/)
- [R4] Lu et al. (2023). *Effects of Similarity in Personality and Values among Dating Couples*. Personality and Individual Differences. [https://doi.org/10.1016/j.paid.2023.112306](https://doi.org/10.1016/j.paid.2023.112306)
- [R5] Mallory et al. (2022). *The dimensions of sexual communication and their associations with sexual and relationship satisfaction: A meta-analysis*. Journal of Sex Research. [https://pubmed.ncbi.nlm.nih.gov/34968095/](https://pubmed.ncbi.nlm.nih.gov/34968095/)
- [R6] Cahill et al. (2020). *Perspective Taking and Romantic Relationships: A Meta-Analytic Review*. Journal of Social and Personal Relationships. [https://doi.org/10.1177/0265407520953895](https://doi.org/10.1177/0265407520953895)
- [R7] Anderson et al. (2025). *Countering monogamy-superiority myth: A quantitative review*. Journal of Sex Research. [https://pubmed.ncbi.nlm.nih.gov/39015884/](https://pubmed.ncbi.nlm.nih.gov/39015884/)
- [R8] Eastwick et al. (2014). *The predictive validity of ideal partner preferences: A review and meta-analysis*. Psychological Bulletin. [https://doi.org/10.1037/a0032432](https://doi.org/10.1037/a0032432)
- [R9] Topinková & Diviák (2025). *Dating app interactions and desirability*. PLOS ONE. [https://pmc.ncbi.nlm.nih.gov/articles/PMC12380961/](https://pmc.ncbi.nlm.nih.gov/articles/PMC12380961/)
- [R10] Bruch & Newman (2019). *Structure of online dating markets in U.S. cities*. PNAS. [https://www.pnas.org/doi/full/10.1073/pnas.1908630116](https://www.pnas.org/doi/full/10.1073/pnas.1908630116)
- [R11] Peacock & Pederson (2022). *Political dissimilarity in romantic relationships*. Human Communication Research. [https://doi.org/10.1093/hcr/hqac024](https://doi.org/10.1093/hcr/hqac024)
- [R12] Liekefett et al. (2025). *Partner (in)congruence in gender role attitudes and relationship satisfaction*. PNAS Nexus. [https://doi.org/10.1093/pnasnexus/pgae589](https://doi.org/10.1093/pnasnexus/pgae589)
- [R13] Torvik et al. (2013). *Discordant and Concordant Alcohol Use in Couples as Predictors of Marital Dissolution*. PLOS ONE. [https://pubmed.ncbi.nlm.nih.gov/23384147/](https://pubmed.ncbi.nlm.nih.gov/23384147/)
- [R14] Rosen et al. (2025). *Sexual Desire Discrepancy and Sexual Demand-Withdraw During Sexual Conflict: A Daily Prospective Study of Couples*. Journal of Social and Personal Relationships. [https://doi.org/10.1177/02654075251361171](https://doi.org/10.1177/02654075251361171)
- [R15] Schrodt et al. (2014). *A Meta-Analytic Review of the Demand/Withdraw Pattern of Interaction and its Associations with Individual, Relational, and Communicative Outcomes*. Communication Monographs. [https://doi.org/10.1080/03637751.2013.813632](https://doi.org/10.1080/03637751.2013.813632)
- [R16] Aassve et al. (2024). *Family ideals in an era of low fertility*. PNAS. [https://doi.org/10.1073/pnas.2311847121](https://doi.org/10.1073/pnas.2311847121)

## Resolved Questions

| Question | Decision | Rationale |
|----------|----------|-----------|
| Which sensitive items should be optional-only? | **Politics, Religion, Substance Use** optional; Guns/Abortion not in MVP | Politics and religion are value-sensitive but not safety-critical. Substance use is personal. Guns/abortion are too polarizing for MVP - defer. |
| Two-pass model (mandatory core + adaptive follow-up)? | **Not for MVP** - Use single-pass with all required items | Simpler implementation. Can add adaptive follow-up post-MVP based on completion rate data. |
| Optimization target for v1? | **Mutual likes + 2-week retention** | Primary: mutual likes (validates matching quality). Secondary: retention (validates engagement). Message exchange is process metric, not outcome. |

## Sensitive Item Policy

| Category | MVP Policy | Post-MVP |
|----------|------------|----------|
| Politics | Optional, soft scoring | Optional, configurable importance |
| Religion | Optional, soft scoring | Optional, configurable importance |
| Substance use | Optional, soft scoring | Optional, dealbreaker option |
| Guns | Not included | Optional, hard filter option |
| Abortion views | Not included | Optional, hard filter option |
