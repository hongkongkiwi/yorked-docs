# AI Strategy

Owner: Applied AI + Engineering  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/vision/product-vision.md`, `docs/technical/decisions/ADR-0005-ai-model-routing.md`

## Overview

Yoked uses AI across three domains:

| Domain | Tasks | Providers | Criticality |
|--------|-------|-----------|-------------|
| Safety & Verification | Liveness, moderation, toxicity | Specialized APIs | High |
| Matching Engine | Psych scoring, visual affinity, reasons | LLMs (OpenRouter/Vertex AI) | Medium |
| Conversation Coaching | Opening lines, assists | LLMs (OpenRouter/Vertex AI) | Low |

## Provider Strategy

### Specialized APIs (Safety)

These use purpose-built APIs with high accuracy and compliance:

- **Amazon Rekognition**: Liveness detection, age estimation
- **Google Vision**: Fallback for liveness
- **OpenAI Moderation**: Primary chat moderation
- **AWS Comprehend**: Fallback moderation
- **Perspective API**: Toxicity detection

See `docs/technical/decisions/ADR-0005-ai-model-routing.md` for routing tables.

### LLM Providers (Matching & Coaching)

**Primary: OpenRouter**

- Single API for multiple models (Claude, GPT-4, Llama, etc.)
- Automatic failover between models
- Cost optimization via model selection
- No vendor lock-in

**Fallback: Vertex AI**

- Direct GCP integration
- Gemini models
- Enterprise SLA and data residency controls

## Matching Engine AI

### Components

1. **Psychological Compatibility Model**
   - Input: Questionnaire construct scores
   - Output: `psych_fit` [0,1], confidence, reason codes
   - Constraint: Must be deterministic given same inputs

2. **Visual Preference Model**
   - Input: VPS profiles for both users
   - Output: `visual_affinity` [0,1] per direction
   - Constraint: Capped contribution to final score

3. **Reason Generator**
   - Input: Deterministic reason codes + strengths
   - Output: User-facing explanation text
   - Constraint: Template-grounded, no free-form inference

### Safeguards

- All outputs clamped to [0,1]
- Confidence thresholds for acceptance
- Model version pinning
- Deterministic fallback when LLMs unavailable
- Audit logging for all inference

### Internal API

```
POST /internal/ai/psych-fit
POST /internal/ai/visual-affinity
POST /internal/ai/reason-codes/render
```

These are internal-only, not in public OpenAPI contract.

## Conversation Coaching

### Scope

- Opening line suggestions
- Conversation assists (future)
- Not: autonomous messaging, profile writing

### Privacy Controls

- Filter PII before API calls
- Hash user IDs
- No training on Yoked data
- 30-day prompt/output retention for audit

### Fallback

- If both LLM providers fail: show generic "start the conversation" prompt
- High latency (>2s): skip suggestion, allow manual compose

## Model Versioning

- Pin specific model versions in production
- A/B test new versions via feature flags
- Gradual rollout with metrics monitoring
- Rollback on quality degradation

## Cost Controls

| Domain | Budget Strategy |
|--------|-----------------|
| Safety | Per-request quotas, daily caps |
| Matching | Batch processing, cache results |
| Coaching | Rate limit per user, daily caps |

## Monitoring

See `docs/technical/decisions/ADR-0005-ai-model-routing.md` for full metrics and alerting.

Key dashboards:
- Provider health and latency
- LLM token usage and cost
- Fallback rates
- Output quality metrics

## Related Docs

- `docs/technical/decisions/ADR-0005-ai-model-routing.md` - Full routing tables and fallback behavior
- `docs/specs/matching-scoring-engine.md` - Matching engine AI architecture
- `docs/specs/safety.md` - Safety verification requirements
- `docs/ops/configuration.md` - AI-related config keys
