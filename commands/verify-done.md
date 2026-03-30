Comprehensive quality gate before declaring work done. Run ALL checks:

1. **Typecheck**: `npx tsc --noEmit` - zero errors
2. **Lint**: project linter - zero errors
3. **Tests**: `npm test` - all passing
4. **Build**: `npm run build` - succeeds
5. **Git status**: show uncommitted changes
6. **Diff review**: summarize what changed (files, lines added/removed)

If all pass: output "READY - all quality gates passed."
If any fail: list failures and stop. Do NOT declare work done.
