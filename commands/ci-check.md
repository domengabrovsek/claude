Run local CI checks equivalent to the GitHub Actions pipeline. Stop at the first failure.

1. **Lint**: run the project's linter (e.g., `npm run lint` or `npx biome check .`)
2. **Typecheck**: run `npx tsc --noEmit`
3. **Tests**: run `npm test` (or `npx vitest run`)
4. **Build**: run `npm run build`

Report results for each step. If all pass, output "All CI checks passed."
If any fail, stop and report the failure details.
