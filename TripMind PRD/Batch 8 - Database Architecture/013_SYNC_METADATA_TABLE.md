# 013_SYNC_METADATA_TABLE.md

# Sync Metadata Table Specification

Version: 1.0

Status: Database Specification

------------------------------------------------------------------------

# Purpose

Defines the `sync_metadata` table used to coordinate offline-first
synchronization between the local SQLite database and the cloud
PostgreSQL database.

------------------------------------------------------------------------

# Table Name

`sync_metadata`

------------------------------------------------------------------------

# Description

Tracks synchronization state for every locally modified record, enabling
reliable uploads, downloads, conflict detection and recovery after
connectivity interruptions.

------------------------------------------------------------------------

# Columns

  Column           Type          Required   Description
  ---------------- ------------- ---------- ----------------------------------
  id               UUID          Yes        Primary key
  entity_type      VARCHAR(50)   Yes        trips, flights, hotels, etc.
  entity_id        UUID          Yes        Record identifier
  operation        VARCHAR(20)   Yes        create, update, delete
  sync_status      VARCHAR(20)   Yes        pending, syncing, synced, failed
  local_version    BIGINT        Yes        Local version
  server_version   BIGINT        No         Server version
  retry_count      INTEGER       Yes        Retry attempts
  last_error       TEXT          No         Failure reason
  queued_at        TIMESTAMP     Yes        Queue time
  synced_at        TIMESTAMP     No         Completion time
  created_at       TIMESTAMP     Yes        Creation timestamp
  updated_at       TIMESTAMP     Yes        Last update

------------------------------------------------------------------------

# Constraints

-   Primary Key: `id`
-   Unique(entity_type, entity_id)
-   Retry count must be \>= 0

------------------------------------------------------------------------

# Indexes

-   PK(id)
-   INDEX(sync_status)
-   INDEX(entity_type)
-   INDEX(entity_id)
-   INDEX(queued_at)

------------------------------------------------------------------------

# Relationships

Logical references to every synchronizable entity.

------------------------------------------------------------------------

# Synchronization

-   FIFO processing by default
-   Dependency-aware ordering
-   Automatic retry with exponential backoff
-   Conflict detection using version numbers
-   Manual resolution supported for conflicting edits

------------------------------------------------------------------------

# Security

-   No user content stored beyond sync metadata.
-   Queue encrypted on device where supported.

------------------------------------------------------------------------

# Acceptance Criteria

-   Pending operations survive app restarts.
-   Failed operations retried automatically.
-   Compatible with PostgreSQL and SQLite.
-   Supports offline-first architecture.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -------------------------------------------
  1.0       Initial Sync Metadata Table Specification
