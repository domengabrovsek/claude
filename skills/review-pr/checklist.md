# PR Review Checklist

Systematically verify each area:

## Correctness

- [ ] Does the code do what the PR description claims?
- [ ] Are edge cases handled (null, empty, boundary values)?
- [ ] Are error paths covered with proper error handling?
- [ ] Are async operations handling errors (no unhandled promise rejections)?

## Type Safety

- [ ] No `any` or `unknown` types (except at validated system boundaries)
- [ ] Types accurately reflect the data (no type assertions hiding issues)
- [ ] Generic types used where appropriate

## Security

- [ ] No secrets in code (API keys, tokens, passwords, credentials)
- [ ] No SQL injection vectors (parameterized queries only)
- [ ] No XSS vectors (user input properly escaped)
- [ ] Authorization checks on every mutation accessing user data
- [ ] Input validation at system boundaries (Zod schemas)
- [ ] No PII in logs (names, emails, phone numbers, IPs)
- [ ] No custom cryptography (use established libraries)
- [ ] JWT/session tokens stored securely (httpOnly cookies, not localStorage)
- [ ] CORS policy is restrictive (no wildcard on authenticated endpoints)
- [ ] Error responses don't leak internal details to clients
- [ ] Dependencies free of known critical vulnerabilities

## Privacy & GDPR

- [ ] Personal data processing has documented lawful basis
- [ ] Data retention periods defined for new PII fields
- [ ] Consent collection is granular (not bundled or pre-ticked)
- [ ] Right to erasure supported (soft delete + cleanup job)
- [ ] No PII transferred outside EEA without safeguards (SCCs)

## Database

- [ ] Migrations are backward-compatible
- [ ] Destructive changes are phased or reversible
- [ ] Indexes added for new foreign keys and query patterns
- [ ] No N+1 queries
- [ ] Soft delete used (not hard delete)

## Testing

- [ ] New behavior has new tests
- [ ] No test coverage reduction for changed files
- [ ] Tests are deterministic (no flakiness)
- [ ] External dependencies are mocked appropriately

## Performance

- [ ] No unnecessary re-renders or recomputations
- [ ] No unbounded queries (pagination/limits)
- [ ] No O(n^2) or worse algorithms on large datasets
- [ ] Caching considered where appropriate

## Code Quality

- [ ] Readable by another engineer in 6 months without context
- [ ] No dead code, commented-out code, or TODOs
- [ ] No circular dependencies
- [ ] No console.log in production code
- [ ] No hardcoded magic numbers or URLs

## Scope

- [ ] PR only contains changes related to its stated goal
- [ ] No drive-by refactors or unrelated cleanup
- [ ] PR size is reasonable (flag 15+ files without justification)
