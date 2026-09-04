---
name: rulebook
description: "Routes agent hosts to the applicable detailed standards in this repo's rules directory. Use before implementation, review, documentation, Git operations, delegation, or other work that needs rules beyond AGENTS.md."
---

# Rulebook

Load detailed standards for the current task from `references/`. Read only the relevant files from the routing table. Do not read every rule by default.

## Routing

| Task or context | Read |
| --- | --- |
| Any implementation | `references/engineering-principles.md` |
| Editing code comments | `references/comments.md` |
| Editing TypeScript | `references/typescript.md` |
| Editing or designing tests | `references/tests.md` |
| Editing migrations, schemas, queries, or database code | `references/database.md` |
| Editing infrastructure, CI/CD, containers, or running infrastructure commands | `references/infrastructure.md` |
| Creating or updating diagrams | `references/diagrams.md` |
| Writing or editing rules, agent instructions, personas, or skills | `references/rule-authoring.md` and `references/communication.md` |
| Committing, branching, pushing, or opening a pull request | `references/git-conventions.md` |
| Using teammates or splitting parallel work | `references/agent-routing.md` and `references/parallel-agents.md` |
| Saving research, plans, specs, or session diaries | `references/state-persistence.md` |
| Working from a Jira reference | `references/jira.md` |
| Answering about a library, framework, SDK, API, CLI, or cloud service | `references/context7.md` |
| User communication not already covered by shared guidance | `references/communication.md` |

Read combinations when the task crosses rows. For example, a TypeScript database change with tests needs the implementation, TypeScript, database, and test rules.

After loading the matching files, follow them as the detailed source of truth. If a rule names a host-specific capability, apply the compatibility mapping in the root `AGENTS.md`.
