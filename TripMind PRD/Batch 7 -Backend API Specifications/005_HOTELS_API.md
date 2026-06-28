# 005_HOTELS_API.md

# Hotels API

Version: 1.0

Status: Backend API Specification

------------------------------------------------------------------------

# Purpose

Defines REST endpoints for managing hotel bookings, hotel metadata and
nearby services.

------------------------------------------------------------------------

# Resource

`/hotels`

------------------------------------------------------------------------

## GET /hotels

Returns hotel bookings for the authenticated user.

### Query Parameters

-   trip_id
-   page
-   page_size

------------------------------------------------------------------------

## POST /hotels

Creates a hotel booking.

### Request

``` json
{
  "trip_id":"uuid",
  "name":"Novotel Phuket",
  "address":"Patong Beach",
  "check_in":"2026-12-02",
  "check_out":"2026-12-05",
  "booking_reference":"ABC123"
}
```

------------------------------------------------------------------------

## POST /hotels/import

Imports booking from:

-   Email
-   PDF confirmation
-   OCR image

Returns parsed hotel details for confirmation.

------------------------------------------------------------------------

## GET /hotels/{hotelId}

Returns:

-   Booking details
-   Contact information
-   Coordinates
-   Stay summary
-   Nearby places

------------------------------------------------------------------------

## PATCH /hotels/{hotelId}

Updates editable booking information.

------------------------------------------------------------------------

## DELETE /hotels/{hotelId}

Soft deletes hotel booking.

------------------------------------------------------------------------

## GET /hotels/{hotelId}/nearby

Returns nearby:

-   Restaurants
-   Attractions
-   Beaches
-   Pharmacies
-   Hospitals
-   ATMs

Supports offline cache when available.

------------------------------------------------------------------------

# Response Schema

``` json
{
  "success": true,
  "data": {
    "hotel_id":"uuid",
    "status":"confirmed"
  }
}
```

------------------------------------------------------------------------

# Validation

-   Check-out must be after check-in.
-   Trip must exist.
-   Booking reference optional.
-   Coordinates validated if supplied.

------------------------------------------------------------------------

# Events

-   HotelCreated
-   HotelImported
-   HotelUpdated
-   HotelCheckedIn
-   HotelCheckedOut

------------------------------------------------------------------------

# Security

JWT authentication required.

------------------------------------------------------------------------

# Acceptance Criteria

-   Hotel creation \<1 second.
-   OCR import supported.
-   Nearby endpoint cache-aware.
-   OpenAPI documentation generated.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- --------------------
  1.0       Initial Hotels API
