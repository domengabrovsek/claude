# Jira Access

**When to apply:** when the user mentions a Jira ticket / issue / story / bug / epic, drops a Jira key (`[A-Z]+-\d+`), or pastes a Jira URL.

Reach for `acli` (Atlassian CLI) before doing anything else.

## Detection

Trigger this rule when any of the following appears in the user's message:

- A Jira-style key matching `[A-Z]+-\d+` `(review-time: trigger condition for the rule, not a rule itself)`
- The words "Jira", "ticket", "issue", "story", "epic", "bug" used in a tracker sense (not a generic "there's an issue with X") `(review-time: trigger condition)`
- A Jira URL (`*.atlassian.net/browse/KEY-123`) `(review-time: trigger condition)`

If the reference is ambiguous (could be GitHub issue vs Jira), ask before assuming. `(review-time: requires judging ambiguity in the user's message)`

## Tool check

1. Run `which acli` to confirm it is installed. `(review-time: procedural step in a sequence)`
2. If installed, run `acli jira auth status` (or attempt a read command) to confirm it is authenticated. If unauthenticated, surface that to the user - do not attempt to authenticate on their behalf. `(review-time: procedural step)`
3. If not installed or not configured, tell the user and fall back to asking them for the ticket contents. `(review-time: error-handling pattern in conversation)`

## Usage

Prefer `acli` over web fetches or asking the user to paste ticket content.

Common commands:

```bash
acli jira workitem view <KEY>           # read a ticket
acli jira workitem search --jql "..."   # search
acli jira workitem comment <KEY> ...    # add comment
acli jira workitem update <KEY> ...     # update fields / transition
```

Run `acli jira workitem --help` for the current command surface - flags change between versions, so do not guess.

## Rules

- **Read first**: when a ticket is referenced, fetch it before asking the user what it says. Do not make the user paste content `acli` could have retrieved. `(review-time: ordering in conversational flow)`
- **No silent writes**: never transition, comment on, or update a ticket without explicit user confirmation. Reading is free; writing affects shared state. `(review-time: requires conversational signal of confirmation)`
- **Do not invent keys**: only act on keys the user actually provided. Do not guess project prefixes. `(review-time: requires reading user's message)`
- **Stay scoped**: fetch the specific tickets referenced, not the entire backlog. Avoid broad `--jql` sweeps unless asked. `(review-time: judging "broad" scope)`
- **Surface auth errors**: if `acli` returns an auth or permission error, report it verbatim - do not retry blindly or attempt to re-auth. `(review-time: error-handling pattern)`
