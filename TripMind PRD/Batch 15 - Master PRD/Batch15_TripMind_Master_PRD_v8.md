# TripMind Product Specification (Master PRD)

## Batch 15 -- Version 8.0

------------------------------------------------------------------------

# Part VIII --- Passport Vault & Travel Document Management

## Purpose

The Passport Vault provides a secure, centralized repository for
passports and travel documents. It proactively validates document
readiness, reminds users of upcoming expirations, and supplies the AI
planner with the information needed to generate visa guidance and travel
recommendations.

------------------------------------------------------------------------

# User Stories

-   As a traveller, I want to securely store my passport.
-   As a parent, I want to manage passports for my children.
-   As a traveller, I want to know if my passport is valid for my
    planned destination.
-   As a user, I want renewal reminders well before expiry.

------------------------------------------------------------------------

# Functional Requirements

### FR-001 -- Add Passport

Supported methods:

-   Manual entry
-   Camera scan
-   Passport photo upload

Captured fields:

-   Passport number
-   Country of issue
-   Full name
-   Date of birth
-   Issue date
-   Expiry date
-   Nationality

------------------------------------------------------------------------

### FR-002 -- Passport Validity Check

The application shall evaluate:

-   Destination entry rules
-   Six-month validity requirements
-   Blank page requirements (future)
-   Passport expiry before return date

Display:

-   Valid
-   Warning
-   Not valid

with a human-readable explanation.

------------------------------------------------------------------------

### FR-003 -- Multiple Passports

Users may store passports for:

-   Self
-   Spouse
-   Children
-   Dependents

Each passport belongs to exactly one traveller profile.

------------------------------------------------------------------------

### FR-004 -- Document Vault

Supported document types:

-   Passport
-   Visa
-   Boarding pass
-   Hotel confirmation
-   Travel insurance
-   Vaccination certificate
-   Driving licence
-   Emergency contacts

------------------------------------------------------------------------

# Screen Specifications

## Passport List

Displays:

-   Traveller
-   Passport status
-   Expiry countdown
-   Validation status

Actions:

-   View
-   Edit
-   Archive
-   Delete
-   Share (future)

------------------------------------------------------------------------

## Passport Details

Sections:

-   Personal details
-   Passport information
-   Validation status
-   Linked trips
-   Renewal reminders
-   Uploaded images

------------------------------------------------------------------------

# Business Rules

BR-001: One active passport per traveller profile.

BR-002: Archived passports are excluded from AI validation.

BR-003: Passport expiry reminders default to:

-   12 months
-   6 months
-   3 months
-   1 month

BR-004: Trip validation always checks passport expiry before departure.

------------------------------------------------------------------------

# Non-Functional Requirements

NFR-001: Passport images must be encrypted at rest.

NFR-002: Opening the vault requires user authentication.

NFR-003: Sensitive fields must never appear in analytics or logs.

------------------------------------------------------------------------

# Permission Matrix

  Role             View   Edit   Delete
  --------------- ------ ------ --------
  Owner             ✓      ✓       ✓
  Family Editor     ✓      ✓       ✗
  Viewer            ✓      ✗       ✗

------------------------------------------------------------------------

# Offline Behaviour

Available offline:

-   View saved documents
-   Search documents
-   Validate against locally cached trip dates

Unavailable offline:

-   Cloud sync
-   OCR processing
-   Destination rule updates

------------------------------------------------------------------------

# Error Catalogue

-   Expired passport
-   Duplicate passport
-   Invalid passport number format
-   Corrupted image upload
-   OCR extraction failed
-   Encryption failure

Each error should provide recovery guidance.

------------------------------------------------------------------------

# Analytics Events

-   passport_added
-   passport_updated
-   passport_deleted
-   passport_expiry_warning_viewed
-   document_uploaded
-   document_viewed

------------------------------------------------------------------------

# Acceptance Test Scenarios

1.  User adds a passport manually.
2.  AI warns when expiry conflicts with travel dates.
3.  Family passports are isolated by traveller.
4.  Offline vault remains readable.
5.  Sensitive fields never appear in logs.

------------------------------------------------------------------------

# Future Enhancements

-   NFC passport reading
-   Biometric verification
-   Automatic visa eligibility analysis
-   Secure document sharing
-   End-to-end encrypted family vault
