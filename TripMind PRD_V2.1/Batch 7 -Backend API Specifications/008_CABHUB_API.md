# 008_CABHUB_API.md

# CabHub API

Version: 1.0

Status: Backend API Specification

------------------------------------------------------------------------

# Purpose

Defines REST endpoints for comparing taxi providers, estimating fares
and recording ride history. TripMind redirects users to provider apps to
complete bookings.

------------------------------------------------------------------------

# Resource

`/transport`

------------------------------------------------------------------------

## GET /transport/options

Returns available transportation options.

### Query Parameters

-   latitude
-   longitude
-   destination_latitude
-   destination_longitude
-   passengers
-   luggage

Returns:

-   Provider
-   ETA
-   Estimated fare
-   Vehicle type
-   Recommendation score

------------------------------------------------------------------------

## POST /transport/recommend

Generates AI-powered transport recommendations.

Inputs:

-   Trip Context
-   Weather
-   Traffic
-   Budget
-   Family size

Returns:

-   Recommended provider
-   Explanation
-   Deep-link URI

------------------------------------------------------------------------

## POST /transport/history

Stores completed ride information.

### Request

``` json
{
  "trip_id":"uuid",
  "provider":"Grab",
  "fare":450,
  "currency":"THB",
  "distance_km":12.4
}
```

------------------------------------------------------------------------

## GET /transport/history

Returns transport history for a trip.

------------------------------------------------------------------------

## GET /transport/providers

Returns supported providers for the current destination.

------------------------------------------------------------------------

# Response Schema

``` json
{
  "success": true,
  "data": {
    "recommendation":"Grab",
    "reason":"Fastest pickup"
  }
}
```

------------------------------------------------------------------------

# Validation

-   Coordinates required.
-   Destination required.
-   Trip must exist for history.
-   Provider must be supported.

------------------------------------------------------------------------

# Events

-   TaxiRecommended
-   RideRecorded
-   RideCompleted

------------------------------------------------------------------------

# Security

JWT authentication required.

------------------------------------------------------------------------

# Acceptance Criteria

-   Comparison endpoint \<3 seconds online.
-   Recommendation includes reasoning.
-   Deep-link returned for supported providers.
-   OpenAPI documentation generated.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- --------------------
  1.0       Initial CabHub API
