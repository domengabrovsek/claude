# Global Rules

These rules apply to every project. Project-level CLAUDE.md files override where they conflict.

## Workflow: Research → Plan → Implement

### Phase 1: Research

- Read every relevant file before forming opinions  - no guessing
- Produce a research artifact summarizing findings, open questions, and constraints
- Do NOT propose solutions yet

### Phase 2: Plan

- Produce a plan with: goal, approach, file-by-file changes (with code snippets), task checklist
- Include exact file paths and line ranges for every change
- Flag risks, trade-offs, and alternatives
- Wait for approval before proceeding  - say **"don't implement yet"** if tempted

### Phase 3: Annotation Cycle

- User annotates the plan with notes, questions, or corrections
- Address every annotation, update the plan, and re-present
- Repeat until user explicitly approves  - do NOT skip ahead to implementation
- This phase may take multiple rounds; that is expected

### Phase 4: Implement

- Execute the approved plan task by task, marking each done in the plan file
- Do not stop mid-implementation to ask questions already answered in the plan
- Run typecheck continuously as you go (`npx tsc --noEmit` or project equivalent)
- After all tasks: build + lint + test must pass before declaring done

### Skipping Phases

For trivial changes (typos, one-liner fixes, config tweaks): skip straight to implementation. If in doubt, ask.

### File Naming

Research and plan files must use dashes for multi-word names and include a timestamp: `YYYY-MM-DD-descriptive-name.md`. Examples: `2026-03-12-research-auth-refactor.md`, `2026-03-12-plan-sqs-buffering.md`.

## Security

- NEVER read or process files containing secrets, credentials, API keys, or private keys
- Sensitive file patterns: `.env*`, `*.pem`, `*.key`, `credentials.json`, `service-account*.json`
- Home directory secrets (`~/.aws`, `~/.ssh`, `~/.config/gcloud`, `~/.kube`) are off-limits
- If you need config values for debugging, ask the user to provide only the non-sensitive parts

## Formatting

- Never use em dashes (—) anywhere - in code, text, translations, or documentation. Use a regular hyphen/dash (-) instead.

## Code Standards

- TypeScript: no `any` or `unknown`  - use proper types. 2-space indent, single quotes
- Use the project's formatter/linter (Biome, ESLint, Prettier  - whatever is configured)
- Zod schemas for runtime validation at system boundaries
- Database: soft delete only, explicit migrations only  - never auto-sync schemas
- Tests: Vitest preferred, mock external deps, manual class instantiation over DI in tests
- Complete code only  - no TODOs, no placeholders, no incomplete implementations

## Behavioral Rules

- **Scope**: only implement what was asked  - no drive-by refactors, extra features, or unsolicited improvements
- **Decisions**: ask before making architectural choices  - never silently pick a pattern, library, or approach
- **Cost**: warn before any change that increases costs (new cloud resources, paid services, upgraded tiers)
- **Git**: never auto-commit or push  - wait for explicit instructions
- **Commits**: always use conventional commits format (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, `test:`, `ci:`, etc.). Scope is optional, e.g. `feat(auth): add token refresh`. Never add Co-Authored-By or any AI attribution to commits
- **Versioning**: follow semantic versioning (semver) - MAJOR for breaking changes, MINOR for new features, PATCH for fixes
- **PR descriptions**: always use bullet points in the summary section, not prose paragraphs. If the repo has a PR template (`.github/pull_request_template.md`), use it. If not, use the default template at `~/.claude/pull_request_template.md`
- **Verification**: build + typecheck + lint + tests must all pass before considering work done
- **Conciseness**: be direct and terse during implementation  - save explanations for when asked
- **Existing patterns**: follow the conventions already in the codebase  - consistency over personal preference

## Expert Agents

Before starting any non-trivial task, determine which expert agents are relevant based on the task context. Read the matching agent files from `~/.claude/agents/` and follow their guardrails, checklists, and red flags throughout the task. Load multiple agents when the task spans domains.

### Agent Routing

| Domain trigger | Agent file | Load when the task involves... |
| --- | --- | --- |
| System design, architecture, DDD, module boundaries | `staff-engineer.md` | Code architecture, design patterns, system-level decisions |
| React, components, CSS, browser, frontend, UI rendering | `frontend-staff-engineer.md` | Frontend code, components, styling, client-side performance |
| API, database, backend, queues, caching, Node.js server | `backend-staff-engineer.md` | Backend code, APIs, database queries, server-side logic |
| CI/CD, Docker, Kubernetes, Terraform, infrastructure | `devops-engineer.md` | Deployment, pipelines, containers, infrastructure changes |
| Tests, QA, coverage, flaky, E2E, Playwright, Vitest | `qa-expert.md` | Writing tests, test strategy, test infrastructure |
| AWS, S3, Lambda, EC2, CloudFront, DynamoDB | `aws-expert.md` | AWS services and infrastructure |
| GCP, Cloud Run, BigQuery, Pub/Sub, Cloud Functions | `gcp-expert.md` | GCP services and infrastructure |
| PostgreSQL, SQL, queries, indexes, migrations | `postgresql-expert.md` | Database schema, queries, migrations, performance |
| Networking, DNS, TCP, load balancer, CDN, VPN | `networking-expert.md` | Network configuration, DNS, connectivity |
| Security, auth, OWASP, XSS, injection, encryption | `cybersecurity-expert.md` | Security review, auth flows, vulnerability assessment |
| GDPR, privacy, consent, DPIA, data subject rights, PII | `gdpr-expert.md` | Data protection, privacy, personal data handling |
| GTM, tags, server-side tagging, data layer, GA4, CAPI | `gtm-expert.md` | Tag management, analytics, tracking, consent mode |
| Product, user story, prioritization, roadmap, metrics | `product-manager.md` | Feature planning, requirements, success criteria |
| UX, usability, accessibility, WCAG, design, interaction | `ux-expert.md` | UI/UX design, accessibility, user experience |

### Rules

- **Always load agents before research phase**  - read the files before forming opinions
- **Load multiple agents** when the task crosses domains (e.g., a new API endpoint → backend + security + QA)
- **Feature planning** should always include: product-manager + the relevant technical agents
- **UI work** should always include: frontend + ux + qa (accessibility)
- **Any data handling** in EU context should include: gdpr
- **Guardrails from all loaded agents apply simultaneously**  - a violation in any agent is a blocker

## Learning from Mistakes

- When corrected by the user, update the relevant CLAUDE.md (global or project-level) so the mistake is not repeated
- Before updating, check if an existing rule already covers the correction  - update it rather than adding a duplicate
- Corrections to general behavior go in this global file; project-specific corrections go in the project's CLAUDE.md

## Environment

- macOS, zsh, Node.js (check `.nvmrc`), npm
- Docker for local services
- Cloud: GCP primary, AWS secondary
- Git + GitHub for version control and CI/CD
- Always use `gh` CLI for GitHub operations (PRs, issues, checks, releases) - never use MCP tools for GitHub
