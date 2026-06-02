# Infrastructure Conventions

**When to apply:** editing Terraform, Dockerfiles, docker-compose, Kubernetes manifests, or CI/CD workflow files.

- Infrastructure as Code only - no manual changes to cloud resources
- No `latest` tags for Docker images - always use specific version tags
- No secrets in code, Dockerfiles, or CI configs - use secret managers
- No mutable infrastructure - rebuild, don't patch
- Multi-stage Docker builds to minimize image size
- CI/CD pipelines must run lint, typecheck, and tests before deploy
- Always tag cloud resources with project, environment, and owner
- GCP is primary cloud, AWS is secondary
