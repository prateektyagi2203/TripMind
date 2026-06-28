# TripMind Product Specification (Master PRD)

## Batch 15 -- Version 5.0

------------------------------------------------------------------------

# Part V --- Flight Management

## Purpose

The Flight module centralizes all flight-related information before,
during, and after a trip. It enables users to organize bookings, monitor
schedules, receive proactive alerts, and integrate flights into their
itinerary.

------------------------------------------------------------------------

# User Stories

-   As a traveller, I want to store all my flight bookings in one place.
-   As a traveller, I want TripMind to automatically detect delays and
    gate changes.
-   As a family traveller, I want to manage flights for all members
    together.
-   As a business traveller, I want quick access to boarding passes and
    loyalty numbers.

------------------------------------------------------------------------

# Flight Sources

### Manual Entry

Users can manually enter: - Airline - Flight number - Departure
airport - Arrival airport - Departure date & time - Arrival date &
time - Booking reference

### Future Enhancements

-   Email import
-   PDF parsing
-   Airline API sync
-   Calendar import

------------------------------------------------------------------------

# Flight Timeline

``` mermaid
stateDiagram-v2
[*] --> Booked
Booked --> Confirmed
Confirmed --> CheckInOpen
CheckInOpen --> CheckedIn
CheckedIn --> Boarding
Boarding --> Departed
Departed --> Arrived
Arrived --> Completed
```

------------------------------------------------------------------------

# Flight Details Screen

Display:

-   Airline
-   Flight number
-   PNR
-   Terminal
-   Gate
-   Seat
-   Cabin class
-   Baggage allowance
-   Boarding time
-   Departure countdown
-   Live flight status

Actions:

-   Edit booking
-   Share booking
-   Download boarding pass
-   Add to calendar
-   Navigate to airport

------------------------------------------------------------------------

# Smart Features

The system should:

-   Detect overlapping flights
-   Warn about tight layovers
-   Highlight overnight flights
-   Calculate airport arrival time
-   Estimate check-in opening
-   Suggest departure reminders

------------------------------------------------------------------------

# Business Rules

-   Flight departure must precede arrival.
-   Time zones are stored independently.
-   Flights are linked to one trip.
-   Multiple flights may exist within one trip.
-   Users may reorder flights for multi-city journeys.

------------------------------------------------------------------------

# Notifications

Examples:

-   Check-in opens
-   Boarding begins
-   Gate changed
-   Delay detected
-   Flight cancelled
-   Baggage belt assigned (future)

------------------------------------------------------------------------

# Edge Cases

-   Flight crosses International Date Line
-   Airport terminal change
-   Flight cancelled
-   Missed connection
-   Duplicate flight import
-   Unknown gate
-   Airline unavailable

------------------------------------------------------------------------

# Analytics Events

-   flight_added
-   flight_updated
-   flight_deleted
-   boarding_pass_uploaded
-   flight_delay_detected
-   checkin_completed

------------------------------------------------------------------------

# Acceptance Criteria

-   Users can manually add a flight in under two minutes.
-   Flight timeline updates correctly.
-   Notifications respect user preferences.
-   Flights appear automatically in itinerary views.

------------------------------------------------------------------------

# Future Enhancements

-   Live tracking
-   Seat map visualization
-   Lounge eligibility
-   Airline loyalty integration
-   Carbon footprint estimation
