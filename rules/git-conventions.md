# Git Conventions

## Commits

- Always use conventional commits format (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, `test:`, `ci:`, etc.)
- Scope is optional, e.g. `feat(auth): add token refresh`
- Never add Co-Authored-By or any AI attribution to commits
- Before committing, verify the current branch with `git branch --show-current` - never commit directly to main/master
- Never auto-commit or push - wait for explicit instructions

## Branches and PRs

- NEVER push directly to the default branch (master/main) - always use a feature branch and create a PR
- NEVER merge PRs automatically - always wait for the user to merge manually
- After completing any feature implementation, create a PR unless explicitly told otherwise - do not wait to be asked
- Always rebase onto the target branch (`git fetch origin main && git rebase origin/main`) before creating a PR
- Always run `/user:verify-done` before pushing any branch - never push without all checks passing
- PR descriptions: always use bullet points in the summary section, not prose paragraphs
- After pushing new commits to an existing PR, update the PR title and description to reflect all changes - use `gh pr edit` to keep them accurate
- If the repo has a PR template (`.github/pull_request_template.md`), use it. If not, use `~/.claude/pull_request_template.md`

## Testing Hygiene

- When modifying test files, ensure all mocks are updated to match new DB queries, service dependencies, and module imports

## Versioning

- Follow semantic versioning (semver) - MAJOR for breaking changes, MINOR for new features, PATCH for fixes

## Tooling

- Always use `gh` CLI for GitHub operations (PRs, issues, checks, releases) - never use MCP tools for GitHub
