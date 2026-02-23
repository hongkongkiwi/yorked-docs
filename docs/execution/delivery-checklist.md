# Yoked: MVP Phase Delivery Checklist

Owner: Product + Engineering
Status: Active
Last Updated: 2026-02-20
Depends On: `docs/vision/roadmap.md`, `docs/execution/phases/implementation-plan.md`, `docs/execution/phases/intent-phase-canonical-map.md`, `docs/specs/onboarding.md`, `docs/specs/matching.md`, `docs/specs/chat.md`, `docs/specs/safety.md`, `docs/ops/testing-strategy.md`, `docs/ops/slo-sla.md`

## Purpose

This checklist is the execution source for MVP phase exits.
Use it to decide if a phase is:
- `not ready`
- `ready with conditions`
- `ready to advance`

Each phase is expected to leave the product in a shippable state for an intended audience slice.

## Ownership Model

| Role | Responsibility |
|---|---|
| Product DRI | Scope control, acceptance of user value, go/no-go recommendation |
| Engineering DRI | Technical delivery, reliability, operational readiness |
| QA DRI | Test completeness, regression risk assessment |
| Trust & Safety DRI | Safety controls, moderation readiness, compliance checks |
| Data/Analytics DRI | Metric definitions, dashboards, phase KPI validation |

Default DRI assignment by phase:
- Phase 1-4: Product DRI + Engineering DRI (+ QA DRI)
- Phase 5: Product DRI + Engineering DRI + Trust & Safety DRI (+ QA DRI)
- Phase 6: Product DRI + Engineering DRI + QA DRI + Data/Analytics DRI (+ Trust & Safety DRI signoff)

## Exit Decision Rules

These rules are guardrails against "paper progress." We only advance when the phase is usable, measurable, and supportable in production conditions.

A phase can only be marked `ready to advance` if all are true:
1. All required checklist items for that phase are complete.
2. All phase exit metrics meet thresholds.
3. No open `P0` defects; any `P1` defects have explicit owner + due date + mitigation.
4. Evidence artifacts are linked and reviewable.

If a phase misses one or more thresholds but risk is bounded, use `ready with conditions` and define:
- specific gap
- owner
- deadline
- rollback or containment plan

Example: if all onboarding paths pass but verification p95 is still above target, the phase may be `ready with conditions` only if there is an owner, a dated remediation plan, and a containment strategy for affected users.

## Phase 1: Identity & Core Platform (Weeks 1-4)

**Primary DRIs:** Product, Engineering

### Ship Criteria
- Identity and core platform flow works end-to-end in staging.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

### Required Checklist
- [ ] Local full-stack environment runs from clean checkout.
- [ ] Supabase auth + core schema migrations are repeatable.
- [ ] Mobile shell supports session lifecycle and navigation baseline.
- [ ] Basic profile create/edit/read flow works end-to-end.
- [ ] Core onboarding analytics events are emitted and queryable.

### Exit Metrics
- [ ] New account creation success rate >= 98% in staging.
- [ ] Auth API p95 latency <= 300ms in staging.
- [ ] Zero unresolved P0 defects in auth/profile flows.

### Evidence
- [ ] Demo script with successful signup + profile flow.
- [ ] Staging dashboard screenshot/export for auth success and latency.
- [ ] Test report for core auth/profile happy path + key failure cases.

## Phase 2: Onboarding & Verification Journey (Weeks 5-8)

**Primary DRIs:** Product, Engineering, QA

### Ship Criteria
- Onboarding and verification journey works end-to-end in staging.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

### Required Checklist
- [ ] OTP send/verify/resend flows pass functional and abuse tests.
- [ ] Questionnaire flow supports required/optional and progress persistence.
- [ ] VPS fast-capture supports provisional and full-confidence readiness states.
- [ ] Verification flow enforces trust/safety policy and manual-review fallback.
- [ ] Onboarding status mapping matches `docs/technical/contracts/openapi.yaml`.

### Exit Metrics
- [ ] Verification completion rate >= 90% (staging/beta cohort).
- [ ] Median onboarding completion time < 10 minutes.
- [ ] Verification processing time p95 <= 10 seconds.

### Evidence
- [ ] Funnel dashboard from app open to verification complete.
- [ ] Contract conformance checks for onboarding endpoints/status values.
- [ ] Runbook for verification failure and manual review path.

## Phase 3: Curated Matching Experience (Weeks 9-12)

**Primary DRIs:** Product, Engineering, QA, Data/Analytics

### Ship Criteria
- Offer generation, decision actions, and match creation work end-to-end in staging.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

### Required Checklist
- [ ] Daily offer generation job is idempotent and timezone-correct.
- [ ] Weekly anchor offer generation works and degrades gracefully on fallback.
- [ ] Accept/pass/not-now actions are idempotent and state-safe.
- [ ] Match explanation payload includes required rationale fields.
- [ ] Behavior-responsive controls are config-driven and auditable.

### Exit Metrics
- [ ] Zero duplicate offers per `{userId, date}`.
- [ ] Match generation runtime < 5 minutes per 1,000 users.
- [ ] 24-hour decision completion rate > 80% in beta cohort.
- [ ] Median decisions per user/day <= 3.

### Evidence
- [ ] Deterministic replay test output for matching jobs.
- [ ] Batch run telemetry snapshot (duration, failure rate, retries).
- [ ] Metric dashboard for decision load and conversion trends.

## Phase 4: Real-Time Messaging Experience (Weeks 13-16)

**Primary DRIs:** Product, Engineering, QA

### Ship Criteria
- Send/receive/reconnect messaging flows work end-to-end in staging.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

### Required Checklist
- [ ] WebSocket chat delivery with ack/retry and reconnect behavior.
- [ ] Read receipts, typing indicators, and history pagination functional.
- [ ] Push notifications for background message delivery are reliable.
- [ ] First-message policy is free-for-all and enforced consistently.
- [ ] Block/report/unmatch links correctly from chat context.

### Exit Metrics
- [ ] Message delivery latency p95 < 100ms.
- [ ] Message delivery reliability > 99.5%.
- [ ] First message within 24 hours > 45% for new matches.

### Evidence
- [ ] Load test report for concurrent chat sessions.
- [ ] E2E report for send/receive/reconnect/fallback scenarios.
- [ ] Incident drill notes for websocket degradation handling.

## Phase 5: Trust & Safety Experience (Weeks 17-20)

**Primary DRIs:** Trust & Safety, Engineering, Product, QA

### Ship Criteria
- Report/block/moderation/escalation flows work end-to-end in staging.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

### Required Checklist
- [ ] Report/block/unmatch workflows complete and audited.
- [ ] AI pre-screen + moderation queue routing works by severity tier.
- [ ] Escalation runbooks tested for critical incidents.
- [ ] Evidence preservation and legal-hold controls validated.
- [ ] CSAM and emergency escalation paths validated in staging simulation.

### Exit Metrics
- [ ] Critical reports acknowledged in < 15 minutes median.
- [ ] Automated moderation false-positive rate < 5%.
- [ ] Safety operations complete staged incident drill with no P0 gaps.

### Evidence
- [ ] Moderation queue SLA dashboard snapshot.
- [ ] T&S drill report with gaps and remediations.
- [ ] Evidence retention validation checklist signed by DRI.

## Phase 6: Reliability & Launch Experience (Weeks 21-24)

**Primary DRIs:** Product, Engineering, QA, Data/Analytics, Trust & Safety

### Ship Criteria
- Release candidate passes reliability, policy, and app-store readiness checks.
- No open P0 defects within phase scope.
- Monitoring and rollback path exist for newly introduced surfaces.
- Increment can be released to the intended audience slice.

### Required Checklist
- [ ] All critical-path E2E tests are green.
- [ ] Monitoring/alerting and on-call ownership are active.
- [ ] App store submission package and policy artifacts are complete.
- [ ] Launch/rollback checklist is approved and rehearsed.
- [ ] Beta cohort instrumentation for fatigue/authenticity metrics is live.

### Exit Metrics
- [ ] Load test validated to 10K concurrent users.
- [ ] All P0 blockers closed.
- [ ] App store approval achieved (or pending with no blocking policy issues).
- [ ] Baseline dashboards for fatigue/authenticity and safety are operational.

### Evidence
- [ ] Release readiness review notes with signoff table.
- [ ] Performance and reliability test report.
- [ ] On-call runbook + escalation matrix.

## Go/No-Go Template (Per Phase)

| Field | Required |
|---|---|
| Phase | Yes |
| Decision (`not ready` / `ready with conditions` / `ready to advance`) | Yes |
| Date | Yes |
| Product DRI signoff | Yes |
| Engineering DRI signoff | Yes |
| QA DRI signoff | Yes |
| Trust & Safety DRI signoff (Phase 5+) | Yes |
| Conditions and deadlines (if any) | Conditional |
| Rollback/containment plan | Yes |

## Natural Next Step

For each active phase, create a short `phase-exit.md` note in the sprint folder that references this checklist and records signoff history.
