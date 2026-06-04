# Database Conventions

**When to apply:** editing migrations, SQL files, or any database schema / query code (Prisma, Drizzle, Knex, raw SQL).

- Soft delete only - never hard delete records (use `deleted_at` timestamp) `(review-time: hard-delete detection has too many false positives on dev / test code)`
- Explicit migrations only - never auto-sync schemas in production `(review-time: enforcement is repo-level config, varies per ORM)`
- Migrations must be backward-compatible (no dropping columns that are still read) `(review-time: semantic check requires reading app code)`
- Always add indexes for foreign keys and frequently queried columns `(review-time: requires query-pattern analysis)`
- No `SELECT *` - explicitly list columns `(hook)`
- No N+1 queries - use joins or batch loading `(review-time: pattern requires runtime / query-plan analysis)`
- No unbounded queries - always include `LIMIT` or pagination `(review-time: semantic - knowing when a result set is bounded by query shape)`
- Include both `up` and `down` migration scripts `(review-time: file-presence check is per-repo)`
- Test migrations against a copy of production-like data before deploying `(review-time: process, not code pattern)`
