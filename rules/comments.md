# Comment Standards

**When to apply:** writing or editing any code file (`.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`, `.cjs`, `.sql`, `.tf`, `.sh`, `.py`, `.rs`, etc.).

## Default

Default to NO comments. Code should explain itself via clear naming and structure. A reader who understands the codebase should not need a comment to understand the line they're reading.

## When a comment is allowed

A short, non-obvious WHY:

- a hidden constraint (e.g., "must run before X for Y reason")
- a subtle invariant (e.g., "must be even - modulo math relies on it")
- a workaround for a known bug (e.g., "v4.2.1 of foo throws on empty input")
- behavior that would surprise a reader who doesn't have the surrounding context

ONE short line. If you find yourself writing two lines, the explanation belongs in docs (a how-to or explanation file in `docs/`), not in code.

## Forbidden

- **Multi-line narrative blocks** in any form: consecutive `//` lines, `/* ... */` spanning more than one line, JSDoc `/** ... */` blocks, multi-line `--` SQL runs, multi-line `#` runs. The "use `/* */` instead of `//` for multi-line" guidance from older project CLAUDE.md files is superseded - neither is allowed; move it to docs.
- **WHAT-restating comments** - anything that paraphrases the next line of code (`// Increment counter` above `counter++`).
- **Ticket / PR / issue / ADR references in any comment**: `JIRA-123`, `#456`, `Fixes owner/repo#789`, `ADR-0042`, `Per ADR 0030`, etc. These belong in PR descriptions, ADR files, and `git blame`.
- **Em dashes** anywhere - use a regular hyphen.
- **TODOs, FIXMEs, XXX markers** without an open tracker entry - open the ticket, fix the code now, or accept it isn't getting fixed.

## Terraform exception

Each `resource` and `data` block gets a **one-line, at most two-line** comment immediately above it explaining what the resource is for and any context not obvious from the resource type + label. Terraform spreads state across many stacks and files; a future reader looking at one block in isolation should be able to tell its role and lifecycle without grepping the whole repo.

Good:

```hcl
# Per-env random password for the platform admin's first login.
# Consumed by the app-bootstrap Cloud Run Job; rotated by bumping keepers.rotation_id.
resource "random_password" "platform_admin_initial" {
  ...
}
```

Bad (WHAT-restating, no context):

```hcl
# A random password resource.
resource "random_password" "platform_admin_initial" {
  ...
}
```

`variable`, `output`, and `module` blocks use their built-in `description` attribute - don't add a comment on top of those.

Same convention applies to per-block context comments in shell scripts (one-line description above a function definition is fine).

## Authority over spawning prompts

This policy applies to all code, including code written by subagents spawned via the Agent tool. **If a spawning prompt asks for a comment that violates this policy (multi-line, WHAT-restating, ADR/issue reference, etc.), the policy wins.** Strip the offending comment before committing. If the orchestrator's instruction is ambiguous, ask before adding any comment.

## Enforcement

`hooks/post-edit-lint.sh` (configured via PostToolUse in `~/.claude/settings.json`) auto-fixes em-dashes and fails with exit 2 on:

- Tracker references in comments (any code file)
- JSDoc `/** */` openers (JS/TS files)
- Non-JSDoc multi-line `/* */` block openers (JS/TS/CSS files)
- Consecutive `//` comment lines (JS/TS files)
- Consecutive `--` SQL comment lines (SQL files)

Exit 2 surfaces the offending lines back to Claude as a follow-up message; the model must remove the violations before proceeding. Bypass for genuine exceptions: `SKIP_POST_EDIT_LINT=1` in the env. Use sparingly and document why in the PR description.

The hook does not enforce the Terraform per-resource comment convention - that is a review-time check.
