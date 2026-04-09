# Expert Agent Routing

Before starting any non-trivial task, determine which expert agents are relevant based on the task context. Read the matching agent files from `~/.claude/agents/` and follow their guardrails, checklists, and red flags throughout the task. Load multiple agents when the task spans domains.

## Routing Table

| Domain trigger | Agent file | Load when the task involves... |
| --- | --- | --- |
| System design, architecture, DDD, module boundaries | `staff-engineer.md` | Code architecture, design patterns, system-level decisions |
| React, components, CSS, browser, frontend, UI rendering | `frontend-staff-engineer.md` | Frontend code, components, styling, client-side performance |
| API, database, backend, queues, caching, Node.js server | `backend-staff-engineer.md` | Backend code, APIs, database queries, server-side logic |
| CI/CD, Docker, Kubernetes, Terraform, infrastructure, GitOps | `devops-engineer.md` | Deployment, pipelines, containers, infrastructure changes |
| Tests, QA, coverage, flaky, E2E, Playwright, Vitest | `qa-expert.md` | Writing tests, test strategy, test infrastructure |
| AWS, S3, Lambda, EC2, CloudFront, DynamoDB | `aws-expert.md` | AWS services and infrastructure |
| GCP, Cloud Run, BigQuery, Pub/Sub, Cloud Functions | `gcp-expert.md` | GCP services and infrastructure |
| ArgoCD, GitOps, ApplicationSet, sync policy, Argo Rollouts | `argocd-expert.md` | ArgoCD configuration, GitOps workflows, progressive delivery |
| PostgreSQL, SQL, queries, indexes, migrations | `postgresql-expert.md` | Database schema, queries, migrations, performance |
| Networking, DNS, TCP, load balancer, CDN, VPN | `networking-expert.md` | Network configuration, DNS, connectivity |
| Security, auth, OWASP, XSS, injection, encryption | `cybersecurity-expert.md` | Security review, auth flows, vulnerability assessment |
| GDPR, privacy, consent, DPIA, data subject rights, PII | `gdpr-expert.md` | Data protection, privacy, personal data handling |
| GTM, tags, server-side tagging, data layer, GA4, CAPI | `gtm-expert.md` | Tag management, analytics, tracking, consent mode |
| Product, user story, prioritization, roadmap, metrics | `product-manager.md` | Feature planning, requirements, success criteria |
| UX, usability, accessibility, WCAG, design, interaction | `ux-expert.md` | UI/UX design, accessibility, user experience |
| Error handling, resilience, circuit breaker, retry, timeout | `backend-staff-engineer.md` | Designing failure modes, degradation patterns |
| API design, REST, GraphQL, schema, contracts | `backend-staff-engineer.md` | Designing APIs, versioning, breaking changes |
| Data model, schema design, normalization, ERD | `postgresql-expert.md` | Designing database structure from scratch |
| Test strategy, test architecture, test pyramid, coverage | `qa-expert.md` | Planning test approach before implementation |
| Performance, profiling, latency, p99, load testing | `backend-staff-engineer.md` + `frontend-staff-engineer.md` | Performance work (load both for full-stack) |
| PR review, code review | `pr-reviewer.md` | Reviewing pull requests or code changes |

## Rules

- **Always load agents before research phase** - read the files before forming opinions
- **Load multiple agents** when the task crosses domains (e.g., a new API endpoint -> backend + security + QA)
- **Feature planning** should always include: product-manager + the relevant technical agents
- **UI work** should always include: frontend + ux + qa (accessibility)
- **Any data handling** in EU context should include: gdpr
- **Guardrails from all loaded agents apply simultaneously** - a violation in any agent is a blocker
- **Skip agent loading for trivial changes** (typos, one-liner fixes, config tweaks)
