---
name: wizard
description: "Generates an interactive bash wizard that walks a human through steps only they can perform. Use when provisioning infrastructure, setting up credentials or CI secrets, walking a third-party dashboard, or running a one-off migration or cutover. Not for steps the agent can perform itself."
---

> Source: [mattpocock/skills - engineering/wizard](https://github.com/mattpocock/skills/tree/main/skills/engineering/wizard)

# Wizard

A **wizard** is a bash script that walks a human through a manual procedure, step by step. It opens each URL and says exactly what to click and copy. It captures the values and writes them where they belong (`.env`, GitHub secrets). It confirms at every stage and shows how many stages are left. Typical jobs: configure third-party services, run a one-off migration, move the project from one state to another.

The UX is already solved by [template.sh](template.sh):

- stage-by-stage progress and a closing summary
- confirmation gates
- cross-platform URL opening (including WSL)
- hidden secret entry
- idempotent `.env` upserts and `gh secret` / `gh variable` writes

Your job is only to scope the procedure and author its stages. The library above the `STAGES` marker is identical in every wizard. That consistency is the point: never hand-edit it.

A wizard is ephemeral by default: built for one run, saved to a scratch or `scripts/` path, deleted when the job is done. Commit it only when the user wants a repeatable setup path in the repo.

## Process

### 1. Scope the procedure

Work out every manual step the human must take and every value captured along the way. Read the repo first, do not ask cold:

- For setup: `.env.example`, `README`, `docker-compose*`, framework config, and `.github/workflows/*`. Every `secrets.*` or `vars.*` reference is a value the wizard must produce.
- For a migration or transition: the current state, the target state, and the irreversible actions between them.

Then show the user the ordered list of stages and the values each produces. Confirm: they may add, drop, or reorder.

**Done when:** every stage is named in order. For each captured value you know three things: where the human gets it, where it lands (`.env`, a GitHub secret, both, or nowhere), and whether it is secret.

### 2. Map each stage's journey

For each stage, write the precise path a human follows: which URL to open, what to do there, where the value shows, which variable it fills. Example: "Dashboard → Developers → API keys → Reveal test key → copy". Where you do not know the current UI or the exact command, say so and ask the user or check the docs. Never invent steps that may not exist.

**Done when:** every stage traces to concrete instructions a stranger could follow.

### 3. Author the wizard

Copy `template.sh` to the target path. Replace the example stage with one `stage` per step, in dependency order. Use the library helpers: `stage`, `say`/`step`, `open_url`, `ask`/`ask_secret`, `write_env`, `set_secret`/`set_var`, `pause`/`confirm`. Set `TOTAL_STAGES` to the number of stages you wrote.

Hold the bar the template sets: open the URL before asking for its value. Use `ask_secret` for anything secret. `write_env` every persisted value. `set_secret` only the values CI actually needs. `confirm` before any irreversible action. Each `stage` clears the screen, so keep a stage to one focused task. Do not touch the library above the marker.

### 4. Verify and hand off

- `bash -n <script>`; run `shellcheck` if available.
- `chmod +x <script>`.
- Do not run it end-to-end: it opens browsers and blocks on human input. Trace it statically instead: every value from step 1 is captured and lands where step 1 said. Every `set_secret` name must match a `secrets.*` reference in CI.
- Tell the user how to run it. For a repeatable setup path, commit it and link it from the README.
