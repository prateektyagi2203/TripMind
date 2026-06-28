# 006_HOME_DASHBOARD_UX.md

# Home Dashboard UX Specification

Version: 1.0

Status: UI/UX Specification

------------------------------------------------------------------------

# Purpose

Define the Home Dashboard, the most frequently used screen in TripMind.
It should provide an at-a-glance summary of everything the traveler
needs for the current day.

------------------------------------------------------------------------

# UX Goals

-   Show the most important information first
-   Minimize navigation
-   Surface AI recommendations proactively
-   Support offline viewing
-   Be usable with one hand

------------------------------------------------------------------------

# Screen Layout

    --------------------------------------------------
    Greeting + Profile + Notifications
    --------------------------------------------------
    Current Trip Selector
    --------------------------------------------------
    AI Morning Briefing
    --------------------------------------------------
    Today's Itinerary
    --------------------------------------------------
    Flight Card
    --------------------------------------------------
    Hotel Card
    --------------------------------------------------
    Weather Card
    --------------------------------------------------
    Budget Summary
    --------------------------------------------------
    Quick Actions
    --------------------------------------------------
    Recent Memories
    --------------------------------------------------
    Bottom Navigation
    --------------------------------------------------

------------------------------------------------------------------------

# Header

Displays:

-   Greeting
-   User avatar
-   Current time
-   Notification icon
-   Active trip selector

------------------------------------------------------------------------

# AI Morning Briefing

Example:

-   Good morning
-   Weather summary
-   First activity
-   Recommended departure time
-   Restaurant suggestion
-   Budget update

Action buttons:

-   View Plan
-   Ask AI

------------------------------------------------------------------------

# Today's Itinerary

Shows:

-   Timeline
-   Current activity
-   Next activity
-   Travel time
-   Progress indicator

------------------------------------------------------------------------

# Flight Card

Displays:

-   Airline
-   Flight number
-   Departure time
-   Terminal
-   Gate
-   Countdown
-   Status

Hidden automatically when no flight is scheduled.

------------------------------------------------------------------------

# Hotel Card

Displays:

-   Hotel name
-   Check-in/out
-   Navigate
-   Reception call
-   Nearby places

------------------------------------------------------------------------

# Weather Card

Displays:

-   Current temperature
-   Rain probability
-   Sunrise
-   Sunset
-   UV index

------------------------------------------------------------------------

# Budget Card

Displays:

-   Total budget
-   Spent
-   Remaining
-   Today's spend

------------------------------------------------------------------------

# Quick Actions

Buttons:

-   AI Concierge
-   Translator
-   Camera
-   CabHub
-   Restaurants
-   Emergency

------------------------------------------------------------------------

# Bottom Navigation

-   Home
-   Explore
-   AI
-   Expenses
-   Profile

------------------------------------------------------------------------

# Empty States

If no trip exists:

-   Welcome message
-   Create Trip button
-   Import Booking button

------------------------------------------------------------------------

# Offline Behaviour

Available offline:

-   Dashboard
-   Itinerary
-   Hotel
-   Flights
-   Budget
-   Cached weather
-   AI briefing (last generated)

------------------------------------------------------------------------

# Flutter Widgets

Suggested widgets:

-   CustomScrollView
-   SliverAppBar
-   Card
-   ListTile
-   PageView
-   FloatingActionButton
-   BottomNavigationBar

------------------------------------------------------------------------

# Acceptance Criteria

-   Dashboard loads in under 1 second.
-   Critical travel information visible without scrolling.
-   Offline dashboard fully functional.
-   AI briefing refreshes automatically when online.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ---------------------------
  1.0       Initial Home Dashboard UX
