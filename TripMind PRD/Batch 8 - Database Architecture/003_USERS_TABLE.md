# 003_USERS_TABLE.md

# Users Table Specification

Version: 1.0

Status: Database Specification

------------------------------------------------------------------------

# Purpose

Defines the canonical `users` table used for authentication, profile
management and personalization across TripMind.

------------------------------------------------------------------------

# Table Name

`users`

------------------------------------------------------------------------

# Description

Stores one record per registered user. This table is the root entity for
all user-owned data including trips, preferences, memories and expenses.

------------------------------------------------------------------------

# Columns

  Column               Type           Required   Description
  -------------------- -------------- ---------- ------------------------------
  id                   UUID           Yes        Primary key
  email                VARCHAR(320)   Yes        Unique email address
  password_hash        TEXT           No         Null for OAuth-only accounts
  auth_provider        VARCHAR(20)    Yes        email, google, apple
  first_name           VARCHAR(100)   Yes        User first name
  last_name            VARCHAR(100)   Yes        User last name
  profile_photo_url    TEXT           No         Profile image URL
  preferred_language   VARCHAR(10)    Yes        ISO language code
  preferred_currency   VARCHAR(3)     Yes        ISO 4217 currency
  home_country         VARCHAR(100)   No         Home country
  timezone             VARCHAR(100)   Yes        IANA timezone
  is_active            BOOLEAN        Yes        Account status
  email_verified       BOOLEAN        Yes        Verification flag
  created_at           TIMESTAMP      Yes        Creation timestamp
  updated_at           TIMESTAMP      Yes        Last update timestamp
  deleted_at           TIMESTAMP      No         Soft delete timestamp
  sync_version         BIGINT         Yes        Sync version
  device_updated_at    TIMESTAMP      Yes        Client update time

------------------------------------------------------------------------

# Constraints

-   Primary Key: `id`
-   Unique: `email`
-   Email stored in lowercase
-   Soft deletes only
-   Password hash required only for email/password authentication

------------------------------------------------------------------------

# Indexes

-   PK(id)
-   UNIQUE(email)
-   INDEX(auth_provider)
-   INDEX(created_at)
-   INDEX(updated_at)

------------------------------------------------------------------------

# Relationships

-   One User → Many Trips
-   One User → Many Preferences
-   One User → Many Destination Packs
-   Many Trips ↔ Many Users (via family_members)

------------------------------------------------------------------------

# Synchronization

-   Version-based conflict resolution
-   Last-write-wins for profile fields
-   Sync metadata maintained in every update

------------------------------------------------------------------------

# Security

-   Passwords stored using Argon2id (preferred) or bcrypt
-   Sensitive fields encrypted at rest where appropriate
-   Row-level authorization enforced by application layer

------------------------------------------------------------------------

# Migration Notes

-   UUID generated server-side
-   Existing OAuth users may have null password_hash
-   Future profile extensions stored in dedicated tables, not JSON blobs

------------------------------------------------------------------------

# Acceptance Criteria

-   Email uniqueness enforced
-   Soft delete supported
-   Compatible with PostgreSQL and SQLite
-   Supports offline synchronization

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -----------------------------------
  1.0       Initial Users Table Specification
