# Monitor CI Pipeline

## Workflow

1. **Detect VCS platform**: `.gitlab-ci.yml` -> glab, `.github/` -> gh
2. **Start a Monitor** with the matching script:
   - GitHub: `bash ~/.claude/skills/ci/scripts/gh-ci-monitor.sh`
   - GitLab: `bash ~/.claude/skills/ci/scripts/glab-ci-monitor.sh`
   - Use `persistent: false`, `timeout_ms: 3600000` (1 hour ceiling — CI pipelines can be long)
   - Description: "CI pipeline on <branch-name>"
3. **React to Monitor notifications**:
   - `no-runs|<branch>`: no CI runs found for this branch — inform the user and stop
   - `error|persistent-failure`: the monitor script hit 5 consecutive errors — report and stop
   - Status change (e.g., `in_progress|null` → `completed|success`): acknowledge briefly
   - **Pipeline passes** (`completed|success`):
     - Run `~/.claude/scripts/notify.sh "CI passed - <branch-name>"`
     - Report success
   - **Pipeline fails** (`completed|failure` or any non-success conclusion):
     a. Fetch the job log:
        - GitLab: `glab ci trace <job-id>`
        - GitHub: `gh run view <run-id> --log-failed`
     b. Do NOT pipe output through head, tail, grep, or any other command - run the commands directly
     c. Analyze the root cause - identify the specific failure (test, lint, type check, build, coverage, etc.)
     d. Run `~/.claude/scripts/notify.sh "CI failed - <failure-summary>"`
     e. **Propose the fix to the user** - explain what failed and what you'd change. Do NOT push automatically
     f. Wait for user approval before implementing the fix
     g. After approval: fix, commit with a descriptive message, push

## How it works

The monitor scripts poll CI status every 30 seconds but only emit a line when the status **changes**. This means:

- Zero token cost while the pipeline is running and status hasn't changed
- Claude reacts within ~30s of a status change (vs up to 2 min with /loop)
- No CronDelete cleanup needed — the script exits on terminal state, ending the Monitor
- If `gh`/`glab` fails 5 times in a row (auth expired, network down), the script exits with an error notification

## Important: Non-interactive commands only

These commands require a TTY and will NOT work - never use them:

- `glab ci view` (interactive TUI)
- `gh run watch` (interactive watcher)
- Any command with `--web` flag (opens browser)

Safe commands to use:

- `glab ci status`, `glab ci list`, `glab ci trace <job-id>`
- `gh pr checks`, `gh run list`, `gh run view <run-id> --log-failed`

## Guardrails

- After 3 consecutive failures on the **same issue**, stop and escalate - something structural is wrong
- Never weaken tests, skip linting, or lower coverage thresholds to make CI pass
- Never use `--no-verify` or skip hooks
- If a failure looks unrelated to your changes (flaky test, infra issue), flag it to the user rather than trying to fix it
