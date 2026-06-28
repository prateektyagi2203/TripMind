# 007_LOGGING_ARCHITECTURE.md

# TripMind Logging Architecture

Version: 2.0

------------------------------------------------------------------------

# 1. Executive Summary

This document defines the production logging architecture for TripMind.
Logs provide the foundation for troubleshooting, security
investigations, performance analysis and operational monitoring.

Goals:

-   Centralized logging
-   Structured JSON logs
-   End-to-end request tracing
-   PII protection
-   Fast troubleshooting
-   Long-term auditability

------------------------------------------------------------------------

# 2. Architecture

``` mermaid
flowchart LR
Flutter-->FastAPI
FastAPI-->Loki
Worker-->Loki
Nginx-->Loki
PostgreSQL-->Exporter
Loki-->Grafana
```

Recommended stack:

-   Grafana Loki
-   Grafana
-   Promtail

Alternative:

-   ELK/OpenSearch

------------------------------------------------------------------------

# 3. Log Categories

-   Application
-   API Access
-   Authentication
-   Security
-   Audit
-   Background Jobs
-   Database
-   Infrastructure

------------------------------------------------------------------------

# 4. JSON Schema

Every log contains:

-   timestamp
-   level
-   service
-   environment
-   request_id
-   correlation_id
-   user_id (masked where required)
-   endpoint
-   duration_ms
-   message
-   exception
-   metadata

------------------------------------------------------------------------

# 5. Log Levels

-   DEBUG
-   INFO
-   WARNING
-   ERROR
-   CRITICAL

Production disables DEBUG by default.

------------------------------------------------------------------------

# 6. Correlation IDs

Each incoming request receives a correlation ID.

Flow:

Flutter → API → Worker → Database → External API

The same ID appears in every related log entry.

------------------------------------------------------------------------

# 7. PII Protection

Never log:

-   Passwords
-   JWTs
-   Credit cards
-   Passport numbers
-   Raw documents
-   Secrets

Sensitive values must be masked before logging.

------------------------------------------------------------------------

# 8. Retention

-   Application logs: 30 days
-   Audit logs: 1 year
-   Security logs: per compliance policy

------------------------------------------------------------------------

# 9. Operational Queries

Common dashboards:

-   Top exceptions
-   Slowest endpoints
-   Failed logins
-   Sync failures
-   Worker failures

------------------------------------------------------------------------

# 10. Best Practices

-   Log events, not noise.
-   Use structured logging only.
-   Include request IDs.
-   Avoid duplicate messages.
-   Treat logs as production data.

------------------------------------------------------------------------

# Acceptance Criteria

-   Centralized searchable logs.
-   Correlation IDs end-to-end.
-   PII masked.
-   Dashboard-ready JSON output.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -------------------------------
  2.0       Expanded Logging Architecture
