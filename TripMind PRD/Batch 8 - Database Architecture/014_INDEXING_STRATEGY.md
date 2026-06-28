# 014_INDEXING_STRATEGY.md

# Indexing Strategy

Version: 1.0

Status: Database Specification

------------------------------------------------------------------------

# Purpose

Defines the indexing strategy for TripMind to ensure predictable query
performance across PostgreSQL and SQLite while supporting offline
synchronization.

------------------------------------------------------------------------

# Objectives

-   Fast lookups by user and trip
-   Efficient date-range queries
-   Optimized geospatial searches
-   Low write amplification
-   Consistent offline performance

------------------------------------------------------------------------

# Primary Indexes

Every table includes:

-   Primary Key (`id`)
-   Foreign key indexes
-   `created_at`
-   `updated_at`

------------------------------------------------------------------------

# Trip-Centric Indexes

-   `trips(owner_id)`
-   `flights(trip_id)`
-   `hotels(trip_id)`
-   `itinerary_items(trip_id, day_number)`
-   `expenses(trip_id, expense_date)`
-   `memories(trip_id, captured_at)`

------------------------------------------------------------------------

# User-Centric Indexes

-   `notifications(user_id, is_read)`
-   `family_members(user_id)`
-   `users(email)` (UNIQUE)

------------------------------------------------------------------------

# Geospatial Indexes

PostgreSQL:

-   PostGIS GiST indexes on location columns

SQLite:

-   Latitude/longitude B-tree indexes for local filtering

------------------------------------------------------------------------

# Search Indexes

-   Hotel name
-   Restaurant name
-   Itinerary title
-   Memory title

Future:

-   PostgreSQL full-text search (`tsvector`)

------------------------------------------------------------------------

# Synchronization Indexes

-   `sync_metadata(sync_status)`
-   `sync_metadata(entity_type, entity_id)`
-   `sync_metadata(queued_at)`

------------------------------------------------------------------------

# Maintenance

-   Regular VACUUM / ANALYZE
-   Index usage monitoring
-   Remove unused indexes
-   Rebuild fragmented indexes during maintenance windows

------------------------------------------------------------------------

# Acceptance Criteria

-   Common trip queries complete using indexed access paths.
-   Geospatial queries optimized.
-   Sync queue retrieval efficient.
-   Compatible with PostgreSQL and SQLite.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ---------------------------
  1.0       Initial Indexing Strategy
