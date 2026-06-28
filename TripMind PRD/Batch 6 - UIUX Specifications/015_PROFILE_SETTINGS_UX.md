# 015_PROFILE_SETTINGS_UX.md

# Profile & Settings UX Specification

Version: 1.0

Status: UI/UX Specification

------------------------------------------------------------------------

# Purpose

The Profile & Settings screen provides access to the user's account,
travel preferences, privacy controls, destination packs, connected
services and application settings.

------------------------------------------------------------------------

# UX Goals

-   Simple account management
-   Clear privacy controls
-   Easy customization
-   Quick access to downloaded destination packs
-   Cross-platform consistency

------------------------------------------------------------------------

# Screen Layout

    --------------------------------------------------
    Profile Header
    --------------------------------------------------
    Travel Statistics
    --------------------------------------------------
    Account
    --------------------------------------------------
    Travel Preferences
    --------------------------------------------------
    Connected Accounts
    --------------------------------------------------
    Destination Packs
    --------------------------------------------------
    Privacy & Security
    --------------------------------------------------
    Application Settings
    --------------------------------------------------
    About
    --------------------------------------------------
    Bottom Navigation
    --------------------------------------------------

------------------------------------------------------------------------

# Profile Header

Displays:

-   Profile photo
-   Name
-   Email
-   Membership level (future)
-   Countries visited
-   Trips completed

Quick actions:

-   Edit profile
-   Change photo
-   Export profile

------------------------------------------------------------------------

# Travel Statistics

Shows:

-   Countries visited
-   Cities visited
-   Flights taken
-   Travel days
-   Total distance
-   Favorite destination

------------------------------------------------------------------------

# Travel Preferences

Configure:

-   Preferred language
-   Preferred currency
-   Seat preference
-   Hotel category
-   Budget level
-   Dietary preferences
-   Walking tolerance
-   Accessibility requirements

------------------------------------------------------------------------

# Connected Accounts

Manage integrations:

-   Google
-   Apple
-   Airline loyalty programs (future)
-   Hotel loyalty programs (future)
-   Grab (future)
-   Klook (future)

------------------------------------------------------------------------

# Destination Packs

Displays:

-   Installed packs
-   Available updates
-   Storage usage
-   Download progress

Actions:

-   Download
-   Update
-   Delete

------------------------------------------------------------------------

# Privacy & Security

Controls:

-   AI learning
-   Travel DNA
-   Family sharing
-   Live location
-   Analytics
-   Notifications
-   Biometric lock
-   Data export
-   Delete account

------------------------------------------------------------------------

# Application Settings

Options:

-   Theme
-   Font size
-   Offline mode
-   Sync preferences
-   Cache management
-   Language
-   Units
-   About

------------------------------------------------------------------------

# Offline Behaviour

Users can:

-   View profile
-   Edit preferences
-   Browse installed destination packs
-   Change local settings

Cloud synchronization resumes automatically.

------------------------------------------------------------------------

# Flutter Widgets

Suggested widgets:

-   SliverAppBar
-   CircleAvatar
-   ListTile
-   SwitchListTile
-   ExpansionTile
-   Card
-   LinearProgressIndicator

------------------------------------------------------------------------

# Acceptance Criteria

-   Profile loads in under 1 second.
-   Settings persist across devices after sync.
-   Privacy changes take effect immediately.
-   Destination packs managed from one screen.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -------------------------------
  1.0       Initial Profile & Settings UX
