# Yoked: Technical Implementation Plan

Owner: Engineering
Status: Active
Last Updated: 2026-02-23
Depends On: `docs/vision/product-vision.md`, `docs/execution/epic-plans/intent-phase-canonical-map.md`, `docs/execution/delivery-checklist.md`

## Overview

This document outlines the technical implementation plan for the Yoked MVP. It translates product requirements into technical milestones, dependencies, and resource allocation.
It executes the `Now (MVP)` scope from the canonical map. Deferred post-launch work is captured under `Post-Launch (Next)` for planning continuity and is explicitly out of MVP scope.

## Stage Shipping Principle

Each MVP epic should end with something real users can use, not just internal progress. In practice, that means every epic must produce a usable end-to-end slice for a defined audience (internal dogfood, limited beta cohort, or broader beta), with observability and rollback ready before rollout.

## Architecture Summary

Yoked uses a hybrid model with explicit ownership boundaries:
- **MVP messaging transport:** REST APIs + push notifications with polling sync.
- **Post-launch realtime transport:** custom WebSocket gateway for typing, presence, and low-latency chat.
- **Platform-owned data plane:** Supabase Auth + Postgres for identity and core data.
- **API layer:** TypeScript REST API service in front of Supabase.

```text
┌──────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                             │
├──────────────────────────────────────────────────────────────────┤
│  React Native (iOS/Android)                                     │
│  ├── REST client (MVP)                                           │
│  ├── Push notifications (MVP)                                    │
│  └── Socket.io client (Post-launch / Next)                       │
└──────────────────────────────────────────────────────────────────┘
                      │
                      ▼
┌────────────────────────────────┐
│ API Gateway (Node/TS REST)     │
└───────────────┬────────────────┘
                │
                ▼
         ┌───────────────┐
         │ Supabase      │
         │ Auth+Postgres │
         └───────────────┘
                │
                ▼
         ┌───────────────┐
         │ S3+CloudFront │
         │ Photo assets  │
         └───────────────┘

(Post-launch / Next)
Client Socket.io <-> WebSocket Gateway (Socket.io) <-> Redis
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
| Messaging transport (MVP) | REST + Push + Polling | - | Lowest-risk path for launch |
| Messaging transport (Post-launch) | Socket.io WebSocket Gateway | 4.x | Lower latency and richer presence semantics |
| Cache / PubSub | Redis (Upstash or ElastiCache) | 7+ | Rate limiting now; websocket fanout post-launch |
| AI Moderation | OpenAI API | - | Content moderation |
| Verification | AWS Rekognition | - | Liveness, face detection |

## Why This Stack

**Hybrid ownership approach:**
- **Supabase for identity and data** - managed auth + Postgres reduce operational load.
- **Custom API for product logic** - keeps business rules and security controls centralized.
- **MVP chat via REST + push/polling** - faster to launch with lower operational complexity.
- **WebSocket deferred to post-launch** - enables typing/presence and lower latency once MVP stabilizes.
- **S3 + CloudFront for media** - predictable performance and cost controls for photos.

**External services for specific needs:**
- **AWS Rekognition** - Industry standard for liveness detection
- **OpenAI Moderation** - Simple API, effective content filtering
- **Redis** - Shared state and rate limits now; websocket fanout post-launch

## Implementation Epics

### Planning Assumptions (AI-Assisted Delivery)

- Team composition: experienced cross-functional team (backend, mobile, and QA ownership covered).
- AI usage: code scaffolding, test generation, migration drafts, and documentation acceleration.
- Human gates remain mandatory for security, architecture, and release decisions.
- Timelines below assume focused scope control (MVP only) and limited parallel priority shifts.

### Epic 1: Identity & Core Platform (Weeks 1-2)

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
- Primary epic flow works end-to-end in staging.
- No open P0 defects within epic scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

---

### Epic 2: Onboarding & Verification Journey (Weeks 3-5)

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

**Dependencies:** Epic 1

**Success Criteria:**
- User can complete onboarding in < 10 minutes
- Photo verification < 10 seconds
- 90%+ verification success rate

**Ship Criteria:**
- Onboarding and verification journey works end-to-end in staging.
- No open P0 defects within epic scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

---

### Epic 3: Curated Matching Experience (Weeks 6-8)

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

**Dependencies:** Epic 2

**Success Criteria:**
- Match generation < 5 min per 1000 users
- API response < 200ms for offers
- Zero duplicate offers

**Ship Criteria:**
- Offer generation, decision actions, and match creation work end-to-end in staging.
- No open P0 defects within epic scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

---

### Epic 4: Messaging Core Experience (Polling + Push) (Weeks 9-10)

**Goal:** Reliable messaging between matches without realtime infrastructure

**Deliverables:**
- [ ] REST messaging endpoints (send/list/ack)
- [ ] Message persistence
- [ ] Polling sync strategy (active + background cadence)
- [ ] Read receipts
- [ ] Message history pagination
- [ ] Chat UI (message bubbles, timestamps)
- [ ] Messages list screen
- [ ] Push notifications for new messages
- [ ] Offline retry queue for pending sends

**Key Decisions:**
- Transport: REST + push + polling (no WebSocket in MVP)
- Message order: Server timestamp
- First message policy: free-for-all in MVP
- Pagination: 50 messages per request
- Typing/presence indicators deferred to post-launch

**Dependencies:** Epic 3

**Success Criteria:**
- Message sync latency < 5s while chat screen is active
- Messaging endpoint p95 latency < 300ms
- Acknowledged send success rate > 99%

**Ship Criteria:**
- Send/receive/sync messaging flows work end-to-end in staging.
- No open P0 defects within epic scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

---

### Epic 5: Trust & Safety Experience (Weeks 11-12)

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

**Dependencies:** Epic 4

**Success Criteria:**
- Critical reports responded to < 15 minutes
- False positive rate < 5%
- Zero safety incidents during beta

**Ship Criteria:**
- Report/block/moderation/escalation flows work end-to-end in staging.
- No open P0 defects within epic scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

---

### Epic 6: Reliability & Launch Experience (Weeks 13-14)

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

**Dependencies:** Epic 5

**Success Criteria:**
- App store approval
- Load tested to 10K concurrent users
- All P0 bugs resolved

**Ship Criteria:**
- Release candidate passes reliability, policy, and app-store readiness checks.
- No open P0 defects within epic scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

## Post-Launch (Next): Deferred Epic

### Epic 7: Real-Time Messaging Upgrade (Post-Launch / Next)

**Goal:** Introduce low-latency realtime messaging semantics after MVP stabilization

**Deliverables:**
- [ ] WebSocket gateway infrastructure
- [ ] Authenticated Socket.io handshake and reconnect handling
- [ ] Typing indicators
- [ ] Presence events
- [ ] Message fanout via Redis adapter
- [ ] Reliability/load testing for ordering and reconnect

**Dependencies:** MVP launch completion (Epic 6)

**Success Criteria:**
- Message delivery < 100ms for websocket path
- WebSocket uptime > 99.5%
- Reconnect recovery success > 99%

**Ship Criteria:**
- WebSocket and fallback messaging paths work end-to-end in staging.
- No open P0 defects within epic scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

## Epic-to-Technical Implementation Breakdown

### Epic List

| Epic | Window | Outcome |
|------|--------|---------|
| Epic 1: Identity & Core Platform | Weeks 1-2 | Runnable platform foundation with auth and profile APIs |
| Epic 2: Onboarding & Verification Journey | Weeks 3-5 | Complete onboarding path from signup to verified profile |
| Epic 3: Curated Matching Experience | Weeks 6-8 | Daily match generation and decision flows |
| Epic 4: Messaging Core Experience (Polling + Push) | Weeks 9-10 | Reliable chat with REST + push + polling sync |
| Epic 5: Trust & Safety Experience | Weeks 11-12 | Moderation, reporting, and enforcement controls |
| Epic 6: Reliability & Launch Experience | Weeks 13-14 | Production hardening and launch readiness |
| Epic 7: Real-Time Messaging Upgrade | Post-launch / Next | WebSocket-based typing, presence, and low-latency chat |

### Technical Implementation by Epic

#### Epic 1: Identity & Core Platform
- Establish monorepo packages (`apps/mobile`, `apps/api`, `packages/shared`) with unified lint/typecheck/test CI.
- Provision Supabase project configuration, migration workflow, and baseline RLS policies.
- Implement OTP auth and session handling in API middleware with shared request validation.
- Stand up mobile shell (navigation, auth guard, API client, token refresh).
- Add foundational observability (structured logs, request IDs, error capture).

#### Epic 2: Onboarding & Verification Journey
- Build onboarding state machine with resumable checkpoints and partial-save semantics.
- Implement questionnaire service with question versioning and response schema validation.
- Integrate photo/liveness verification service (AWS Rekognition) with async status polling.
- Add onboarding endpoints and mobile screens for profile, preferences, and verification.
- Instrument onboarding funnel analytics and drop-off/error monitoring.

#### Epic 3: Curated Matching Experience
- Implement compatibility scoring module with configurable weights and hard-filter gates.
- Build idempotent matchmaking batch pipeline (scheduler, dedupe keys, retry-safe execution).
- Expose match-offer API contracts for fetch, accept, pass, and defer actions.
- Add mutual-match creation logic with transactional integrity and duplicate prevention.
- Integrate push notification workflow for daily offer and mutual match events.

#### Epic 4: Messaging Core Experience (Polling + Push)
- Implement message domain model and REST endpoints (send, list, ack, pagination cursors).
- Add push-triggered refresh flow and polling scheduler for active/background sync.
- Build offline send queue with retry and idempotent message submission.
- Keep read receipts in REST path with server-side ordering guarantees.
- Run reliability tests for sync lag, retry behavior, and duplicate prevention.

#### Epic 5: Trust & Safety Experience
- Build moderation ingestion pipeline (AI pre-screen, queueing, human review handoff).
- Implement report, block, and unmatch APIs with evidence retention and audit trails.
- Integrate policy enforcement checks into chat and matching decision points.
- Build internal moderation queue views and response workflow tooling.
- Add escalation hooks and SLA monitoring for critical safety incidents.

#### Epic 6: Reliability & Launch Experience
- Tune API/DB performance (indexing, caching, hot-path profiling, backpressure controls).
- Finalize release pipeline (build signing, store submissions, staged rollout controls).
- Complete operational readiness (dashboards, alerts, SLO monitors, runbooks, rollback drills).
- Validate resilience with load, failover, and backup/restore exercises.
- Close launch gates with security audit remediation and release checklist sign-off.

#### Epic 7: Real-Time Messaging Upgrade (Post-Launch / Next)
- Deploy Socket.io gateway with authenticated handshake and Redis-backed horizontal fanout.
- Add typing and presence channels with bounded TTL and reconnect synchronization.
- Add websocket transport upgrades while preserving REST fallback.
- Execute load tests for message throughput, reconnect behavior, and ordering guarantees.
- Roll out progressively with feature flags and transport-level observability.

### Delivery Split by Product Area

Admin-system scope is included in MVP and mapped by epic. See `docs/ops/admin-operations.md` for detailed admin capabilities.

| Epic | Backend | Mobile App | Admin Area |
|------|---------|------------|------------|
| Epic 1: Identity & Core Platform | API scaffolding, auth middleware, schema migrations | App shell, auth flow bootstrap, API client | Admin auth guard, admin user bootstrap, audit logging foundation |
| Epic 2: Onboarding & Verification Journey | Onboarding APIs, questionnaire/versioning, verification orchestration | Onboarding UI, profile flow, verification UX | Read-only user lookup and status visibility for support ops |
| Epic 3: Curated Matching Experience | Matching jobs, scoring service, offers APIs | Offer cards, decision actions, notification handling | Segment metadata and config-override APIs for operator controls |
| Epic 4: Messaging Core (Polling + Push) | Messaging REST APIs, polling orchestration, idempotent send/ack | Chat UI, offline queue UX, sync behavior | User status actions (suspend/activate) and messaging-related admin controls |
| Epic 5: Trust & Safety Experience | Moderation pipeline, report/block APIs, enforcement logic | Report/block/unmatch UX | Moderation queue, action workflow, evidence/audit review tooling |
| Epic 6: Reliability & Launch Experience | Performance hardening, SLO alerts, release safety gates | Launch polish, reliability fixes, crash/perf improvements | Permission hardening, admin runbooks, operational smoke checks |
| Epic 7: Realtime Upgrade (Post-launch) | WebSocket gateway and fanout services | Transport upgrade and reconnect UX | Presence/moderation realtime surfaces and audit observability |

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
  - AWS Fargate (ECS) services: API + Admin interface
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
  - AWS Fargate (ECS) services: API + Admin interface (auto-scaling)
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
| Message sync latency (MVP path) | < 5s | Active chat screen |
| WebSocket message delivery (post-launch) | < 100ms | Chat messages |
| App cold start | < 3s | React Native |
| Image load | < 2s | Profile photos |
| Onboarding completion | < 10 min | End-to-end |

## Monitoring & Observability

**Metrics:**
- Request rate, latency, errors (RED method)
- Database query performance
- Message sync lag (polling + push path)
- WebSocket connection health (post-launch)
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
| Post-launch WebSocket scaling | Redis adapter, horizontal scaling |
| Photo storage costs | Compression, lifecycle policies |
| AI service outages | Circuit breakers, fallbacks |
| Database performance | Query optimization, indexing |

## Team Allocation

| Epic | Backend | Mobile App | Admin Area | ML/AI | QA |
|-------|---------|------------|------------|-------|-----|
| 1. Foundation | 100% | 50% | 15% | - | - |
| 2. Onboarding | 75% | 100% | 40% | 50% | - |
| 3. Matching | 100% | 75% | 35% | 100% | 50% |
| 4. Chat Core (Polling + Push) | 100% | 100% | 45% | - | 100% |
| 5. Safety | 75% | 50% | 100% | 50% | 100% |
| 6. Launch | 50% | 75% | 50% | - | 100% |
| 7. Realtime Upgrade (Post-launch) | 100% | 75% | 25% | - | 75% |

## Resolved Technical Decisions

| Question | Decision | Notes |
|----------|----------|-------|
| Supabase Realtime vs WebSocket | Hybrid ownership model | MVP uses REST + push/polling for chat. WebSocket for typing/presence is deferred to post-launch. See ADR-0002. |
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
