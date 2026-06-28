# 012_DESTINATION_PACKS_TABLE.md

# Destination Packs Table Specification

Version: 1.0

Status: Database Specification

------------------------------------------------------------------------

# Purpose

Defines the `destination_packs` table for managing downloadable offline
travel content used by TripMind.

------------------------------------------------------------------------

# Table Name

`destination_packs`

------------------------------------------------------------------------

# Description

Stores metadata for downloadable destination packs and tracks
installation state per user. Destination packs provide offline
attractions, restaurants, maps metadata, emergency contacts and
phrasebooks.

------------------------------------------------------------------------

# Columns

  Column              Type           Required   Description
  ------------------- -------------- ---------- ------------------------
  id                  UUID           Yes        Primary key
  country             VARCHAR(100)   Yes        Destination country
  region              VARCHAR(100)   No         Region or state
  language            VARCHAR(10)    Yes        Pack language
  version             VARCHAR(20)    Yes        Semantic version
  package_size_mb     NUMERIC(8,2)   Yes        Download size
  checksum            VARCHAR(128)   Yes        Integrity hash
  download_url        TEXT           Yes        Package URL
  installed           BOOLEAN        Yes        Installed on device
  installed_at        TIMESTAMP      No         Installation timestamp
  last_checked_at     TIMESTAMP      No         Last update check
  created_at          TIMESTAMP      Yes        Creation timestamp
  updated_at          TIMESTAMP      Yes        Last update
  deleted_at          TIMESTAMP      No         Soft delete
  sync_version        BIGINT         Yes        Sync version
  device_updated_at   TIMESTAMP      Yes        Client update time

------------------------------------------------------------------------

# Constraints

-   Primary Key: `id`
-   Unique(country, region, language, version)
-   Package size must be positive.
-   Soft deletes only.

------------------------------------------------------------------------

# Indexes

-   PK(id)
-   INDEX(country)
-   INDEX(region)
-   INDEX(language)
-   INDEX(installed)
-   INDEX(version)

------------------------------------------------------------------------

# Relationships

-   Referenced by Trips
-   Referenced by Offline Cache
-   Used by Recommendation Engine
-   Used by Translator Engine

------------------------------------------------------------------------

# Synchronization

-   Installation state synchronized across devices.
-   Package metadata refreshed periodically.
-   Version conflicts resolved by newest compatible release.

------------------------------------------------------------------------

# Security

-   Package checksum verified before installation.
-   HTTPS downloads only.
-   Digital signature verification required.

------------------------------------------------------------------------

# Acceptance Criteria

-   Fast lookup by destination.
-   Version integrity enforced.
-   Offline availability tracked.
-   Compatible with PostgreSQL and SQLite.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -----------------------------------------------
  1.0       Initial Destination Packs Table Specification
