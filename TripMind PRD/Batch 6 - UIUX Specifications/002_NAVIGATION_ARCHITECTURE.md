# 002_NAVIGATION_ARCHITECTURE.md

# Navigation Architecture

Version: 1.0

Status: UI/UX Specification

------------------------------------------------------------------------

# Purpose

Define the navigation model for TripMind across Android and iPhone using
a single Flutter codebase.

------------------------------------------------------------------------

# Navigation Principles

-   Maximum depth of 3 levels for common tasks.
-   Persistent bottom navigation.
-   AI Concierge accessible from every primary screen.
-   Deep-link support for trips, bookings and notifications.
-   Offline navigation must continue to work.

------------------------------------------------------------------------

# Primary Navigation

    Splash
      │
    Authentication
      │
    Trip Selection
      │
    Home Dashboard

Bottom Navigation:

1.  Home
2.  Explore
3.  AI Concierge
4.  Expenses
5.  Profile

------------------------------------------------------------------------

# Home

Contains:

-   Today's itinerary
-   Flight card
-   Hotel card
-   Weather
-   Budget
-   Quick actions
-   Upcoming reminders

------------------------------------------------------------------------

# Explore

Sections:

-   Attractions
-   Beaches
-   Restaurants
-   Shopping
-   Activities
-   Maps
-   CabHub

------------------------------------------------------------------------

# AI Concierge

Entry points:

-   Bottom navigation
-   Floating Action Button
-   Voice shortcut
-   Notification actions

Supports:

-   Chat
-   Voice
-   Camera
-   Suggested actions

------------------------------------------------------------------------

# Expenses

Sections:

-   Dashboard
-   Categories
-   Receipts
-   Shared expenses
-   Budget analytics

------------------------------------------------------------------------

# Profile

Sections:

-   Account
-   Preferences
-   Family
-   Destination Packs
-   Documents
-   Privacy
-   Settings

------------------------------------------------------------------------

# Secondary Navigation

Trip Details

-   Flights
-   Hotels
-   Itinerary
-   Family
-   Memories

Hotel

-   Nearby
-   Map
-   Contact
-   Notes

Translator

-   Text
-   Voice
-   Camera
-   Conversation

Camera

-   Landmark
-   Receipt
-   Boarding Pass
-   Hotel Booking

------------------------------------------------------------------------

# Global Navigation

Available everywhere:

-   Search
-   Notifications
-   AI Concierge
-   Emergency (long press future)

------------------------------------------------------------------------

# Deep Linking

Examples:

tripmind://trip/{tripId}

tripmind://flight/{flightId}

tripmind://expense/{expenseId}

tripmind://restaurant/{restaurantId}

------------------------------------------------------------------------

# Back Navigation Rules

-   Preserve scroll position.
-   Preserve filters.
-   Restore previous screen state.
-   Confirm before leaving unsaved forms.

------------------------------------------------------------------------

# Flutter Implementation

-   GoRouter
-   Nested navigation
-   ShellRoute for bottom navigation
-   Typed routes
-   Deep-link support

------------------------------------------------------------------------

# Acceptance Criteria

-   Reach any primary feature within three taps.
-   Navigation state survives app restart.
-   Deep links open the correct screen.
-   Bottom navigation remains responsive.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ---------------------------------
  1.0       Initial Navigation Architecture
