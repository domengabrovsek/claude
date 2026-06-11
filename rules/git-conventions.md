# Git Conventions

**When to apply:** every commit, branch operation, or pull-request action.

## Commits

- Always use conventional commits format (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, `test:`, `ci:`, etc.) `(hook)`
- Scope is optional, e.g. `feat(auth): add token refresh` `(review-time: descriptive sub-rule of the format above)`
- Never add Co-Authored-By or any AI attribution anywhere - commits, PR/MR titles and descriptions, issues, comments, or any other artifact. This includes the "Generated with Claude Code" footer harnesses append by default `(hook for commits; review-time for PR bodies and other artifacts)`
- Before committing, verify the current branch with `git branch --show-current` - never commit directly to main/master `(hook)`
- Never auto-commit or push - wait for explicit instructions `(review-time: depends on conversational signal, not pattern)`

## Branches and PRs

- NEVER push directly to the default branch (master/main) - always use a feature branch and create a PR `(hook)`
- NEVER force-push any ref without asking immediately before the push - approval of a plan that includes a force-push is not approval of the push itself. Ask at execution time, every time (applies to agents/subagents too: they must report back for confirmation, not push) `(review-time: requires a fresh user confirmation at execution time; deny rules block bare --force/-f)`
- NEVER merge PRs automatically - always wait for the user to merge manually `(review-time: depends on user signal, not pattern)`
- After completing any feature implementation, create a PR unless explicitly told otherwise - do not wait to be asked `(review-time: requires judging "completion")`
- Always rebase onto the target branch (`git fetch origin main && git rebase origin/main`) before creating a PR `(hook)`
- Always run `/verify-done` before pushing any branch - never push without all checks passing `(hook)`
- PR descriptions: always use bullet points in the summary section, not prose paragraphs `(review-time: formatting of free-form text Claude produces)`
- Never reference local planning artifacts (`.claude/state/` plans, research, session diaries) in PR descriptions - they are untracked and invisible to reviewers `(review-time: formatting of free-form text Claude produces)`
- After pushing new commits to an existing PR, update the PR title and description to reflect all changes - use `gh pr edit` to keep them accurate `(review-time: requires judging "reflects all changes")`
- If the repo has a PR template (`.github/pull_request_template.md`), use it. If not, use `~/.claude/pull_request_template.md` `(review-time: template selection requires reading directory)`

## PR State Freshness

PR / branch state from earlier in the conversation goes stale. Probe ground truth before acting or claiming.

- Before asserting PR state in a reply (open / merged / closed / checks-passing / "you're all set"), run `gh pr view --json state,mergedAt,statusCheckRollup,url` and base the reply on that output, not on conversation memory `(review-time: requires recognizing a state-claim in the reply)`
- A probe result is reusable for 5 minutes within the same turn-stream, but only if no state-changing action (`git push`, `gh pr merge`, `gh pr close`, `gh pr ready`, etc.) was taken in between - any such action voids the exemption, re-probe `(review-time: requires tracking probe age and intervening actions)`
- Write-side `git push` / `git commit` / `gh pr (edit|comment|merge|close|ready|review)` are auto-probed by `hooks/pre-git-state-refresh.sh`, which injects a `[pr-state]` line into the tool context - read that line before deciding the next step `(hook)`
- If the injected `[pr-state]` line reports `state=MERGED` or `state=CLOSED` for a command that writes to that PR, pause and confirm intent with the user instead of proceeding silently `(review-time: requires reading the injected state line and recognizing intent mismatch)`

## Testing Hygiene

- When modifying test files, ensure all mocks are updated to match new DB queries, service dependencies, and module imports `(review-time: requires understanding mock-target coupling)`

## Versioning

- Follow semantic versioning (semver) - MAJOR for breaking changes, MINOR for new features, PATCH for fixes `(review-time: classifying a change as breaking vs additive requires judgment)`

## Tooling

- Always use `gh` CLI for GitHub operations (PRs, issues, checks, releases) - never use MCP tools for GitHub `(review-time: tool selection per action, not a single regex)`
