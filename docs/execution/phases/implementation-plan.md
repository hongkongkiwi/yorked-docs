# Yoked: Technical Implementation Plan

Owner: Engineering
Status: Active
Last Updated: 2026-02-20
Depends On: `docs/vision/product-vision.md`, `docs/execution/phases/intent-phase-canonical-map.md`, `docs/execution/delivery-checklist.md`

## Overview

This document outlines the technical implementation plan for the Yoked MVP. It translates product requirements into technical milestones, dependencies, and resource allocation.
It executes only the `Now (MVP)` scope from the canonical map and excludes `Next/Later` idea backlog items.

## Stage Shipping Principle

Each MVP phase should end with something real users can use, not just internal progress. In practice, that means every phase must produce a usable end-to-end slice for a defined audience (internal dogfood, limited beta cohort, or broader beta), with observability and rollback ready before rollout.

## Architecture Summary

Yoked uses a hybrid model with explicit ownership boundaries:
- **Application-owned realtime:** custom WebSocket gateway for chat, typing, presence, and match events.
- **Platform-owned data plane:** Supabase Auth + Postgres for identity and core data.
- **API layer:** TypeScript REST API service in front of Supabase.

```text
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                              │
├─────────────────────────────────────────────────────────────────┤
│  React Native (iOS/Android)                                      │
│  ├── REST client                                                  │
│  └── Socket.io client (chat/presence)                             │
└─────────────────────────────────────────────────────────────────┘
             │                              │
             ▼                              ▼
┌─────────────────────────────┐   ┌───────────────────────────────┐
│ API Gateway (Node/TS REST)  │   │ WebSocket Gateway (Socket.io) │
└──────────────┬──────────────┘   └──────────────┬────────────────┘
               │                                 │
               ▼                                 ▼
        ┌───────────────┐                 ┌───────────────┐
        │ Supabase      │                 │ Redis         │
        │ Auth+Postgres │                 │ Pub/Sub, RL   │
        └───────────────┘                 └───────────────┘
               │
               ▼
        ┌───────────────┐
        │ S3+CloudFront │
        │ Photo assets  │
        └───────────────┘
```

## Technology Stack

| Layer | Technology | Version | Rationale |
|-------|------------|---------|-----------|
| Mobile | React Native | 0.73+ | Cross-platform, team expertise |
| Mobile State | React Query | 5.x | Caching, background sync |
| API | Node.js + TypeScript REST service | 20+ | Full control of authZ, rate limiting, and business logic |
| Database | PostgreSQL (Supabase) | 15+ | Full SQL, RLS, pgvector ready |
| Auth | Supabase Auth | Latest | Phone OTP, OAuth built-in |
| Storage | AWS S3 + CloudFront | Latest | Durable object storage, CDN delivery |
| Real-time (primary) | Socket.io WebSocket Gateway | 4.x | App-owned chat semantics and delivery guarantees |
| Real-time (secondary) | Supabase Realtime | Latest | Low-risk DB change subscriptions |
| Cache / PubSub | Redis (Upstash or ElastiCache) | 7+ | Rate limiting, presence, WS fanout |
| AI Moderation | OpenAI API | - | Content moderation |
| Verification | AWS Rekognition | - | Liveness, face detection |

## Why This Stack

**Hybrid ownership approach:**
- **Supabase for identity and data** - managed auth + Postgres reduce operational load.
- **Custom API for product logic** - keeps business rules and security controls centralized.
- **Custom WebSocket for chat** - needed for acknowledgments, ordering, and reconnection semantics.
- **S3 + CloudFront for media** - predictable performance and cost controls for photos.

**External services for specific needs:**
- **AWS Rekognition** - Industry standard for liveness detection
- **OpenAI Moderation** - Simple API, effective content filtering
- **Redis** - Shared state, rate limits, and WebSocket fanout

## Implementation Phases

### Phase 1: Identity & Core Platform (Weeks 1-4)

**Goal:** Core infrastructure, authentication, and user management

**Deliverables:**
- [ ] Project scaffolding (monorepo structure)
- [ ] Supabase project setup with local dev
- [ ] Database schema (migrations)
- [ ] Authentication service (phone OTP)
- [ ] User profile API
- [ ] React Native app skeleton
- [ ] Navigation structure
- [ ] API client with auth handling

**Key Decisions:**
- Monorepo: `apps/mobile`, `apps/api`, `packages/shared`
- Database migrations: Supabase CLI
- State management: React Query (server), Zustand (client)

**Dependencies:** None

**Success Criteria:**
- Team can run full stack locally
- Can create user via API
- Can authenticate in mobile app

**Ship Criteria:**
- Primary phase flow works end-to-end in staging.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

---

### Phase 2: Onboarding & Verification Journey (Weeks 5-8)

**Goal:** Complete onboarding flow from download to match-ready

**Deliverables:**
- [ ] Phone OTP UI (send, verify, resend)
- [ ] Profile creation screens
- [ ] Location permission + manual entry
- [ ] Compatibility questionnaire system
- [ ] Question set versioning
- [ ] Photo verification (liveness detection)
- [ ] AWS Rekognition integration
- [ ] Onboarding state machine
- [ ] Analytics events

**Key Decisions:**
- Questionnaire: Progressive disclosure, one question per screen
- Profiling model: integrate psychological and physical preference prompts in one flow
- Photo verification: AWS Rekognition Face Liveness
- Age verification: policy gate for legal/safety checks only (no attractiveness/ranking input)
- Progress persistence: Auto-save after each question

**Dependencies:** Phase 1

**Success Criteria:**
- User can complete onboarding in < 10 minutes
- Photo verification < 10 seconds
- 90%+ verification success rate

**Ship Criteria:**
- Onboarding and verification journey works end-to-end in staging.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

---

### Phase 3: Curated Matching Experience (Weeks 9-12)

**Goal:** Daily match generation and offer presentation

**Deliverables:**
- [ ] Compatibility scoring algorithm
- [ ] Matchmaking job scheduler
- [ ] Daily batch generation (idempotent)
- [ ] Match offer API
- [ ] Accept/Pass/Not Now actions
- [ ] Mutual match detection
- [ ] Match offer UI (card stack)
- [ ] Push notification service
- [ ] Daily match notification

**Key Decisions:**
- Batch time: 9 AM local time
- Algorithm: Composite score (psych compatibility + physical preference affinity) + hard filters
- Offers per day: 1-5 (configurable)
- Offer expiry: 6 days
- Active match limits: behavior/risk based only (no demographic caps)

**Dependencies:** Phase 2

**Success Criteria:**
- Match generation < 5 min per 1000 users
- API response < 200ms for offers
- Zero duplicate offers

**Ship Criteria:**
- Offer generation, decision actions, and match creation work end-to-end in staging.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

---

### Phase 4: Real-Time Messaging Experience (Weeks 13-16)

**Goal:** Real-time messaging between matches

**Deliverables:**
- [ ] WebSocket gateway infrastructure
- [ ] Message sending/receiving
- [ ] Message persistence
- [ ] Read receipts
- [ ] Typing indicators
- [ ] Message history pagination
- [ ] Chat UI (message bubbles, timestamps)
- [ ] Messages list screen
- [ ] Push notifications for messages

**Key Decisions:**
- WebSocket: Socket.io with Redis adapter
- Message order: Server timestamp
- First message policy: free-for-all in MVP
- Pagination: 50 messages per request
- Fallback: REST polling if WebSocket fails

**Dependencies:** Phase 3

**Success Criteria:**
- Message delivery < 100ms
- WebSocket uptime > 99.5%
- Messages per match > 5 average

**Ship Criteria:**
- Send/receive/reconnect messaging flows work end-to-end in staging.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

---

### Phase 5: Trust & Safety Experience (Weeks 17-20)

**Goal:** Trust & safety infrastructure

**Deliverables:**
- [ ] Content moderation pipeline
- [ ] AI moderation integration (OpenAI/AWS)
- [ ] Report submission system
- [ ] Block/unmatch functionality
- [ ] Moderation queue UI
- [ ] Safety response workflows
- [ ] Evidence preservation
- [ ] CSAM detection integration

**Key Decisions:**
- Moderation: AI pre-screen + human review
- Response times: Critical < 15 min, High < 4 hours
- Evidence retention: 90 days minimum

**Dependencies:** Phase 4

**Success Criteria:**
- Critical reports responded to < 15 minutes
- False positive rate < 5%
- Zero safety incidents during beta

**Ship Criteria:**
- Report/block/moderation/escalation flows work end-to-end in staging.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

---

### Phase 6: Reliability & Launch Experience (Weeks 21-24)

**Goal:** Production readiness and beta launch

**Deliverables:**
- [ ] Performance optimization
- [ ] Error handling improvements
- [ ] App store submission prep
- [ ] Beta testing infrastructure
- [ ] Analytics dashboards
- [ ] Monitoring and alerting
- [ ] Documentation completion
- [ ] Security audit

**Dependencies:** Phase 5

**Success Criteria:**
- App store approval
- Load tested to 10K concurrent users
- All P0 bugs resolved

**Ship Criteria:**
- Release candidate passes reliability, policy, and app-store readiness checks.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

## Database Schema Overview

See `docs/technical/schema/database.md` for complete schema documentation.

**Core Tables:**
- `users` - User accounts and profile data
- `profiles` - Extended profile information
- `compatibility_responses` - Questionnaire answers
- `match_offers` - Daily match offers
- `matches` - Mutual matches
- `messages` - Chat messages
- `reports` - Safety reports
- `verification_sessions` - Photo verification

**Infrastructure:**
- OpenTofu for IaC (see `docs/ops/infrastructure.md`)
- Supabase CLI for migrations

## API Endpoints

See `docs/technical/contracts/openapi.yaml` for complete API specification.

**Endpoint Groups:**
- `/auth/*` - Authentication
- `/users/*` - User management
- `/compatibility/*` - Questionnaire
- `/verification/*` - Photo verification
- `/matches/*` - Matching
- `/safety/*` - Reporting and blocking

## Infrastructure Requirements

### Development Environment

```yaml
Local:
  - Docker Desktop
  - Supabase CLI
  - Node.js 20+
  - React Native dev environment
  - Redis (Docker)
```

### Staging Environment

```yaml
AWS:
  - ECS Fargate (API + WebSocket)
  - Supabase (managed)
  - ElastiCache Redis
  - S3 (photo storage)
  - CloudWatch (logs, metrics)
  - Route53 (DNS)

Provisioning:
  - OpenTofu (infrastructure as code)
  - See docs/ops/infrastructure.md
```

### Production Environment

```yaml
AWS:
  - ECS Fargate (auto-scaling)
  - Supabase (managed)
  - ElastiCache Redis (cluster mode)
  - S3 + CloudFront (photos)
  - CloudWatch + PagerDuty
  - WAF (security)

Provisioning:
  - OpenTofu (infrastructure as code)
  - See docs/ops/infrastructure.md
```

## Testing Strategy

See `docs/ops/testing-strategy.md` for detailed testing plan.

**Testing Levels:**
1. Unit tests (Jest) - 80%+ coverage
2. Integration tests - API endpoints
3. Contract tests - OpenAPI compliance
4. E2E tests (Maestro) - Critical user flows
5. Load tests (k6) - Matchmaking, chat

## Security Checklist

- [ ] Phone number hashing at rest
- [ ] OTP rate limiting
- [ ] JWT token rotation
- [ ] Row Level Security (RLS) policies
- [ ] Input validation (Zod schemas)
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS protection
- [ ] CSRF tokens
- [ ] HTTPS everywhere
- [ ] Security headers
- [ ] Dependency scanning
- [ ] Secrets management (not in code)

## Performance Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| API p95 latency | < 500ms | All endpoints |
| WebSocket message delivery | < 100ms | Chat messages |
| App cold start | < 3s | React Native |
| Image load | < 2s | Profile photos |
| Onboarding completion | < 10 min | End-to-end |

## Monitoring & Observability

**Metrics:**
- Request rate, latency, errors (RED method)
- Database query performance
- WebSocket connection health
- Business metrics (matches, messages)

**Logging:**
- Structured JSON logs
- Correlation IDs
- Error tracking (Sentry)

**Alerting:**
- PagerDuty integration
- On-call rotation
- Severity-based escalation

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Supabase scaling limits | Monitor, plan migration path |
| WebSocket scaling | Redis adapter, horizontal scaling |
| Photo storage costs | Compression, lifecycle policies |
| AI service outages | Circuit breakers, fallbacks |
| Database performance | Query optimization, indexing |

## Team Allocation

| Phase | Backend | Mobile | ML/AI | QA |
|-------|---------|--------|-------|-----|
| 1. Foundation | 100% | 50% | - | - |
| 2. Onboarding | 75% | 100% | 50% | - |
| 3. Matching | 100% | 75% | 100% | 50% |
| 4. Chat | 100% | 100% | - | 100% |
| 5. Safety | 75% | 50% | 50% | 100% |
| 6. Polish | 50% | 75% | - | 100% |

## Resolved Technical Decisions

| Question | Decision | Notes |
|----------|----------|-------|
| Supabase Realtime vs WebSocket | Hybrid ownership model | WebSocket owns chat/presence; Supabase Realtime handles non-critical DB updates. See ADR-0002. |
| Match algorithm iteration | Manual for MVP | Iterate based on feedback. Add A/B testing post-launch. |
| Photo CDN | S3 + CloudFront | Built-in CDN, global edge caching. |
| GraphQL | No for MVP | REST is simpler. Revisit if mobile team requests. |
| Backup/DR | Daily backups, 4-hour RTO | Balanced cost/recovery. See docs/ops/infrastructure.md. |

> **All configuration values are tunable.** See `docs/ops/configuration.md` for the complete list of configurable parameters.

## Appendix

### Development Setup

```bash
# Clone and setup
git clone https://github.com/your-org/yoked.git
cd yoked

# Install dependencies
npm install

# Start local infrastructure
npx supabase start
docker-compose up -d redis

# Run migrations
npx supabase db reset

# Start development
npm run dev:api
npm run dev:mobile
```

### Deployment Process

1. PR review required
2. CI passes (tests, lint, typecheck)
3. Deploy to staging
4. Smoke tests
5. Deploy to production
6. Monitor for 30 minutes

---

*This plan is a living document. Update as technical decisions evolve.*
