# 012_KEY_MANAGEMENT

## Purpose

Manage encryption keys securely.

### Requirements

-   Central secret manager
-   Key rotation
-   Separate keys by environment
-   Least privilege access

### Protected Assets

-   JWT signing keys
-   Database credentials
-   API keys
-   Object storage keys

### Operational Rules

-   No keys in source control
-   Audit all key access
-   Scheduled rotation

## Acceptance

All production secrets managed outside application code.
