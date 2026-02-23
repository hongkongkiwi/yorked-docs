# Yoked

An AI-first dating app that replaces swipe fatigue with curated, high-probability daily matches.

## Overview

Yoked delivers a curated dating experience focused on quality over quantity. Instead of endless swiping, users receive a small number of highly compatible matches each day based on detailed compatibility assessments.

**Key Differentiators:**
- Curated daily matches (not infinite swiping)
- Compatibility-first matching algorithm
- Photo verification for trust and safety
- AI-assisted conversation quality

## Quick Start

### For Developers

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-org/yoked.git
   cd yoked
   ```

2. **Set up Superpowers (AI assistant skills):**
   
   Tell your AI assistant:
   ```
   Use the setup-superpowers skill to ensure superpowers is installed
   ```
   
   Or manually:
   ```bash
   ./.superpowers/install.sh
   ```

3. **Read the documentation:**
   - Start with `docs/README.md` for documentation governance
   - Use `docs/AGENTS.md` for agent workflow guidance
   - Check `docs/specs/` for feature specifications
   - Review `docs/contracts/openapi.yaml` for API details

### Documentation Structure

```
├── docs/
│   ├── README.md              # Documentation governance (canonical)
│   ├── AGENTS.md              # Agent workflow guide
│   ├── contracts/             # API contracts (OpenAPI, WebSocket)
│   ├── specs/                 # Feature specifications
│   ├── ux/                    # User experience flows
│   ├── decisions/             # Architecture Decision Records (ADRs)
│   ├── ops/                   # Operational specs (SLO/SLA)
│   ├── schema/                # Database schema docs
│   ├── plans/                 # Planning docs (see plans/README)
│   └── trust-safety/          # Safety and compliance
├── .codex/                    # Codex-specific configuration
├── .claude/                   # Claude Code configuration
├── .opencode/                 # OpenCode configuration
├── .github/                   # GitHub configuration
└── .superpowers/              # Superpowers skill framework setup
```

## Technology Stack

| Layer | Technology |
|-------|------------|
| Mobile App | React Native (TypeScript) |
| Web Admin | TanStack Start (TypeScript) |
| Backend | TypeScript REST API + WebSocket Gateway |
| Auth | Supabase Auth (Phone OTP + Apple/Google) |
| Database | Supabase Postgres |
| Storage | Supabase Storage |
| Real-time | Custom WebSocket + Supabase Realtime |
| AI/ML | AWS Rekognition, OpenAI |

## Core Features

### MVP Scope

1. **Onboarding**
   - Phone OTP authentication
   - Compatibility questionnaire
   - Photo verification (liveness detection)
   - Profile creation

2. **Matching**
   - Daily curated match offers
   - Compatibility scoring
   - Mutual match creation
   - Match management (accept/pass/not now)

3. **Chat**
   - Real-time 1:1 messaging
   - Read receipts
   - Typing indicators
   - Safety controls (block/report/unmatch)

4. **Safety**
   - Content moderation
   - User reporting
   - Account verification
   - Legal compliance (CSAM, data retention)

## Spec-Driven Development

This repository uses **spec-driven development**. Specifications are the source of truth.

For source-of-truth order, status taxonomy, and planning authority, use `docs/README.md`.
For agent workflow rules, use `docs/AGENTS.md`.

## Architecture

### System Overview

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  React Native   │────▶│  TypeScript     │────▶│   Supabase      │
│  Mobile App     │     │  REST API       │     │  (Postgres,     │
│                 │◀────│                 │◀────│   Auth, Storage)│
└────────┬────────┘     └────────┬────────┘     └─────────────────┘
         │                       │
         │              ┌────────┴────────┐
         │              │  WebSocket      │
         └─────────────▶│  Gateway        │
                        │  (Chat, Real-time)│
                        └─────────────────┘
```

### Key Decisions

See `docs/decisions/` for detailed architecture decisions:

- **ADR-0001**: Supabase over Convex for backend platform
- **ADR-0002**: Hybrid real-time (WebSocket for chat, Supabase for notifications)
- **ADR-0003**: Phone-centric authentication with assisted recovery
- **ADR-0004**: Deterministic, idempotent matchmaking
- **ADR-0005**: Multi-provider AI with fallback
- **ADR-0006**: Modular monolith boundaries and two-phase matching architecture

## Development

### Prerequisites

- Node.js 20+
- Docker (for local Supabase)
- Git

### Local Setup

```bash
# Install dependencies
npm install

# Start local Supabase
npx supabase start

# Run migrations
npx supabase db reset

# Start development server
npm run dev
```

### Testing

```bash
# Unit tests
npm test

# Integration tests
npm run test:integration

# Contract tests (validate against OpenAPI)
npm run test:contracts
```

### Code Quality

```bash
# Lint
npm run lint

# Type check
npm run typecheck

# Format
npm run format
```

## Deployment

### Environments

| Environment | URL | Branch |
|-------------|-----|--------|
| Production | https://yoked.app | `main` |
| Staging | https://staging.yoked.app | `develop` |
| Local | http://localhost:3000 | any |

### CI/CD

GitHub Actions workflows:
- `ci.yml` - Run tests on PR
- `deploy-staging.yml` - Deploy to staging on merge to `develop`
- `deploy-production.yml` - Deploy to production on merge to `main`

## Contributing

1. **Check for skills** - Use `setup-superpowers` skill first
2. **Read specs** - Understand requirements before coding
3. **Follow TDD** - Write tests first (see `test-driven-development` skill)
4. **Update docs** - Keep specs in sync with implementation
5. **Request review** - Use `requesting-code-review` skill

See `docs/AGENTS.md` for detailed contribution guidelines.

## Safety & Compliance

- **CSAM**: Immediate reporting to NCMEC
- **Data Retention**: 24 months safety metadata, 30 days post-deletion
- **Privacy**: GDPR/CCPA compliant
- **Moderation**: < 15 min response for critical reports

See `docs/trust-safety/` for detailed policies.

## License

[MIT](LICENSE)

## Support

- **Issues**: [GitHub Issues](https://github.com/your-org/yoked/issues)
- **Documentation**: See `docs/` directory
- **Agent Workflow**: See `docs/AGENTS.md`
