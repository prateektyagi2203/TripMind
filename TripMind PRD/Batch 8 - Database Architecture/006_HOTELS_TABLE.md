# 006_HOTELS_TABLE.md

# Hotels Table Specification

Version: 1.0

Status: Database Specification

------------------------------------------------------------------------

# Purpose

Defines the canonical `hotels` table for storing hotel reservations,
stay details and location metadata associated with a Trip.

------------------------------------------------------------------------

# Table Name

`hotels`

------------------------------------------------------------------------

# Columns

  Column              Type           Required   Description
  ------------------- -------------- ---------- -------------------------
  id                  UUID           Yes        Primary key
  trip_id             UUID           Yes        References trips.id
  name                VARCHAR(200)   Yes        Hotel name
  address             TEXT           Yes        Hotel address
  latitude            DECIMAL(9,6)   No         Latitude
  longitude           DECIMAL(9,6)   No         Longitude
  check_in            TIMESTAMP      Yes        Check-in date/time
  check_out           TIMESTAMP      Yes        Check-out date/time
  booking_reference   VARCHAR(50)    No         Reservation number
  phone               VARCHAR(30)    No         Hotel contact
  email               VARCHAR(320)   No         Hotel email
  rating              NUMERIC(2,1)   No         User or provider rating
  notes               TEXT           No         Stay notes
  created_at          TIMESTAMP      Yes        Creation timestamp
  updated_at          TIMESTAMP      Yes        Last update
  deleted_at          TIMESTAMP      No         Soft delete
  sync_version        BIGINT         Yes        Sync version
  device_updated_at   TIMESTAMP      Yes        Client update time

------------------------------------------------------------------------

# Constraints

-   Primary Key: `id`
-   Foreign Key: `trip_id → trips.id`
-   Check-out must be after check-in.
-   Soft deletes only.

------------------------------------------------------------------------

# Indexes

-   PK(id)
-   INDEX(trip_id)
-   INDEX(check_in)
-   INDEX(check_out)
-   INDEX(latitude, longitude)

------------------------------------------------------------------------

# Relationships

-   Many Hotels → One Trip
-   One Hotel → Many Nearby Cache Records
-   One Hotel → Many Memories
-   One Hotel → Many Itinerary Items

------------------------------------------------------------------------

# Synchronization

-   Offline editing supported.
-   Sync based on `sync_version`.
-   Last-write-wins for non-conflicting updates.

------------------------------------------------------------------------

# Security

-   Accessible only to authorized trip members.
-   Booking references protected.
-   Soft-deleted records retained for recovery.

------------------------------------------------------------------------

# Acceptance Criteria

-   Fast lookup by trip.
-   Geo queries supported.
-   Offline synchronization supported.
-   Compatible with PostgreSQL and SQLite.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ------------------------------------
  1.0       Initial Hotels Table Specification
