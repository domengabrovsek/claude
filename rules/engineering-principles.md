# Engineering Principles

**When to apply:** every implementation task.

## Change sizing

- Target ~100 lines per commit. 300 is fine for a cohesive change that cannot be split. 1000+ must be split into sequential PRs or stacked commits `(review-time: judging cohesion; a mechanical line gate would block legitimate work)`
- A PR touching 15+ files needs a reason. A rename or migration qualifies; "I was in the area" does not `(review-time: separating a needed sweep from a drive-by)`

## Shape of the work

- Ship thin end-to-end slices (UI plus API plus DB plus test), not horizontal layers. Too large? Narrow the scope: fewer fields, simpler validation, fewer edge cases `(review-time: slice-shape judgment)`
- Before removing or changing existing code, find out why it exists. Run `git blame`, read the commit, check linked issues. No context and it looks unnecessary? Ask, do not silently delete `(review-time: requires recognizing the absence of context)`
- Catch problems as early as the stack allows: types, then lint, then unit tests, then integration, then runtime validation, then monitoring. Something the type system can catch does not need a test - fix the types `(review-time: layer-selection judgment)`

## When information conflicts

Rules files beat specs, specs beat source code, source code beats error output, error output beats conversation history. Conversation history is the least reliable of the five: it goes stale and gets misremembered `(review-time: source-of-truth ranking)`

## Exploration guard rails

- Open-ended task? Explore briefly, then start writing. Partial progress beats a perfect plan `(review-time: time-budget judgment)`
- Reading files for more than 5 minutes with no code produced? Stop and implement with what you know `(review-time: requires self-tracking)`
- Never spend a whole session on analysis without producing a working artifact `(review-time: session-shape judgment)`
