# Global Rules

These rules apply to every project. Project-level CLAUDE.md files override where they conflict.

## Read this first

The four rules broken most often. They outrank everything below.

**why-no-hook:** voice, prose volume, and "is this the existing pattern" are judgments about intent. `hooks/prose-gate.sh` catches the mechanical slice (word list, filler, chatbot phrasing, sentence length) on markdown writes, commit messages and PR bodies. It cannot see a chat reply, and the judgment tier lives in the `write-plain` skill.

### 1. Write plain

Covers replies, PR descriptions, tickets, docs, rules, skills, commit messages.
Sentence shape follows ASD-STE100 Simplified Technical English (Issue 9), without its approved-word dictionary.

- Active voice, present tense. Name the actor `(review-time: see section note)`
- One idea per sentence. Cut any sentence whose only job is introducing the next one `(review-time: see section note)`
- Sentences: 20 words maximum for a step or an instruction, 25 for description. Split anything longer `(hook)`
- One instruction per sentence. Two actions means two steps `(review-time: needs the step's intent, not its shape)`
- Noun clusters: three words maximum. "post-edit lint hook" passes, "post-edit lint hook config loader" does not `(review-time: needs part-of-speech tagging a grep cannot do)`
- Write "because" for cause. Keep "since" for time only `(hook)`
- Paragraphs: six sentences maximum `(review-time: diff-added lines carry no paragraph boundaries)`
- Asked for a table or a list? Output only that. No prose wrapper, no summary after it `(review-time: see section note)`
- Say the thing, then stop. No closing paragraph repeating what you just said `(review-time: see section note)`
- Never write: "to make sure X, let's Y", "it's worth noting", "I should mention", "we'll want to", "it's important to", "in order to", "leverage", "utilize", "delve", "robust", "seamless", "comprehensive", "crucial", "pivotal", "showcase", "facilitate", "numerous", "serves as" `(hook)`
- Revising a doc, ADR, spec or PR body? Use the `write-plain` skill for the patterns no regex catches `(review-time: see section note)`
- Length caps: PR body 150 words, review or Slack reply 120, session diary 300, ADR 400. In chat, write the shortest version that answers and expand when asked `(review-time: see section note)`

### 2. Verify before asserting

- Cite the file:line, command output, or query you checked. Never answer from a research doc, a session note, or memory. If you cannot verify, say so instead of asserting `(review-time: see section note)`

### 3. Follow the pattern already here

- Search for the existing pattern and name it with a path before adding any new abstraction (permission set, config file, CLI command, plugin) `(review-time: see section note)`

### 4. Build only what was asked

- No extra pages, sections, or nice-to-haves. Extra scope needs a question first `(review-time: see section note)`
- Never edit production request-handling code to satisfy a linter or bot finding. Defer it to a follow-up PR and say so `(review-time: see section note)`

## Priority order

When goals conflict: **quality > consistent > efficient > fast**.

## Workflow: Research - Grill - Implement - Summarize

1. **Research** (optional): orientation pass in unfamiliar code, artifact to `.claude/state/research/`. Skip when the area is familiar.
2. **Grill**: `/grill-with-docs <topic>`. Walks the decision tree one question at a time, emits CONTEXT.md terms and ADRs inline, ends by writing a plan to `.claude/state/plans/`. Your confirmation at exit is the approval gate.
3. **Implement**: `/build` walks the plan task by task. Build, lint, and tests must pass before done.
4. **Summarize**: session diary to `.claude/state/sessions/`.

The grill is self-pacing and exits in two turns when there is nothing to align on.

Trivial bypass (straight to implement, no summary): typos, single-line fixes, version bumps, config tweaks. Only when you are certain.

Other intents have their own shapes: `/debug`, `/zoom-out`, `/review-pr`, `/document`, `/spec`.

## Already enforced

These are backed by hooks or deny rules. Know them so you do not waste a cycle hitting the gate.

- Never read `.env*`, `*.pem`, `*.key`, `credentials.json`, `service-account*.json`, `~/.aws`, `~/.ssh`, `~/.config/gcloud`, `~/.kube` `(hook)`
- Never use em dashes. Use a hyphen `(hook)`
- Complete code only. No TODOs, no placeholders `(hook)`
- Conventional commit format `(hook)`
- No AI attribution anywhere: no Co-Authored-By, no "Generated with" footer `(hook)`
- Never commit or push to main/master. Branch first `(hook)`
- Rebase onto the target branch before opening a PR `(hook)`
- Run `/verify-done` before any push `(hook)`

For debugging config, ask the user for the non-sensitive parts rather than reading a blocked file `(review-time: conversational pattern, no tool call to intercept)`

## Code Standards

- Use the project's configured formatter and linter `(review-time: per-repo configuration choice)`
- **Comments**: see [`rules/comments.md`](rules/comments.md) `(review-time: pointer, substance lives in the linked file)`
- Detailed standards in `rules/` (typescript, tests, database, infrastructure, comments) `(review-time: pointer)`

## Docs Sync

- Engineering docs live in each repo's `/docs/` tree, organized by [Diataxis](https://diataxis.fr/) plus `adr/` `(review-time: directory-layout convention)`
- When code changes behavior documented in `docs/`, update those docs in the same PR `(review-time: requires recognizing behavior-doc impact)`
- Use `/document` to create or refresh docs `(review-time: workflow guidance)`
- Only touch docs describing behavior changed in this session. No forward-looking or speculative content `(review-time: session-scope discipline)`
- Diagrams default to Mermaid; drawio for custom shapes, multi-layer architecture, or precise layout - see `rules/diagrams.md` `(review-time: diagram-tool selection)`
- ADRs are immutable once Accepted. A reversal creates a new ADR superseding the old `(review-time: ADR lifecycle convention)`
- Outside `/grill-with-docs` and `/document`, never create an ADR, README, or other doc unless asked `(review-time: requires separating the doc-emitting workflows from ad-hoc doc creation)`

## Behavioral Rules

- **Minimal fix**: for bugs, state the smallest change first (ideally 1-5 lines). Expand only when the minimal fix is provably not enough. No new abstractions, files, or patterns in a bug fix `(review-time: minimal-fix judgment)`
- **Decisions**: ask before making an architectural choice. Never silently pick a pattern, library, or approach `(review-time: requires recognizing a choice point)`
- **Cost**: warn before any change that raises costs (new cloud resources, paid services, upgraded tiers) `(review-time: cost-impact recognition)`
- **Destructive infra ops**: before destroying a shared or stateful cloud resource, list its consumers and confirm. Full policy in `rules/infrastructure.md` `(review-time: blast-radius knowledge lives outside the rule text)`
- **Testing**: always write tests for a new feature or a bug fix `(review-time: per-PR judgment on coverage of the change)`
- **Atomic feature unit**: "implement" means implement, commit on a feature branch, push, open PR. Never stop at the code change `(hook)`
- **Parallelization**: 2+ independent sub-tasks touching different files? Split across teammates - see `rules/parallel-agents.md` `(review-time: parallelization judgment)`

## Learning from Mistakes

- When corrected, update the rule file that covers it rather than adding a duplicate `(review-time: meta-process for rule maintenance)`

## Environment

macOS, zsh, Node (check `.nvmrc`), npm. Docker for local services. GCP primary, AWS secondary. Current year is 2026.

- Never work around a deny rule. For staging databases and external services, ask for credentials or URLs `(review-time: backed by permissions.deny; the no-workaround part is behavioral)`
- Sentry: use the `sentry-issue` skill for any issue ID or URL. Never print the token `(review-time: routing to a skill; non-disclosure is behavioral)`

## Imported rules

Loaded into every session. Edit the files in `rules/`, not this list.

@rules/agent-routing.md
@rules/comments.md
@rules/communication.md
@rules/context7.md
@rules/engineering-principles.md
@rules/git-conventions.md
@rules/parallel-agents.md
@rules/state-persistence.md

## Loaded on demand

Never add these to the import list above. An `@`-import loads a file unconditionally and defeats the trigger.

- `paths:` frontmatter, loading when a matching file is touched: `rules/typescript.md`, `rules/tests.md`, `rules/database.md`, `rules/infrastructure.md`, `rules/diagrams.md`, `rules/rule-authoring.md` `(review-time: import-list discipline)`
- Model-invoked skills, loading when the request matches: `jira` `(review-time: import-list discipline)`
