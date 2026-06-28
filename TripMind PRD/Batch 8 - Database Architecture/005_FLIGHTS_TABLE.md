# 005_FLIGHTS_TABLE.md

# Flights Table Specification

Version: 1.0

Status: Database Specification

------------------------------------------------------------------------

# Purpose

Defines the canonical `flights` table for storing flight bookings,
schedules and operational flight metadata linked to a Trip.

------------------------------------------------------------------------

# Table Name

`flights`

------------------------------------------------------------------------

# Columns

  Column              Type           Required   Description
  ------------------- -------------- ---------- ---------------------
  id                  UUID           Yes        Primary key
  trip_id             UUID           Yes        References trips.id
  airline             VARCHAR(100)   Yes        Airline name
  flight_number       VARCHAR(20)    Yes        Flight number
  departure_airport   CHAR(3)        Yes        IATA code
  arrival_airport     CHAR(3)        Yes        IATA code
  departure_time      TIMESTAMP      Yes        Scheduled departure
  arrival_time        TIMESTAMP      Yes        Scheduled arrival
  terminal            VARCHAR(20)    No         Departure terminal
  gate                VARCHAR(20)    No         Boarding gate
  seat                VARCHAR(20)    No         Assigned seat
  booking_reference   VARCHAR(50)    No         PNR/reference
  status              VARCHAR(30)    Yes        Flight status
  baggage_allowance   VARCHAR(100)   No         Baggage details
  created_at          TIMESTAMP      Yes        Creation timestamp
  updated_at          TIMESTAMP      Yes        Last update
  deleted_at          TIMESTAMP      No         Soft delete
  sync_version        BIGINT         Yes        Sync version
  device_updated_at   TIMESTAMP      Yes        Client update time

------------------------------------------------------------------------

# Constraints

-   Primary Key: `id`
-   Foreign Key: `trip_id → trips.id`
-   Arrival time must be after departure time.
-   Soft deletes only.

------------------------------------------------------------------------

# Indexes

-   PK(id)
-   INDEX(trip_id)
-   INDEX(flight_number)
-   INDEX(departure_time)
-   INDEX(arrival_time)
-   INDEX(status)

------------------------------------------------------------------------

# Relationships

-   Many Flights → One Trip
-   One Flight → One Boarding Pass (logical)
-   One Flight → Many Notifications

------------------------------------------------------------------------

# Synchronization

-   Offline edits supported.
-   Live flight status refreshes when online.
-   Conflict resolution based on sync_version.

------------------------------------------------------------------------

# Security

-   Visible only to authorized trip members.
-   Booking references protected from unauthorized access.

------------------------------------------------------------------------

# Acceptance Criteria

-   Fast lookup by trip.
-   Supports live status updates.
-   Compatible with PostgreSQL and SQLite.
-   Offline synchronization supported.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -------------------------------------
  1.0       Initial Flights Table Specification
