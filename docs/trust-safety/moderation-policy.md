# Moderation Policy

Owner: Trust & Safety  
Status: Planned  
Last Updated: 2026-02-20  
Depends On: `docs/specs/safety.md`, `docs/trust-safety/legal-escalation-and-evidence.md`

## Purpose

Define content moderation standards, enforcement actions, and appeal processes.

## Content Standards

### Prohibited Content

| Category | Examples | Severity |
|----------|----------|----------|
| Child Safety | CSAM, child exploitation | Critical |
| Violence | Threats, gore, violence promotion | Critical |
| Harassment | Targeted harassment, doxxing | High |
| Hate Speech | Slurs, discrimination | High |
| Nudity/Sexual | Explicit content, unsolicited sexual content | High |
| Scam/Fraud | Romance scams, phishing | High |
| Spam | Commercial spam, bot behavior | Medium |
| Misinformation | False safety claims | Medium |

### Context Matters
- Same content may be evaluated differently based on context
- User history and intent considered
- Cultural context where applicable

## Enforcement Actions

### Action Hierarchy

| Action | When Used | Duration | Appeal? |
|--------|-----------|----------|---------|
| Warning | First minor violation | N/A | No |
| Content Removal | Policy-violating content | Permanent | Yes |
| Feature Restriction | Repeated violations | Variable | Yes |
| Temporary Suspension | Serious or repeated violations | 7-30 days | Yes |
| Permanent Ban | Severe violations, no rehabilitation | Permanent | Yes (once) |
| Device Ban | Evasion, extreme violations | Permanent | No |

### Escalation Matrix

| Violation Type | 1st Offense | 2nd Offense | 3rd Offense |
|----------------|-------------|-------------|-------------|
| Spam | Warning | 7-day suspension | 30-day suspension |
| Harassment | Warning | 7-day suspension | Permanent |
| Hate Speech | 7-day suspension | 30-day suspension | Permanent |
| Violence | 30-day suspension | Permanent | Permanent |
| Child Safety | Permanent + Law Enforcement | - | - |

## Moderation Process

### 1. Detection
- AI pre-screening (real-time)
- User reports
- Proactive monitoring

### 2. Review
- Triage by severity
- Assign to moderator
- Review within SLA

### 3. Decision
- Apply policy consistently
- Document rationale
- Notify user

### 4. Enforcement
- Implement action
- Preserve evidence
- Update user record

### 5. Appeal (if requested)
- Independent review
- Response within 48 hours
- Final decision

## AI Moderation

### Scope
- Real-time message scanning
- Image classification
- Behavioral pattern detection

### Limitations
- AI assists, doesn't replace human review
- High-severity always human-reviewed
- Appeals always human-reviewed

### Accuracy Targets

| Metric | Target |
|--------|--------|
| False negative rate | < 5% |
| False positive rate | < 5% |
| Critical detection rate | > 99% |

## Transparency

### User Communication
- Clear reason for action
- Which policy violated
- How to appeal

### Reporting
- Monthly moderation report
- Action breakdown by type
- Appeal outcomes

## Related Documents

- `docs/specs/safety.md` - Safety feature spec
- `docs/trust-safety/legal-escalation-and-evidence.md` - Legal escalation
- `docs/ops/slo-sla.md` - Response SLAs
