# 007_EXPLORE_SCREEN_UX.md

# Explore Screen UX Specification

Version: 1.0

Status: UI/UX Specification

------------------------------------------------------------------------

# Purpose

The Explore screen helps travelers discover nearby attractions,
restaurants, beaches, shopping areas and experiences based on their
current location, itinerary and Trip Context.

------------------------------------------------------------------------

# UX Goals

-   Discover nearby places quickly
-   Personalize recommendations
-   Minimize search effort
-   Support offline browsing using Destination Packs
-   Provide map and list views

------------------------------------------------------------------------

# Screen Layout

    --------------------------------------------------
    Search Bar
    --------------------------------------------------
    Current Location
    --------------------------------------------------
    Quick Category Chips
    --------------------------------------------------
    AI Recommended For You
    --------------------------------------------------
    Nearby Attractions
    --------------------------------------------------
    Nearby Restaurants
    --------------------------------------------------
    Nearby Beaches
    --------------------------------------------------
    Shopping
    --------------------------------------------------
    Map Preview
    --------------------------------------------------
    Bottom Navigation
    --------------------------------------------------

------------------------------------------------------------------------

# Header

Displays:

-   Search field
-   Filter button
-   Current location
-   Active trip indicator

------------------------------------------------------------------------

# Quick Categories

Horizontal chips:

-   Attractions
-   Beaches
-   Restaurants
-   Shopping
-   Cafes
-   Parks
-   Museums
-   Night Markets
-   Family Activities

------------------------------------------------------------------------

# AI Recommendations

Examples:

-   Best sunset nearby
-   Ideal lunch stop after current attraction
-   Rain-friendly indoor activity
-   Kid-friendly destination

Each recommendation includes a reason.

------------------------------------------------------------------------

# List Cards

Each card displays:

-   Hero image
-   Name
-   Distance
-   Rating
-   Opening hours
-   Estimated visit duration
-   "Why Recommended"

Actions:

-   Navigate
-   Add to Itinerary
-   Save
-   Share

------------------------------------------------------------------------

# Map Mode

Displays:

-   Hotel
-   Current location
-   Attractions
-   Restaurants
-   Beaches
-   Selected route

Supports clustering when zoomed out.

------------------------------------------------------------------------

# Search & Filters

Filters:

-   Distance
-   Rating
-   Budget
-   Family Friendly
-   Vegetarian
-   Wheelchair Accessible
-   Open Now

------------------------------------------------------------------------

# Offline Behaviour

When offline:

-   Search Destination Pack
-   Cached places
-   Saved favourites
-   Cached maps metadata

Live ratings and availability are marked as unavailable.

------------------------------------------------------------------------

# Flutter Widgets

Suggested widgets:

-   CustomScrollView
-   SliverAppBar
-   SearchAnchor
-   ChoiceChip
-   Card
-   GoogleMap
-   DraggableScrollableSheet

------------------------------------------------------------------------

# Acceptance Criteria

-   Nearby places load in under 2 seconds online.
-   Offline search works from Destination Pack.
-   Filters update instantly.
-   AI recommendations explain why they are shown.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ---------------------------
  1.0       Initial Explore Screen UX
