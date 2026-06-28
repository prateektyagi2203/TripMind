# 004_DOCKER_ARCHITECTURE.md

# TripMind Docker Architecture

Version: 2.0

------------------------------------------------------------------------

# 1. Executive Summary

This document defines the Docker architecture for TripMind. Every
backend component runs in an isolated container to ensure consistent
development, testing and production deployments.

The objectives are:

-   Environment consistency
-   Reproducible builds
-   Fast onboarding
-   Immutable deployments
-   Horizontal scalability
-   Secure container execution

------------------------------------------------------------------------

# 2. Container Architecture

``` mermaid
flowchart LR
    Flutter --> FastAPI
    FastAPI --> PostgreSQL
    FastAPI --> Redis
    FastAPI --> ObjectStorage
    FastAPI --> Worker
    Worker --> PostgreSQL
    Worker --> Redis
```

Core containers:

-   API
-   Background Worker
-   Scheduler
-   PostgreSQL
-   Redis
-   Nginx (optional reverse proxy)

------------------------------------------------------------------------

# 3. Repository Layout

``` text
docker/
├── api/
│   └── Dockerfile
├── worker/
│   └── Dockerfile
├── scheduler/
│   └── Dockerfile
├── nginx/
│   └── Dockerfile
├── docker-compose.dev.yml
├── docker-compose.qa.yml
├── docker-compose.prod.yml
└── .dockerignore
```

------------------------------------------------------------------------

# 4. Image Strategy

-   One Dockerfile per deployable service.
-   Multi-stage builds to minimize image size.
-   Semantic version tags.
-   Immutable images.
-   Images scanned before publication.

------------------------------------------------------------------------

# 5. Development Workflow

1.  Clone repository.
2.  Build images.
3.  Start stack with Docker Compose.
4.  Hot reload API.
5.  Run automated tests.
6.  Destroy environment after use.

Developers should be able to start the entire backend with a single
command.

------------------------------------------------------------------------

# 6. Docker Compose Services

Recommended services:

-   api
-   worker
-   scheduler
-   postgres
-   redis

Use named volumes for persistent database storage in development.

------------------------------------------------------------------------

# 7. Networking

Create an isolated Docker network.

Rules:

-   Containers communicate by service name.
-   Database is not exposed publicly.
-   Redis is internal only.
-   API is the only externally accessible service.

------------------------------------------------------------------------

# 8. Security

-   Run as non-root user.
-   Read-only filesystem where practical.
-   Minimize installed packages.
-   Never bake secrets into images.
-   Inject secrets at runtime.

------------------------------------------------------------------------

# 9. Logging

-   JSON formatted logs
-   stdout/stderr only
-   Central aggregation in production
-   Correlation IDs propagated across services

------------------------------------------------------------------------

# 10. Health Checks

Every container exposes:

-   Liveness endpoint
-   Readiness endpoint

Compose/Kubernetes use these checks for restart decisions.

------------------------------------------------------------------------

# 11. Optimization

-   Multi-stage builds
-   Layer caching
-   Slim base images
-   Dependency pinning
-   Small image footprint

------------------------------------------------------------------------

# 12. Operational Best Practices

-   Rebuild from source.
-   Never patch running containers.
-   Replace containers instead of modifying them.
-   Scan images continuously.
-   Remove unused images regularly.

------------------------------------------------------------------------

# 13. Acceptance Criteria

-   Entire backend starts using Docker Compose.
-   Images are reproducible.
-   Security scanning enabled.
-   Containers restart automatically after failures.
-   Production images remain immutable.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- --------------------------------------------
  2.0       Expanded Docker architecture specification
