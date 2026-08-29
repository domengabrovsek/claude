---
paths:
  - "**/*.sql"
  - "**/migrations/**"
  - "**/*.prisma"
  - "**/prisma/**"
  - "**/drizzle/**"
  - "**/models/**"
  - "**/repositories/**"
  - "**/db/**"
  - "**/database/**"
---

# Database Conventions

**When to apply:** editing migrations, SQL files, or any database schema / query code (Prisma, Drizzle, Knex, raw SQL).

- Soft delete only - never hard delete records (use `deleted_at` timestamp) `(review-time: hard-delete detection has too many false positives on dev / test code)`
- Explicit migrations only - never auto-sync schemas in production `(review-time: enforcement is repo-level config, varies per ORM)`
- Migrations must be backward-compatible (no dropping columns that are still read) `(review-time: semantic check requires reading app code)`
- Always add indexes for foreign keys and frequently queried columns `(review-time: requires query-pattern analysis)`
- No `SELECT *` - explicitly list columns `(hook)`
- No N+1 queries - use joins or batch loading `(review-time: pattern requires runtime / query-plan analysis)`
- No unbounded queries - always include `LIMIT` or pagination `(review-time: semantic - knowing when a result set is bounded by query shape)`
- Include both `up` and `down` migration scripts, and run the `down` before merging `(review-time: file-presence check is per-repo)`
- Test migrations against a copy of production-like data before deploying `(review-time: process, not code pattern)`

## Expand/contract migrations

Never change a column in place. Old and new code run at once during a rollout, so migrate in additive phases. The worked shape for renaming `name` to `full_name`:

1. Expand: add `full_name` as nullable. Deploy; old code ignores it.
2. Dual-write: the app writes both columns on every insert and update. Deploy.
3. Backfill: copy `name` to `full_name` in throttled batches, off the hot path.
4. Switch reads: point the app at `full_name`, keep writing both. Deploy and bake.
5. Contract: stop writing `name`, then drop the column in a separate, later deploy.

Each step is independently deployable and reversible. If step 4 misbehaves, roll the code back; `full_name` is still being populated.

- Additive first, destructive last and alone: drops and renames get their own deploy after no code references the old shape `(review-time: semantic check requires reading app code)`
- Backfill in batches with throttling; one `UPDATE` over millions of rows locks the table `(review-time: requires knowing table size)`
- Build large indexes without blocking writes: Postgres `CREATE INDEX CONCURRENTLY` `(review-time: requires knowing table size and traffic)`
