# 016_PROFILE_ENGINE.md

# Profile Engine

Version: 1.0

Status: Module Specification

------------------------------------------------------------------------

# Purpose

The Profile Engine manages user identity, preferences, travel settings
and long-term personalization. It provides the foundation for Travel
DNA, AI recommendations and a consistent experience across devices.

------------------------------------------------------------------------

# Responsibilities

-   Manage user profile
-   Store travel preferences
-   Manage account settings
-   Configure privacy controls
-   Maintain connected accounts
-   Publish User Context to the Trip Context Engine

------------------------------------------------------------------------

# Business Rules

-   Every user has one profile.
-   Profile changes synchronize across devices.
-   Sensitive information is encrypted.
-   Users retain full control over exported and deleted data.

------------------------------------------------------------------------

# Core Profile

Fields

-   User ID
-   Name
-   Email
-   Phone (optional)
-   Profile photo
-   Preferred language
-   Preferred currency
-   Time zone
-   Home country

------------------------------------------------------------------------

# Travel Preferences

Store preferences for:

-   Window/Aisle seat
-   Vegetarian/Vegan
-   Indian cuisine
-   Hotel category
-   Budget range
-   Preferred taxi provider
-   Walking tolerance
-   Accessibility needs
-   Notification preferences

------------------------------------------------------------------------

# Connected Accounts

Supported integrations:

-   Google
-   Apple
-   Grab (future)
-   Klook (future)
-   Airline loyalty programs (future)
-   Hotel loyalty programs (future)

------------------------------------------------------------------------

# Privacy Controls

Users can manage:

-   AI learning
-   Travel DNA
-   Family sharing
-   Live location
-   Photo sharing
-   Analytics
-   Marketing preferences

------------------------------------------------------------------------

# Travel Statistics

Display:

-   Countries visited
-   Cities visited
-   Flights taken
-   Trips completed
-   Total travel days
-   Total distance travelled
-   Travel memories

------------------------------------------------------------------------

# APIs

-   GET /profile
-   PATCH /profile
-   GET /preferences
-   PATCH /preferences
-   POST /profile/export
-   DELETE /profile

------------------------------------------------------------------------

# Database Tables

-   users
-   user_preferences
-   connected_accounts
-   privacy_settings
-   travel_statistics

------------------------------------------------------------------------

# Events

Publishes:

-   ProfileUpdated
-   PreferencesChanged
-   PrivacyUpdated
-   AccountConnected

------------------------------------------------------------------------

# Offline Behaviour

Users can view and edit cached profile information offline. Updates
synchronize automatically when connectivity returns.

------------------------------------------------------------------------

# Dependencies

-   Trip Context Engine
-   Travel DNA Engine
-   Sync Engine
-   Security Engine
-   AI Concierge

------------------------------------------------------------------------

# Acceptance Criteria

-   Profile loads in under 1 second.
-   Preference changes synchronize across devices.
-   Privacy settings are enforced immediately.
-   Exported profile includes user-controlled data only.

------------------------------------------------------------------------

# Future Enhancements

-   Multiple traveler profiles
-   Corporate travel profiles
-   Frequent flyer dashboard
-   Health & accessibility profile
-   Travel achievements and badges

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ------------------------
  1.0       Initial Profile Engine
