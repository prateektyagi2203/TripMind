# 001_DATABASE_ARCHITECTURE.md

# Database Architecture

Version: 1.0

Status: Database Specification

------------------------------------------------------------------------

# Purpose

This document defines the overall database architecture for TripMind,
covering cloud storage, offline storage, synchronization and
scalability.

------------------------------------------------------------------------

# Technology Stack

## Cloud Database

-   PostgreSQL 16
-   PostGIS (location support)
-   UUID primary keys
-   JSONB for flexible metadata

## Offline Database

-   SQLite
-   Encrypted local storage
-   Automatic synchronization

## Cache

-   Redis
-   API caching
-   Session storage
-   Rate limiting

## Object Storage

-   Photos
-   Videos
-   Receipts
-   Documents

------------------------------------------------------------------------

# High-Level Architecture

    Flutter App
          │
     Offline SQLite
          │
     Sync Engine
          │
     FastAPI Backend
          │
     PostgreSQL
          │
    Object Storage + Redis

------------------------------------------------------------------------

# Database Design Principles

-   UUID primary keys
-   Soft deletes
-   Audit timestamps
-   Foreign key constraints
-   Indexed search fields
-   Offline-first synchronization

------------------------------------------------------------------------

# Core Schemas

-   Users
-   Trips
-   Flights
-   Hotels
-   Itinerary
-   Restaurants
-   Expenses
-   Family
-   Memories
-   Notifications
-   Destination Packs

------------------------------------------------------------------------

# Naming Convention

Tables: - snake_case

Columns: - snake_case

Primary Keys: - id (UUID)

Foreign Keys: -
```{=html}
<table>
```
\_id

------------------------------------------------------------------------

# Standard Columns

Every table contains:

-   id
-   created_at
-   updated_at
-   deleted_at (nullable)
-   sync_version
-   device_updated_at

------------------------------------------------------------------------

# Index Strategy

Indexes on:

-   user_id
-   trip_id
-   created_at
-   updated_at
-   latitude/longitude (PostGIS)
-   full-text search columns

------------------------------------------------------------------------

# Synchronization

-   Version-based sync
-   Conflict detection
-   Last-write-wins default
-   Manual conflict resolution for critical records

------------------------------------------------------------------------

# Security

-   Row-level authorization
-   Encrypted sensitive fields
-   Signed media URLs
-   Audit logging

------------------------------------------------------------------------

# Backup

-   Daily full backup
-   Hourly incremental backup
-   Point-in-time recovery
-   Multi-region replication (future)

------------------------------------------------------------------------

# Acceptance Criteria

-   Offline database mirrors required cloud schema.
-   Sync supports intermittent connectivity.
-   PostgreSQL optimized for \>1M trips.
-   Migration strategy supports zero-downtime deployments.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -------------------------------
  1.0       Initial Database Architecture
