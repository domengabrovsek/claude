# Monitor CI Pipeline

Use `/loop 2m /ci` to poll CI every 2 minutes automatically.

## Workflow

1. **Detect VCS platform**: `.gitlab-ci.yml` -> glab, `.github/` -> gh
2. **Check pipeline status** (non-interactive commands only):
   - GitLab: `glab ci status`
   - GitHub: `gh pr checks` or `gh run list --branch <current-branch>`
3. **If pipeline is still running**: report current status and stop (the /loop will re-invoke)
4. **If pipeline passes**:
   - Run `~/.claude/scripts/notify.sh "CI passed - <branch-name>"`
   - Report success and stop
5. **If pipeline fails**:
   a. Fetch the job log:
      - GitLab: `glab ci trace <job-id>`
      - GitHub: `gh run view <run-id> --log-failed`
   b. Do NOT pipe output through head, tail, grep, or any other command - run the commands directly
   c. Analyze the root cause - identify the specific failure (test, lint, type check, build, coverage, etc.)
   d. Run `~/.claude/scripts/notify.sh "CI failed - <failure-summary>"`
   e. **Propose the fix to the user** - explain what failed and what you'd change. Do NOT push automatically
   f. Wait for user approval before implementing the fix
   g. After approval: fix, commit with a descriptive message, push

## Important: Non-interactive commands only

These commands require a TTY and will NOT work - never use them:

- `glab ci view` (interactive TUI)
- `gh run watch` (interactive watcher)
- Any command with `--web` flag (opens browser)

Safe commands to use:

- `glab ci status`, `glab ci list`, `glab ci trace <job-id>`
- `gh pr checks`, `gh run list`, `gh run view <run-id> --log-failed`

## Loop cleanup

If invoked via `/loop`, call `CronDelete` to cancel the polling job once the pipeline reaches a terminal state (passed or failed). Don't leave it running.

## Guardrails

- After 3 consecutive failures on the **same issue**, stop and escalate - something structural is wrong
- Never weaken tests, skip linting, or lower coverage thresholds to make CI pass
- Never use `--no-verify` or skip hooks
- If a failure looks unrelated to your changes (flaky test, infra issue), flag it to the user rather than trying to fix it
