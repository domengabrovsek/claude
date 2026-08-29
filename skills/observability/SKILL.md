---
name: observability
description: "Instruments a feature so production behavior is diagnosable before the first incident: structured logs, RED/USE metrics, traces, symptom alerts. Use when adding logging, metrics, tracing, or alerting, when shipping a feature that runs in production, or when a PR adds I/O, retries, queues, or cross-service calls."
---

> Source: [addyosmani/agent-skills - skills/observability-and-instrumentation](https://github.com/addyosmani/agent-skills/tree/main/skills/observability-and-instrumentation), adapted.

# Observability

Instrumentation is written alongside the feature, the same way tests are. A feature that ships without telemetry turns its first bug into archaeology instead of a query.

Not for diagnosing a failure happening right now: that is `/debug`. This skill is what makes `/debug` fast next time.

## Process

**why-no-hook:** skill workflow guidance; each step requires understanding the surrounding context (repo, task shape, prior state).

### 1. Write the on-call questions first

Telemetry without a question is noise. Before adding any instrumentation, write down 2-4 questions an on-call engineer will ask about this feature.

```text
FEATURE: checkout payment retry
QUESTIONS ON-CALL WILL ASK:
1. What fraction of payments succeed on first attempt vs after retry?
2. When a payment fails permanently, why? (provider error? timeout? validation?)
3. Is the payment provider slower than usual?
```

Every signal below must help answer one of these questions. If you cannot name the questions, you are not ready to instrument: you will log everything and learn nothing.

### 2. Pick the signal per question

Metrics tell you **that** something is wrong. Traces tell you **where**. Logs tell you **why**.

| Signal | Answers | Cost profile |
| --- | --- | --- |
| Structured log | "What happened in this specific case?" | Per event; grows with traffic |
| Metric | "How often, how fast, in aggregate?" | Fixed per series; cheap to query |
| Trace | "Where did time go across services?" | Per request; usually sampled |

### 3. Structured logging

Log events, not prose. Every log line is a JSON object with a stable event name and machine-readable fields.

```typescript
/* BAD: string interpolation, unqueryable */
logger.info(`Payment ${id} failed for user ${userId} after ${n} retries`);

/* GOOD: stable event name plus structured fields */
logger.warn({ event: 'payment_failed', paymentId: id, provider: 'stripe', errorCode: err.code, attempt: n }, 'payment failed');
```

Levels: `error` means an invariant broke and someone may need to act. `warn` means degraded but handled (retry succeeded, fallback used). `info` marks a significant business event. `debug` stays off in production.

Correlation IDs are mandatory. Generate or accept a request ID at the system boundary. Attach it to every log line, span, and outbound call.

```typescript
app.use((req, res, next) => {
  req.id = req.headers['x-request-id'] ?? crypto.randomUUID();
  req.log = logger.child({ requestId: req.id });
  res.setHeader('x-request-id', req.id);
  next();
});
```

Never log secrets, tokens, passwords, or full PII. Allowlist fields; never log whole request bodies `(review-time: leak detection needs the field semantics, not a pattern)`

### 4. Metrics

Instrument **RED** on every endpoint and every external dependency: Rate, Errors, Duration as a latency histogram. For resources (queues, pools, hosts) use **USE**: Utilization, Saturation, Errors.

Cardinality is the failure mode. Every unique label combination is a separate time series, so labels come from small fixed sets.

```text
OK as label:    route="/api/tasks/:id"   status_class="5xx"   provider="stripe"
NEVER a label:  user_id, email, request_id, full URL, error message text
```

Averages never, percentiles always: an average hides the 1% of users having a terrible time. Use histograms and read p50/p95/p99.

### 5. Tracing

Use OpenTelemetry. Auto-instrumentation covers HTTP, gRPC, and common DB clients with near-zero code.

```typescript
/* tracing.ts, imported before anything else */
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';

const sdk = new NodeSDK({ serviceName: 'checkout-service', instrumentations: [getNodeAutoInstrumentations()] });
sdk.start();
```

Add manual spans only around meaningful internal units of work, with the attributes on-call will filter by. Propagate context across every async boundary (HTTP headers, queue message metadata), or the trace dies at the gap. Sample head-based at a low rate; keep 100% of errors when the backend supports tail sampling.

### 6. Alerting

Alert on symptoms users feel, never on causes. Cause alerts (CPU at 85%, one pod restarted) fire when nothing is wrong and miss the failures you did not predict.

Rules for every alert you create:

1. Actionable: if the response is "ignore it, it self-heals", delete the alert `(review-time: see section note)`
2. Links to a runbook, even three lines: what it means, first query, escalation path `(review-time: see section note)`
3. Threshold and duration justified by the SLO or historical data, never a guess `(review-time: see section note)`
4. Two severities only: **page** (users hurt, act now) and **ticket** (act this week) `(review-time: see section note)`

### 7. Verify the telemetry itself

Instrumentation is code; it can be wrong. Trigger the paths and look at the actual output:

- Force an error in staging, then find it in the logs by `requestId` with structured fields.
- Send test traffic; confirm metric series appear with the expected labels and sane values.
- Follow one request across services in the tracing UI: no broken spans.
- Fire each new alert once with a temporarily lowered threshold; confirm the channel and the runbook link.
