# ADR-0005: AI Model Routing and Fallback

Date: 2026-02-19
Status: Accepted
Owner: Engineering + Applied AI
Last Updated: 2026-02-20
Depends On: `docs/technical/ai/README.md`, `docs/specs/safety.md`, `docs/specs/onboarding.md`, `docs/specs/matching-scoring-engine.md`

## Context

Yoked uses AI for:

**Safety & Verification (Specialized APIs):**
- Photo verification (liveness detection)
- Age estimation
- Content moderation (chat safety)
- Toxicity detection

**Matching Engine (LLMs via OpenRouter/Vertex AI):**
- Psychological compatibility scoring
- Visual preference affinity
- Match reason generation

**Conversation Coaching (LLMs via OpenRouter/Vertex AI):**
- Conversation assistance (future)
- Opening line suggestions

We need a policy for model selection, routing, and fallback when providers fail.

## Decision

Implement **tiered AI routing** with:
1. Primary provider per task type
2. Secondary fallback for critical paths
3. Circuit breaker pattern for resilience
4. Human review queue for low-confidence predictions

## Rationale

### Why Multiple Providers

1. **Reliability**
   - No single point of failure
   - Graceful degradation
   - 99.9% uptime for critical AI functions

2. **Capability Matching**
   - Different providers excel at different tasks
   - Optimize for accuracy per task
   - Cost optimization

3. **Vendor Independence**
   - Avoid lock-in
   - Negotiating leverage
   - Regulatory flexibility (EU AI Act)

### Why Circuit Breaker

- Prevents cascading failures
- Reduces costs during outages
- Faster failure detection
- Automatic recovery

## Provider Selection

### Task-Based Routing

**Safety & Verification (Specialized APIs):**

| Task | Primary | Fallback | Human Review Trigger |
|------|---------|----------|---------------------|
| Liveness detection | Amazon Rekognition | Google Vision | Confidence < 90% |
| Age estimation | Amazon Rekognition | Manual review | Confidence < 85% |
| Chat moderation | OpenAI Moderation | AWS Comprehend | Confidence < 70% |
| Toxicity detection | Perspective API | OpenAI Moderation | Confidence < 75% |

**Matching Engine (LLMs via OpenRouter/Vertex AI):**

| Task | Primary | Fallback | Notes |
|------|---------|----------|-------|
| Psych compatibility | OpenRouter (Claude) | Vertex AI (Gemini) | Bounded output [0,1] |
| Visual affinity | OpenRouter (Claude) | Vertex AI (Gemini) | Requires VPS profiles |
| Reason generation | OpenRouter (Claude) | Vertex AI (Gemini) | Template-grounded only |

**Conversation Coaching (LLMs via OpenRouter/Vertex AI):**

| Task | Primary | Fallback | Notes |
|------|---------|----------|-------|
| Opening suggestions | OpenRouter (Claude) | Vertex AI (Gemini) | Context-limited |
| Conversation assists | OpenRouter (Claude) | Vertex AI (Gemini) | Privacy-filtered inputs |

### LLM Provider Strategy

**Why OpenRouter + Vertex AI:**

1. **OpenRouter Benefits:**
   - Single API for multiple model providers (Anthropic, OpenAI, Meta, etc.)
   - Automatic failover between models
   - Cost optimization via model selection
   - No vendor lock-in

2. **Vertex AI Benefits:**
   - Direct GCP integration (same cloud as potential infrastructure)
   - Gemini models for fallback
   - Enterprise SLA and support
   - Data residency controls

3. **Why Two Providers:**
   - OpenRouter for flexibility and cost
   - Vertex AI for reliability and compliance backup
   - No single point of failure

### Selection Criteria

**Primary Selection:**
- Accuracy on validation set
- Latency (p95 < 500ms)
- Cost per request
- Privacy compliance (GDPR, biometric laws)

**Fallback Selection:**
- Different provider (not just different model)
- Lower accuracy acceptable for availability
- Higher cost acceptable for critical path

**LLM Selection:**
- Primary: OpenRouter (best cost/performance, multi-model access)
- Fallback: Vertex AI (enterprise reliability, data residency)
- Model selection per task based on capability benchmarks

## Implementation

### Routing Layer

```typescript
interface ModelRouter {
  route(task: Task, input: unknown): Promise<Result>;
}

class TieredRouter implements ModelRouter {
  private providers: Map<string, Provider[]>;
  private circuitBreakers: Map<string, CircuitBreaker>;
  
  async route(task: Task, input: unknown): Promise<Result> {
    const providers = this.providers.get(task);
    
    for (const provider of providers) {
      const cb = this.circuitBreakers.get(provider.name);
      
      if (cb.isOpen()) {
        continue; // Skip failed provider
      }
      
      try {
        const result = await provider.call(input);
        cb.recordSuccess();
        
        // Check if human review needed
        if (result.confidence < task.humanReviewThreshold) {
          await this.queueHumanReview(task, input, result);
        }
        
        return result;
      } catch (error) {
        cb.recordFailure();
        logger.warn(`${provider.name} failed for ${task}`, error);
      }
    }
    
    throw new Error(`All providers failed for task ${task}`);
  }
}
```

### Circuit Breaker

```typescript
class CircuitBreaker {
  private state: 'closed' | 'open' | 'half-open' = 'closed';
  private failureCount = 0;
  private lastFailureTime?: Date;
  
  constructor(
    private failureThreshold = 5,
    private resetTimeoutMs = 30000
  ) {}
  
  isOpen(): boolean {
    if (this.state === 'open') {
      if (Date.now() - this.lastFailureTime.getTime() > this.resetTimeoutMs) {
        this.state = 'half-open';
        return false;
      }
      return true;
    }
    return false;
  }
  
  recordSuccess(): void {
    this.failureCount = 0;
    this.state = 'closed';
  }
  
  recordFailure(): void {
    this.failureCount++;
    this.lastFailureTime = new Date();
    
    if (this.failureCount >= this.failureThreshold) {
      this.state = 'open';
    }
  }
}
```

### Confidence Scoring

```typescript
interface PredictionResult {
  prediction: string;
  confidence: number; // 0-1
  provider: string;
  latencyMs: number;
  rawResponse: unknown;
}

// Human review thresholds
const HUMAN_REVIEW_THRESHOLDS = {
  'liveness': 0.90,
  'age-estimation': 0.85,
  'chat-moderation': 0.70,
  'toxicity': 0.75
};

function needsHumanReview(result: PredictionResult, task: Task): boolean {
  return result.confidence < HUMAN_REVIEW_THRESHOLDS[task];
}
```

## Fallback Behavior

### Graceful Degradation

**Safety & Verification:**

| Scenario | Behavior |
|----------|----------|
| Liveness primary fails | Use fallback, increase human review rate |
| All liveness fails | Block verification, queue for manual review |
| Moderation primary fails | Use fallback, reduce auto-actions |
| All moderation fails | Queue all content for human review |

**Matching Engine LLMs:**

| Scenario | Behavior |
|----------|----------|
| OpenRouter fails | Route to Vertex AI |
| Both LLM providers fail | Use deterministic fallback scoring |
| Psych model unavailable | Skip candidate for batch, log failure |
| Reason generator fails | Use default template reasons |

**Conversation Coaching:**

| Scenario | Behavior |
|----------|----------|
| OpenRouter fails | Route to Vertex AI |
| Both LLM providers fail | Disable coaching feature, show generic message |
| High latency (>2s) | Skip suggestion, allow manual compose |

### User Experience

- Never show provider errors to users
- Show "processing..." during fallback
- If all providers fail, route to human review
- Set user expectations for verification time

## Privacy and Compliance

### Data Handling

**Specialized APIs:**

| Provider | Data Residency | Retention | GDPR |
|----------|---------------|-----------|------|
| Amazon Rekognition | Configurable | 0 (no storage) | DPA signed |
| Google Vision | Configurable | 0 (no storage) | DPA signed |
| OpenAI Moderation | US | 30 days for abuse | DPA signed |
| AWS Comprehend | Configurable | 0 (no storage) | DPA signed |
| Perspective API | US | Varies | DPA available |

**LLM Providers:**

| Provider | Data Residency | Retention | GDPR | Notes |
|----------|---------------|-----------|------|-------|
| OpenRouter | Varies by model | Model-dependent | Check per model | Routes to multiple providers |
| Vertex AI | Configurable (US/EU) | Configurable | DPA signed | Enterprise data controls |

### LLM Data Privacy

For matching engine and conversation coaching:
- Send only anonymized/aggregate data (no PII)
- User IDs hashed before sending to LLM
- Conversation coaching: filter out sensitive content before API call
- No training on Yoked data (opt-out where applicable)
- Log all prompts/outputs for audit (30-day retention)

### Biometric Data

- Raw photos: Deleted within 24 hours
- Face vectors: Deleted 30 days after account deletion
- No biometric data sent to third parties (only photos)
- Explicit consent required

## Monitoring

### Metrics

**Safety & Verification:**

| Metric | Target | Alert |
|--------|--------|-------|
| Provider availability | > 99.5% | < 99% |
| Average latency | < 300ms | > 500ms |
| Fallback rate | < 5% | > 10% |
| Human review rate | < 10% | > 20% |
| Cost per request | Baseline | > 150% baseline |

**Matching Engine LLMs:**

| Metric | Target | Alert |
|--------|--------|-------|
| LLM availability | > 99% | < 98% |
| Average latency | < 1s | > 2s |
| Output in bounds | 100% | < 99% |
| Cost per match batch | Baseline | > 150% baseline |
| Token usage per request | Tracked | Anomaly detection |

**Conversation Coaching:**

| Metric | Target | Alert |
|--------|--------|-------|
| Suggestion latency | < 1.5s | > 3s |
| Acceptance rate | > 20% | < 10% |
| Skip rate | < 50% | > 70% |

### Alerting

- Circuit breaker opens
- All providers fail for task
- Latency p95 > 1 second (safety) or > 2 seconds (LLM)
- Human review queue depth > 100
- LLM cost exceeds daily budget

## Consequences

### Positive

- High availability for AI features
- Optimized accuracy per task
- Cost control
- Vendor independence

### Tradeoffs

- More complex infrastructure
- Multiple provider integrations
- Higher baseline cost (maintaining fallbacks)
- Consistency challenges across providers

### Risks

| Risk | Mitigation |
|------|------------|
| Provider API changes | Abstract behind internal API, versioned contracts |
| Inconsistent predictions | Calibrate confidence scores per provider |
| Cost overruns | Rate limiting, quotas per provider |
| Privacy violations | DPA audits, data residency controls |

## Future Considerations

### Model Versioning

- Pin model versions in production
- A/B test new versions
- Gradual rollout with monitoring

### Custom Models

- Train custom models for specific tasks
- Reduce dependency on third parties
- Improve accuracy for dating-specific content

### Edge Deployment

- Deploy models on-device for privacy
- Liveness detection on mobile
- Reduce latency and server costs

## Validation

Success metrics:
- AI feature uptime > 99.9%
- False positive rate < 5%
- Human review queue processed within SLA
- Cost per verification < $0.10

## Related Docs

- `docs/specs/safety.md`
- `docs/ops/privacy-security.md`
