# ADR-0001: Backend Platform Decision

Date: 2026-02-19
Status: Accepted
Owner: Engineering
Last Updated: 2026-02-20
Depends On: `docs/execution/phases/implementation-plan.md`

## Context

Yoked requires a backend platform that supports:
- REST-first API architecture
- Real-time capabilities for chat
- Managed authentication
- File storage for photos
- PostgreSQL-compatible database with pgvector

## Decision

Use **Supabase for Postgres + Auth** with **cloud object storage** for files.

| Component | Provider | Rationale |
|-----------|----------|-----------|
| Database | Supabase Postgres | Managed, pgvector built-in |
| Auth | Supabase Auth | Phone OTP, OAuth, sessions |
| Storage | S3 / GCS / Cloudflare R2 | Pick most cost-effective |
| Real-time | Supabase (optional) | For subscriptions only |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    React Native App                         │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   Your API Server                           │
│                   (TypeScript/Node)                         │
└─────────────────────────────────────────────────────────────┘
            │              │              │
            ▼              ▼              ▼
    ┌────────────┐  ┌────────────┐  ┌────────────────────┐
    │  Supabase  │  │  Supabase  │  │ S3 / GCS /         │
    │  Postgres  │  │    Auth    │  │ Cloudflare R2      │
    │ + pgvector │  │            │  │ (choose cheapest)  │
    └────────────┘  └────────────┘  └────────────────────┘
```

## Rationale

### Why Supabase for Database + Auth

1. **PostgreSQL + pgvector**
   - Full PostgreSQL with no abstraction layer
   - pgvector extension built-in (critical for preference matching)
   - Complex queries, joins, and transactions supported
   - Standard SQL - portable if we need to migrate

2. **Authentication**
   - Phone OTP authentication (hard to build correctly)
   - Apple/Google OAuth providers
   - Session management and JWT handling
   - Row Level Security (RLS) policies

3. **Ecosystem**
   - React Native SDK
   - TypeScript client libraries
   - Good local development experience

### Why Cloud Storage Instead of Supabase Storage

1. **Cost at Scale**
   - Supabase Storage: $0.021/GB + transfer costs
   - S3/GCS/R2: Competitive pricing, cheaper egress options

2. **Control**
   - Direct control over CDN configuration
   - More flexibility with signed URLs and access policies
   - Better integration with image processing services

3. **Portability**
   - Standard S3 API (all providers compatible)
   - Easy to switch providers
   - No vendor-specific features

4. **No Lock-in**
   - Storage is decoupled from database/auth
   - Can swap providers easily

### Why Not Alternatives

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| Supabase (all-in) | Simplest, integrated | Storage lock-in, less control | Partial (DB + Auth only) |
| Convex | Excellent real-time | No pgvector, lock-in | Rejected |
| Neon + Clerk | Best-in-class each | More vendors, Clerk costs | Future migration option |
| Firebase | Mature, scalable | NoSQL, no pgvector | Rejected |
| Self-hosted | Full control | High ops burden | Rejected for MVP |

## Storage Decision

### Provider Options

Choose based on cost-effectiveness. All use S3-compatible API.

| Provider | Storage | Egress | CDN | Free Tier |
|----------|---------|--------|-----|-----------|
| **AWS S3** | $0.023/GB | $0.09/GB | CloudFront | 5GB, 100GB egress |
| **GCS** | $0.020/GB | $0.12/GB | Cloud CDN | 5GB, 100GB egress |
| **Cloudflare R2** | $0.015/GB | **$0** | Cloudflare | 10GB, no egress fees |

### Cost Comparison (Monthly)

| Usage | S3 + CloudFront | GCS + Cloud CDN | Cloudflare R2 |
|-------|-----------------|-----------------|---------------|
| 10GB storage, 50GB egress | ~$5 | ~$6 | **~$0.15** |
| 50GB storage, 200GB egress | ~$20 | ~$25 | **~$0.75** |
| 100GB storage, 500GB egress | ~$50 | ~$60 | **~$1.50** |

**Recommendation:** Start with **Cloudflare R2** (free egress = significant savings at scale).

### Decision Factors

| Factor | S3 | GCS | R2 |
|--------|----|----|----|
| Egress cost | High | High | **Free** |
| Storage cost | Medium | Low | **Lowest** |
| CDN integration | CloudFront | Cloud CDN | **Cloudflare (free)** |
| Existing AWS infra | ✅ | ❌ | ❌ |
| Terraform support | ✅ Official | ✅ Official | ✅ Official |

**Choose S3 if:** Already using AWS heavily
**Choose GCS if:** Already using GCP heavily
**Choose R2 if:** Want lowest cost (recommended)

### Storage Architecture

```
Upload Flow:
1. Client requests upload URL from API
2. API generates signed URL (S3/GCS/R2)
3. Client uploads directly to storage
4. Client notifies API of completion
5. API verifies and updates database

Download Flow:
1. Client requests image URL from API
2. API returns signed URL or public URL (CDN-backed)
3. Client fetches from CDN
```

## Consequences

### Positive

- Familiar SQL development model
- Managed auth reduces complexity
- Storage is decoupled and portable
- Clear separation of concerns

### Tradeoffs

- Multiple vendors (Supabase + Storage + hosting)
- More integration code for storage
- Real-time requires careful architecture

### Risks

| Risk | Mitigation |
|------|------------|
| Supabase pricing at scale | Monitor usage, can migrate to Neon |
| Auth lock-in | Standard JWT, can migrate to Clerk |
| Storage costs | Use R2 (free egress), implement lifecycle policies |

## Migration Path

### If Outgrowing Supabase

**Phase 1: Migrate Storage** (Already done - using S3/GCS)

**Phase 2: Migrate Database**
1. Export PostgreSQL dump from Supabase
2. Set up Neon/Railway/RDS with pgvector
3. Migrate data
4. Update connection strings

**Phase 3: Migrate Auth (if needed)**
1. Export users from Supabase
2. Set up Clerk
3. Migrate user data
4. Update auth integration

Estimated migration effort:
- Database only: 1 week
- Database + Auth: 2-3 weeks

## Validation

Success metrics:
- API response times < 500ms p95
- Zero auth downtime during MVP
- Storage costs predictable
- Team productivity (feature velocity)

## Related Documents

- `docs/technical/decisions/ADR-0002-realtime-ownership.md`
- `docs/technical/decisions/ADR-0003-auth-recovery-policy.md`
- `docs/technical/decisions/ADR-0007-api-gateway-security-architecture.md`
