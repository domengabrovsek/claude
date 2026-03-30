---
globs: "**/*.test.ts,**/*.spec.ts,**/*.test.tsx,**/*.spec.tsx"
description: "Testing standards and patterns"
---

# Testing Standards

- Vitest preferred as the test runner
- Mock external dependencies only (APIs, databases, file system) - not internal modules
- Manual class instantiation over dependency injection in tests
- Test behavior, not implementation details
- No flaky tests in main branch - if a test is flaky, fix or remove it
- No hardcoded test data that couples to environment - use factories or builders
- Each test should be independent - no shared mutable state between tests
- Prefer `describe`/`it` blocks with descriptive names that read as sentences
- Run single test files during development, full suite before declaring done
