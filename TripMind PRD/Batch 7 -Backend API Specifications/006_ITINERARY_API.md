# 006_ITINERARY_API.md

# Itinerary API

Version: 1.0

Status: Backend API Specification

------------------------------------------------------------------------

# Purpose

Defines REST endpoints for creating, updating and optimizing trip
itineraries.

------------------------------------------------------------------------

# Resource

`/itinerary`

------------------------------------------------------------------------

## GET /itinerary

Returns itinerary items.

### Query Parameters

-   trip_id
-   day
-   page
-   page_size

------------------------------------------------------------------------

## POST /itinerary

Creates a new itinerary item.

### Request

``` json
{
  "trip_id":"uuid",
  "title":"Visit Big Buddha",
  "activity_type":"attraction",
  "start_time":"2026-12-03T09:00:00Z",
  "end_time":"2026-12-03T11:00:00Z",
  "location":"Big Buddha Phuket"
}
```

------------------------------------------------------------------------

## GET /itinerary/{itemId}

Returns full itinerary item details.

------------------------------------------------------------------------

## PATCH /itinerary/{itemId}

Updates:

-   Time
-   Location
-   Notes
-   Status
-   Order

------------------------------------------------------------------------

## DELETE /itinerary/{itemId}

Soft deletes the itinerary item.

------------------------------------------------------------------------

## POST /itinerary/optimize

Optimizes itinerary using:

-   Distance
-   Weather
-   Opening hours
-   Traffic
-   Trip Context
-   Family preferences

Returns reordered itinerary with reasoning.

------------------------------------------------------------------------

## POST /itinerary/reorder

Updates activity order after drag-and-drop.

------------------------------------------------------------------------

# Response Schema

``` json
{
  "success": true,
  "data": {
    "item_id":"uuid",
    "optimized":true
  }
}
```

------------------------------------------------------------------------

# Validation

-   Activity must belong to an existing trip.
-   End time must be after start time.
-   Only authorized users may edit shared itineraries.

------------------------------------------------------------------------

# Events

-   ItineraryCreated
-   ActivityAdded
-   ActivityUpdated
-   ActivityCompleted
-   ItineraryOptimized

------------------------------------------------------------------------

# Security

JWT authentication required.

------------------------------------------------------------------------

# Acceptance Criteria

-   CRUD operations complete in under 1 second.
-   Optimization endpoint returns ordered results.
-   Drag-and-drop ordering persists across devices.
-   OpenAPI documentation generated.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -----------------------
  1.0       Initial Itinerary API
