---
name: test
description: "Write tests using TDD workflow. Use when the user says 'write tests', 'add tests', 'TDD', or 'prove-it pattern'."
---

Write tests for: $ARGUMENTS

## Choose the Workflow

### For New Features: RED-GREEN-REFACTOR

**why-not-mechanizable:** skill workflow guidance; each step requires understanding the surrounding context (repo, task shape, prior state).

1. **RED**: write a failing test that describes the expected behavior `(review-time: see section note)`
   - Test name reads like a specification: "returns empty array when no users match" `(review-time: see section note)`
   - Run the test - confirm it fails for the right reason (not a syntax error) `(review-time: see section note)`
2. **GREEN**: write the minimum code to make the test pass `(review-time: see section note)`
   - Do not optimize, do not handle edge cases yet - just make it green `(review-time: see section note)`
3. **REFACTOR**: improve the code while keeping tests green `(review-time: see section note)`
   - Extract duplication, improve naming, simplify logic `(review-time: see section note)`
   - Run tests after each refactor step `(review-time: see section note)`
4. **Repeat**: add the next test for the next behavior. Continue the cycle. `(review-time: see section note)`

### For Bug Fixes: PROVE-IT Pattern

1. **Reproduce**: write a test that triggers the exact bug as reported `(review-time: see section note)`
2. **Confirm RED**: run the test - it must fail, proving the bug exists in code `(review-time: see section note)`
3. **Fix**: implement the minimum change to fix the root cause `(review-time: see section note)`
4. **Confirm GREEN**: run the test - it must now pass `(review-time: see section note)`
5. **Regression**: run the full test suite to verify nothing else broke `(review-time: see section note)`

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

- [ ] Happy path covered `(review-time: see section note)`
- [ ] Edge cases covered (empty input, boundary values, null/undefined) `(review-time: see section note)`
- [ ] Error paths covered (invalid input, network failure, timeout) `(review-time: see section note)`
- [ ] Each test is independent - passes with `test.only()` `(review-time: see section note)`
- [ ] No hardcoded test data - using factories or builders `(review-time: see section note)`
- [ ] Mocks only at module boundaries - not on internal code `(review-time: see section note)`
- [ ] Test names read like specifications `(review-time: see section note)`
- [ ] All tests pass, no flaky behavior `(review-time: see section note)`
- [ ] Run full test suite to check for regressions `(review-time: see section note)`
