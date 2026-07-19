# Infrastructure Conventions

**When to apply:** editing Terraform, Dockerfiles, docker-compose, Kubernetes manifests, or CI/CD workflow files - and when running any infra command that applies, destroys, or grants access (`terraform apply/destroy`, `gcloud`, `gsutil`, `aws`, `kubectl delete`).

- Infrastructure as Code only - no manual changes to cloud resources `(review-time: process, not detectable in code)`
- No `latest` tags for Docker images - always use specific version tags `(hook)`
- No secrets in code, Dockerfiles, or CI configs - use secret managers `(review-time: secrets blocked by deny rules + reviewer judgment; pattern detection has false positives)`
- No mutable infrastructure - rebuild, don't patch `(review-time: requires understanding the change's effect on a running resource)`
- Multi-stage Docker builds to minimize image size `(review-time: structural Dockerfile pattern, hard to flag without false positives)`
- CI/CD pipelines must run lint, typecheck, and tests before deploy `(CI)`
- Always tag cloud resources with project, environment, and owner `(review-time: tag presence varies per Terraform resource type)`
- GCP is primary cloud, AWS is secondary `(review-time: provider preference, not a code pattern)`

## Destructive and privileged operations

**why-not-mechanizable:** each rule needs knowledge external to the command text - who consumes a resource, whether a role is valid at a given scope, what a deploy pipeline actually does. A hook sees only the argv, not the blast radius.

- Before destroying or deleting any shared or stateful cloud resource (bucket, database, KV store, secret, DNS zone), enumerate every system that consumes it and confirm with the user - never assume a resource is single-purpose `(review-time: see section note)`
- Before granting an IAM role, verify the role is assignable at the target scope (project vs folder vs org) before applying - some roles are org/folder-only (e.g. `orgpolicy.policyAdmin`) and an invalid binding can fail the apply and clobber existing bindings `(review-time: see section note)`
- Read the actual CI/CD workflow and deployment config files before explaining or modifying how a deploy works - never guess at deploy mechanics from naming or convention `(review-time: see section note)`
