# Yoked: MVP Epic Delivery Checklist

Owner: Product + Engineering
Status: Active
Last Updated: 2026-02-23
Depends On: `docs/vision/roadmap.md`, `docs/execution/epic-plans/implementation-plan.md`, `docs/specs/onboarding.md`, `docs/specs/matching.md`, `docs/specs/chat.md`, `docs/specs/safety.md`, `docs/ops/testing-strategy.md`, `docs/ops/slo-sla.md`

## Purpose

Execution source for epic exit decisions.
Use this checklist to decide whether an epic is:
- `not ready`
- `ready with conditions`
- `ready to advance`

## Canonical Rule

This checklist validates epic completion.
Epic scope, sequencing, and dependencies are canonical in:
`docs/execution/epic-plans/implementation-plan.md`.

## Exit Decision Rules

An epic is `ready to advance` only when all are true:
1. Required checklist items are complete.
2. Exit metrics meet thresholds.
3. No open `P0` defects; `P1` defects have owner, due date, and mitigation.
4. Evidence artifacts are linked and reviewable.

If one or more thresholds are missed but risk is bounded, use `ready with conditions` and capture:
- gap
- owner
- deadline
- rollback/containment plan

## DRI Model

| Epic | Primary DRIs |
|------|---------------|
| Epic 1-4 | Product + Engineering (+ QA) |
| Epic 5 | Product + Engineering + Trust & Safety (+ QA) |
| Epic 6 | Product + Engineering + QA + Data/Analytics (+ Trust & Safety signoff) |
| Epic 7 (Post-launch) | Product + Engineering + QA |

## Global Evidence Requirements

- [ ] Demo script or recording for core user flow in scope
- [ ] Test report for happy path + critical failure paths
- [ ] Dashboard snapshot for epic KPIs
- [ ] Known risks and mitigation log

## Epic Exit Matrix

| Epic | Window | Minimum Required Checklist | Exit Metrics |
|------|--------|----------------------------|--------------|
| Epic 1: Identity & Core Platform | Weeks 1-2 | Auth/profile flows work end-to-end, schema migrations repeatable, session lifecycle works in mobile | Account creation success >= 98%, auth p95 <= 300ms, zero unresolved P0 auth/profile defects |
| Epic 2: Onboarding & Verification Journey | Weeks 3-5 | OTP flow, onboarding persistence, verification policy handling, contract alignment | Verification completion >= 90%, onboarding median < 10 min, verification p95 <= 10s |
| Epic 3: Curated Matching Experience | Weeks 6-8 | Idempotent daily offers, decision actions state-safe, match creation deterministic | Zero duplicate offers per `{userId,date}`, generation runtime < 5 min / 1000 users, offer API p95 < 200ms |
| Epic 4: Messaging Core (Polling + Push) | Weeks 9-10 | REST send/list/ack, polling + push sync, read receipts, offline retry queue | Active-screen sync latency < 5s, messaging endpoint p95 < 300ms, send success > 99% |
| Epic 5: Trust & Safety Experience | Weeks 11-12 | Report/block/unmatch complete, moderation routing by severity, evidence retention validated | Critical reports acknowledged < 15 min median, false-positive rate < 5%, staged T&S drill passes |
| Epic 6: Reliability & Launch Experience | Weeks 13-14 | Critical-path E2E green, monitoring/alerts active, launch + rollback rehearsed | Load tested to 10K concurrent users, zero P0 blockers, launch readiness signoff complete |
| Epic 7: Real-Time Messaging Upgrade (Post-launch) | Post-launch / Next | WebSocket handshake/reconnect, presence/typing, REST fallback retained | WebSocket delivery < 100ms p95, websocket uptime > 99.5%, reconnect recovery > 99% |

## Go/No-Go Template

| Field | Required |
|---|---|
| Epic | Yes |
| Decision (`not ready` / `ready with conditions` / `ready to advance`) | Yes |
| Date | Yes |
| Product DRI signoff | Yes |
| Engineering DRI signoff | Yes |
| QA DRI signoff | Yes |
| Trust & Safety DRI signoff (Epic 5+) | Yes |
| Conditions and deadlines (if any) | Conditional |
| Rollback/containment plan | Yes |
