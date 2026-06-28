# 002_FLIGHT_ENGINE.md

# Flight Engine

Version: 1.0

Status: Module Specification

------------------------------------------------------------------------

# Purpose

The Flight Engine manages all flight-related information before, during
and after travel. It keeps travelers informed, synchronized and prepared
throughout their journey.

------------------------------------------------------------------------

# Responsibilities

-   Import flights
-   Parse boarding passes
-   Monitor flight status
-   Notify schedule changes
-   Provide airport guidance
-   Publish flight events to Trip Context

------------------------------------------------------------------------

# Business Rules

-   Every flight belongs to one Trip.
-   A trip may contain multiple flights.
-   Boarding passes are stored securely.
-   Flight changes update the itinerary automatically.

------------------------------------------------------------------------

# Core Entity

Flight

Fields

-   id
-   trip_id
-   airline
-   flight_number
-   departure_airport
-   arrival_airport
-   departure_time
-   arrival_time
-   terminal
-   gate
-   seat
-   baggage
-   status

------------------------------------------------------------------------

# Features

## Flight Import

Supported methods

-   Email parsing
-   Boarding pass OCR
-   Manual entry

------------------------------------------------------------------------

## Live Flight Status

Displays

-   Scheduled
-   Boarding
-   Delayed
-   Gate changes
-   Landed

------------------------------------------------------------------------

## Airport Assistant

Provides

-   Terminal
-   Boarding time
-   Check-in reminder
-   Security recommendation
-   Departure countdown

------------------------------------------------------------------------

## Notifications

-   Check-in opens
-   Leave for airport
-   Boarding begins
-   Gate change
-   Delay alerts

------------------------------------------------------------------------

# APIs

-   POST /flights
-   GET /flights/{id}
-   PATCH /flights/{id}
-   DELETE /flights/{id}
-   POST /flights/import

------------------------------------------------------------------------

# Database Tables

-   flights
-   boarding_passes
-   flight_notifications

------------------------------------------------------------------------

# Events

Publishes

-   FlightImported
-   FlightUpdated
-   FlightDelayed
-   GateChanged
-   FlightCompleted

------------------------------------------------------------------------

# Offline Behaviour

Cached flight details, boarding passes and reminders remain available
without internet. Live status resumes automatically when connectivity
returns.

------------------------------------------------------------------------

# Dependencies

-   Trip Engine
-   Trip Context Engine
-   Notification Engine
-   Camera Engine
-   Sync Engine

------------------------------------------------------------------------

# Acceptance Criteria

-   Flight import in under 30 seconds.
-   Boarding pass OCR \>95% accuracy (supported formats).
-   Offline boarding pass access.
-   Automatic itinerary updates after flight changes.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -----------------------
  1.0       Initial Flight Engine
