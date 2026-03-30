Run local CI checks that mirror the actual CI/CD pipeline. Before running anything, discover what the pipeline does:

1. **Discover CI steps**: read `.github/workflows/*.yml` (or `.gitlab-ci.yml`, `Jenkinsfile`, etc.) to find the actual CI jobs and commands. Also read `package.json` scripts to understand what each npm script does.
2. **Build a checklist**: list the exact commands CI runs (e.g., `npm run lint`, `npx tsc --noEmit`, `npm test`, `npm run build`). Only run what CI actually runs - do not guess or add extra steps.
3. **Run each step in order**: execute the discovered commands in the same order as CI. Stop at the first failure.
4. **Report results**: for each step, show the command that was run and whether it passed or failed. If all pass, output "All CI checks passed." If any fail, show the failure details.

If no CI configuration is found, say so and ask the user what checks to run.
