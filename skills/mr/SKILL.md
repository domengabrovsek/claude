# Create Merge Request / Pull Request

## Workflow

1. **Detect VCS platform**: check for `.gitlab-ci.yml` (-> glab) or `.github/` (-> gh)
2. **Determine base branch**:
   - Default for GitLab repos: `main`
   - Default for GitHub repos: `develop`
   - If the user specifies a different target, use that instead
3. **Review all commits on the branch**: run `git log <base>..HEAD` and `git diff <base>...HEAD` to understand the full changeset
4. **Ensure conventional commits**: all commits on the branch should use conventional commit format
5. **Check for env-specific values**: scan diff for hard-coded URLs, credentials, environment names that look wrong for the target branch
6. **Push branch** with `-u` flag
7. **Create MR/PR using the template**:
   - If `.github/pull_request_template.md` or `.gitlab/merge_request_templates/` exists, use that template
   - Otherwise use `~/.claude/pull_request_template.md`
   - Fill in the description explaining what changed and why
   - Check the relevant category box(es) - exactly one or more of: Bugfix, Feature, Refactor, Chore, CI/CD, Infrastructure
   - Check "Changes have been tested locally" only if tests were actually run
   - Check "No unnecessary changes outside the scope of this PR" only if true
   - Check "Considered the security impact of these changes" - always check, we always consider it
   - Check "No credentials or secrets in the code" only if verified
   - Do NOT edit the template structure, wording, or add extra sections - only fill in data and check boxes
8. **Set dependencies for stacked MRs/PRs**:
   If the target branch is not the default branch (`main`/`master`/`develop`), check for a base MR/PR:

   **GitLab:**
   - Find the base MR: `glab mr list --source-branch <target-branch>`
   - If found, create a blocking dependency after MR creation:

     ```sh
     glab api --method POST "projects/<url-encoded-project-path>/merge_requests/<our-iid>/blocks" \
       -f "blocking_merge_request_iid=<base-mr-iid>"
     ```

   - HTTP 409 is fine - GitLab may auto-detect some dependencies
   - Mention in description: `> **Stacked MR**: depends on !<base-iid>. Retarget to main after !<base-iid> is merged.`

   **GitHub:**
   - Find the base PR: `gh pr list --head <target-branch> --json number,title --jq '.[0]'`
   - GitHub has no native dependency enforcement. Instead, add `Depends on #<base-pr-number>` in the PR description (under Linked Issues or similar). This is a widely recognized convention that third-party apps (e.g., Dependent Issues, PR Dependencies) can enforce via status checks.
   - Mention in description: `> **Stacked PR**: depends on #<base-pr-number>. Retarget to main/develop after #<base-pr-number> is merged.`

9. **Report**: print the MR/PR URL. If a dependency was set, mention it.

## Rules

- Use CLI tools (`gh pr create` / `glab mr create`), not MCP tools or APIs (except `glab api` for MR dependencies - `glab mr create` has no dependency flag)
- Pass the body via HEREDOC for correct formatting
- If auth fails, stop and ask the user to authenticate - do not retry
- If the repo has a specific MR template, prefer it over the default
