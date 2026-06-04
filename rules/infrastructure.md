# Infrastructure Conventions

**When to apply:** editing Terraform, Dockerfiles, docker-compose, Kubernetes manifests, or CI/CD workflow files.

- Infrastructure as Code only - no manual changes to cloud resources `(review-time: process, not detectable in code)`
- No `latest` tags for Docker images - always use specific version tags `(hook)`
- No secrets in code, Dockerfiles, or CI configs - use secret managers `(review-time: secrets blocked by deny rules + reviewer judgment; pattern detection has false positives)`
- No mutable infrastructure - rebuild, don't patch `(review-time: requires understanding the change's effect on a running resource)`
- Multi-stage Docker builds to minimize image size `(review-time: structural Dockerfile pattern, hard to flag without false positives)`
- CI/CD pipelines must run lint, typecheck, and tests before deploy `(CI)`
- Always tag cloud resources with project, environment, and owner `(review-time: tag presence varies per Terraform resource type)`
- GCP is primary cloud, AWS is secondary `(review-time: provider preference, not a code pattern)`
