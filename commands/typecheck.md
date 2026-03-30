Run `npx tsc --noEmit` (or the project's equivalent typecheck command).

For each type error found:

1. Show the error with file and line number
2. Explain what's wrong
3. Fix it with proper types (no `any` or `unknown` escape hatches)
4. Re-run typecheck to verify the fix

Continue until zero type errors remain.
