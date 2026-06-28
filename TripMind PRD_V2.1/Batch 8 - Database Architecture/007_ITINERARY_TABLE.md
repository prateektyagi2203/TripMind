# 007_ITINERARY_TABLE.md

# Itinerary Table Specification

Version: 1.0

Status: Database Specification

------------------------------------------------------------------------

# Purpose

Defines the canonical `itinerary_items` table used to store every
scheduled activity within a Trip.

------------------------------------------------------------------------

# Table Name

`itinerary_items`

------------------------------------------------------------------------

# Description

Stores all planned activities such as flights, hotel check-ins,
sightseeing, restaurants, shopping, transfers and custom events. It is
the primary source for the daily itinerary displayed throughout the
application.

------------------------------------------------------------------------

# Columns

  -------------------------------------------------------------------------------
  Column              Type           Required            Description
  ------------------- -------------- ------------------- ------------------------
  id                  UUID           Yes                 Primary key

  trip_id             UUID           Yes                 References trips.id

  day_number          INTEGER        Yes                 Sequential trip day

  title               VARCHAR(200)   Yes                 Activity title

  activity_type       VARCHAR(50)    Yes                 attraction, restaurant,
                                                         flight, hotel,
                                                         transport, shopping,
                                                         custom

  start_time          TIMESTAMP      Yes                 Activity start

  end_time            TIMESTAMP      No                  Activity end

  location_name       VARCHAR(255)   No                  Display location

  latitude            DECIMAL(9,6)   No                  Latitude

  longitude           DECIMAL(9,6)   No                  Longitude

  notes               TEXT           No                  User notes

  status              VARCHAR(20)    Yes                 planned, completed,
                                                         cancelled

  sort_order          INTEGER        Yes                 Display order within the
                                                         day

  ai_generated        BOOLEAN        Yes                 Created by AI
                                                         recommendation

  created_at          TIMESTAMP      Yes                 Creation timestamp

  updated_at          TIMESTAMP      Yes                 Last update

  deleted_at          TIMESTAMP      No                  Soft delete

  sync_version        BIGINT         Yes                 Sync version

  device_updated_at   TIMESTAMP      Yes                 Client update time
  -------------------------------------------------------------------------------

------------------------------------------------------------------------

# Constraints

-   Primary Key: `id`
-   Foreign Key: `trip_id → trips.id`
-   End time must be greater than start time when supplied.
-   `sort_order` must be unique within a trip day.
-   Soft deletes only.

------------------------------------------------------------------------

# Indexes

-   PK(id)
-   INDEX(trip_id)
-   INDEX(day_number)
-   INDEX(start_time)
-   INDEX(activity_type)
-   INDEX(status)
-   INDEX(latitude, longitude)

------------------------------------------------------------------------

# Relationships

-   Many Itinerary Items → One Trip
-   One Itinerary Item → Many Notifications
-   One Itinerary Item → Many Memories
-   Optional links to Flights, Hotels, Restaurants and Expenses

------------------------------------------------------------------------

# Synchronization

-   Offline creation and editing supported.
-   Reordering synchronized using `sort_order`.
-   Conflict detection based on `sync_version`.

------------------------------------------------------------------------

# Security

-   Accessible only to authorized trip members.
-   Owner controls edit permissions for shared trips.

------------------------------------------------------------------------

# Acceptance Criteria

-   Daily itinerary loads quickly.
-   Drag-and-drop ordering preserved.
-   Offline edits synchronize correctly.
-   Compatible with PostgreSQL and SQLite.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ---------------------------------------
  1.0       Initial Itinerary Table Specification
