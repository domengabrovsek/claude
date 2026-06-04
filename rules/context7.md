# Library Documentation (ctx7 CLI)

**When to apply:** whenever the user asks about a library, framework, SDK, API, CLI tool, or cloud service. Including well-known ones (React, Next.js, Prisma, Tailwind, Django) since your training data may not reflect recent changes.

Use the `ctx7` CLI to fetch current documentation. This covers API syntax, configuration, version migration, library-specific debugging, setup instructions, and CLI tool usage. Prefer it over web search for library docs. `(review-time: tool-selection decision per question)`

Do not use for: refactoring, writing scripts from scratch, debugging business logic, code review, or general programming concepts. `(review-time: classifying the user's question requires reading it)`

## Steps

1. Resolve library: `npx ctx7@latest library <name> "<user's question>"`
2. Pick the best match (ID format: `/org/project`) by: exact name match, description relevance, code snippet count, source reputation (High/Medium preferred), and benchmark score (higher is better). If results don't look right, try alternate names or queries (e.g., "next.js" not "nextjs", or rephrase the question)
3. Fetch docs: `npx ctx7@latest docs <libraryId> "<user's question>"`
4. Answer using the fetched documentation

You MUST call `library` first to get a valid ID unless the user provides one directly in `/org/project` format. Use the user's full question as the query -- specific and detailed queries return better results than vague single words. Do not run more than 3 commands per question. Do not include sensitive information (API keys, passwords, credentials) in queries. `(review-time: ordering and query-quality enforcement requires reading the in-progress command)`

For version-specific docs, use `/org/project/version` from the `library` output (e.g., `/vercel/next.js/v14.3.0`). `(review-time: requires knowing when version-specific docs are needed)`

If a command fails with a quota error, inform the user and suggest `npx ctx7@latest login` or setting `CONTEXT7_API_KEY` env var for higher limits. Do not silently fall back to training data. `(review-time: error-handling pattern in conversation)`
