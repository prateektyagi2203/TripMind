# 004_TRIPS_TABLE.md

# Trips Table Specification

Version: 1.0

Status: Database Specification

------------------------------------------------------------------------

# Purpose

Defines the canonical `trips` table that represents a travel journey.
Nearly every operational entity in TripMind references a Trip.

------------------------------------------------------------------------

# Table Name

`trips`

------------------------------------------------------------------------

# Description

Stores trip metadata, ownership, destination information, budget and
lifecycle state.

------------------------------------------------------------------------

# Columns

  ----------------------------------------------------------------------------------
  Column                Type            Required            Description
  --------------------- --------------- ------------------- ------------------------
  id                    UUID            Yes                 Primary key

  owner_id              UUID            Yes                 References users.id

  title                 VARCHAR(200)    Yes                 Trip title

  destination_country   VARCHAR(100)    Yes                 Primary country

  destination_city      VARCHAR(100)    No                  Primary city

  start_date            DATE            Yes                 Trip start

  end_date              DATE            Yes                 Trip end

  currency              CHAR(3)         Yes                 Budget currency

  budget                NUMERIC(12,2)   No                  Planned budget

  status                VARCHAR(20)     Yes                 draft, planned, active,
                                                            completed, archived

  destination_pack_id   UUID            No                  Installed destination
                                                            pack

  notes                 TEXT            No                  General notes

  created_at            TIMESTAMP       Yes                 Creation timestamp

  updated_at            TIMESTAMP       Yes                 Last update

  deleted_at            TIMESTAMP       No                  Soft delete

  sync_version          BIGINT          Yes                 Sync version

  device_updated_at     TIMESTAMP       Yes                 Client update time
  ----------------------------------------------------------------------------------

------------------------------------------------------------------------

# Constraints

-   Primary Key: `id`
-   Foreign Key: `owner_id → users.id`
-   End date must be on or after start date.
-   Status restricted to supported lifecycle values.
-   Soft deletes only.

------------------------------------------------------------------------

# Indexes

-   PK(id)
-   INDEX(owner_id)
-   INDEX(status)
-   INDEX(start_date)
-   INDEX(end_date)
-   INDEX(created_at)

------------------------------------------------------------------------

# Relationships

-   One Trip → Many Flights
-   One Trip → Many Hotels
-   One Trip → Many Itinerary Items
-   One Trip → Many Expenses
-   One Trip → Many Memories
-   One Trip → Many Notifications
-   One Trip → Many Family Members

------------------------------------------------------------------------

# Synchronization

-   Offline edits supported.
-   Version-based conflict detection.
-   Last-write-wins for non-critical metadata.
-   Manual merge available for concurrent trip edits.

------------------------------------------------------------------------

# Security

-   Only owner and authorized family members may access.
-   Ownership changes audited.
-   Soft-deleted trips retained for recovery period.

------------------------------------------------------------------------

# Migration Notes

-   UUID generated server-side.
-   Existing child records remain valid after archival.
-   Destination pack reference is optional.

------------------------------------------------------------------------

# Acceptance Criteria

-   Fast retrieval by owner.
-   Supports offline synchronization.
-   Referential integrity maintained.
-   Compatible with PostgreSQL and SQLite.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -----------------------------------
  1.0       Initial Trips Table Specification
