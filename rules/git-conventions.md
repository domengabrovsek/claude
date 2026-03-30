# Git Conventions

- Never auto-commit or push - wait for explicit instructions
- Always use conventional commits format (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, `test:`, `ci:`, etc.)
- Scope is optional, e.g. `feat(auth): add token refresh`
- Never add Co-Authored-By or any AI attribution to commits
- Follow semantic versioning (semver) - MAJOR for breaking changes, MINOR for new features, PATCH for fixes
- PR descriptions: always use bullet points in the summary section, not prose paragraphs
- If the repo has a PR template (`.github/pull_request_template.md`), use it. If not, use `~/.claude/pull_request_template.md`
- Always use `gh` CLI for GitHub operations (PRs, issues, checks, releases) - never use MCP tools for GitHub
