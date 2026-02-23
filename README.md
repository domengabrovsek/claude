# Claude Code Configuration

Custom configuration for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — a global `CLAUDE.md` with workflow rules and code standards, plus 15 expert agent personas with strict guardrails, review checklists, and red-flag detection.

## Setup

Copy the global configuration and agents into your Claude Code directory:

```bash
cp CLAUDE.md ~/.claude/CLAUDE.md
cp -r agents/ ~/.claude/agents/
```

## Global Configuration

[`CLAUDE.md`](CLAUDE.md) defines the rules that apply across all projects:

- **Workflow** — Research, Plan, Annotate, Implement (no skipping phases)
- **Security** — never read secrets, credentials, or private keys
- **Code Standards** — TypeScript (no `any`), Zod validation, soft deletes, Vitest, complete code only
- **Behavioral Rules** — scope discipline, ask before architectural choices, build/typecheck/lint/test before done

## Agents

### Engineering

| Agent | File | Focus |
|-------|------|-------|
| Senior Staff Engineer | [`staff-engineer.md`](agents/staff-engineer.md) | System design, code architecture, design principles, DDD, SOLID |
| Senior Frontend Staff Engineer | [`frontend-staff-engineer.md`](agents/frontend-staff-engineer.md) | React, component architecture, rendering strategies, Core Web Vitals, accessibility |
| Senior Backend Staff Engineer | [`backend-staff-engineer.md`](agents/backend-staff-engineer.md) | API design, database engineering, event-driven architecture, caching, resilience |
| Senior DevOps Engineer | [`devops-engineer.md`](agents/devops-engineer.md) | IaC, containers, Kubernetes, CI/CD, observability, SRE |
| Senior QA Expert | [`qa-expert.md`](agents/qa-expert.md) | Test strategy, test automation, CI testing, performance testing, accessibility testing |

### Infrastructure & Data

| Agent | File | Focus |
|-------|------|-------|
| Senior AWS Expert | [`aws-expert.md`](agents/aws-expert.md) | AWS services, Well-Architected Framework, cost optimization, IAM |
| Senior GCP Expert | [`gcp-expert.md`](agents/gcp-expert.md) | GCP services, Cloud Run, BigQuery, IAM, networking |
| Senior PostgreSQL Expert | [`postgresql-expert.md`](agents/postgresql-expert.md) | Query optimization, indexing, partitioning, replication, schema design |
| Senior Networking Expert | [`networking-expert.md`](agents/networking-expert.md) | TCP/IP, DNS, load balancing, CDN, VPN, network security |

### Marketing & Analytics

| Agent | File | Focus |
|-------|------|-------|
| Senior GTM Expert | [`gtm-expert.md`](agents/gtm-expert.md) | Server-side tagging, GTM web/server containers, data layer, Consent Mode v2, Conversion APIs |

### Security & Compliance

| Agent | File | Focus |
|-------|------|-------|
| Senior Cybersecurity Expert | [`cybersecurity-expert.md`](agents/cybersecurity-expert.md) | OWASP, auth, cryptography, supply chain security, threat modeling |
| Senior MDR Expert | [`mdr-expert.md`](agents/mdr-expert.md) | EU MDR 2017/745, medical device classification, clinical evaluation, SaMD |
| Senior GDPR Expert | [`gdpr-expert.md`](agents/gdpr-expert.md) | EU data protection, DPIAs, consent management, data subject rights, international transfers |

### Product & Design

| Agent | File | Focus |
|-------|------|-------|
| Senior Product Manager | [`product-manager.md`](agents/product-manager.md) | Product strategy, user stories, prioritization, roadmapping, metrics |
| Senior UX Expert | [`ux-expert.md`](agents/ux-expert.md) | Interaction design, usability, accessibility, design systems, information architecture |

## Agent Structure

Every agent follows the same 9-section structure:

1. **Identity** — role, experience, certifications
2. **Core Expertise** — domain knowledge areas
3. **Thinking Approach** — 7 principles that guide reasoning
4. **Response Style** — communication patterns
5. **Strict Guardrails** — non-negotiable rules flagged as BLOCKER (18-24 per agent)
6. **Review Checklist** — verification items for code/architecture review (12-14 per agent)
7. **Red Flags** — patterns that trigger immediate investigation (12-15 per agent)
8. **Tools & Frameworks** — recommended tooling
9. **Integration with Workflow** — how the agent works within the research/plan/implement phases
