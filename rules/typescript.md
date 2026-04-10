---
globs: "**/*.ts,**/*.tsx"
description: "TypeScript coding standards"
---

# TypeScript Standards

- No `any` or `unknown` - use proper types, generics, or branded types
- 2-space indentation, single quotes
- Prefer `interface` over `type` for object shapes (unless union/intersection needed)
- Prefer an options object when a function takes 3+ parameters, or when any parameter is optional. Destructure inside the function body. Exceptions: tightly coupled, order-intuitive positional params where the order IS the contract (e.g., `clamp(value, min, max)`, `range(start, end, step)`, `lerp(a, b, t)`), and variadic/rest functions. Boolean parameters should always be passed via an options object regardless of count - avoid "flag soup" like `doThing(true, false, true)`
- Destructure imports when possible: `import { foo } from 'bar'`
- No barrel exports (`index.ts` re-exports) - import directly from source
- No default exports - use named exports only
- Zod schemas for runtime validation at system boundaries (API inputs, env vars, external data)
- Prefer `const` over `let`, never use `var`
- Use strict null checks - handle `null`/`undefined` explicitly
- No non-null assertion operator (`!`) - use proper null checks, optional chaining, or narrowing instead
