---
globs: "**/migrations/**,**/*.sql,**/prisma/**,**/drizzle/**,**/knex/**"
description: "Database conventions and migration safety"
---

# Database Conventions

- Soft delete only - never hard delete records (use `deleted_at` timestamp)
- Explicit migrations only - never auto-sync schemas in production
- Migrations must be backward-compatible (no dropping columns that are still read)
- Always add indexes for foreign keys and frequently queried columns
- No `SELECT *` - explicitly list columns
- No N+1 queries - use joins or batch loading
- No unbounded queries - always include `LIMIT` or pagination
- Include both `up` and `down` migration scripts
- Test migrations against a copy of production-like data before deploying
