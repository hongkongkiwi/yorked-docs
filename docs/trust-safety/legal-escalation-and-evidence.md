# Legal Escalation and Evidence Preservation

Owner: Trust & Safety + Legal  
Status: Draft  
Last Updated: 2026-02-20  
Depends On: `docs/ops/slo-sla.md`, `docs/technical/contracts/openapi.yaml`

## Overview

This document defines procedures for legal escalation, law enforcement requests, and evidence preservation. It ensures compliance with legal obligations while protecting user privacy.

## Legal Escalation Triggers

### Automatic Escalation

The following trigger immediate legal team notification:

| Trigger | Severity | Response Time |
|---------|----------|---------------|
| Child safety report (CSAM) | Critical | Immediate |
| Law enforcement request | Critical | Within 4 hours |
| Subpoena or court order | Critical | Within 4 hours |
| Search warrant | Critical | Immediate |
| User data breach | Critical | Immediate |
| Threat to life | Critical | Immediate |
| Underage user (confirmed < 18) | High | Within 24 hours |
| Harassment with legal threat | High | Within 24 hours |

### Manual Escalation

Moderators may escalate to legal when:
- User mentions legal action
- Report involves public figure
- Cross-jurisdictional issues
- Unclear legal obligations
- Novel situation without precedent

## Law Enforcement Request Handling

### Request Types and Requirements

| Request Type | Legal Requirement | User Notification |
|--------------|-------------------|-------------------|
| Emergency disclosure | Good faith belief of imminent harm | Delayed if would jeopardize investigation |
| Subpoena | Valid court subpoena | 7 days before production unless delayed |
| Search warrant | Valid warrant | Delayed per warrant terms |
| Preservation request | 90-day hold, no content required | Not required |
| National security letter | Valid NSL | Gagged by law |

### Verification Process

```
1. Receive request (legal@yoked.app)
2. Verify authenticity:
   - Call back using official directory number
   - Verify badge/warrant number with issuing agency
   - Confirm jurisdiction
3. Log request in legal tracking system
4. Notify legal counsel
5. Assess scope and validity
6. Respond or challenge within legal deadlines
```

### Response Timeline

| Request Type | Acknowledgment | Production/Challenge |
|--------------|----------------|---------------------|
| Emergency | 1 hour | Immediate if valid |
| Preservation | 24 hours | 90-day hold |
| Subpoena | 3 days | 14 days or challenge |
| Warrant | 1 hour | Per warrant terms |

## Evidence Preservation

### Preservation Triggers

Evidence is automatically preserved when:
- Safety report submitted
- Account flagged for review
- Legal hold notice received
- Law enforcement request received
- Litigation anticipated

### Preservation Scope

| Data Type | Preservation Period | Access Control |
|-----------|---------------------|----------------|
| User profile | Duration of hold + 2 years | Legal + T&S only |
| Chat messages | Duration of hold + 2 years | Legal + T&S only |
| Photos | Duration of hold + 2 years | Legal + T&S only |
| IP addresses | Duration of hold + 2 years | Legal + SRE only |
| Device IDs | Duration of hold + 2 years | Legal + SRE only |
| Login history | Duration of hold + 2 years | Legal + SRE only |
| Safety reports | Duration of hold + 7 years | Legal + T&S only |
| Moderation actions | Duration of hold + 7 years | Legal + T&S only |

### Preservation Implementation

```sql
-- Flag account for preservation
UPDATE users
SET legal_hold = true,
    legal_hold_reason = 'CSAM investigation #2026-001',
    legal_hold_expires_at = '2028-02-19'
WHERE id = 'user-uuid';

-- Prevent deletion
CREATE TRIGGER prevent_deletion_under_hold
BEFORE DELETE ON users
FOR EACH ROW
WHEN (OLD.legal_hold = true)
BEGIN
  RAISE EXCEPTION 'Cannot delete user under legal hold';
END;
```

## Child Safety (CSAM)

### Detection and Reporting

**Automated Detection:**
- Photo hash matching against known CSAM databases (NCMEC)
- ML-based content classification
- User report triage

**Mandatory Reporting:**
- Report to NCMEC within 24 hours of discovery
- Preserve evidence for 90 days minimum
- Cooperate with law enforcement

### CSAM Response Workflow

```
1. Detection (automated or reported)
2. Immediate content removal
3. Account suspension (pending investigation)
4. Hash submitted to NCMEC CyberTipline
5. Evidence preserved
6. Law enforcement notified if required
7. User banned if confirmed
8. No appeal permitted for confirmed CSAM
```

### CSAM Handling Requirements

- Only trained personnel may view CSAM
- Viewing logged with witness present
- Content never downloaded to personal devices
- Secure viewing environment (isolated machine)
- Mental health support available for reviewers

## Data Retention for Legal Holds

### Standard Retention (No Hold)

| Data Type | Retention Period |
|-----------|------------------|
| Active user data | Account lifetime |
| Deleted account data | 30 days |
| Chat messages | 24 months from last activity |
| Safety metadata | 24 months from last event |
| Raw biometric data | 24 hours |
| Derived face vectors | 30 days after account deletion |

### Legal Hold Extension

When legal hold is active:
- All standard deletions suspended
- Data retained until hold expires
- Hold may be extended by legal counsel
- Maximum hold: 7 years (unless litigation pending)

## User Notification

### Notification Requirements

| Scenario | Notification | Timing |
|----------|--------------|--------|
| Data provided to law enforcement | Required | Within 7 days of production, unless delayed by law |
| Account preservation | Not required | N/A |
| Subpoena challenge | Optional | If challenging on user's behalf |
| Emergency disclosure | Delayed | After emergency passes |

### Notification Content

```
Subject: Legal Request for Your Account Information

We are writing to inform you that Yoked received a legal request 
for information related to your account. We have produced the 
following information:

- Account profile data
- Messages from [date] to [date]

Request details:
- Requesting agency: [Agency name]
- Date received: [Date]
- Date produced: [Date]

If you have questions, please contact [legal contact].
```

## Transparency Reporting

### Annual Transparency Report

Published annually including:
- Total law enforcement requests received
- Requests by type (subpoena, warrant, emergency)
- Requests by country
- Percentage of requests fulfilled
- Number of accounts affected
- Number of user notifications delayed

### Internal Metrics

| Metric | Tracking |
|--------|----------|
| Legal requests received | Monthly |
| Average response time | Monthly |
| User notifications sent | Monthly |
| CSAM reports to NCMEC | Immediate |
| Legal holds active | Weekly |

## Cross-Border Considerations

### Data Localization

- Primary data stored in US (AWS us-east-1)
- EU user data: Additional copy in EU (GDPR compliance)
- No data transfer to third countries without safeguards

### Jurisdictional Conflicts

When receiving requests from non-US authorities:
1. Verify MLAT (Mutual Legal Assistance Treaty) or equivalent
2. Consult legal counsel
3. Assess conflict with US law
4. Respond or challenge appropriately

### GDPR Article 48

Non-EU government requests for EU user data:
- Generally not recognized without MLAT
- May challenge if no international agreement
- Notify user unless prohibited by law

## Evidence Production

### Production Format

| Data Type | Format | Encryption |
|-----------|--------|------------|
| User profile | JSON | PGP encrypted |
| Chat messages | JSON | PGP encrypted |
| Photos | Original files | Password-protected ZIP |
| Metadata | CSV | PGP encrypted |
| Logs | JSONL | PGP encrypted |

### Chain of Custody

```
1. Extract data from production systems
2. Generate SHA-256 hash of each file
3. Package with manifest
4. Encrypt for requesting party
5. Log all access in custody log
6. Transfer via secure method (no email)
7. Maintain copy for 2 years
```

## Training and Compliance

### Required Training

| Role | Training | Frequency |
|------|----------|-----------|
| T&S Moderators | CSAM recognition | Annual |
| T&S Leads | Legal escalation | Annual |
| Legal Team | Platform policies | Quarterly |
| SRE | Evidence preservation | Annual |

### Compliance Audits

- Annual third-party audit of T&S practices
- Quarterly internal audit of legal holds
- Monthly review of evidence preservation

## Emergency Contacts

| Situation | Contact | Response |
|-----------|---------|----------|
| CSAM discovery | NCMEC CyberTipline: 1-800-843-5678 | Immediate |
| Imminent harm threat | Local law enforcement + legal@ | Immediate |
| Legal after-hours | legal-oncall@yoked.app | 1 hour |
| Data breach | security@yoked.app | Immediate |

## Record Keeping

All legal matters retained for 7 years:
- Law enforcement requests
- Legal hold notices
- Evidence production logs
- User notifications
- Training records
- Audit reports

## Implementation Checklist

- [ ] Legal request tracking system
- [ ] CSAM hash database integration
- [ ] Automated legal hold enforcement
- [ ] Evidence preservation infrastructure
- [ ] PGP key management for production
- [ ] Custody log system
- [ ] Transparency report automation
- [ ] Legal team on-call rotation
- [ ] T&S CSAM training program
- [ ] Cross-border request procedure
- [ ] User notification templates
- [ ] NCMEC reporting integration
