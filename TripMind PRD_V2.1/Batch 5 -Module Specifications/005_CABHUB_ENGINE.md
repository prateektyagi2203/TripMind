# 005_CABHUB_ENGINE.md

# CabHub Engine

Version: 1.0

Status: Module Specification

------------------------------------------------------------------------

# Purpose

CabHub is TripMind's intelligent ground transportation engine. Instead
of replacing taxi providers, it compares available services and
recommends the best option using Trip Context.

------------------------------------------------------------------------

# Responsibilities

-   Compare taxi providers
-   Estimate fares and travel times
-   Recommend the best provider
-   Deep-link into provider apps
-   Record completed rides as trip events and expenses

------------------------------------------------------------------------

# Supported Providers (MVP)

-   Grab
-   Bolt
-   inDrive
-   Hotel Taxi
-   Airport Shuttle

Future: - Uber (where available) - Local providers by destination pack

------------------------------------------------------------------------

# Business Rules

-   Ride booking is completed in the provider's app.
-   TripMind never stores payment credentials.
-   Recommendations must explain *why* a provider is suggested.

------------------------------------------------------------------------

# Recommendation Inputs

-   Current GPS location
-   Destination
-   Traffic
-   Weather
-   Family size
-   Luggage
-   Budget
-   Preferred providers
-   Historical usage (Travel DNA)

------------------------------------------------------------------------

# Features

## Fare Comparison

Display: - Estimated fare - ETA - Pickup time - Vehicle type

## Smart Recommendation

Examples: - Cheapest - Fastest - Best for family - Best during rain

## Ride History

Store: - Provider - Fare - Distance - Duration - Linked expense

------------------------------------------------------------------------

# APIs

-   GET /transport/options
-   POST /transport/history
-   GET /transport/history

------------------------------------------------------------------------

# Database Tables

-   taxi_history
-   taxi_preferences
-   provider_cache

------------------------------------------------------------------------

# Events

Publishes

-   TaxiRecommended
-   RideStarted
-   RideCompleted

------------------------------------------------------------------------

# Offline Behaviour

When offline: - Show previously cached provider information - Use
destination pack estimates - Disable live fare comparison gracefully

------------------------------------------------------------------------

# Dependencies

-   Trip Context Engine
-   Recommendation Engine
-   Expense Engine
-   Maps Provider

------------------------------------------------------------------------

# Acceptance Criteria

-   Provider comparison completes in under 3 seconds online.
-   Recommendation includes an explanation.
-   Deep-link launches installed provider app.
-   Completed ride automatically appears in trip timeline.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -----------------------
  1.0       Initial CabHub Engine
