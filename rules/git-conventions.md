# Git Conventions

**When to apply:** every commit, branch operation, or pull-request action.

## Commits

- Always use conventional commits format (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, `test:`, `ci:`, etc.) `(hook)`
- Scope is optional, e.g. `feat(auth): add token refresh` `(review-time: descriptive sub-rule of the format above)`
- Never add Co-Authored-By or any AI attribution to commits `(hook)`
- Before committing, verify the current branch with `git branch --show-current` - never commit directly to main/master `(hook)`
- Never auto-commit or push - wait for explicit instructions `(review-time: depends on conversational signal, not pattern)`

## Branches and PRs

- NEVER push directly to the default branch (master/main) - always use a feature branch and create a PR `(hook)`
- NEVER merge PRs automatically - always wait for the user to merge manually `(review-time: depends on user signal, not pattern)`
- After completing any feature implementation, create a PR unless explicitly told otherwise - do not wait to be asked `(review-time: requires judging "completion")`
- Always rebase onto the target branch (`git fetch origin main && git rebase origin/main`) before creating a PR `(hook)`
- Always run `/verify-done` before pushing any branch - never push without all checks passing `(hook)`
- PR descriptions: always use bullet points in the summary section, not prose paragraphs `(review-time: formatting of free-form text Claude produces)`
- After pushing new commits to an existing PR, update the PR title and description to reflect all changes - use `gh pr edit` to keep them accurate `(review-time: requires judging "reflects all changes")`
- If the repo has a PR template (`.github/pull_request_template.md`), use it. If not, use `~/.claude/pull_request_template.md` `(review-time: template selection requires reading directory)`

## Testing Hygiene

- When modifying test files, ensure all mocks are updated to match new DB queries, service dependencies, and module imports `(review-time: requires understanding mock-target coupling)`

## Versioning

- Follow semantic versioning (semver) - MAJOR for breaking changes, MINOR for new features, PATCH for fixes `(review-time: classifying a change as breaking vs additive requires judgment)`

## Tooling

- Always use `gh` CLI for GitHub operations (PRs, issues, checks, releases) - never use MCP tools for GitHub `(review-time: tool selection per action, not a single regex)`
