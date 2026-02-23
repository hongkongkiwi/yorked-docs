# ADR-0009: API Hosting Platform

Date: 2026-02-20
Status: Accepted
Owner: Engineering
Last Updated: 2026-02-20
Depends On: `docs/technical/decisions/ADR-0001-supabase-over-convex.md`

## Context

We need to host our API server (Node.js + WebSocket). Requirements:
- WebSocket support (Socket.io)
- TypeScript/Node.js runtime
- Simple deployment
- Low ops burden
- Cost-effective for MVP scale

## Decision

Use **Railway** (primary) or **Fly.io** (alternative) for API hosting.

| Component | Provider | Rationale |
|-----------|----------|-----------|
| API Server | Railway or Fly.io | WebSocket support, simple DX |
| Database | Supabase | Already decided (ADR-0001) |
| Storage | S3/GCS | Already decided (ADR-0001) |

## Rationale

### Why Railway (Primary Choice)

1. **Simplest Developer Experience**
   - Connect GitHub, auto-deploy on push
   - No Docker required (detects Node.js)
   - Built-in logs and metrics

2. **WebSocket Support**
   - Full Socket.io support out of the box
   - No configuration needed

3. **Pricing**
   - $5/mo starter plan
   - Predictable costs
   - Scales with usage

4. **Fast Iteration**
   - Deploy in seconds
   - Easy rollbacks
   - Preview deployments

### Why Fly.io (Alternative)

1. **Better Free Tier**
   - 3 VMs free
   - Global edge deployment

2. **Docker-Native**
   - Full control over container
   - Portable to other platforms

3. **Global Distribution**
   - Deploy to multiple regions
   - Lower latency for users

### Why Not Other Options

| Platform | Why Not |
|----------|---------|
| Vercel | No WebSocket support |
| Cloudflare Workers | WebSocket requires Durable Objects ($$$) |
| ECS/Fargate | High ops burden, overkill for MVP |
| DigitalOcean | More manual setup |
| Heroku | More expensive for similar features |

## Comparison

| Factor | Railway | Fly.io | ECS |
|--------|---------|--------|-----|
| Setup time | Minutes | Minutes | Days |
| WebSocket | ✅ | ✅ | ✅ |
| Free tier | No | Yes (3 VMs) | No |
| DX | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| MVP cost | $5-10/mo | $0-10/mo | $15-50/mo |
| Ops burden | Minimal | Minimal | High |

## Architecture

```
┌─────────────────┐
│  React Native   │
│      App        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Railway/Fly.io  │
│   API Server    │
│   (Node.js)     │
│   + Socket.io   │
└────────┬────────┘
         │
    ┌────┴────┬─────────┐
    ▼         ▼         ▼
┌───────┐ ┌───────┐ ┌─────────┐
│Supabase│ │S3/GCS │ │Trigger.dev│
│(DB+Auth)│ │(Files)│ │ (Jobs)  │
└───────┘ └───────┘ └─────────┘
```

## Deployment

### Railway Setup

```bash
# 1. Install CLI
npm i -g @railway/cli

# 2. Login
railway login

# 3. Create project
railway init

# 4. Link to existing project
railway link

# 5. Set environment variables
railway variables set SUPABASE_URL=xxx
railway variables set SUPABASE_SERVICE_ROLE_KEY=xxx

# 6. Deploy
railway up

# 7. Get URL
railway domain
```

### Fly.io Setup

```bash
# 1. Install CLI
curl -L https://fly.io/install.sh | sh

# 2. Login
fly auth login

# 3. Create app
fly apps create yoked-api

# 4. Create Dockerfile (standard Node.js)

# 5. Set secrets
fly secrets set SUPABASE_URL=xxx
fly secrets set SUPABASE_SERVICE_ROLE_KEY=xxx

# 6. Deploy
fly deploy

# 7. Get URL
fly apps info
```

## Scaling

### When to Scale

| Metric | Trigger |
|--------|---------|
| CPU | > 70% sustained |
| Memory | > 80% usage |
| Connections | > 1000 concurrent |
| Response time | > 500ms p95 |

### How to Scale

**Railway:**
```bash
# Upgrade plan in dashboard
# Or add more services
railway run --service api
```

**Fly.io:**
```bash
# Scale horizontally
fly scale count 2

# Scale vertically
fly scale vm shared-cpu-2x
```

## Migration Path

If we outgrow Railway/Fly.io:

1. **Containerize fully** (Docker)
2. **Deploy to ECS/K8s** when needed
3. **Estimated effort:** 1-2 weeks

**Trigger for migration:**
- Costs > $200/mo
- Need multi-region deployment
- Need advanced networking

## Costs

### MVP Scale (~1K-5K users)

| Platform | Monthly Cost |
|----------|--------------|
| Railway | $5-10 |
| Fly.io | $0-5 |

### Growth Scale (~10K-50K users)

| Platform | Monthly Cost |
|----------|--------------|
| Railway | $20-50 |
| Fly.io | $20-40 |

## Related Documents

- `docs/technical/decisions/ADR-0001-supabase-over-convex.md`
- `docs/technical/decisions/ADR-0007-api-gateway-security-architecture.md`
- `docs/ops/infrastructure.md`
