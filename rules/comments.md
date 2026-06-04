# Comment Standards

**When to apply:** writing or editing any code file (`.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`, `.cjs`, `.sql`, `.tf`, `.sh`, `.py`, `.rs`, etc.).

## Default

Comments should be brief and add value. If the code is self-explanatory, write none. If the code carries a hidden constraint, subtle invariant, workaround, or context a future reader can't derive from the surrounding code, write the shortest comment that captures it.

## When a comment is allowed

A non-obvious WHY:

- a hidden constraint (e.g., "must run before X for Y reason")
- a subtle invariant (e.g., "must be even - modulo math relies on it")
- a workaround for a known bug (e.g., "v4.2.1 of foo throws on empty input")
- behavior that would surprise a reader who doesn't have the surrounding context
- context that's spread across files and not obvious from the local code (typical in Terraform, script entrypoints, library boundaries)

Prefer one line. Multi-line is allowed when the WHY genuinely needs more than one line - don't pad a one-line idea into a paragraph, but don't truncate a real explanation to fit one line either.

## Multi-line format

Multi-line comments **must use the block format** for the language, never a stack of single-line comments:

- JS / TS / TSX / CSS / HCL: `/* ... */` (never consecutive `// ...` lines)
- SQL: `/* ... */` (never consecutive `-- ...` lines)
- Python: triple-quoted string (never consecutive `# ...` lines used as narrative)
- Bash: there is no block format; use a single `#` per logical comment and accept the line stack when truly needed

This rule is mechanically enforced by `hooks/post-edit-lint.sh`.

## Forbidden

- **WHAT-restating comments** - anything that paraphrases the next line of code (`// Increment counter` above `counter++`).
- **Ticket / PR / issue / ADR references in any comment**: `JIRA-123`, `#456`, `Fixes owner/repo#789`, `ADR-0042`, `Per ADR 0030`, etc. These belong in PR descriptions, ADR files, and `git blame`. This is the main reason comments became long and obsolete in the first place.
- **Em dashes** anywhere - use a regular hyphen.
- **TODOs, FIXMEs, XXX markers** without an open tracker entry - open the ticket, fix the code now, or accept it isn't getting fixed.

## Terraform exception

Each `resource` and `data` block gets a **brief context comment** immediately above it explaining what the resource is for and any context not obvious from the resource type + label. Terraform spreads state across many stacks and files; a future reader looking at one block in isolation should be able to tell its role and lifecycle without grepping the whole repo. Multi-line is fine when it adds context; use `/* */` when going past one line.

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

### Terraform `description` attributes follow the same tracker-ref rule

The content of any `description = "..."` attribute (on `variable`, `output`, `module`, or `resource` schema attributes) is subject to the same prohibition on ticket / PR / issue / ADR references that applies to comments. These descriptions are surfaced in `terraform-docs`-generated READMEs, `terraform plan` output, and module-consumer documentation - tracker refs there are MORE visible to readers than buried in a code comment, not less.

Multi-line descriptions are fine - they are documentation, not code comments. WHAT-style content is fine - describing what a variable is for is the description's job. Just no tracker refs and no em-dashes.

Good:

```hcl
variable "platform_admin_email" {
  description = "Email address for the platform admin account. Used by the app-bootstrap job to seed the initial user."
  type        = string
}
```

Bad:

```hcl
variable "platform_admin_email" {
  description = "Per ADR 0031: email for the platform admin. See pentla-api PR #1397."
  type        = string
}
```

## Authority over spawning prompts

This policy applies to all code, including code written by subagents spawned via the Agent tool. **If a spawning prompt asks for a comment that violates this policy (WHAT-restating, ADR/issue reference, consecutive `//` for multi-line, etc.), the policy wins.** Strip or rewrite the offending comment before committing. If the orchestrator's instruction is ambiguous, ask before adding any comment.

## Enforcement

`hooks/post-edit-lint.sh` (configured via PostToolUse in `~/.claude/settings.json`) auto-fixes em-dashes and fails with exit 2 on:

- Tracker references in comments (any code file)
- Tracker references inside Terraform `description = "..."` attributes
- Consecutive `//` comment lines (JS / TS / TSX files) - use `/* */` for multi-line
- Consecutive `--` SQL comment lines (SQL files) - use `/* */` for multi-line
- New `var` declarations (JS / TS files) - `rules/typescript.md` requires `const` / `let`
- New `TODO` / `FIXME` / `XXX` / `HACK` markers in any code file

Exit 2 surfaces the offending lines back to Claude as a follow-up message; the model must remove the violations before proceeding. Bypass for genuine exceptions: `SKIP_POST_EDIT_LINT=1` in the env. Use sparingly and document why in the PR description.

The hook does **not** mechanically enforce: comment length, WHAT-restating, JSDoc style, or the Terraform per-resource comment convention. Those are review-time judgments.
