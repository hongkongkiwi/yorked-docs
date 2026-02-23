# Yoked: Kanban Breakdown

Owner: Product + Engineering
Status: Active
Last Updated: 2026-02-21
Depends On: 
- `docs/execution/phases/implementation-plan.md`
- `docs/execution/phases/phase-0-monorepo-setup.md`
- `docs/vision/roadmap.md`

## Epic Overview

This board includes both committed MVP work and exploratory backlog.

- **Setup:** Phase 0 (Monorepo scaffolding)
- **Committed now:** E01-E06 (MVP path)
- **Exploratory backlog:** E07-E15 (revisit after MVP evidence and phase gates)

| Epic ID | Name | Source | Duration | Team | Priority | Commitment |
|---------|------|--------|----------|------|----------|------------|
| P0 | Monorepo Setup | Prerequisite | 1-2 days | Backend + Mobile | P0 | Committed |
| E01 | Identity & Core Platform | Tech Phase 1 | 4 weeks | Backend + Mobile | P0 | Committed |
| E02 | Onboarding & Verification Journey | Tech Phase 2 | 4 weeks | Full Stack | P0 | Committed |
| E03 | Curated Matching Experience | Tech Phase 3 | 4 weeks | Backend + Mobile | P0 | Committed |
| E04 | Real-Time Messaging Experience | Tech Phase 4 | 4 weeks | Full Stack | P0 | Committed |
| E05 | Trust & Safety Experience | Tech Phase 5 | 4 weeks | Backend + ML | P0 | Committed |
| E06 | Reliability & Launch Experience | Tech Phase 6 | 4 weeks | Full Stack | P0 | Committed |
| E07 | Attraction Signal Foundations | Post-MVP Expansion A | 4 weeks (estimate) | Backend + ML | P1 | Exploratory |
| E08 | Photo Studio Lite | Product Phase 3 | 6 weeks (estimate) | Full Stack + ML | P1 | Exploratory |
| E09 | Enhanced Matching | Product Phase 4 | 4 weeks (estimate) | Backend | P1 | Exploratory |
| E10 | AI Questionnaire | Product Phase 5a | 3 weeks (estimate) | Backend + ML | P2 | Exploratory |
| E11 | AI Chat Coach | Product Phase 5b | 3 weeks (estimate) | Backend + ML | P2 | Exploratory |
| E12 | AI Comfort Bot | Product Phase 5c | 2 weeks (estimate) | Backend + ML | P2 | Exploratory |
| E13 | Face Generation | Product Phase 6a | 4 weeks (estimate) | ML + Backend | P2 | Exploratory |
| E14 | Preference Learning | Product Phase 6b | 3 weeks (estimate) | ML + Backend | P2 | Exploratory |
| E15 | Mutual Attraction | Product Phase 6c | 3 weeks (estimate) | Backend + ML | P2 | Exploratory |

### Evidence-Based Method Integration Queue (Ranked)

These method cards are exploratory and not scheduled commitments.

| Rank | Method ID | Name | Benchmark Sources | Phase Placement | Owner | Team | Est. Points | Priority |
|------|---------------|------|-------------------|-----------------|-------|------|-------------|----------|
| 1 | M01 | Serendipity Opt-In Discovery | Happn, Grindr | Post-MVP Expansion B (Weeks 29-32) | Product | Backend + Mobile + QA | 13 | P1 |
| 2 | M02 | Guided Pre-Match Text Room | Heymandi, Tantan, Hinge | Exploratory (not scheduled) | Backend | Backend + ML + Mobile + QA | 16 | P1 |
| 3 | M03 | Intent Track & Relationship Modes | eharmony, Match.com, SweetRing, Coffee Meets Bagel | Post-MVP Expansion A (Weeks 25-28) | Product | Product + Backend + Mobile | 11 | P1 |
| 4 | M04 | Friend-Assisted Introductions | Bumble BFF, BeFriend, Friendchise | Exploratory (not scheduled) | Product | Product + Backend + Mobile + QA | 14 | P1 |
| 5 | M05 | Group Social Onramp | Timeleft, Lunch Actually | Post-MVP Expansion C (Weeks 33-36+) | Product | Product + Backend + Mobile | 10 | P2 |
| 6 | M06 | Slow-Pace + 40+ Experience Mode | Slowly, Wyzr, Match.com | Post-MVP Expansion B (Weeks 29-32) | Product | Product + Backend + Mobile + QA | 9 | P2 |
| 7 | M07 | Community + Culture Preference Pack | AsianDating, Grindr, Raya | Post-MVP Expansion C (Weeks 33-36+) | Product | Product + Backend + Mobile + QA | 12 | P2 |

---

## Phase 0: Monorepo Setup

**Duration:** 1-2 days  
**Goal:** Scaffold monorepo before E01 begins  
**Dependencies:** None  
**Details:** `docs/execution/phases/phase-0-monorepo-setup.md`

### Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| P0-T01 | Initialize Turborepo with pnpm workspaces | Backend | 2 | |
| P0-T02 | Create apps/api scaffold (Hono) | Backend | 1 | |
| P0-T03 | Create apps/admin-api scaffold | Backend | 1 | |
| P0-T04 | Create apps/admin scaffold (TanStack Start) | Backend | 2 | |
| P0-T05 | Create apps/mobile scaffold (Expo) | Mobile | 2 | |
| P0-T06 | Create packages/shared | Backend | 1 | |
| P0-T07 | Create packages/api-client with openapi-typescript | Backend | 2 | |
| P0-T08 | Create packages/ws-client (types package) | Backend | 1 | |
| P0-T09 | Create packages/admin-api-client | Backend | 1 | |
| P0-T10 | Configure shared TypeScript configs | Backend | 1 | |
| P0-T11 | Configure shared ESLint config | Backend | 1 | |
| P0-T12 | Set up Turborepo pipeline | Backend | 1 | |
| P0-T13 | Create root package.json scripts | Backend | 1 | |

**Total Points:** 17

---

## E01: Identity & Core Platform

**Duration:** 4 weeks (Weeks 1-4)
**Goal:** Core infrastructure, authentication, and user management
**Dependencies:** Phase 0

### Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E01-T01 | Copy OpenAPI/AsyncAPI specs to apps/api/ | Backend | 1 | |
| E01-T02 | Generate initial API client types | Backend | 1 | |
| E01-T03 | Configure Supabase project with local development | Backend | 2 | |
| E01-T04 | Create database migration system (Supabase CLI) | Backend | 2 | |
| E01-T05 | Implement core schema migrations (users, profiles) | Backend | 5 | |
| E01-T06 | Implement phone OTP authentication endpoint | Backend | 5 | |
| E01-T07 | Create user profile CRUD API | Backend | 3 | |
| E01-T08 | Set up API error handling and response standards | Backend | 2 | |
| E01-T09 | Configure request validation with Zod | Backend | 2 | |
| E01-T10 | Set up React Navigation structure | Mobile | 3 | |
| E01-T11 | Create API client with auth token handling | Mobile | 3 | |
| E01-T12 | Implement auth state management (Zustand) | Mobile | 2 | |
| E01-T13 | Build phone number input screen | Mobile | 3 | |
| E01-T14 | Build OTP verification screen | Mobile | 3 | |
| E01-T15 | Write auth flow E2E tests (Maestro) | QA | 3 | |
| E01-T16 | Set up CI/CD pipeline | Backend | 3 | |

**Total Points:** 43
**Definition of Done:**
- [ ] Full stack runs locally with single command
- [ ] User can authenticate via phone OTP
- [ ] User profile can be created/updated via API
- [ ] Mobile app persists auth state across restarts
- [ ] CI passes on all PRs

---

## E02: Onboarding & Verification Journey

**Duration:** 4 weeks (Weeks 5-8)
**Goal:** Complete onboarding with integrated profiling (psych + physical preferences) and baseline verification
**Dependencies:** E01

### Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E02-T01 | Design integrated profiling schema (psychological + physical preferences) | Backend | 3 | |
| E02-T02 | Build question set versioning system | Backend | 5 | |
| E02-T03 | Create questionnaire response API | Backend | 3 | |
| E02-T04 | Implement progress auto-save (per question) | Backend | 2 | |
| E02-T05 | Build location API (geocode + manual entry) | Backend | 3 | |
| E02-T06 | Create verification session API | Backend | 3 | |
| E02-T07 | Integrate AWS Rekognition liveness verification | Backend | 3 | |
| E02-T08 | Build onboarding state machine (backend) | Backend | 3 | |
| E02-T09 | Design onboarding flow wireframes | Product | 2 | |
| E02-T10 | Build profile creation screens (name, bio, age) | Mobile | 5 | |
| E02-T11 | Build verification UI flow (consent, capture, result) | Mobile | 5 | |
| E02-T12 | Build location permission + manual entry UI | Mobile | 3 | |
| E02-T13 | Build questionnaire screen (single question) | Mobile | 5 | |
| E02-T14 | Implement questionnaire progress indicator | Mobile | 2 | |
| E02-T15 | Build onboarding completion screen | Mobile | 2 | |
| E02-T16 | Implement onboarding state machine (client) | Mobile | 3 | |
| E02-T17 | Add analytics events for onboarding | Mobile | 2 | |
| E02-T18 | Write onboarding + verification E2E tests | QA | 5 | |

**Total Points:** 59
**Definition of Done:**
- [ ] User can complete full onboarding in < 10 minutes
- [ ] Progress persists across app restarts
- [ ] Integrated profiling questions completed and stored
- [ ] Verification completion rate > 90%
- [ ] Location captured (GPS or manual)
- [ ] Analytics events firing correctly

---

## E03: Curated Matching Experience

**Duration:** 4 weeks (Weeks 9-12)
**Goal:** Daily match generation and offer presentation
**Dependencies:** E02

### Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E03-T01 | Design composite scoring algorithm (psych + physical preferences) | Backend | 5 | |
| E03-T02 | Implement hard filter logic (age, location, intent, block/pass state) | Backend | 3 | |
| E03-T03 | Build match candidate query (pool generation) | Backend | 5 | |
| E03-T04 | Create match offer batch generator | Backend | 5 | |
| E03-T05 | Implement idempotent batch creation (9 AM daily) | Backend | 5 | |
| E03-T06 | Build match offer API (GET /offers) | Backend | 3 | |
| E03-T07 | Implement Accept/Pass/Not Now actions | Backend | 3 | |
| E03-T08 | Create mutual match detection job | Backend | 3 | |
| E03-T09 | Set up match generation scheduler (cron/queue) | Backend | 3 | |
| E03-T10 | Design match card UI | Product | 2 | |
| E03-T11 | Build match offer card component | Mobile | 5 | |
| E03-T12 | Build card stack navigation | Mobile | 3 | |
| E03-T13 | Implement swipe gestures (accept/pass) | Mobile | 3 | |
| E03-T14 | Build "Not Now" bottom sheet | Mobile | 2 | |
| E03-T15 | Create empty state (no matches) | Mobile | 2 | |
| E03-T16 | Build mutual match celebration screen | Mobile | 3 | |
| E03-T17 | Implement push notification service (Expo) | Mobile | 3 | |
| E03-T18 | Add daily match notification | Mobile | 2 | |
| E03-T19 | Write matching algorithm unit tests | Backend | 3 | |
| E03-T20 | Write match flow E2E tests | QA | 5 | |

**Total Points:** 68
**Definition of Done:**
- [ ] Match generation completes in < 5 min per 1000 users
- [ ] API responds in < 200ms for match offers
- [ ] Zero duplicate offers per user
- [ ] Composite score explainability visible (psych + preference fit)
- [ ] Mutual matches detected within 1 minute of second acceptance
- [ ] Push notifications delivered within 30 seconds
- [ ] Swipe gestures feel smooth (60fps)

---

## E04: Real-Time Messaging Experience

**Duration:** 4 weeks (Weeks 13-16)
**Goal:** Real-time messaging between matches
**Dependencies:** E03

### Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E04-T01 | Set up WebSocket gateway (Socket.io) | Backend | 5 | |
| E04-T02 | Configure Redis adapter for WebSocket scaling | Backend | 3 | |
| E04-T03 | Implement connection auth middleware | Backend | 3 | |
| E04-T04 | Build message persistence layer | Backend | 3 | |
| E04-T05 | Create message send/receive handlers | Backend | 5 | |
| E04-T06 | Implement read receipts logic | Backend | 3 | |
| E04-T07 | Build typing indicator broadcast | Backend | 2 | |
| E04-T08 | Create message history API (pagination) | Backend | 3 | |
| E04-T09 | Implement message rate limiting | Backend | 2 | |
| E04-T10 | Build Socket.io client integration | Mobile | 3 | |
| E04-T11 | Create WebSocket connection management | Mobile | 3 | |
| E04-T12 | Build messages list screen | Mobile | 5 | |
| E04-T13 | Build chat screen UI | Mobile | 5 | |
| E04-T14 | Implement message bubbles component | Mobile | 3 | |
| E04-T15 | Build message input with send button | Mobile | 2 | |
| E04-T16 | Implement typing indicator UI | Mobile | 2 | |
| E04-T17 | Add read receipts UI (checkmarks) | Mobile | 2 | |
| E04-T18 | Implement message pagination (infinite scroll) | Mobile | 3 | |
| E04-T19 | Add push notifications for new messages | Mobile | 2 | |
| E04-T20 | Implement REST polling fallback | Mobile | 3 | |
| E04-T21 | Write chat E2E tests | QA | 5 | |
| E04-T22 | Load test WebSocket (k6) | QA | 3 | |

**Total Points:** 70
**Definition of Done:**
- [ ] Message delivery < 100ms p95
- [ ] WebSocket uptime > 99.5%
- [ ] Typing indicators update in < 500ms
- [ ] Read receipts accurate within 1 second
- [ ] REST fallback activates on WebSocket failure
- [ ] 50+ messages load in < 500ms

---

## E05: Trust & Safety Experience

**Duration:** 4 weeks (Weeks 17-20)
**Goal:** Basic trust & safety infrastructure
**Dependencies:** E04

### Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E05-T01 | Integrate OpenAI content moderation API | Backend | 3 | |
| E05-T02 | Build message pre-screen pipeline | Backend | 3 | |
| E05-T03 | Create report submission API | Backend | 3 | |
| E05-T04 | Implement block/unmatch functionality | Backend | 3 | |
| E05-T05 | Build report storage and audit trail | Backend | 2 | |
| E05-T06 | Create basic moderation queue schema | Backend | 2 | |
| E05-T07 | Build report UI (reason selection) | Mobile | 3 | |
| E05-T08 | Implement block/unmatch UI flow | Mobile | 3 | |
| E05-T09 | Create report confirmation screen | Mobile | 2 | |
| E05-T10 | Write safety flow E2E tests | QA | 3 | |

**Total Points:** 27
**Definition of Done:**
- [ ] AI moderation flags 95%+ of policy violations
- [ ] False positive rate < 5%
- [ ] Reports stored with full context
- [ ] Blocked users cannot message or match
- [ ] Report submission < 3 taps

---

## E06: Reliability & Launch Experience

**Duration:** 4 weeks (Weeks 21-24)
**Goal:** Production readiness
**Dependencies:** E05

### Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E06-T01 | Performance audit and optimization | Full Stack | 5 | |
| E06-T02 | Error boundary implementation | Mobile | 3 | |
| E06-T03 | Offline mode improvements | Mobile | 3 | |
| E06-T04 | App icon and splash screen | Mobile | 2 | |
| E06-T05 | App store assets (screenshots, previews) | Product | 2 | |
| E06-T06 | Privacy policy and terms screens | Mobile | 2 | |
| E06-T07 | Build analytics dashboard (basic metrics) | Backend | 5 | |
| E06-T08 | Set up monitoring and alerting (PagerDuty) | Backend | 3 | |
| E06-T09 | Configure log aggregation | Backend | 2 | |
| E06-T10 | Security audit (dependency scan) | Backend | 3 | |
| E06-T11 | Load test to 10K concurrent users | QA | 5 | |
| E06-T12 | Bug bash and P0 fixes | Full Stack | 5 | |
| E06-T13 | App store submission prep (iOS) | Mobile | 3 | |
| E06-T14 | App store submission prep (Android) | Mobile | 3 | |
| E06-T15 | Beta tester onboarding docs | Product | 2 | |

**Total Points:** 48
**Definition of Done:**
- [ ] App store approved (iOS + Android)
- [ ] Load tested to 10K concurrent users
- [ ] All P0 bugs resolved
- [ ] Monitoring dashboards live
- [ ] Alerting configured
- [ ] Beta tester program ready

---

## E07: Attraction Signal Foundations

> Exploratory backlog starts here. Durations and sequence are rough planning estimates, not commitments.

**Duration:** 4 weeks (Weeks 25-28)
**Goal:** Post-MVP enhancement of physical-preference signal quality
**Dependencies:** E06

### Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E07-T01 | Add expanded physical preference taxonomy for profiling prompts | Product | 3 | |
| E07-T02 | Build preference-signal quality checks and outlier detection | Backend | 3 | |
| E07-T03 | Implement preference-affinity scoring telemetry | Backend | 3 | |
| E07-T04 | Add ranking explainability tags for physical-preference fit | Backend | 3 | |
| E07-T05 | Instrument profile-like interaction events as secondary signals | Mobile | 3 | |
| E07-T06 | Build calibration hooks for score-weight tuning | Backend | 5 | |
| E07-T07 | Add preference clarity UX copy and controls | Mobile | 3 | |
| E07-T08 | Write signal-quality validation tests | QA | 3 | |

**Total Points:** 26
**Definition of Done:**
- [ ] Preference-affinity score quality is measurable in dashboards
- [ ] Explainability tags visible in match cards
- [ ] Signal pipeline supports safe weight calibration
- [ ] No regression to psych-based match quality

---

## E08: Photo Studio Lite

**Duration:** 6 weeks (Weeks 29-34)
**Goal:** Face measurement and attraction data collection
**Dependencies:** E07

### Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E08-T01 | Integrate Mediapipe Face Mesh | Mobile | 5 | |
| E08-T02 | Build face landmark detection | Mobile | 5 | |
| E08-T03 | Calculate facial ratios (golden ratio, symmetry) | Mobile | 5 | |
| E08-T04 | Create face vector storage schema | Backend | 3 | |
| E08-T05 | Build face measurement API | Backend | 3 | |
| E08-T06 | Implement vector storage in Postgres | Backend | 3 | |
| E08-T07 | Create pre-generated face set (100 faces) | ML | 5 | |
| E08-T08 | Build face preference capture UI | Mobile | 5 | |
| E08-T09 | Implement like/dislike gesture on faces | Mobile | 3 | |
| E08-T10 | Create preference storage API | Backend | 3 | |
| E08-T11 | Build basic attraction score calculator | Backend | 5 | |
| E08-T12 | Create Photo Studio intro screen | Mobile | 2 | |
| E08-T13 | Build in-app camera with positioning guide | Mobile | 5 | |
| E08-T14 | Implement measurement progress tracking | Mobile | 3 | |
| E08-T15 | Write Photo Studio E2E tests | QA | 3 | |

**Total Points:** 58
**Definition of Done:**
- [ ] Face measurement captures 468 landmarks
- [ ] Facial ratios calculated and stored
- [ ] User can rate 100 pre-generated faces
- [ ] Attraction score calculated from preferences
- [ ] Photo guidance helps users capture good photos

---

## E09: Enhanced Matching

**Duration:** 4 weeks (Weeks 35-38)
**Goal:** Dual-score matching (compatibility + attraction)
**Dependencies:** E08

### Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E09-T01 | Design dual-score algorithm | Backend | 5 | |
| E09-T02 | Implement compatibility + attraction combination | Backend | 5 | |
| E09-T03 | Create match priority ranking | Backend | 3 | |
| E09-T04 | Build conditional question logic engine | Backend | 8 | |
| E09-T05 | Update questionnaire to support branching | Backend | 5 | |
| E09-T06 | Create admin question editor UI | Backend | 8 | |
| E09-T07 | Implement question versioning for editor | Backend | 3 | |
| E09-T08 | Update match limits using engagement/risk signals (no demographic caps) | Backend | 2 | |
| E09-T09 | Build attraction score display in match card | Mobile | 3 | |
| E09-T10 | Update questionnaire UI for branching | Mobile | 5 | |
| E09-T11 | Add match quality feedback prompt | Mobile | 2 | |
| E09-T12 | Write dual-score algorithm tests | Backend | 3 | |

**Total Points:** 52
**Definition of Done:**
- [ ] Matches ranked by dual score
- [ ] Conditional questions branch correctly
- [ ] Admin can update questions without deploy
- [ ] Match limits enforced by configurable engagement/risk rules
- [ ] Attraction score visible (optional)

---

## E10: AI Questionnaire Assistant

**Duration:** 3 weeks (Weeks 39-41)
**Goal:** AI help for questionnaire completion
**Dependencies:** E09

### Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E10-T01 | Design RAG infrastructure | Backend | 5 | |
| E10-T02 | Create question context embeddings | Backend | 3 | |
| E10-T03 | Build OpenAI/Claude integration | Backend | 3 | |
| E10-T04 | Design assistant prompts | ML | 5 | |
| E10-T05 | Create assistant API endpoint | Backend | 3 | |
| E10-T06 | Implement rate limiting for AI calls | Backend | 2 | |
| E10-T07 | Build assistant chat UI | Mobile | 5 | |
| E10-T08 | Create help button on questions | Mobile | 2 | |
| E10-T09 | Add typing indicator for AI response | Mobile | 2 | |
| E10-T10 | Write assistant E2E tests | QA | 3 | |

**Total Points:** 33
**Definition of Done:**
- [ ] AI explains questions on demand
- [ ] Response time < 3 seconds
- [ ] Rate limited to prevent abuse
- [ ] Contextual help based on question

---

## E11: AI Conversation Coach

**Duration:** 3 weeks (Weeks 42-44)
**Goal:** AI-assisted chat for better conversations
**Dependencies:** E10

### Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E11-T01 | Design conversation coach prompts | ML | 5 | |
| E11-T02 | Build icebreaker suggestion engine | Backend | 5 | |
| E11-T03 | Create message suggestion API | Backend | 3 | |
| E11-T04 | Implement chat context extraction | Backend | 5 | |
| E11-T05 | Build suggestion caching layer | Backend | 2 | |
| E11-T06 | Create coach button in chat | Mobile | 2 | |
| E11-T07 | Build suggestion carousel UI | Mobile | 3 | |
| E11-T08 | Implement tap-to-use suggestion | Mobile | 2 | |
| E11-T09 | Add coach onboarding tooltip | Mobile | 2 | |
| E11-T10 | Write coach E2E tests | QA | 3 | |

**Total Points:** 32
**Definition of Done:**
- [ ] 3+ icebreakers suggested per match
- [ ] Message suggestions contextually relevant
- [ ] Suggestions appear in < 2 seconds
- [ ] Users can easily use or dismiss suggestions

---

## E12: AI Comfort Bot

**Duration:** 2 weeks (Weeks 45-46)
**Goal:** Supportive experience after rejection
**Dependencies:** E11

### Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E12-T01 | Design comfort bot prompts | ML | 3 | |
| E12-T02 | Create unmatch trigger detection | Backend | 2 | |
| E12-T03 | Build comfort message generation | Backend | 3 | |
| E12-T04 | Implement message delivery timing | Backend | 2 | |
| E12-T05 | Create comfort message UI | Mobile | 3 | |
| E12-T06 | Add dismiss and never show options | Mobile | 2 | |
| E12-T07 | Write comfort bot tests | QA | 2 | |

**Total Points:** 17
**Definition of Done:**
- [ ] Comfort message appears within 30s of unmatch
- [ ] Message feels supportive (user feedback)
- [ ] Users can opt out permanently
- [ ] No creepy timing (delay added)

---

## E13: Face Generation

**Duration:** 4 weeks (Weeks 47-50)
**Goal:** AI-generated faces for preference learning
**Dependencies:** E12

### Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E13-T01 | Research and select face generation model | ML | 5 | |
| E13-T02 | Set up StyleGAN or alternative | ML | 8 | |
| E13-T03 | Create face generation pipeline | ML | 8 | |
| E13-T04 | Build diverse face dataset generation | ML | 5 | |
| E13-T05 | Create face storage and serving API | Backend | 3 | |
| E13-T06 | Implement face caching (CDN) | Backend | 2 | |
| E13-T07 | Update preference capture UI for generated faces | Mobile | 3 | |
| E13-T08 | Build face rating session (10-20 faces) | Mobile | 3 | |
| E13-T09 | Write face generation tests | ML | 3 | |

**Total Points:** 40
**Definition of Done:**
- [ ] Generated faces look realistic
- [ ] Diverse face generation (age, ethnicity, features)
- [ ] Face generation < 500ms per face
- [ ] Users can rate unlimited generated faces

---

## E14: Preference Learning

**Duration:** 3 weeks (Weeks 51-53)
**Goal:** Enhanced attraction model from face ratings
**Dependencies:** E13

### Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E14-T01 | Design preference learning model | ML | 5 | |
| E14-T02 | Build face embedding extraction | ML | 5 | |
| E14-T03 | Create preference vector training | ML | 8 | |
| E14-T04 | Implement user attraction model storage | Backend | 3 | |
| E14-T05 | Build model update pipeline | ML | 5 | |
| E14-T06 | Create attraction prediction API | Backend | 3 | |
| E14-T07 | Add body type classification (optional) | ML | 5 | |
| E14-T08 | Write preference model tests | ML | 3 | |

**Total Points:** 37
**Definition of Done:**
- [ ] Model learns from user face ratings
- [ ] Attraction prediction improves over time
- [ ] Model updates daily from new ratings
- [ ] Body type classification optional but working

---

## E15: Mutual Attraction Matching

**Duration:** 3 weeks (Weeks 54-56)
**Goal:** Full dual-preference matching algorithm
**Dependencies:** E14

### Tasks

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| E15-T01 | Design mutual attraction algorithm | Backend | 5 | |
| E15-T02 | Implement bidirectional attraction scoring | Backend | 5 | |
| E15-T03 | Create mutual attraction threshold logic | Backend | 3 | |
| E15-T04 | Update match generation with new scores | Backend | 5 | |
| E15-T05 | Build match explanation (why matched) | Backend | 3 | |
| E15-T06 | Update match card to show mutual attraction | Mobile | 3 | |
| E15-T07 | Create match quality feedback loop | Mobile | 2 | |
| E15-T08 | Write mutual attraction tests | Backend | 3 | |
| E15-T09 | Load test final matching algorithm | QA | 3 | |

**Total Points:** 32
**Definition of Done:**
- [ ] Mutual attraction score calculated for all matches
- [ ] Matches with low mutual attraction deprioritized
- [ ] Users can see match compatibility breakdown
- [ ] Algorithm performs at scale (1000+ users)

---

## Evidence-Based Method Integration Cards (Ranked)

Source: `docs/vision/competitive.md`

### M01: Serendipity Opt-In Discovery

**Duration:** 2 weeks  
**Goal:** Integrate optional crossed-path discovery without changing core compatibility-first ranking  
**Phase Placement:** Post-MVP Expansion B (Weeks 29-32)

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| M01-T01 | Define consent-first crossed-path UX and privacy controls | Product | 2 | |
| M01-T02 | Build coarse-location crossed-path ingestion with retention TTL | Backend | 5 | |
| M01-T03 | Add opt-in toggle and serendipity shelf in matches UI | Mobile | 3 | |
| M01-T04 | Add safety instrumentation and abuse simulation tests | QA | 3 | |

**Total Points:** 13  
**Success Criteria:**
- [ ] Opt-in rate > 25% among eligible cohort
- [ ] No increase in safety incidents versus current baseline
- [ ] Match quality metrics not degraded versus compatibility baseline

---

### M02: Guided Pre-Match Text Room

**Duration:** 3 weeks  
**Goal:** Integrate low-pressure text-first interaction before mutual match while preserving identity and safety controls  
**Phase Placement:** MVP Phase 6 method rollout (Weeks 21-24), hardening in Post-MVP Expansion A

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| M02-T01 | Define pre-match messaging policy (identity-bound, non-anonymous persistence) | Product | 2 | |
| M02-T02 | Build pre-match room API with rate limits and anti-spam controls | Backend | 5 | |
| M02-T03 | Add AI moderation policy layer for pre-match room traffic | ML | 3 | |
| M02-T04 | Build mobile pre-match room UI and transition-to-match flow | Mobile | 5 | |
| M02-T05 | Write abuse-path and moderation E2E tests | QA | 1 | |

**Total Points:** 16  
**Success Criteria:**
- [ ] 24-hour first-message rate improves by > 15%
- [ ] Moderation SLA and false-positive targets remain within baseline limits
- [ ] Report rate in pre-match rooms <= chat report baseline + 10%

---

### M03: Intent Track & Relationship Modes

**Duration:** 2 weeks  
**Goal:** Improve serious-intent matching outcomes via explicit intent tracks and ranking emphasis  
**Phase Placement:** Post-MVP Expansion A (Weeks 25-28)

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| M03-T01 | Define intent taxonomy and UX copy for relationship goals | Product | 3 | |
| M03-T02 | Add intent-track onboarding branches and config flags | Backend | 4 | |
| M03-T03 | Implement intent-alignment boost in ranking pipeline | Backend | 2 | |
| M03-T04 | Update onboarding/profile UI for intent track selection | Mobile | 2 | |

**Total Points:** 11  
**Success Criteria:**
- [ ] Intent completion rate > 85%
- [ ] Mutual match rate improves in long-term-intent cohorts
- [ ] No onboarding completion drop > 3%

---

### M04: Friend-Assisted Introductions

**Duration:** 3 weeks  
**Goal:** Add trusted-friend confidence signal flows without exposing private chat content  
**Phase Placement:** MVP Phase 6 method rollout (Weeks 21-24), scale in Post-MVP Expansion B

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| M04-T01 | Define wingperson permission model and access boundaries | Product | 3 | |
| M04-T02 | Build invite/vouch API and audit trail | Backend | 4 | |
| M04-T03 | Build friend-assist UI (invite, review, feedback summary) | Mobile | 5 | |
| M04-T04 | Add abuse detection and verification tests for vouch misuse | QA | 2 | |

**Total Points:** 14  
**Success Criteria:**
- [ ] Friend-assist-enabled users show higher decision completion rates
- [ ] No private message content exposed to friend participants
- [ ] Abuse incidents from assist channel remain below defined threshold

---

### M05: Group Social Onramp

**Duration:** 2 weeks  
**Goal:** Integrate lower-pressure group-first meeting format for first-date conversion  
**Phase Placement:** Post-MVP Expansion C (Weeks 33-36+)

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| M05-T01 | Define rollout format (group size, cadence, eligibility) | Product | 2 | |
| M05-T02 | Build group coordination service (availability + matching constraints) | Backend | 3 | |
| M05-T03 | Build group invite and RSVP flows in mobile app | Mobile | 3 | |
| M05-T04 | Create rollout ops runbook and incident checklist | Product | 2 | |

**Total Points:** 10  
**Success Criteria:**
- [ ] Group-event attendance rate > 60%
- [ ] Match-to-date conversion improves in enrolled cohort
- [ ] Safety incident rate remains within baseline

---

### M06: Slow-Pace + 40+ Experience Mode

**Duration:** 2 weeks  
**Goal:** Reduce burnout and improve conversation quality for slower-paced and older-user cohorts  
**Phase Placement:** Post-MVP Expansion B (Weeks 29-32)

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| M06-T01 | Design slow-mode cadence and 40+ onboarding variant | Product | 3 | |
| M06-T02 | Implement pacing engine and configurable response windows | Backend | 2 | |
| M06-T03 | Build slow-mode toggles and 40+ UI copy variants | Mobile | 3 | |
| M06-T04 | Add retention and conversation-quality method analytics | QA | 1 | |

**Total Points:** 9  
**Success Criteria:**
- [ ] 30-day retention improves in 40+ cohort
- [ ] Conversation depth (messages per match) improves in slow-mode cohort
- [ ] Unmatch rate does not increase

---

### M07: Community + Culture Preference Pack

**Duration:** 2 weeks  
**Goal:** Add optional culture/language/community preference controls with fairness guardrails  
**Phase Placement:** Post-MVP Expansion C (Weeks 33-36+)

| ID | Task | Assignee | Points | Status |
|----|------|----------|--------|--------|
| M07-T01 | Define preference schema and fairness guardrails | Product | 3 | |
| M07-T02 | Build language/culture preference filters and matching hooks | Backend | 4 | |
| M07-T03 | Add preference controls and localized prompt variants in UI | Mobile | 3 | |
| M07-T04 | Build fairness regression checks and review dashboard | QA | 2 | |

**Total Points:** 12  
**Success Criteria:**
- [ ] Users can explicitly set and revise cultural/language preferences
- [ ] Fairness checks pass before enabling broad rollout
- [ ] Match quality improves for users with explicit preference settings

---

## Summary Statistics

| Metric | Value |
|--------|-------|
| Committed Epics | 6 (E01-E06) |
| Exploratory Epics | 9 (E07-E15) |
| Committed MVP Points | 318 |
| Exploratory Backlog Points | 327 |
| Committed MVP Duration | 24 weeks |
| Exploratory Duration | Estimate only (subject to re-planning) |
| Method Integrations (M01-M07) | 7 methods, 85 points (uncommitted backlog) |

> Metrics above separate committed scope from exploratory backlog to avoid premature commitment during brainstorming.

---

## Kanban Board Columns

Recommended column structure:

```
Backlog → Ready → In Progress → In Review → Testing → Done → Blocked
```

### Swimlanes

- **By Priority:** P0 (Critical) / P1 (High) / P2 (Medium)
- **By Team:** Backend / Mobile / ML / QA / Product
- **By Epic:** E01-E15 plus method cards M01-M07

---

## WIP Limits

| Column | Limit |
|--------|-------|
| Ready | 10 |
| In Progress | 5 per person |
| In Review | 3 |
| Testing | 5 |

---

## Velocity Planning

Assuming 2-week sprints and team of 4 engineers:

- **Sprint velocity:** ~40 points
- **Epics per sprint:** 1-2 (depending on size)
- **MVP completion:** 12 sprints (24 weeks)
- **Full vision:** 28 sprints (56 weeks)

---

*This breakdown should be imported into your project management tool (Linear, Jira, GitHub Projects, etc.) and updated as work progresses.*
