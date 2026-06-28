# 004_FLIGHTS_API.md

# Flights API

Version: 1.0

Status: Backend API Specification

------------------------------------------------------------------------

# Purpose

Defines REST endpoints for managing flights, boarding passes and live
flight information.

------------------------------------------------------------------------

# Resource

`/flights`

------------------------------------------------------------------------

## GET /flights

Returns all flights for the authenticated user or a specific trip.

### Query Parameters

-   trip_id
-   status
-   page
-   page_size

------------------------------------------------------------------------

## POST /flights

Creates a flight manually.

### Request

``` json
{
  "trip_id":"uuid",
  "airline":"Air India",
  "flight_number":"AI379",
  "departure_airport":"DEL",
  "arrival_airport":"HKT",
  "departure_time":"2026-12-02T08:00:00Z",
  "arrival_time":"2026-12-02T13:30:00Z"
}
```

------------------------------------------------------------------------

## POST /flights/import

Imports a flight from:

-   Boarding pass OCR
-   Booking confirmation
-   Email parser

Returns normalized flight data for confirmation.

------------------------------------------------------------------------

## GET /flights/{flightId}

Returns complete flight information.

Includes:

-   Airline
-   Schedule
-   Terminal
-   Gate
-   Seat
-   Baggage
-   Status

------------------------------------------------------------------------

## PATCH /flights/{flightId}

Updates editable fields.

------------------------------------------------------------------------

## DELETE /flights/{flightId}

Soft deletes the flight.

------------------------------------------------------------------------

## GET /flights/{flightId}/status

Returns latest live flight status.

------------------------------------------------------------------------

# Response Schema

``` json
{
  "success": true,
  "data": {
    "flight_id":"uuid",
    "status":"boarding"
  }
}
```

------------------------------------------------------------------------

# Validation

-   Flight number required.
-   Departure before arrival.
-   Trip must exist.
-   Only authorized users may edit.

------------------------------------------------------------------------

# Events

-   FlightCreated
-   FlightImported
-   FlightUpdated
-   FlightDelayed
-   GateChanged
-   FlightCompleted

------------------------------------------------------------------------

# Security

JWT required.

------------------------------------------------------------------------

# Acceptance Criteria

-   Flight creation \<1 second.
-   OCR imports supported.
-   Live status endpoint cache-aware.
-   OpenAPI documentation generated.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ---------------------
  1.0       Initial Flights API
