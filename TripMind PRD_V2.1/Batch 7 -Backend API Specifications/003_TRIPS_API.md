# 003_TRIPS_API.md

# Trips API

Version: 1.0

Status: Backend API Specification

------------------------------------------------------------------------

# Purpose

Defines all REST endpoints for creating, updating, retrieving and
sharing Trips.

------------------------------------------------------------------------

# Resource

`/trips`

------------------------------------------------------------------------

## GET /trips

Returns all trips for the authenticated user.

### Query Parameters

-   page
-   page_size
-   status (upcoming, active, completed, archived)
-   sort

------------------------------------------------------------------------

## POST /trips

Creates a new trip.

### Request

``` json
{
  "title":"Thailand Family Trip",
  "country":"Thailand",
  "start_date":"2026-12-02",
  "end_date":"2026-12-05",
  "currency":"THB",
  "budget":100000
}
```

------------------------------------------------------------------------

## GET /trips/{tripId}

Returns complete trip details including summary, members and status.

------------------------------------------------------------------------

## PATCH /trips/{tripId}

Updates editable trip fields.

------------------------------------------------------------------------

## DELETE /trips/{tripId}

Archives the trip (soft delete).

------------------------------------------------------------------------

## POST /trips/{tripId}/share

Invites family members.

### Request

``` json
{
  "emails":[
    "wife@example.com",
    "child@example.com"
  ]
}
```

------------------------------------------------------------------------

## POST /trips/{tripId}/activate

Marks trip as active.

------------------------------------------------------------------------

## POST /trips/{tripId}/complete

Marks trip as completed.

------------------------------------------------------------------------

# Response Schema

``` json
{
  "success":true,
  "data":{
    "trip_id":"uuid",
    "status":"active"
  }
}
```

------------------------------------------------------------------------

# Validation

-   End date must be after start date.
-   Budget cannot be negative.
-   Country required.
-   Only owner may delete or share a trip.

------------------------------------------------------------------------

# Events

-   TripCreated
-   TripUpdated
-   TripActivated
-   TripCompleted
-   TripArchived

------------------------------------------------------------------------

# Security

JWT required for all endpoints.

------------------------------------------------------------------------

# Acceptance Criteria

-   Create trip \<1 second.
-   Soft deletes only.
-   Family sharing supported.
-   OpenAPI documentation generated.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -------------------
  1.0       Initial Trips API
