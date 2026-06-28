# 012_FAMILY_UX.md

# Family UX Specification

Version: 1.0

Status: UI/UX Specification

------------------------------------------------------------------------

# Purpose

The Family screen enables seamless collaboration between family members
traveling together. It provides shared trip information, permissions,
expenses, locations (optional), memories and communication tools while
respecting privacy controls.

------------------------------------------------------------------------

# UX Goals

-   Simple family management
-   Clear ownership and permissions
-   Shared itinerary and expenses
-   Minimal setup
-   Privacy-first

------------------------------------------------------------------------

# Screen Layout

    --------------------------------------------------
    Trip Header
    --------------------------------------------------
    Family Overview
    --------------------------------------------------
    Member Cards
    --------------------------------------------------
    Shared Itinerary
    --------------------------------------------------
    Shared Expenses
    --------------------------------------------------
    Shared Memories
    --------------------------------------------------
    Invite Member
    --------------------------------------------------
    Bottom Navigation
    --------------------------------------------------

------------------------------------------------------------------------

# Header

Displays:

-   Active trip
-   Number of members
-   Trip owner
-   Sync status

------------------------------------------------------------------------

# Family Overview

Shows:

-   Adults
-   Children
-   Pending invitations
-   Shared budget
-   Shared documents

------------------------------------------------------------------------

# Member Card

Each member displays:

-   Avatar
-   Name
-   Role
-   Online/Offline (optional)
-   Current activity
-   Last sync

Actions:

-   View profile
-   Change permissions (Owner)
-   Remove from trip (Owner)

------------------------------------------------------------------------

# Shared Itinerary

Displays:

-   Today's plan
-   Member assignments
-   Activity status
-   Recent updates

Users can:

-   Add activity
-   Comment (future)
-   Reorder activities (with permission)

------------------------------------------------------------------------

# Shared Expenses

Displays:

-   Total shared spend
-   Paid by
-   Outstanding balances
-   Settlement suggestions

Quick actions:

-   Add shared expense
-   Split bill
-   Mark settled

------------------------------------------------------------------------

# Shared Memories

Shows:

-   Recent photos
-   Journals
-   Albums
-   Highlights

Users choose whether uploaded media is:

-   Private
-   Shared with trip
-   Shared with selected members

------------------------------------------------------------------------

# Invitations

Methods:

-   Email
-   QR Code
-   Share Link

Pending invitations are displayed with status.

------------------------------------------------------------------------

# Privacy Controls

Per member:

-   Live location
-   Photo sharing
-   Expense visibility
-   Document access
-   Notification preferences

------------------------------------------------------------------------

# Offline Behaviour

Available offline:

-   Member list
-   Shared itinerary
-   Shared expenses
-   Shared memories

Changes synchronize automatically when online.

------------------------------------------------------------------------

# Flutter Widgets

Suggested widgets:

-   SliverAppBar
-   Card
-   ExpansionTile
-   ListTile
-   AvatarGroup
-   TabBar
-   FloatingActionButton

------------------------------------------------------------------------

# Acceptance Criteria

-   Family dashboard loads in under 1 second.
-   Invitations complete in under 2 minutes.
-   Shared updates synchronize correctly.
-   Privacy settings are respected across devices.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -------------------
  1.0       Initial Family UX
