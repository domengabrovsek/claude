---
name: resolve-conflicts
description: "Resolves an in-progress git merge or rebase conflict by recovering each side's intent from commits, PRs, and issues. Use when a merge or rebase stops on conflicts, or when the tree contains conflict markers."
---

> Source: [mattpocock/skills - engineering/resolving-merge-conflicts](https://github.com/mattpocock/skills/tree/main/skills/engineering/resolving-merge-conflicts)

1. **See the current state** of the merge or rebase. Check git history and the conflicting files.

2. **Find the primary sources** for each conflict. Understand why each change was made and what the original intent was. Read the commit messages, check the PRs, check the original issues or tickets.

3. **Resolve each hunk.** Preserve both intents where possible. Where incompatible, pick the one matching the merge's stated goal and note the trade-off. Do **not** invent new behaviour. Resolve by default; reach for `--abort` only when the user asks for it.

4. **Run the quality gate.** Use `/verify-done` to discover and run the project's checks. Fix anything the merge broke.

5. **Finish the merge or rebase.** Stage everything and commit. If rebasing, continue until all commits are rebased.
