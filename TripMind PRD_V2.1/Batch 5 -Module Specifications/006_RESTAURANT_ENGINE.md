# 006_RESTAURANT_ENGINE.md

# Restaurant Engine

Version: 1.0

Status: Module Specification

------------------------------------------------------------------------

# Purpose

The Restaurant Engine discovers, ranks and recommends dining options
based on Trip Context, user preferences and destination data.

------------------------------------------------------------------------

# Responsibilities

-   Discover nearby restaurants
-   Filter by cuisine and dietary needs
-   Recommend restaurants using AI
-   Save favourites
-   Link restaurant visits to itinerary and memories

------------------------------------------------------------------------

# Business Rules

-   Recommendations must consider current location.
-   Restaurant rankings must explain why they were selected.
-   Favourite restaurants sync across devices.

------------------------------------------------------------------------

# Inputs

-   GPS location
-   Trip Context
-   Travel DNA
-   Budget
-   Time of day
-   Family size
-   Destination Pack
-   Online map providers

------------------------------------------------------------------------

# Features

## Search

-   Nearby
-   Search by name
-   Search by cuisine

## Filters

-   Indian
-   Vegetarian
-   Vegan
-   Family friendly
-   Budget
-   Fine dining

## Restaurant Card

Displays: - Rating - Distance - Opening hours - Price level - Cuisine -
AI recommendation reason

## AI Suggestions

Examples: - Lunch near next attraction - Dinner after sunset -
Kid-friendly restaurant - Rain-friendly indoor dining

------------------------------------------------------------------------

# APIs

-   GET /restaurants/nearby
-   GET /restaurants/{id}
-   POST /restaurants/favourites
-   DELETE /restaurants/favourites/{id}

------------------------------------------------------------------------

# Database Tables

-   restaurants
-   favourite_restaurants
-   restaurant_visits

------------------------------------------------------------------------

# Events

-   RestaurantRecommended
-   RestaurantVisited
-   FavouriteAdded

------------------------------------------------------------------------

# Offline Behaviour

Uses cached restaurant metadata from Destination Packs and previous
searches. Clearly indicates when live availability or ratings may be
outdated.

------------------------------------------------------------------------

# Dependencies

-   Recommendation Engine
-   Trip Context Engine
-   Maps Provider
-   Destination Packs
-   Memory Engine

------------------------------------------------------------------------

# Acceptance Criteria

-   Nearby search \< 2 seconds online.
-   Filters applied instantly.
-   Offline search available for cached destinations.
-   AI recommendation includes explanation.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ---------------------------
  1.0       Initial Restaurant Engine
