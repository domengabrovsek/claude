---
name: spec
description: "Define requirements before planning. Use when starting a new feature, when requirements are ambiguous, or when the user says 'write a spec' or 'define requirements'."
---

Write a specification for: $ARGUMENTS

Follow this workflow:

1. **Discovery**: ask the user clarifying questions before writing anything. Cover:
   - **Who** - who is the user/audience for this feature?
   - **What** - what exactly should it do? What is the expected behavior?
   - **Why** - what problem does it solve? What is the success metric?
   - **Constraints** - what technical, time, or scope constraints exist?
   - **Boundaries** - what is explicitly out of scope?
   - Ask all questions at once. Wait for answers before proceeding.

2. **Draft the spec**: based on the answers, write a specification with these sections:

```markdown
# Spec: <title>

## Problem Statement
<What problem does this solve and for whom?>

## User Stories
- As a <role>, I want <capability> so that <benefit>

## Acceptance Criteria
- [ ] <Specific, testable criterion>
- [ ] <Specific, testable criterion>

## Non-Functional Requirements
- Performance: <latency, throughput targets>
- Security: <auth, data handling requirements>
- Accessibility: <WCAG level, specific requirements>

## Technical Constraints
- <Stack, infrastructure, API compatibility requirements>

## Out of Scope
- <Explicitly excluded from this work>

## Open Questions
- <Anything unresolved that needs a decision>
```

1. **Save**: save the spec to `.claude/state/specs/YYYY-MM-DD-spec-<topic>.md`
2. **Review**: present the spec to the user. Wait for approval before proceeding to /plan.
3. **Iterate**: if the user has feedback, update the spec and re-present. Repeat until approved.

Do NOT proceed to planning or implementation until the spec is explicitly approved.
