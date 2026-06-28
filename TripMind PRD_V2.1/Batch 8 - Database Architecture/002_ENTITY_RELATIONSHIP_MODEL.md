# 002_ENTITY_RELATIONSHIP_MODEL.md

# Entity Relationship Model

Version: 1.0

Status: Database Specification

------------------------------------------------------------------------

# Purpose

Defines the logical entity relationships used by TripMind. This document
acts as the canonical data model before physical PostgreSQL
implementation.

------------------------------------------------------------------------

# Core Entities

-   User
-   Trip
-   FamilyMember
-   Flight
-   Hotel
-   ItineraryItem
-   Expense
-   RestaurantVisit
-   Memory
-   Notification
-   DestinationPack
-   TravelDocument

------------------------------------------------------------------------

# High-Level ER Diagram

``` text
User
 ├──< Trip
 │      ├──< Flight
 │      ├──< Hotel
 │      ├──< ItineraryItem
 │      ├──< Expense
 │      ├──< Memory
 │      ├──< Notification
 │      ├──< RestaurantVisit
 │      ├──< TravelDocument
 │      └──< FamilyMember
 │
 └──< DestinationPack
```

------------------------------------------------------------------------

# Relationships

## User → Trip

-   One User owns many Trips.
-   One Trip has exactly one Owner.

Relationship:

1 : N

------------------------------------------------------------------------

## Trip → FamilyMember

-   One Trip contains many members.
-   One User may participate in many Trips.

Implemented through a junction table.

Relationship:

N : N

------------------------------------------------------------------------

## Trip → Flight

Relationship:

1 : N

------------------------------------------------------------------------

## Trip → Hotel

Relationship:

1 : N

------------------------------------------------------------------------

## Trip → ItineraryItem

Relationship:

1 : N

------------------------------------------------------------------------

## Trip → Expense

Relationship:

1 : N

------------------------------------------------------------------------

## Trip → Memory

Relationship:

1 : N

------------------------------------------------------------------------

## Expense → Receipt

Relationship:

1 : 1

Optional.

------------------------------------------------------------------------

## Hotel → Nearby Places Cache

Relationship:

1 : N

------------------------------------------------------------------------

## Destination Pack

Referenced by:

-   Trips
-   Offline cache
-   Recommendations

------------------------------------------------------------------------

# Cardinality Rules

-   Every Flight belongs to exactly one Trip.
-   Every Expense belongs to one Trip.
-   A Memory cannot exist without a Trip.
-   Notifications may reference multiple entity types through metadata.

------------------------------------------------------------------------

# Referential Integrity

-   Foreign keys enforced.
-   Cascading deletes avoided.
-   Soft deletes preferred.
-   Audit timestamps mandatory.

------------------------------------------------------------------------

# Future Entities

-   Loyalty Programs
-   Visa Applications
-   Insurance Policies
-   Shopping Orders
-   Rewards
-   AI Conversations

------------------------------------------------------------------------

# Acceptance Criteria

-   No orphan records.
-   All relationships enforce integrity.
-   Junction tables used for many-to-many relations.
-   Compatible with PostgreSQL and SQLite.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -----------------------------------
  1.0       Initial Entity Relationship Model
