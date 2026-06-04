---
name: write-a-skill
description: Create new agent skills with proper structure, progressive disclosure, and bundled resources. Use when user wants to create, write, or build a new skill.
---

> Source: [mattpocock/skills — productivity/write-a-skill](https://github.com/mattpocock/skills/tree/main/skills/productivity/write-a-skill)

# Writing Skills

## Process

**why-not-mechanizable:** skill workflow guidance; each step requires understanding the surrounding context (repo, task shape, prior state).

1. **Gather requirements** - ask user about: `(review-time: see section note)`
   - What task/domain does the skill cover? `(review-time: see section note)`
   - What specific use cases should it handle? `(review-time: see section note)`
   - Does it need executable scripts or just instructions? `(review-time: see section note)`
   - Any reference materials to include? `(review-time: see section note)`

2. **Draft the skill** - create: `(review-time: see section note)`
   - SKILL.md with concise instructions `(review-time: see section note)`
   - Additional reference files if content exceeds 500 lines `(review-time: see section note)`
   - Utility scripts if deterministic operations needed `(review-time: see section note)`

3. **Review with user** - present draft and ask: `(review-time: see section note)`
   - Does this cover your use cases? `(review-time: see section note)`
   - Anything missing or unclear? `(review-time: see section note)`
   - Should any section be more/less detailed? `(review-time: see section note)`

## Skill Structure

```text
skill-name/
├── SKILL.md           # Main instructions (required)
├── REFERENCE.md       # Detailed docs (if needed)
├── EXAMPLES.md        # Usage examples (if needed)
└── scripts/           # Utility scripts (if needed)
    └── helper.js
```

## SKILL.md Template

```md
---
name: skill-name
description: Brief description of capability. Use when [specific triggers].
---

# Skill Name

## Quick start

[Minimal working example]

## Workflows

[Step-by-step processes with checklists for complex tasks]

## Advanced features

[Link to separate files: See [REFERENCE.md](REFERENCE.md)]
```

## Description Requirements

The description is **the only thing your agent sees** when deciding which skill to load. It's surfaced in the system prompt alongside all other installed skills. Your agent reads these descriptions and picks the relevant skill based on the user's request.

**Goal**: Give your agent just enough info to know:

1. What capability this skill provides `(review-time: see section note)`
2. When/why to trigger it (specific keywords, contexts, file types) `(review-time: see section note)`

**Format**:

- Max 1024 chars `(review-time: see section note)`
- Write in third person `(review-time: see section note)`
- First sentence: what it does `(review-time: see section note)`
- Second sentence: "Use when [specific triggers]" `(review-time: see section note)`

**Good example**:

```text
Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when user mentions PDFs, forms, or document extraction.
```

**Bad example**:

```text
Helps with documents.
```

The bad example gives your agent no way to distinguish this from other document skills.

## When to Add Scripts

Add utility scripts when:

- Operation is deterministic (validation, formatting) `(review-time: see section note)`
- Same code would be generated repeatedly `(review-time: see section note)`
- Errors need explicit handling `(review-time: see section note)`

Scripts save tokens and improve reliability vs generated code.

## When to Split Files

Split into separate files when:

- SKILL.md exceeds 100 lines `(review-time: see section note)`
- Content has distinct domains (finance vs sales schemas) `(review-time: see section note)`
- Advanced features are rarely needed `(review-time: see section note)`

## Review Checklist

After drafting, verify:

- [ ] Description includes triggers ("Use when...") `(review-time: see section note)`
- [ ] SKILL.md under 100 lines `(review-time: see section note)`
- [ ] No time-sensitive info `(review-time: see section note)`
- [ ] Consistent terminology `(review-time: see section note)`
- [ ] Concrete examples included `(review-time: see section note)`
- [ ] References one level deep `(review-time: see section note)`
