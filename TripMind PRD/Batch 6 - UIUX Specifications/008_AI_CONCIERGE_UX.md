# 008_AI_CONCIERGE_UX.md

# AI Concierge UX Specification

Version: 1.0

Status: UI/UX Specification

------------------------------------------------------------------------

# Purpose

The AI Concierge is the central intelligence hub of TripMind. It acts as
a travel companion that understands the user's Trip Context, Family
Context and Travel DNA to provide proactive assistance before, during
and after the journey.

------------------------------------------------------------------------

# UX Goals

-   Natural conversational experience
-   Minimize typing
-   Surface proactive recommendations
-   Support voice, text and camera interactions
-   Work seamlessly across Android and iPhone

------------------------------------------------------------------------

# Screen Layout

    --------------------------------------------------
    AI Header
    --------------------------------------------------
    Trip Context Summary
    --------------------------------------------------
    Suggested Actions
    --------------------------------------------------
    Conversation History
    --------------------------------------------------
    Quick Action Chips
    --------------------------------------------------
    Voice / Camera / Keyboard Input
    --------------------------------------------------
    Bottom Navigation
    --------------------------------------------------

------------------------------------------------------------------------

# Header

Displays:

-   AI Concierge avatar
-   Active trip
-   Current destination
-   Online / Offline indicator

------------------------------------------------------------------------

# Trip Context Card

Shows:

-   Current location
-   Today's itinerary
-   Weather
-   Flight status
-   Hotel
-   Remaining budget

This context is continuously refreshed from the Trip Context Engine.

------------------------------------------------------------------------

# Suggested Actions

Examples:

-   Book a taxi to the next attraction
-   Translate a menu
-   Find nearby vegetarian restaurants
-   Rearrange itinerary due to rain
-   Check flight status
-   View sunset recommendations

------------------------------------------------------------------------

# Conversation

Supports:

-   Markdown responses
-   Rich cards
-   Action buttons
-   Maps previews
-   Expense summaries
-   Restaurant recommendations

The AI should always explain *why* it recommends an action.

------------------------------------------------------------------------

# Input Methods

## Text

Standard chat input.

## Voice

-   Tap microphone
-   Speak naturally
-   AI transcribes and responds

## Camera

Capture:

-   Menu
-   Signboard
-   Receipt
-   Landmark
-   Boarding pass

AI routes the image to the appropriate engine automatically.

------------------------------------------------------------------------

# Quick Action Chips

Examples:

-   Taxi
-   Translate
-   Weather
-   Budget
-   Restaurants
-   Attractions
-   Hotel
-   Flights
-   Emergency

------------------------------------------------------------------------

# Offline Behaviour

Available offline:

-   Cached conversation history
-   Destination Pack knowledge
-   Local Trip Context
-   Previously generated recommendations

Cloud-only reasoning is disabled gracefully with clear messaging.

------------------------------------------------------------------------

# Flutter Widgets

Suggested widgets:

-   CustomScrollView
-   SliverAppBar
-   ListView
-   ChatBubble
-   InputDecorator
-   FloatingActionButton
-   BottomSheet
-   Voice waveform widget

------------------------------------------------------------------------

# Acceptance Criteria

-   AI screen opens in under 1 second.
-   Voice input starts within 500 ms.
-   Camera launches directly from chat.
-   Suggested actions update automatically when Trip Context changes.
-   Offline mode provides useful guidance using cached data.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -------------------------
  1.0       Initial AI Concierge UX
