# Runbook Template

Owner: Engineering  
Status: Planned  
Last Updated: 2026-02-20  
Depends On: `docs/ops/incident-response.md`

## Service: [Service Name]

Brief description of the service.

### Service Owners
- Primary: [Team/Person]
- Secondary: [Team/Person]

### Related Services
- [Dependency 1]
- [Dependency 2]

## Architecture

### Components
- Component 1: Description
- Component 2: Description

### Data Flow
```
[Input] → [Process] → [Output]
```

### Dependencies
| Dependency | Purpose | Impact if Down |
|------------|---------|----------------|
| Supabase | Database | Critical |
| Redis | Cache/PubSub | Degraded |

## Monitoring

### Dashboards
- Main: [Link to Grafana/Datadog]
- Errors: [Link]
- Latency: [Link]

### Key Metrics
| Metric | SLO | Alert Threshold |
|--------|-----|-----------------|
| Availability | 99.9% | < 99.5% |
| Latency p95 | < 200ms | > 500ms |
| Error rate | < 0.1% | > 1% |

### Alerts
| Alert | Severity | Runbook Section |
|-------|----------|-----------------|
| HighErrorRate | SEV-2 | [Section] |
| HighLatency | SEV-3 | [Section] |

## Common Issues

### Issue 1: [Symptom]

**Symptoms:**
- Observable behavior
- Error messages

**Diagnosis:**
```bash
# Commands to diagnose
```

**Resolution:**
1. Step 1
2. Step 2
3. Step 3

**Prevention:**
- How to prevent recurrence

### Issue 2: [Another Symptom]

**Symptoms:**
- ...

**Diagnosis:**
```bash
# ...
```

**Resolution:**
1. ...

## Deployment

### Deploy Process
1. Merge PR to main
2. CI builds and tests
3. Deploy to staging
4. Smoke tests
5. Deploy to production
6. Monitor

### Rollback
```bash
# Rollback command
```

### Configuration
| Config Key | Default | Description |
|------------|---------|-------------|
| `KEY_NAME` | value | description |

## On-Call Notes

### Quick Checks
- [ ] Check recent deployments
- [ ] Check dependent services
- [ ] Check error logs
- [ ] Check resource usage

### Escalation
- First: [Who to contact]
- Second: [Secondary contact]

## Runbook Metadata

| Field | Value |
|-------|-------|
| Created | YYYY-MM-DD |
| Last Reviewed | YYYY-MM-DD |
| Review Frequency | Quarterly |
