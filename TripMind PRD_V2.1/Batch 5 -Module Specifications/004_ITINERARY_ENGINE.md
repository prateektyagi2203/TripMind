# 004_ITINERARY_ENGINE.md

# Itinerary Engine

Version: 1.0

Status: Module Specification

------------------------------------------------------------------------

# Purpose

The Itinerary Engine manages the day-by-day schedule of a trip. It
combines user plans with AI recommendations to produce an optimized,
flexible itinerary.

------------------------------------------------------------------------

# Responsibilities

-   Create daily itineraries
-   Add, edit and remove activities
-   Optimize travel order
-   Adapt plans based on weather, traffic and delays
-   Synchronize itinerary across family members
-   Publish current activity to the Trip Context Engine

------------------------------------------------------------------------

# Business Rules

-   Every itinerary belongs to one Trip.
-   Activities are grouped by day.
-   Activities can be manually arranged or AI-optimized.
-   Changes by one family member are synchronized to others according to
    permissions.

------------------------------------------------------------------------

# Core Entity

Itinerary Item

Fields

-   id
-   trip_id
-   day_number
-   title
-   activity_type
-   start_time
-   end_time
-   location
-   notes
-   status
-   ai_generated

------------------------------------------------------------------------

# Features

## Day Planner

-   Timeline view
-   Agenda view
-   Calendar view

## AI Optimization

Optimize using:

-   Distance
-   Opening hours
-   Weather
-   Traffic
-   Family preferences
-   Budget

## Activity Types

-   Attraction
-   Beach
-   Restaurant
-   Shopping
-   Hotel
-   Flight
-   Transport
-   Free time

## Daily Briefing

Generate:

-   Weather
-   First activity
-   Departure recommendation
-   Meal suggestions
-   Budget summary

------------------------------------------------------------------------

# APIs

-   POST /itinerary
-   GET /itinerary/{tripId}
-   PATCH /itinerary/{itemId}
-   DELETE /itinerary/{itemId}
-   POST /itinerary/optimize

------------------------------------------------------------------------

# Database Tables

-   itinerary_items
-   itinerary_notes
-   itinerary_templates

------------------------------------------------------------------------

# Events

Publishes

-   ItineraryCreated
-   ActivityAdded
-   ActivityUpdated
-   ActivityCompleted
-   ItineraryOptimized

------------------------------------------------------------------------

# Offline Behaviour

Users can fully view and edit itineraries offline. Optimization
requiring live services falls back to local rules when disconnected.

------------------------------------------------------------------------

# Dependencies

-   Trip Engine
-   Trip Context Engine
-   Recommendation Engine
-   Weather Engine
-   Sync Engine

------------------------------------------------------------------------

# Acceptance Criteria

-   Create a daily itinerary in under 2 minutes.
-   Drag-and-drop updates reflected immediately.
-   Offline itinerary editing supported.
-   AI optimization completes in under 5 seconds when online.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- --------------------------
  1.0       Initial Itinerary Engine
