---
globs: "**/*.ts,**/*.tsx"
description: "TypeScript coding standards"
---

# TypeScript Standards

- No `any` or `unknown` - use proper types, generics, or branded types
- 2-space indentation, single quotes
- Prefer `interface` over `type` for object shapes (unless union/intersection needed)
- Destructure imports when possible: `import { foo } from 'bar'`
- No barrel exports (`index.ts` re-exports) - import directly from source
- No default exports - use named exports only
- Zod schemas for runtime validation at system boundaries (API inputs, env vars, external data)
- Prefer `const` over `let`, never use `var`
- Use strict null checks - handle `null`/`undefined` explicitly
