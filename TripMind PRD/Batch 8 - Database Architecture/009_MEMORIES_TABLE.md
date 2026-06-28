# 009_MEMORIES_TABLE.md

# Memories Table Specification

Version: 1.0

Status: Database Specification

------------------------------------------------------------------------

# Purpose

Defines the canonical `memories` table for storing photos, videos,
journals and AI-generated travel memories associated with a Trip.

------------------------------------------------------------------------

# Table Name

`memories`

------------------------------------------------------------------------

# Description

Stores every memory captured during a trip, including media references,
locations, journals and sharing metadata.

------------------------------------------------------------------------

# Columns

  Column              Type           Required   Description
  ------------------- -------------- ---------- -----------------------------
  id                  UUID           Yes        Primary key
  trip_id             UUID           Yes        References trips.id
  user_id             UUID           Yes        References users.id
  memory_type         VARCHAR(30)    Yes        photo, video, journal, note
  title               VARCHAR(255)   No         Memory title
  description         TEXT           No         User/AI description
  media_url           TEXT           No         Object storage URL
  thumbnail_url       TEXT           No         Thumbnail
  latitude            DECIMAL(9,6)   No         GPS latitude
  longitude           DECIMAL(9,6)   No         GPS longitude
  captured_at         TIMESTAMP      Yes        Capture time
  visibility          VARCHAR(20)    Yes        private, family, selected
  ai_generated        BOOLEAN        Yes        AI generated summary
  created_at          TIMESTAMP      Yes        Created
  updated_at          TIMESTAMP      Yes        Updated
  deleted_at          TIMESTAMP      No         Soft delete
  sync_version        BIGINT         Yes        Sync version
  device_updated_at   TIMESTAMP      Yes        Client update time

------------------------------------------------------------------------

# Constraints

-   Primary Key: `id`
-   Foreign Keys:
    -   `trip_id → trips.id`
    -   `user_id → users.id`
-   Soft deletes only.

------------------------------------------------------------------------

# Indexes

-   PK(id)
-   INDEX(trip_id)
-   INDEX(user_id)
-   INDEX(captured_at)
-   INDEX(memory_type)
-   INDEX(latitude, longitude)

------------------------------------------------------------------------

# Relationships

-   Many Memories → One Trip
-   Many Memories → One User
-   One Memory → Many Timeline Events
-   One Memory → One Smart Album (logical)

------------------------------------------------------------------------

# Synchronization

-   Offline capture supported.
-   Media uploads resume automatically.
-   Metadata synchronized using `sync_version`.

------------------------------------------------------------------------

# Security

-   Signed URLs for media access.
-   Visibility enforced by sharing settings.
-   Media encrypted in transit.

------------------------------------------------------------------------

# Acceptance Criteria

-   Fast retrieval by trip.
-   Offline browsing supported.
-   Compatible with PostgreSQL and SQLite.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- --------------------------------------
  1.0       Initial Memories Table Specification
