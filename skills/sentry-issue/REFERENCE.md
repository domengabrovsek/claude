# Sentry API Reference for Issue Investigation

All endpoints are org-scoped under `https://sentry.io/api/0` (or `SENTRY_URL`
for self-hosted). `sentry.io` proxies org-scoped routes to the correct region
silo (verified with EU orgs), so no region URL handling is needed. The legacy
non-org route `/api/0/issues/<id>/` 404s for EU-region orgs - never use it.

Auth: `Authorization: Bearer <token>` header. Always resolve the token the way
`scripts/sentry-issue.sh` does (env -> project rc -> home rc) inside a shell
command substitution so it never appears in conversation output. Required
scopes: `org:read`, `project:read`, `event:read`.

## Endpoint map

| Need | Endpoint |
| --- | --- |
| Discover accessible orgs | `GET /organizations/` (slug + `links.regionUrl`) |
| Short ID -> issue | `GET /organizations/<org>/shortids/<SHORT-ID>/` (`.groupId`) |
| Issue summary | `GET /organizations/<org>/issues/<id>/` |
| Latest / oldest event | `GET /organizations/<org>/issues/<id>/events/latest\|oldest/` |
| List all events | `GET /organizations/<org>/issues/<id>/events/` (paginated via `Link` header) |
| Specific event | `GET /organizations/<org>/issues/<id>/events/<eventID>/` |
| Tag value distribution | `GET /organizations/<org>/issues/<id>/tags/<key>/` |
| All tags overview | `GET /organizations/<org>/issues/<id>/tags/` |
| Attachments | `GET /organizations/<org>/issues/<id>/attachments/` |
| Search issues | `GET /organizations/<org>/issues/?query=<sentry-search>&project=<projectID>` |

## Issue payload (what to look for)

- `count`, `userCount`, `firstSeen`, `lastSeen` - blast radius and timeline
- `stats."24h"` / `stats."30d"` - spike vs steady drip
- `firstRelease.version`, `lastRelease.version` - regression window
- `isUnhandled` - crash vs caught-and-reported
- `activity[]` - comments, status changes, regressions (who did what)
- `permalink` - link for the user

## Event payload (what to look for)

- `entries[]` by `type`:
  - `exception`: `.data.values[]` - exception chain (outermost last; reverse
    for display). Frames have `filename`, `lineNo`, `function`, `inApp`, and
    `context` - **the surrounding source lines**, so the failing code is
    readable without checking out the deployed commit.
  - `breadcrumbs`: `.data.values[]` - trail of console/http/query events
    before the failure. Often absent on cron/server events.
  - `request`: `.data` - method, URL, headers, data.
  - `message` / `threads`: present on non-exception events.
- `contexts`: `cloud_resource` (Cloud Run service/region), `runtime`, `os`,
  `app`, `trace` (trace ID), `culture`
- `tags[]`: `environment`, `functionName`, `transaction`, `url`, `release`...
- `previousEventID` / `nextEventID` - walk the issue's events chronologically
- `user`, `release`, `sdk`, `fingerprints`, `_meta` (PII-scrubbing info)

## Not available (do not hunt for these)

- Local variable values per frame (`vars` is null unless the SDK enables
  `includeLocalVariables`) - SDK config, not a token limitation
- Session Replay and profiling data (separate products, not in event JSON)
- Anything requiring write scopes (resolve, assign, comment) - token is
  read-only by design

## jq recipes

```bash
E=/tmp/sentry-event-<id>.json I=/tmp/sentry-issue-<id>.json

# Failing source code with context lines
jq -r '.entries[] | select(.type=="exception") | .data.values[-1].stacktrace.frames[]
  | select(.inApp) | .filename, (.context[] | "\(.[0])\t\(.[1])")' $E

# Exception chain one-liner
jq -r '[.entries[] | select(.type=="exception") | .data.values[]
  | "\(.type): \(.value)"] | reverse | .[]' $E

# Spike or drip - hourly counts, last 24h
jq -r '.stats."24h"[] | "\(.[0] | todate)  \(.[1])"' $I

# Regression window
jq '{first: .firstRelease.version, last: .lastRelease.version}' $I

# Where is it running
jq '.contexts.cloud_resource' $E
```

## Pitfalls

- `sentry-cli organizations list` crashes on a JSON parse bug (CLI 3.5.0);
  use `GET /organizations/` instead. `sentry-cli` is otherwise only useful
  for `info` (verify auth/scopes) - it has no issue-detail commands.
- Event payloads can be hundreds of KB - always save to `/tmp` and jq them;
  never cat the whole file into the conversation.
- `message` is often empty on exception events - use `title`/`metadata`.
