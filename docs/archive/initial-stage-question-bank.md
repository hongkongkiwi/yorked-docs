# Feature Specification: Initial-Stage Question Bank

Owner: Product + Research  
Status: Deprecated  
Last Updated: 2026-02-20  
Depends On: `docs/specs/onboarding.md`, `docs/technical/contracts/openapi.yaml`, `docs/technical/schema/database.md`

> Superseded by `docs/specs/science-backed-relationship-question-bank.md` for production question design and required-item policy.

## Overview

This document defines candidate questions for the **initial onboarding stage** of compatibility profiling.
The source list comes from a Marriage Pact 2025-style questionnaire and has been normalized for product usage.

## Goals

- Capture high-signal compatibility inputs early.
- Keep wording neutral and answerable.
- Use standardized answer formats compatible with `GET /compatibility/questions` and `POST /compatibility/responses`.

## Response Formats

- `single_choice`: Pick one option.
- `multiple_choice`: Pick one or more options.
- `slider` (1-7): Likert-style scale.

## Slider Scale Rules (1-7)

Default meaning unless overridden:
- `1` = strongly disagree / less
- `7` = strongly agree / more

For bipolar prompts, custom anchors are provided per question.

## Section A: Core Intake Questions (Categorical + Strength)

| ID | Prompt | Type | Category | Notes |
|---|---|---|---|---|
| Q001 | What is your sexual orientation? | single_choice | background | Include "prefer not to say" and self-describe option. |
| Q002 | Which genders are you open to being matched with? | multiple_choice | background | Allow multi-select and self-describe. |
| Q003 | How do you identify politically? | single_choice | values | Include "prefer not to say". |
| Q004 | How strongly do you care about your partner's political identity? | slider | values | 1 = not at all, 7 = very strongly. |
| Q005 | Which political identity do you prefer in a partner? | single_choice | values | Ask only if Q004 >= 4. |
| Q006 | How do you identify religiously? | single_choice | values | Include "not religious", "spiritual", and self-describe. |
| Q007 | How strongly do you care about your partner's religion? | slider | values | 1 = not at all, 7 = very strongly. |
| Q008 | How do you identify ethnically? | single_choice | background | Multi-select can be enabled if needed. |
| Q009 | How strongly do you care about your partner's ethnicity? | slider | values | 1 = not at all, 7 = very strongly. |

## Section B: 1-7 Scale Candidate Questions

| ID | Prompt | Category | Anchors |
|---|---|---|---|
| Q101 | It is okay if my partner drinks alcohol. | lifestyle | 1 = strongly disagree, 7 = strongly agree |
| Q102 | It is okay if my partner smokes (including cigarettes/vapes). | lifestyle | 1 = strongly disagree, 7 = strongly agree |
| Q103 | It is okay if my partner uses soft or hard drugs. | lifestyle | 1 = strongly disagree, 7 = strongly agree |
| Q104 | I am the life of the party. | lifestyle | 1 = strongly disagree, 7 = strongly agree |
| Q105 | It is best to split the bill on the first date. | values | 1 = strongly disagree, 7 = strongly agree |
| Q106 | I would bring a hookup home to an unmade bed. | lifestyle | 1 = strongly disagree, 7 = strongly agree |
| Q107 | It is better to wait a long time before having sex. | values | 1 = strongly disagree, 7 = strongly agree |
| Q108 | I find politically incorrect humor funny. | interests | 1 = strongly disagree, 7 = strongly agree |
| Q109 | It is unacceptable to use AI to write wedding vows. | values | 1 = strongly disagree, 7 = strongly agree |
| Q110 | I always vote. | values | 1 = strongly disagree, 7 = strongly agree |
| Q111 | When someone vents to me, I first offer emotions vs advice. | communication | 1 = emotions first, 7 = advice first |
| Q112 | Sex is important to me in a relationship. | values | 1 = strongly disagree, 7 = strongly agree |
| Q113 | I am open to being in a non-monogamous relationship. | values | 1 = strongly disagree, 7 = strongly agree |
| Q114 | My partner can be friends with an ex. | values | 1 = strongly disagree, 7 = strongly agree |
| Q115 | Everyone deserves my empathy. | values | 1 = strongly disagree, 7 = strongly agree |
| Q116 | I generally like to take control during sex. | lifestyle | 1 = strongly disagree, 7 = strongly agree |
| Q117 | Exercising is an important part of my lifestyle. | lifestyle | 1 = strongly disagree, 7 = strongly agree |
| Q118 | I track every dollar I spend. | lifestyle | 1 = strongly disagree, 7 = strongly agree |
| Q119 | I have said "I love you" even when I did not mean it. | communication | 1 = strongly disagree, 7 = strongly agree |
| Q120 | I want children. | values | 1 = strongly disagree, 7 = strongly agree |
| Q121 | It is important that my children spend some time growing up outside the U.S. | values | 1 = strongly disagree, 7 = strongly agree |
| Q122 | It is important that my children are raised religious. | values | 1 = strongly disagree, 7 = strongly agree |
| Q123 | I am comfortable with my child being gay. | values | 1 = strongly disagree, 7 = strongly agree |
| Q124 | I say what is bothering me, even if it makes others uncomfortable. | communication | 1 = strongly disagree, 7 = strongly agree |
| Q125 | I respect activists. | values | 1 = strongly disagree, 7 = strongly agree |
| Q126 | I believe I can truly change the world. | values | 1 = strongly disagree, 7 = strongly agree |
| Q127 | I believe in a higher power. | values | 1 = strongly disagree, 7 = strongly agree |
| Q128 | I would end a friendship over political differences. | values | 1 = strongly disagree, 7 = strongly agree |
| Q129 | I want to be part of the top 1%. | values | 1 = strongly disagree, 7 = strongly agree |
| Q130 | I go to great lengths to minimize my harm to the planet. | values | 1 = strongly disagree, 7 = strongly agree |
| Q131 | AI is a net good for society. | values | 1 = strongly disagree, 7 = strongly agree |
| Q132 | Sex without love is meaningless. | values | 1 = strongly disagree, 7 = strongly agree |
| Q133 | It is important that my partner has an artistic side. | interests | 1 = strongly disagree, 7 = strongly agree |
| Q134 | I usually find it harder to chill out vs get hyped up. | lifestyle | 1 = harder to chill out, 7 = harder to get hyped up |
| Q135 | I would go on spontaneous trips even if it means postponing responsibilities. | lifestyle | 1 = strongly disagree, 7 = strongly agree |
| Q136 | I have a dry sense of humor. | interests | 1 = strongly disagree, 7 = strongly agree |
| Q137 | I would rather have a partner who plans meticulously vs goes with the flow. | lifestyle | 1 = meticulously plans, 7 = goes with the flow |
| Q138 | I consider myself to be an adult. | values | 1 = strongly disagree, 7 = strongly agree |
| Q139 | I would send a dish back at a restaurant. | lifestyle | 1 = strongly disagree, 7 = strongly agree |
| Q140 | It is important that my parents approve of my partner. | values | 1 = strongly disagree, 7 = strongly agree |
| Q141 | I would rather ghost someone than reject them directly. | communication | 1 = strongly disagree, 7 = strongly agree |
| Q142 | The world needs more realism vs more imagination. | values | 1 = more realism, 7 = more imagination |
| Q143 | Abortion should be legal. | values | 1 = strongly disagree, 7 = strongly agree |
| Q144 | I avoid burning bridges at all costs. | communication | 1 = strongly disagree, 7 = strongly agree |
| Q145 | I would keep a gun in the house. | values | 1 = strongly disagree, 7 = strongly agree |
| Q146 | I run most major decisions by my parents. | communication | 1 = strongly disagree, 7 = strongly agree |
| Q147 | Billionaires should not exist. | values | 1 = strongly disagree, 7 = strongly agree |
| Q148 | I would rather fail than cheat on an exam. | values | 1 = strongly disagree, 7 = strongly agree |
| Q149 | I am the most important person in my life. | values | 1 = strongly disagree, 7 = strongly agree |
| Q150 | I am smarter than most people I meet. | background | 1 = strongly disagree, 7 = strongly agree |
| Q151 | How single are you right now? | background | 1 = very single, 7 = in a relationship |

## Legacy Suggested Subset (Non-Canonical)

This subset is retained as historical reference from the Marriage Pact-style source list.
Do not use this section as the canonical implementation source.

- Q002 Match gender preferences
- Q004 Partner political-identity importance
- Q007 Partner religion importance
- Q009 Partner ethnicity importance
- Q111 Emotions vs advice communication style
- Q112 Importance of sex in a relationship
- Q120 Desire for children
- Q127 Belief in a higher power
- Q137 Planning style preference in partner
- Q151 Current relationship status

All other questions remain optional in early onboarding and can be asked adaptively.

## Content and Safety Notes

- Several prompts are sensitive (politics, religion, ethnicity, sex, abortion, guns). Show a "prefer not to answer" path where appropriate.
- For high-risk or polarizing prompts, include optional skip behavior and explain how responses are used.
- Keep question wording neutral and avoid framing that pressures users toward one social viewpoint.

## Open Questions

1. Should drug-use tolerance be split into separate prompts for cannabis and hard drugs?
2. Should non-monogamy questions be gated by relationship-intent responses?
3. Do we require hard constraints (must-match) vs soft preferences for politics/religion/ethnicity?
