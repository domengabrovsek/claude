# Library Documentation (ctx7 CLI)

**When to apply:** any question about a library, framework, SDK, API, CLI tool, or cloud service - including well-known ones, whose recent releases your training data may not cover.

Fetch current docs with `ctx7` rather than answering from memory or web search. Covers API syntax, config, version migration, library-specific debugging, setup, and CLI usage.

Skip it for refactoring, writing scripts from scratch, debugging business logic, code review, and general programming concepts `(review-time: classifying the question requires reading it)`

## Steps

1. `npx ctx7@latest library <name> "<user's question>"`
2. Pick the match (ID format `/org/project`) by exact name, description fit, snippet count, source reputation, and score. Wrong-looking results? Try another name or rephrase.
3. `npx ctx7@latest docs <libraryId> "<user's question>"`
4. Answer from what came back.

## Rules

- Always call `library` first unless the user hands you an `/org/project` ID `(review-time: ordering enforcement requires reading the in-progress command)`
- Pass the user's full question as the query. Specific beats single keywords `(review-time: query-quality judgment)`
- Three commands per question, maximum `(review-time: requires tracking calls within the turn)`
- Never put API keys, passwords, or credentials in a query `(review-time: requires reading the constructed query)`
- Version-specific docs use `/org/project/version` from the `library` output `(review-time: requires knowing a version is in play)`
- On a quota error, tell the user and suggest `npx ctx7@latest login` or `CONTEXT7_API_KEY`. Never fall back to training data silently `(review-time: error-handling pattern in conversation)`
