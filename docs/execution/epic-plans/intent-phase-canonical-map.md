# Yoked: Intent and Phase Canonical Map (V3/V4 Reconciliation)

Owner: Product + Engineering
Status: Active
Last Updated: 2026-02-20
Depends On: `docs/vision/product-vision.md`, `docs/vision/roadmap.md`, `docs/specs/onboarding.md`, `docs/specs/matching.md`, `docs/specs/chat.md`, `docs/specs/safety.md`

## Purpose

This document is the canonical interpretation layer for:
- `MVP VERSION 3.pdf`
- `V3 CORE Features List.pdf`
- `V4 Features List (Photo Studio 2.0).pdf`

Those files include a mix of product intent, feature candidates, and world-building concepts. This map converts them into a phase-safe execution scope.

## Canonical Product Intent

Yoked's stable intent is:
1. Deliver low-fatigue, curated matching with clear compatibility rationale.
2. Prioritize trust and authenticity signals before growth features.
3. Use visual preference signals as a secondary ranking input, not a standalone gate.
4. Use AI as assistive UX, not as an opaque replacement for safety/policy controls.

## Interpretation Rules

When source documents conflict:
1. Follow `docs/technical/contracts/` and `docs/technical/decisions/` first.
2. Then follow `docs/specs/` and `docs/ux/`.
3. Treat `docs/vision/` and `docs/execution/` and PDF idea docs as planning inputs, not contract authority.

Classification model:
- `Now`: MVP phases 1-6 (Weeks 1-24), beta-ready scope.
- `Next`: post-MVP expansion candidates already aligned with current architecture.
- `Later`: concept backlog requiring new policy, legal, fairness, or infra work.

## Conflict Resolutions (Creative Liberties Applied)

| Original idea in PDFs | Canonical interpretation |
|---|---|
| Heterosexual-only matching | Inclusive matching by explicit user preference. No orientation lock in core logic. |
| Gender-based active match caps (men 2 / women 3) | Behavior/risk-based controls only; no demographic caps. |
| Hard attractiveness-band filter from verification artifacts | No public attractiveness score. Verification remains trust/safety. Visual preference affinity is secondary ranking input. |
| Passive-only moderator behavior | Proactive detection + severity routing + human moderation queue. |
| Chat media and advanced edits in first release | MVP chat is text-first core messaging; advanced media/editing is post-MVP. |
| Facebook login in early scope | MVP auth providers remain phone OTP + Apple + Google. |
| Long-horizon content retention assumptions | MVP evidence/chat retention follows current safety/privacy policy windows and legal-hold extensions. |

## Now / Next / Later Phase Map

| Capability area | Now (MVP) | Next (Post-MVP aligned) | Later (Concept backlog) |
|---|---|---|---|
| Onboarding + profile building | Phone OTP, Apple/Google social login, profile setup, questionnaire v1/v2, verification | Admin question tuning and richer branching | Fully open-ended free-text-only profiling loop |
| Photo Studio | Verification and lightweight VPS capture tied to matching readiness | Expanded preference learning and better UX for VPS | Full facial/body ratio R&D and generated-face pipelines |
| Matching engine | Daily offers + weekly anchor, deterministic scoring, compatibility-first ranking | Adaptive cadence experiments and improved explainability | Surprise Encounters and other location-game mechanics |
| Chat | Real-time 1:1 text messaging, read receipts, typing, block/report/unmatch | AI opening-move quality improvements, guided conversation assists | Full attachment suite, advanced editing/reactions ecosystem |
| Safety + moderation | AI pre-screen + human queue, report/block workflows, evidence preservation | More automation and triage tooling | Fully character-mediated moderation experiences |
| AI companion roles | Minimal role-specific assistive prompts where already scoped | Date helper and unmatch support pilots with strict policy controls | Full character world-building and persistent roleplay layer |
| Monetization + ads | MVP remains free during beta | Controlled post-MVP subscription rollout | In-chat bespoke/scenic ad ecosystems |

## Phase-Gating Rules

A feature can move from `Later` to `Next` or `Now` only if all are true:
1. It has a spec under `docs/specs/`.
2. Required contract changes are reflected in `docs/technical/contracts/openapi.yaml` or WebSocket contracts.
3. Trust/safety and privacy impact are documented.
4. Clear success metric and rollback path are defined.

## Working Agreement

- Keep the tone and mascot concepts as UX flavor, not architecture blockers.
- Preserve compatibility-first + trust-first behavior as the invariant.
- Treat V3/V4 PDFs as ideation inventory unless explicitly promoted through spec + contract updates.

## Related Documents

- `docs/vision/product-vision.md`
- `docs/vision/roadmap.md`
- `docs/specs/onboarding.md`
- `docs/specs/matching.md`
- `docs/specs/chat.md`
- `docs/specs/safety.md`
