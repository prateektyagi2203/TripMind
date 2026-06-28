# 016_MEMORIES_API.md

# Memories API

Version: 1.0

Status: Backend API Specification

------------------------------------------------------------------------

# Purpose

Defines REST endpoints for managing travel memories, journals, smart
albums and timelines generated during a trip.

------------------------------------------------------------------------

# Resource

`/memories`

------------------------------------------------------------------------

## GET /memories

Returns memories for the authenticated user.

### Query Parameters

-   trip_id
-   album
-   date
-   page
-   page_size

------------------------------------------------------------------------

## GET /memories/{memoryId}

Returns detailed memory information.

Includes:

-   Photos
-   Videos
-   Notes
-   GPS location
-   Related itinerary events
-   AI summary

------------------------------------------------------------------------

## POST /memories/journal

Generates or updates an AI travel journal.

### Request

``` json
{
  "trip_id":"uuid",
  "day":"2026-12-03"
}
```

------------------------------------------------------------------------

## POST /memories/share

Shares selected memories.

### Request

``` json
{
  "memory_ids":["uuid1","uuid2"],
  "visibility":"family"
}
```

Visibility values:

-   private
-   family
-   selected_members

------------------------------------------------------------------------

## GET /memories/albums

Returns smart albums.

Examples:

-   Beaches
-   Restaurants
-   Attractions
-   Hotels
-   Shopping
-   Family

------------------------------------------------------------------------

## GET /memories/timeline

Returns chronological trip events.

------------------------------------------------------------------------

# Response Schema

``` json
{
  "success": true,
  "data": {
    "memory_id":"uuid",
    "album":"Beaches",
    "shared":false
  }
}
```

------------------------------------------------------------------------

# Validation

-   Trip must exist.
-   User must own or have access to shared memories.
-   Visibility value must be valid.

------------------------------------------------------------------------

# Events

-   MemoryCreated
-   JournalGenerated
-   AlbumUpdated
-   TimelineRebuilt
-   MemoryShared

------------------------------------------------------------------------

# Security

-   JWT authentication required.
-   Access controlled by trip membership and sharing settings.
-   Media URLs are time-limited and signed.

------------------------------------------------------------------------

# Acceptance Criteria

-   Timeline loads in under 2 seconds.
-   AI journal generation completes asynchronously.
-   Smart albums update automatically.
-   OpenAPI documentation generated.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ----------------------
  1.0       Initial Memories API
