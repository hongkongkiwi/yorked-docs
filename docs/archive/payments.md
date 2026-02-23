# Feature Specification: Payments

Owner: Backend + Mobile  
Status: Planned  
Last Updated: 2026-02-20  
Depends On: `docs/technical/contracts/openapi.yaml`

## Overview

Subscription management and payment processing. **Post-MVP feature.**

## User Stories

### US-001: View Subscription Plans

**As a** user  
**I want to** see available subscription plans  
**So that** I can choose to upgrade

**Acceptance Criteria:**
- [ ] Display plan tiers and pricing
- [ ] Show feature comparison
- [ ] Localized pricing
- [ ] Free trial option if eligible

**API Contract:** `GET /subscriptions/plans`

### US-002: Subscribe

**As a** user  
**I want to** purchase a subscription  
**So that** I get premium features

**Acceptance Criteria:**
- [ ] Native in-app purchase (iOS/Android)
- [ ] Or web checkout fallback
- [ ] Payment confirmation
- [ ] Immediate feature access

**API Contract:** `POST /subscriptions`, Apple IAP, Google Play Billing

### US-003: Manage Subscription

**As a** subscriber  
**I want to** manage my subscription  
**So that** I can cancel or change plans

**Acceptance Criteria:**
- [ ] View subscription status
- [ ] Cancel subscription
- [ ] Change plan
- [ ] View billing history
- [ ] Restore purchases

**API Contract:** `GET /users/me/subscription`

### US-004: Premium Features

**As a** premium user  
**I want to** access premium features  
**So that** I get value from my subscription

**Acceptance Criteria:**
- [ ] Increased daily matches
- [ ] See who liked you
- [ ] Advanced filters
- [ ] No ads (if applicable)

## Technical Requirements

### Payment Providers
- iOS: Apple In-App Purchase (IAP)
- Android: Google Play Billing
- Web: Stripe (future)

### Subscription Tiers

| Tier | Price | Features |
|------|-------|----------|
| Free | $0 | 3 matches/day, basic features |
| Premium | $XX/month | 10 matches/day, see likes, advanced filters |
| Premium+ | $XX/month | All Premium + unlimited matches, priority support |

### Entitlements
- Stored in `user_entitlements` table
- Synced from Apple/Google via webhooks
- Grace period for payment failures

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| Payment failure | Grace period, retry, then downgrade |
| Refund issued | Revoke entitlements immediately |
| Subscription expired | Downgrade to free tier |
| Platform outages | Cached entitlements, retry sync |
| Currency change | Prorate, apply new rate |

## Security

- Verify receipts server-side
- Protect against replay attacks
- Rate limit purchase attempts
- Audit all transactions

## Open Questions

1. Pricing strategy (A/B test)?
2. Lifetime subscription option?
3. Gift subscriptions?
4. Regional pricing?
