# 011_FAMILY_MEMBERS_TABLE.md

# Family Members Table Specification

Version: 1.0

Status: Database Specification

------------------------------------------------------------------------

# Purpose

Defines the `family_members` junction table that manages trip sharing,
member roles and permissions.

------------------------------------------------------------------------

# Table Name

`family_members`

------------------------------------------------------------------------

# Description

Stores membership records linking users to trips. Enables collaborative
travel while enforcing role-based permissions.

------------------------------------------------------------------------

# Columns

  Column                  Type          Required   Description
  ----------------------- ------------- ---------- -----------------------------
  id                      UUID          Yes        Primary key
  trip_id                 UUID          Yes        References trips.id
  user_id                 UUID          Yes        References users.id
  role                    VARCHAR(20)   Yes        owner, adult, child, guest
  invitation_status       VARCHAR(20)   Yes        pending, accepted, declined
  can_edit_itinerary      BOOLEAN       Yes        Permission flag
  can_view_expenses       BOOLEAN       Yes        Permission flag
  can_add_expenses        BOOLEAN       Yes        Permission flag
  can_share_memories      BOOLEAN       Yes        Permission flag
  can_view_documents      BOOLEAN       Yes        Permission flag
  live_location_enabled   BOOLEAN       Yes        Optional location sharing
  joined_at               TIMESTAMP     No         Acceptance timestamp
  created_at              TIMESTAMP     Yes        Creation timestamp
  updated_at              TIMESTAMP     Yes        Last update
  deleted_at              TIMESTAMP     No         Soft delete
  sync_version            BIGINT        Yes        Sync version
  device_updated_at       TIMESTAMP     Yes        Client update time

------------------------------------------------------------------------

# Constraints

-   Primary Key: `id`
-   Foreign Keys:
    -   `trip_id → trips.id`
    -   `user_id → users.id`
-   Unique constraint on (`trip_id`, `user_id`)
-   Soft deletes only.

------------------------------------------------------------------------

# Indexes

-   PK(id)
-   UNIQUE(trip_id, user_id)
-   INDEX(user_id)
-   INDEX(role)
-   INDEX(invitation_status)

------------------------------------------------------------------------

# Relationships

-   Many Family Members → One Trip
-   Many Family Members → One User

Implements the many-to-many relationship between users and trips.

------------------------------------------------------------------------

# Synchronization

-   Invitation status synchronized across devices.
-   Permission updates versioned with `sync_version`.
-   Offline acceptance queued until connectivity returns.

------------------------------------------------------------------------

# Security

-   Only trip owner may change roles or permissions.
-   Members can view only data allowed by permission flags.
-   Invitation tokens expire server-side.

------------------------------------------------------------------------

# Acceptance Criteria

-   Duplicate memberships prevented.
-   Permission checks supported efficiently.
-   Offline synchronization supported.
-   Compatible with PostgreSQL and SQLite.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- --------------------------------------------
  1.0       Initial Family Members Table Specification
