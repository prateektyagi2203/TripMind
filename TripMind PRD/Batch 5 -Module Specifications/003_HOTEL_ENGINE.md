# 003_HOTEL_ENGINE.md

# Hotel Engine

Version: 1.0

Status: Module Specification

------------------------------------------------------------------------

# Purpose

The Hotel Engine manages hotel reservations, stay information and
location-based services. It transforms a hotel booking into the
operational hub for the traveler's daily activities.

------------------------------------------------------------------------

# Responsibilities

-   Import hotel bookings
-   Maintain stay details
-   Provide nearby recommendations
-   Support check-in/check-out reminders
-   Publish hotel context to the Trip Context Engine

------------------------------------------------------------------------

# Business Rules

-   Every hotel belongs to one Trip.
-   A trip may include multiple hotel stays.
-   Hotel location becomes the default origin for recommendations.
-   Nearby services are cached for offline use when available.

------------------------------------------------------------------------

# Core Entity

Hotel

Fields

-   id
-   trip_id
-   name
-   address
-   latitude
-   longitude
-   check_in
-   check_out
-   booking_reference
-   phone
-   email
-   rating

------------------------------------------------------------------------

# Features

## Hotel Import

Supported methods

-   Email parsing
-   Booking confirmation OCR
-   Manual entry

## Hotel Dashboard

Displays

-   Booking details
-   Check-in/out times
-   Contact information
-   Maps
-   Wi-Fi notes (manual)
-   AI summary

## Nearby Services

Recommend nearby:

-   Indian restaurants
-   Vegetarian restaurants
-   Beaches
-   Attractions
-   ATM
-   Pharmacy
-   Hospital
-   Convenience stores

## Stay Assistance

-   Check-in reminders
-   Check-out reminders
-   Route back to hotel
-   Weather around hotel
-   Sunrise & sunset near hotel

------------------------------------------------------------------------

# APIs

-   POST /hotels
-   GET /hotels/{id}
-   PATCH /hotels/{id}
-   DELETE /hotels/{id}
-   POST /hotels/import

------------------------------------------------------------------------

# Database Tables

-   hotels
-   hotel_notes
-   nearby_places_cache

------------------------------------------------------------------------

# Events

Publishes

-   HotelImported
-   HotelUpdated
-   HotelCheckedIn
-   HotelCheckedOut

------------------------------------------------------------------------

# Offline Behaviour

Hotel information, maps metadata, cached nearby places and booking
details remain available offline.

------------------------------------------------------------------------

# Dependencies

-   Trip Engine
-   Trip Context Engine
-   Recommendation Engine
-   Maps Provider
-   Sync Engine

------------------------------------------------------------------------

# Acceptance Criteria

-   Hotel import in under 30 seconds.
-   Nearby recommendations available within 2 seconds.
-   Offline hotel details accessible.
-   Hotel location automatically updates Trip Context.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ----------------------
  1.0       Initial Hotel Engine
