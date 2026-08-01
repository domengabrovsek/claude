# Communication

**When to apply:** every interaction with the user (grilling, planning, debugging, code review, casual conversation).

## Asking questions

Ask **one** question at a time. Wait for the answer before asking the next.

**why-no-hook:** every bullet in this file is about phrasing and turn cadence of free-form text Claude produces, not patterns in tool input. Hooks operate on tool calls, not on conversational output.

- Do not stack multiple questions in a single turn, even closely related ones. `(review-time: see section note)`
- Do not bundle a question with "and also confirm X, Y, Z" tacked onto the end - those are separate questions, ask them on later turns. `(review-time: see section note)`
- If you have many things to clarify, pick the single most blocking one and ask only that. The rest go in the next turn. `(review-time: see section note)`
- Applies to all interaction (grilling, planning, debugging, code review, casual conversation), not just to the `/grill-with-docs` skill. `(review-time: see section note)`

Long multi-question turns are hard to answer clearly. One question per turn keeps the back-and-forth legible and lets each answer actually shape the next question instead of being lost in a wall of text.

## Phrasing

- Keep the question itself short. Context above the question is fine; the question line itself should be one sentence. `(review-time: phrasing length is subjective)`
- Lead with your recommendation when you have one, then ask for confirmation or pushback. Open-ended "what do you think?" without a recommendation wastes a turn. `(review-time: requires reading what Claude is about to say)`

## Links

Whenever a reply mentions something that has a URL, include the full clickable URL inline - never a bare identifier the user has to resolve by hand. A number or key without its link forces the user to do extra steps to reach it, which is the exact friction this rule removes.

**why-no-hook:** hooks fire on tool calls, not on the markdown Claude sends the user, so a bare reference in a reply can't be pattern-matched by the harness. This is a review-time obligation on output text.

- GitHub / GitLab issues, PRs, and MRs: print the full URL (`https://github.com/owner/repo/issues/123`), not just `#123` or `owner/repo#123` `(review-time: see section note)`
- Jira tickets: print the full browse URL (`https://<site>.atlassian.net/browse/KEY-123`), not just the bare `KEY-123` `(review-time: see section note)`
- Any other linkable resource mentioned in a reply - commits, CI runs, dashboards, deploy logs, docs pages, Sentry issues, cloud console resources: include the URL you used or can construct `(review-time: see section note)`
- If you genuinely cannot construct the URL, say so explicitly rather than leaving a bare identifier that looks complete `(review-time: see section note)`
- This is a superset of the PR/MR URL rule in `rules/git-conventions.md` - it applies to every linkable reference, not only PRs you opened `(review-time: see section note)`

## Plain language

Fancy words slow the reader down and hide the point. This applies to everything written for a human: replies, PR descriptions, tickets, docs, rules, skills, and personas.

- Prefer the plain word: use (not utilize), combine (not synthesize), settle or agree (not converge), unrelated (not orthogonal), make consistent (not homogenize), important (not salient). A short list of the worst offenders is blocked in newly added markdown by `hooks/post-edit-lint.sh` `(hook)`
- Words with legitimate technical uses (leverage, canonical, converge, reconcile, distill) are not hook-blocked - if a simpler word says the same thing, use it `(review-time: word choice needs surrounding context)`
- Keep real terms of art (worktree, frontmatter, idempotent, GitOps reconciliation) and the defined glossary terms in CONTEXT.md and LANGUAGE.md files - precision beats false simplicity `(review-time: term-of-art recognition)`
- When a precise term is genuinely needed, define it in one plain sentence at first use `(review-time: phrasing judgment)`

## Skill-level overrides

If a skill explicitly instructs a different cadence (e.g. "ask all questions at once"), this global rule wins. Update the skill to align rather than following the skill's contradictory instruction.
