# TripMind Product Specification (Master PRD)

## Batch 15 -- Version 17.0

------------------------------------------------------------------------

# Part XVII --- Global Business Rules & Validation Framework

## Purpose

This chapter defines the cross-cutting rules that apply across every
TripMind module. These rules ensure consistent behavior, predictable
validation, and high data integrity regardless of feature or platform.

------------------------------------------------------------------------

# Objectives

-   Standardize validation
-   Protect data integrity
-   Eliminate conflicting behaviors
-   Simplify QA and automation
-   Support consistent AI reasoning

------------------------------------------------------------------------

# Entity Lifecycle Rules

## Trip

Draft → Planned → Active → Completed → Archived → Deleted

Rules:

-   Archived trips are read-only by default.
-   Deleted trips enter a soft-delete period before permanent removal.
-   Active trips may be edited unless restricted by business workflows.

------------------------------------------------------------------------

## Traveller

Invited → Active → Inactive → Removed

Rules:

-   Historical trip participation is retained after removal.
-   Every traveller belongs to exactly one user or family profile.

------------------------------------------------------------------------

## Document

Uploaded → Processing → Verified → Active → Archived

Rules:

-   Original documents are never overwritten.
-   Verification status is immutable unless explicitly reset.

------------------------------------------------------------------------

# Global Business Rules

### GBR-001

Every entity shall have:

-   UUID
-   Created timestamp
-   Updated timestamp
-   Owner
-   Version number

### GBR-002

Soft delete is preferred over permanent deletion for user-generated
content.

### GBR-003

Every write operation must be attributable to a user or trusted system
process.

### GBR-004

User confirmation is required before irreversible actions.

### GBR-005

Manual user edits always take precedence over AI-generated suggestions.

### GBR-006

Sensitive information must never be written to analytics events.

### GBR-007

All timestamps are stored in UTC and rendered in the traveller's local
timezone.

------------------------------------------------------------------------

# Global Validation Rules

## Identity

-   Email format validation
-   Password policy
-   Unique account per email

## Dates

-   End date ≥ Start date
-   Date of birth cannot be in the future
-   Passport expiry after issue date

## Financial

-   Amount \> 0
-   Supported currency required
-   Exchange rate recorded when applicable

## Documents

-   Allowed formats
-   Maximum upload size
-   Virus scan before processing
-   OCR confidence threshold

------------------------------------------------------------------------

# Cross-Module Dependencies

  Module          Depends On
  --------------- ----------------------------
  AI Planner      Trips, Preferences, Memory
  Visa            Passport, Documents
  Expenses        Trips
  Notifications   All major modules
  Family          Authentication, Trips

------------------------------------------------------------------------

# State Transition Policy

``` mermaid
stateDiagram-v2
[*] --> Created
Created --> Active
Active --> Suspended
Suspended --> Active
Active --> Archived
Archived --> Deleted
Deleted --> [*]
```

Rules:

-   Invalid transitions are rejected.
-   Every transition is audit logged.
-   Version conflicts require reconciliation.

------------------------------------------------------------------------

# Data Integrity Rules

-   Foreign keys must reference existing entities.
-   Cascading deletes are prohibited for user-owned content.
-   Duplicate active passports for one traveller are not allowed.
-   Duplicate active trips with the same identifier are prohibited.

------------------------------------------------------------------------

# Validation Error Standards

Every validation response includes:

-   Error code
-   Human-readable message
-   Field name
-   Recovery guidance

Example:

``` json
{
  "code":"VAL-001",
  "field":"email",
  "message":"Invalid email address.",
  "suggestion":"Enter a valid email."
}
```

------------------------------------------------------------------------

# Acceptance Criteria

-   Validation behavior is identical across mobile and backend.
-   Business rules are enforced server-side.
-   Validation errors are localized.
-   Invalid state transitions are rejected.

------------------------------------------------------------------------

# Future Enhancements

-   Rule engine for configurable validations
-   Country-specific validation packs
-   Organization policy extensions
