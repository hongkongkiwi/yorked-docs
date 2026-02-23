# SLO and SLA Definitions

Owner: Engineering + SRE  
Status: Draft  
Last Updated: 2026-02-20  
Depends On: `docs/technical/contracts/openapi.yaml`

## Overview

This document defines Service Level Objectives (SLOs) and Service Level Agreements (SLAs) for the Yoked platform. SLOs are internal targets; SLAs are customer-facing commitments.

## Definitions

- **SLO (Service Level Objective):** Internal reliability target. Missing an SLO triggers engineering action.
- **SLA (Service Level Agreement):** Contractual commitment to customers. Missing an SLA triggers customer compensation.
- **SLI (Service Level Indicator):** Measurable metric used to calculate SLO/SLA compliance.
- **Error Budget:** Allowed downtime/unavailability within an SLO period.

## API Availability

### SLO: API Uptime

| Attribute | Value |
|-----------|-------|
| **SLI** | Percentage of successful API requests (2xx/3xx) |
| **Target** | 99.9% |
| **Window** | 30 days |
| **Error Budget** | 43 minutes downtime per month |
| **Measurement** | All regions, all endpoints |

**Calculation:**
```
availability = successful_requests / total_requests
```

### SLA: API Uptime (Beta)

| Attribute | Value |
|-----------|-------|
| **Target** | 99.5% |
| **Window** | 30 days |
| **Credit** | 10% monthly credit if < 99.5% |

**Exclusions:** Scheduled maintenance, beta features, third-party outages.

## API Latency

### SLO: API Response Time

| Percentile | Target | Scope |
|------------|--------|-------|
| p50 (median) | < 100ms | All authenticated requests |
| p95 | < 500ms | All authenticated requests |
| p99 | < 2000ms | All authenticated requests |

**Measurement:**
- From request received to response sent
- Excludes: WebSocket connections, file uploads/downloads
- Includes: Database queries, cache lookups, external API calls

### Endpoint-Specific Latency

| Endpoint Category | p95 Target | Notes |
|-------------------|------------|-------|
| Auth (OTP) | < 300ms | External SMS provider latency |
| User profile | < 100ms | Cached |
| Match offers | < 200ms | Pre-computed |
| Chat send | < 200ms | Async WebSocket delivery |
| Chat history | < 500ms | Paginated |
| Photo upload | < 5s | Includes S3 upload |

## WebSocket Reliability

### SLO: WebSocket Connection Stability

| Attribute | Value |
|-----------|-------|
| **SLI** | Connection uptime per session |
| **Target** | 99.5% |
| **Window** | Per connection lifetime |

### SLO: Message Delivery

| Attribute | Value |
|-----------|-------|
| **SLI** | Percentage of messages delivered within 5 seconds |
| **Target** | 99.9% |
| **Window** | 24 hours |

**Delivery Definition:**
- Message received by server
- Message forwarded to recipient's connection
- Acknowledgment received from recipient (or timeout)

## Safety Response Times

### SLA: Safety Report Response

| Severity | Median | p95 | Staffed Hours | Off-Hours |
|----------|--------|-----|---------------|-----------|
| Critical | ≤ 15 min | ≤ 60 min | 08:00-22:00 ET | On-call ≤ 60 min |
| High | ≤ 4 hours | ≤ 8 hours | 08:00-22:00 ET | Next business day |
| Standard | ≤ 24 hours | ≤ 48 hours | 08:00-22:00 ET | Next business day |

**Critical Severity Includes:**
- Child safety reports
- Violence or physical harm threats
- Self-harm or suicide indicators
- Extortion or blackmail

### SLO: Automated Safety Detection

| Metric | Target |
|--------|--------|
| Critical term detection latency | < 5 seconds |
| False positive rate | < 5% |
| Detection coverage | > 95% of known patterns |

## Data Durability

### SLO: Data Persistence

| Data Type | Durability Target | RPO |
|-----------|-------------------|-----|
| User accounts | 99.999% | 0 (synchronous replication) |
| Chat messages | 99.999% | 0 (synchronous replication) |
| Photos | 99.99% | 1 hour |
| Analytics | 99.9% | 24 hours |

**RPO (Recovery Point Objective):** Maximum data loss in a disaster scenario.

### SLO: Backup Recovery

| Metric | Target |
|--------|--------|
| Database RTO | < 4 hours |
| Photo storage RTO | < 8 hours |
| Backup test frequency | Monthly |

## Matchmaking

### SLO: Daily Offer Generation

| Attribute | Value |
|-----------|-------|
| **SLI** | Percentage of users receiving offers by 9 AM local time |
| **Target** | 99.5% |
| **Window** | Daily |

**Grace Period:**
- Offers may be delayed up to 2 hours due to timezone batching
- Delayed offers still count as meeting SLO

### SLO: Match Quality (Beta)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Mutual accept rate | > 20% | First 4 weeks of cohort |
| Offer generation time | < 5 minutes per batch | 1000 users |

## Error Rates

### SLO: API Error Rate

| Category | Target | Scope |
|----------|--------|-------|
| 5xx errors | < 0.1% | All requests |
| 4xx errors | < 5% | All requests (indicates client issues) |
| Timeout errors | < 0.5% | All requests |

### SLO: Webhook Delivery

| Metric | Target |
|--------|--------|
| Delivery success rate | > 95% |
| Average delivery latency | < 30 seconds |

## Mobile App

### SLO: App Performance

| Metric | Target | Measurement |
|--------|--------|-------------|
| Cold start time | < 3 seconds | 95th percentile |
| Time to first match | < 5 seconds | After onboarding complete |
| Crash-free sessions | > 99.5% | Daily active users |
| ANR rate | < 0.1% | Android |

## Measurement and Alerting

### SLI Collection

**Metrics Sources:**
1. Application logs (structured JSON)
2. Load balancer access logs
3. Database query logs
4. WebSocket connection metrics
5. Client-side telemetry (opt-in)

**Aggregation:**
- Real-time: 1-minute buckets
- Historical: 1-hour and 1-day buckets
- Retention: 90 days raw, 1 year aggregated

### Alert Thresholds

| SLO | Burn Rate | Alert Window | Action |
|-----|-----------|--------------|--------|
| API 99.9% | 2% budget/day | 1 hour | Page on-call |
| API 99.9% | 5% budget/day | 5 minutes | Page on-call |
| Latency p95 | 10% over SLO | 10 minutes | Notify team |
| Safety critical | Any miss | Immediate | Page on-call + T&S |

### Error Budget Policy

**Error Budget Consumption:**

| Burn Rate | Time to Exhaust | Response |
|-----------|-----------------|----------|
| 100% (baseline) | 30 days | Normal operations |
| 200% (2x) | 15 days | Freeze non-critical deploys |
| 500% (5x) | 6 days | All deploys frozen, focus on reliability |
| 1000% (10x) | 3 days | Emergency response, exec notification |

**Budget Reset:**
- Monthly on 1st of month
- No rollover of unused budget
- Post-incident budget adjustments require SRE approval

## Incident Severity

### Severity 1 (Critical)

**Criteria:**
- Complete service outage
- Safety SLA breach (critical report not triaged in 60 min)
- Data loss or corruption
- Security breach

**Response:**
- All engineers paged immediately
- War room within 15 minutes
- Executive notification within 30 minutes
- Post-mortem within 24 hours

### Severity 2 (Major)

**Criteria:**
- Major feature degradation (> 50% users affected)
- API availability < 95% for 10 minutes
- Safety high-priority SLA breach

**Response:**
- On-call engineer paged
- Team lead notified
- Post-mortem within 48 hours

### Severity 3 (Minor)

**Criteria:**
- Partial degradation (< 50% users affected)
- Single region issues
- Non-critical feature failure

**Response:**
- Ticket created
- Fix in next business day
- Post-mortem optional

## Compliance Reporting

### Monthly SLO Report

Distributed to engineering leadership:

| Metric | Target | Actual | Budget Remaining |
|--------|--------|--------|------------------|
| API Availability | 99.9% | 99.95% | 65% |
| API Latency p95 | < 500ms | 320ms | N/A |
| Safety Critical | ≤ 15 min | 8 min median | N/A |
| Message Delivery | 99.9% | 99.97% | 70% |

### Quarterly SLA Review

- Review SLA achievement vs targets
- Adjust SLOs based on data
- Update error budget policies
- Present to executive team

## Implementation Checklist

- [ ] SLI metric collection pipeline
- [ ] Real-time SLO dashboards (Grafana/Datadog)
- [ ] Error budget tracking
- [ ] Automated alerting (PagerDuty)
- [ ] Incident severity runbooks
- [ ] Monthly SLO report automation
- [ ] SLA credit calculation system
- [ ] Customer-facing status page
- [ ] Post-mortem template and process
- [ ] SLO review meeting (monthly)
