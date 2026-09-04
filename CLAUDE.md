# Claude Code Adapter

@AGENTS.md

Claude Code loads the modular rule files below through `@` imports. They remain the detailed source of truth for Claude-specific loading behavior. Other agent hosts reach the same files through the `rulebook` skill.

## Imported rules

Loaded into every Claude Code session. Edit the files in `rules/`, not this list.

@rules/agent-routing.md
@rules/comments.md
@rules/communication.md
@rules/context7.md
@rules/engineering-principles.md
@rules/git-conventions.md
@rules/parallel-agents.md
@rules/state-persistence.md

## Loaded on demand

Never add these to the import list above. An `@` import loads a file unconditionally and defeats the trigger.

- `paths:` frontmatter, loading when a matching file is touched: `rules/typescript.md`, `rules/tests.md`, `rules/database.md`, `rules/infrastructure.md`, `rules/diagrams.md`, `rules/rule-authoring.md` `(review-time: import-list discipline)`
- Model-invoked skills, loading when the request matches: `jira` `(review-time: import-list discipline)`
