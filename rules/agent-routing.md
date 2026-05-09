# Expert Agent Routing

Specialized agent personas live in `~/.claude/agents/`. Each captures domain expertise plus guardrails and red flags.

## Loading model

When a task touches a specialized domain, **spawn a subagent** via the Agent tool with the matching `subagent_type`. The subagent loads the agent file in its own context, runs the work, and returns a summary to the parent.

Do NOT read agent files into the main conversation. That pollutes context and bleeds biases across unrelated work later in the session. The agent file is for the subagent; you act on the subagent's summary.

Skip subagent spawning for trivial changes (typos, one-liner fixes, config tweaks).

## Agents

| `subagent_type` | Spawn when the task touches... |
| --- | --- |
| `Staff Engineer` | Architecture, DDD, module boundaries, system-level design |
| `Backend Staff Engineer` | Node.js APIs, server logic, data pipelines, caching, rate limiting, error handling |
| `Frontend Staff Engineer` | React, components, CSS, browser, client-side performance |
| `DevOps Engineer` | CI/CD, Docker, Kubernetes, Terraform, observability, GitOps, monitoring |
| `QA Expert` | Test strategy, test architecture, flaky tests, E2E, coverage |
| `PR Reviewer` | Pull request review, code review |
| `Cybersecurity Expert` | Security review, OWASP, auth flows, vulnerability assessment |
| `PostgreSQL Expert` | SQL, indexes, query plans, migrations, schema design |
| `AWS Expert` | AWS services and infrastructure |
| `GCP Expert` | GCP services and infrastructure |
| `Networking Expert` | DNS, TCP, load balancers, CDN, VPN |
| `ArgoCD Expert` | ArgoCD, ApplicationSet, sync policy, Argo Rollouts |
| `GDPR Expert` | Privacy, consent, DPIA, PII handling for EU subjects |
| `GTM Expert` | Google Tag Manager, server-side tagging, GA4, CAPI |
| `Product Manager` | Feature planning, user stories, success criteria, roadmap |
| `UX Expert` | Usability, accessibility, WCAG, interaction design |

## Cross-domain combinations

- **UI work** -> `Frontend Staff Engineer` + `UX Expert` + `QA Expert` (accessibility)
- **Feature planning** -> `Product Manager` + the relevant technical agents
- **Performance work** -> `Backend Staff Engineer` + `Frontend Staff Engineer`
- **Rate limiting / throttling / DDoS** -> `Backend Staff Engineer` + `Networking Expert`
- **Data handling for EU subjects** -> include `GDPR Expert`
- **PR with security implications** -> `PR Reviewer` + `Cybersecurity Expert`

When a task crosses domains, spawn multiple subagents in **parallel** - send a single message with multiple Agent tool calls so they run concurrently.

## Rules

- Subagent guardrails apply within their context. Act on the subagent's summary, not the agent file
- Multiple subagents may produce conflicting recommendations - surface conflicts to the user, do not silently pick a side
- Subagents see none of the parent conversation - brief them with self-contained prompts (goal, file paths, constraints, verification command)
