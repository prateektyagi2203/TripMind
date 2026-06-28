# 010_NOTIFICATIONS_TABLE.md

# Notifications Table Specification

Version: 1.0

Status: Database Specification

------------------------------------------------------------------------

# Purpose

Defines the canonical `notifications` table for storing local and
server-generated notifications delivered to TripMind users.

------------------------------------------------------------------------

# Table Name

`notifications`

------------------------------------------------------------------------

# Description

Stores all user notifications including flight reminders, itinerary
updates, weather alerts, AI recommendations, budget alerts and safety
notifications.

------------------------------------------------------------------------

# Columns

  Column              Type           Required   Description
  ------------------- -------------- ---------- -----------------------------
  id                  UUID           Yes        Primary key
  user_id             UUID           Yes        References users.id
  trip_id             UUID           No         References trips.id
  category            VARCHAR(50)    Yes        Notification category
  title               VARCHAR(255)   Yes        Notification title
  message             TEXT           Yes        Notification body
  priority            VARCHAR(20)    Yes        low, normal, high, critical
  is_read             BOOLEAN        Yes        Read status
  scheduled_at        TIMESTAMP      No         Scheduled delivery time
  delivered_at        TIMESTAMP      No         Delivery timestamp
  action_url          TEXT           No         Deep link
  metadata            JSONB          No         Context-specific payload
  created_at          TIMESTAMP      Yes        Creation timestamp
  updated_at          TIMESTAMP      Yes        Last update
  deleted_at          TIMESTAMP      No         Soft delete
  sync_version        BIGINT         Yes        Sync version
  device_updated_at   TIMESTAMP      Yes        Client update time

------------------------------------------------------------------------

# Constraints

-   Primary Key: `id`
-   Foreign Key: `user_id → users.id`
-   Foreign Key: `trip_id → trips.id` (nullable)
-   Soft deletes only.

------------------------------------------------------------------------

# Indexes

-   PK(id)
-   INDEX(user_id)
-   INDEX(trip_id)
-   INDEX(category)
-   INDEX(priority)
-   INDEX(is_read)
-   INDEX(scheduled_at)

------------------------------------------------------------------------

# Relationships

-   Many Notifications → One User
-   Many Notifications → One Trip (optional)
-   Notifications may reference Flights, Hotels, Itinerary Items or
    Expenses through metadata.

------------------------------------------------------------------------

# Synchronization

-   Offline read status supported.
-   Notification state synchronized using `sync_version`.
-   Duplicate notifications suppressed during sync.

------------------------------------------------------------------------

# Security

-   Notifications visible only to intended user.
-   Metadata validated before delivery.
-   Critical alerts audited.

------------------------------------------------------------------------

# Acceptance Criteria

-   Fast retrieval by user.
-   Read state synchronized across devices.
-   Offline access supported.
-   Compatible with PostgreSQL and SQLite.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -------------------------------------------
  1.0       Initial Notifications Table Specification
