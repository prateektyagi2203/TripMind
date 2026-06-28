# 001_TRIP_ENGINE.md

# Trip Engine

Version: 1.0

Status: Module Specification

------------------------------------------------------------------------

# Purpose

The Trip Engine is the core business module of TripMind. Every other
engine operates within the context of a Trip.

------------------------------------------------------------------------

# Responsibilities

-   Create Trip
-   Update Trip
-   Archive Trip
-   Duplicate Trip
-   Share Trip
-   Manage trip lifecycle
-   Publish Trip Context events

------------------------------------------------------------------------

# Business Rules

-   A trip has one owner.
-   A trip may have multiple family members.
-   Every flight, hotel, activity and expense belongs to exactly one
    trip.
-   Trips can be active, upcoming, completed or archived.

------------------------------------------------------------------------

# Lifecycle

    Draft
      │
    Planned
      │
    Active
      │
    Completed
      │
    Archived

------------------------------------------------------------------------

# Core Entity

Trip

Fields

-   id
-   title
-   destination
-   country
-   start_date
-   end_date
-   status
-   budget
-   currency
-   owner_id
-   destination_pack_id
-   created_at
-   updated_at

------------------------------------------------------------------------

# Features

## Trip Dashboard

Displays:

-   Countdown
-   Weather
-   Flights
-   Hotels
-   Today's itinerary
-   Budget
-   Family
-   AI briefing

------------------------------------------------------------------------

## Family Sharing

Supports:

-   Invite
-   Remove
-   Permission management

------------------------------------------------------------------------

## Timeline

Maintains chronological sequence of:

-   Flights
-   Activities
-   Expenses
-   Memories
-   Notifications

------------------------------------------------------------------------

# APIs

-   POST /trips
-   GET /trips
-   GET /trips/{id}
-   PATCH /trips/{id}
-   DELETE /trips/{id}
-   POST /trips/{id}/share

------------------------------------------------------------------------

# Database Tables

-   trips
-   family_members
-   itinerary_items
-   trip_settings

------------------------------------------------------------------------

# Events

Publishes:

-   TripCreated
-   TripUpdated
-   TripActivated
-   TripCompleted
-   TripArchived

------------------------------------------------------------------------

# Offline Behaviour

Trips can be created and edited offline.

Changes are queued through the Sync Engine.

------------------------------------------------------------------------

# Dependencies

-   Family Engine
-   Flight Engine
-   Hotel Engine
-   Trip Context Engine
-   Sync Engine

------------------------------------------------------------------------

# Acceptance Criteria

-   Create trip in under 30 seconds.
-   Trip dashboard loads in under 1 second.
-   Offline trip creation supported.
-   Family sharing functions correctly.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ---------------------
  1.0       Initial Trip Engine
