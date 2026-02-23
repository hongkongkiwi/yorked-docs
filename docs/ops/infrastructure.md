# Infrastructure as Code

Owner: Engineering  
Status: Active  
Last Updated: 2026-02-20  
Depends On: `docs/technical/decisions/ADR-0001-supabase-over-convex.md`, `docs/technical/decisions/ADR-0009-api-hosting.md`

## Overview

All infrastructure is managed via **OpenTofu** (Terraform fork) with state stored in S3 + DynamoDB. Secrets are managed via **Infisical** and synced to all services.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Infrastructure Stack                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Managed by OpenTofu:                                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐               │
│  │    AWS      │ │  Supabase   │ │   Fly.io    │               │
│  │ S3, DynamoDB│ │   Project   │ │ Public API  │               │
│  └─────────────┘ └─────────────┘ └─────────────┘               │
│                                                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐               │
│  │   GitHub    │ │   Railway   │ │   Vercel    │               │
│  │   Repo      │ │ Admin API   │ │Admin UI     │               │
│  └─────────────┘ └─────────────┘ └─────────────┘               │
│                                                                 │
│  Secrets (Infisical):                                           │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Infisical → Sync to: AWS, Supabase, Fly, Railway,     │   │
│  │               GitHub, Vercel                            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Stack Components

| Component | Provider | Managed By | Purpose |
|-----------|----------|------------|---------|
| S3 | AWS | OpenTofu | File storage, Terraform state |
| DynamoDB | AWS | OpenTofu | Terraform state locking |
| CloudFront | AWS | OpenTofu | CDN (optional) |
| Supabase | Supabase | OpenTofu | Database + Auth |
| Public API | Fly.io/Railway | OpenTofu | User-facing REST API |
| Admin API | Railway | OpenTofu | Admin-only REST API |
| Admin UI | Vercel | Manual | Admin interface (TanStack Start) |
| GitHub | GitHub | OpenTofu | Repo settings, secrets |
| Trigger.dev | Trigger.dev | Manual | Background jobs |
| OpenRouter | OpenRouter | Manual | LLM gateway (primary) |
| Vertex AI | GCP | Manual | LLM fallback |
| Secrets | Infisical | Infisical CLI | Secret management |

## Repository Structure

```
infra/
├── tofu/
│   ├── modules/
│   │   ├── aws-storage/       # S3, DynamoDB, CloudFront
│   │   ├── supabase/          # Supabase project config
│   │   ├── fly/               # Fly.io app and machines
│   │   ├── railway/           # Railway project and services
│   │   ├── github/            # Repo settings, secrets
│   │   └── monitoring/        # Alerts, dashboards
│   │
│   ├── environments/
│   │   ├── dev/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── terraform.tfvars
│   │   │   └── backend.tf
│   │   ├── staging/
│   │   └── prod/
│   │
│   ├── backend.tf             # S3 + DynamoDB state
│   ├── providers.tf           # All providers
│   └── versions.tf
│
├── infisical/
│   ├── .infisical.json        # Project config
│   └── environments/
│       ├── dev.env
│       ├── staging.env
│       └── prod.env
│
├── .tofu-version
└── Makefile
```

## Providers

```hcl
# providers.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.0"
    }
    fly = {
      source  = "fly-apps/fly"
      version = "~> 0.1"
    }
    railway = {
      source  = "terraform-community-providers/railway"
      version = "~> 0.1"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "supabase" {
  access_token = var.supabase_access_token
}

provider "fly" {
  fly_api_token = var.fly_api_token
}

provider "railway" {
  token = var.railway_token
}

provider "github" {
  token = var.github_token
  owner = "your-org"
}
```

## Backend Configuration

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "yoked-terraform-state"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "yoked-terraform-locks"
    encrypt        = true
  }
}
```

## Module Examples

### AWS Storage Module

```hcl
# modules/aws-storage/main.tf
resource "aws_s3_bucket" "files" {
  bucket = "${var.project_name}-${var.environment}-files"
}

resource "aws_s3_bucket_versioning" "files" {
  bucket = aws_s3_bucket.files.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project_name}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

### Supabase Module

```hcl
# modules/supabase/main.tf
resource "supabase_project" "main" {
  name              = "${var.project_name}-${var.environment}"
  database_password = var.database_password
  region            = var.region
}

resource "supabase_settings" "main" {
  project_id = supabase_project.main.id
  
  api = {
    db_schema            = "public"
    db_extra_search_path = "public,extensions"
  }
}

output "project_url" {
  value = supabase_project.main.endpoint
}
```

### Fly.io Module

```hcl
# modules/fly/main.tf
resource "fly_app" "api" {
  name = "${var.project_name}-${var.environment}-api"
  org  = var.fly_org
}

resource "fly_machine" "api" {
  app    = fly_app.api.name
  region = var.region
  name   = "${var.project_name}-${var.environment}"
  
  services = [{
    ports = [{
      port     = 443
      handlers = ["tls", "http"]
    }]
    internal_port = 8080
  }]
  
  cpu_kind = "shared"
  cpus     = 1
  memory   = 256
  
  env = {
    NODE_ENV = var.environment
  }
}
```

### Railway Module

```hcl
# modules/railway/main.tf
resource "railway_project" "main" {
  name = "${var.project_name}-${var.environment}"
}

resource "railway_service" "api" {
  name       = "api"
  project_id = railway_project.main.id
  
  source = {
    repo = var.github_repo
  }
  
  variables = {
    NODE_ENV = var.environment
  }
}

resource "railway_domain" "api" {
  service_id = railway_service.api.id
  domain     = "${var.project_name}-${var.environment}"
}

output "api_url" {
  value = railway_domain.api.domain
}
```

### GitHub Module

```hcl
# modules/github/main.tf
resource "github_repository" "main" {
  name       = var.repo_name
  visibility = "private"
  
  security_and_analysis {
    secret_scanning {
      status = "enabled"
    }
    dependabot_security_updates {
      status = "enabled"
    }
  }
}

resource "github_actions_secret" "secrets" {
  for_each = var.secrets
  
  repository       = github_repository.main.name
  secret_name      = each.key
  plaintext_value  = each.value
}
```

## Infisical Setup

### Installation

```bash
# macOS
brew install infisical

# Or via npm
npm install -g infisical-cli
```

### Project Setup

```bash
# Initialize project
infisical init

# Create environments
infisical set dev SUPABASE_URL "https://xxx.supabase.co"
infisical set dev SUPABASE_ANON_KEY "xxx"
infisical set dev SUPABASE_SERVICE_ROLE_KEY "xxx"
# ... etc
```

### Environment File Structure

```bash
# .infisical.json
{
  "workspaceId": "xxx",
  "defaultEnvironment": "dev",
  "gitBranchToEnvironmentMapping": {
    "main": "prod",
    "staging": "staging"
  }
}
```

### Sync Secrets

```bash
# Sync to Fly.io
infisical export --env=prod | fly secrets import

# Sync to Railway (via CLI)
infisical export --env=prod | railway variables import

# Use in Terraform
infisical run -- tofu apply
```

### CI/CD Integration

```yaml
# .github/workflows/deploy.yml
- name: Install Infisical
  run: curl -sL https://infisical.com/install | sh

- name: Deploy
  run: |
    infisical login --token ${{ secrets.INFISICAL_TOKEN }}
    infisical run -- tofu apply -auto-approve
```

## Setup Instructions

### 1. Initial AWS Setup (One-time)

```bash
# Create S3 bucket for state
aws s3api create-bucket \
  --bucket yoked-terraform-state \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket yoked-terraform-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for locks
aws dynamodb create-table \
  --table-name yoked-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### 2. Initialize OpenTofu

```bash
cd infra/tofu/environments/dev
tofu init
```

### 3. Set Up Infisical

```bash
# Login
infisical login

# Initialize
cd infra/infisical
infisical init

# Add secrets
infisical set dev AWS_ACCESS_KEY_ID xxx
infisical set dev AWS_SECRET_ACCESS_KEY xxx
infisical set dev SUPABASE_ACCESS_TOKEN xxx
infisical set dev FLY_API_TOKEN xxx
infisical set dev RAILWAY_TOKEN xxx
infisical set dev GITHUB_TOKEN xxx
infisical set dev OPENROUTER_API_KEY xxx
infisical set dev GOOGLE_APPLICATION_CREDENTIALS_BASE64 xxx
```

### 4. Deploy Infrastructure

```bash
# Plan
infisical run -- tofu plan

# Apply
infisical run -- tofu apply
```

### 5. Sync Secrets to Services

```bash
# Sync to Fly.io
infisical export --env=prod | fly secrets import

# Sync to Railway
railway variables set $(infisical export --env=prod --format=env)
```

## Cost Summary

### Infrastructure Costs (Monthly)

| Service | Free Tier | MVP Cost |
|---------|-----------|----------|
| AWS S3 | 5GB | $0-2 |
| AWS DynamoDB | 25GB | $0-1 |
| AWS CloudFront | 1TB | $0-5 |
| **Total AWS** | | **$0-8** |

### Managed Services (Monthly)

| Service | MVP Cost |
|---------|----------|
| Supabase | $0-25 |
| Fly.io / Railway | $0-10 |
| Trigger.dev | $0 |
| Infisical | $0 (self-hosted) or $7/mo |
| OpenRouter | $0-50 (usage-based) |
| Vertex AI | $0 (fallback only) |
| **Total** | **$0-92** |

**Grand Total: $0-100/mo**

### AI/LLM Costs

| Use Case | Est. Calls/Month | Est. Cost |
|----------|------------------|-----------|
| Psych compatibility | ~10K batches | $10-20 |
| Visual affinity | ~10K batches | $10-20 |
| Reason generation | ~10K batches | $5-10 |
| Opening line suggestions | ~5K requests | $5-10 |
| **Total LLM** | | **$30-60** |

## Related Documents

- `docs/technical/decisions/ADR-0001-supabase-over-convex.md`
- `docs/technical/decisions/ADR-0009-api-hosting.md`
- `docs/technical/decisions/ADR-0010-background-jobs.md`
- `docs/technical/decisions/ADR-0011-monorepo-project-structure.md`
- `docs/ops/configuration.md`
