---
name: test
description: "Write tests using TDD workflow. Use when the user says 'write tests', 'add tests', 'TDD', or 'prove-it pattern'."
---

Write tests for: $ARGUMENTS

## Choose the Workflow

### For New Features: RED-GREEN-REFACTOR

1. **RED**: write a failing test that describes the expected behavior
   - Test name reads like a specification: "returns empty array when no users match"
   - Run the test - confirm it fails for the right reason (not a syntax error)
2. **GREEN**: write the minimum code to make the test pass
   - Do not optimize, do not handle edge cases yet - just make it green
3. **REFACTOR**: improve the code while keeping tests green
   - Extract duplication, improve naming, simplify logic
   - Run tests after each refactor step
4. **Repeat**: add the next test for the next behavior. Continue the cycle.

### For Bug Fixes: PROVE-IT Pattern

1. **Reproduce**: write a test that triggers the exact bug as reported
2. **Confirm RED**: run the test - it must fail, proving the bug exists in code
3. **Fix**: implement the minimum change to fix the root cause
4. **Confirm GREEN**: run the test - it must now pass
5. **Regression**: run the full test suite to verify nothing else broke

If you cannot write a failing test, you do not fully understand the bug. Investigate further.

## Test Level Selection

Pick the lowest level that captures the behavior (see `references/testing-patterns.md`):

| Behavior | Test Level | Why |
| --- | --- | --- |
| Pure logic, calculations, validation | Unit test | Fast, isolated, deterministic |
| API request/response contracts | Integration test | Verifies real boundaries |
| Database queries, migrations | Integration test | Needs real database behavior |
| Critical user journeys | E2E test | Tests the full stack |
| Visual appearance, layout | Visual regression | Screenshot comparison |

## Test Quality Gates

Before considering tests complete:

- [ ] Happy path covered
- [ ] Edge cases covered (empty input, boundary values, null/undefined)
- [ ] Error paths covered (invalid input, network failure, timeout)
- [ ] Each test is independent - passes with `test.only()`
- [ ] No hardcoded test data - using factories or builders
- [ ] Mocks only at module boundaries - not on internal code
- [ ] Test names read like specifications
- [ ] All tests pass, no flaky behavior
- [ ] Run full test suite to check for regressions
