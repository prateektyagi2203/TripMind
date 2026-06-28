# 004_USE_CASES.md

# Use Cases

Version: 1.0

Status: Product

------------------------------------------------------------------------

# Purpose

This document defines the primary functional use cases for TripMind.
Each use case will later map to UI screens, APIs, database entities and
AI workflows.

------------------------------------------------------------------------

# UC-001 Create a Trip

## Actor

Traveler

## Goal

Create a new trip with destination, dates and travelers.

## Preconditions

Authenticated user.

## Main Flow

1.  Tap "Create Trip"
2.  Enter destination
3.  Enter dates
4.  Add family members
5.  Save trip

## Success

Trip dashboard created.

------------------------------------------------------------------------

# UC-002 Import Flight

## Goal

Import flight using:

-   Email
-   Boarding pass
-   Manual entry

### Outcome

Flight timeline updated.

Notifications scheduled.

------------------------------------------------------------------------

# UC-003 Import Hotel

User imports hotel booking.

TripMind extracts:

-   Hotel name
-   Address
-   Check-in
-   Check-out

AI enriches:

-   Nearby restaurants
-   Beaches
-   Pharmacy
-   ATM
-   Hospital

------------------------------------------------------------------------

# UC-004 Download Destination Pack

User downloads Thailand Pack.

Offline content becomes available.

Includes:

-   Attractions
-   Restaurants
-   Emergency contacts
-   Suggested itineraries
-   Common phrases

------------------------------------------------------------------------

# UC-005 Plan Daily Itinerary

User creates itinerary manually or asks AI.

AI suggests:

-   Travel order
-   Taxi
-   Lunch
-   Weather adjustments

------------------------------------------------------------------------

# UC-006 Compare Taxi Providers

Input:

Current location

Destination

Output:

-   Grab
-   Bolt
-   inDrive
-   Hotel taxi

AI recommends best option.

------------------------------------------------------------------------

# UC-007 Translate

Supports:

-   Camera OCR
-   Voice
-   Typed text
-   Conversation mode

Offline supported after language pack download.

------------------------------------------------------------------------

# UC-008 Capture Expense

Expense sources:

-   SMS
-   Email
-   Receipt
-   Ride providers

Expense automatically categorized.

------------------------------------------------------------------------

# UC-009 Smart Camera

User photographs:

-   Attraction
-   Receipt
-   Menu
-   Boarding pass

TripMind processes and stores structured information.

------------------------------------------------------------------------

# UC-010 Family Collaboration

Members can:

-   Join trip
-   View itinerary
-   Add expenses
-   Upload photos
-   Receive notifications

Permissions configurable.

------------------------------------------------------------------------

# UC-011 Daily AI Briefing

Every morning TripMind generates:

-   Weather
-   Today's itinerary
-   Taxi recommendation
-   Budget status
-   Flight reminders
-   Suggested restaurants

------------------------------------------------------------------------

# UC-012 Emergency Mode

Displays:

-   Nearest hospital
-   Embassy
-   Emergency contacts
-   Offline map
-   Hotel contact

Works offline where practical.

------------------------------------------------------------------------

# UC-013 End Trip

TripMind generates:

-   Expense report
-   Travel journal
-   Smart albums
-   Timeline
-   Statistics

Trip archived.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -------------------
  1.0       Initial Use Cases
