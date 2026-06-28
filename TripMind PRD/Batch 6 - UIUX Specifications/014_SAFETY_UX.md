# 014_SAFETY_UX.md

# Safety UX Specification

Version: 1.0

Status: UI/UX Specification

------------------------------------------------------------------------

# Purpose

The Safety screen provides immediate access to emergency assistance,
medical resources, travel documents and destination-specific safety
guidance. It is designed to minimize the number of interactions required
during stressful situations.

------------------------------------------------------------------------

# UX Goals

-   One-tap access to emergency actions
-   Offline-first emergency information
-   Clear visual hierarchy
-   Fast access to travel documents
-   Support family emergency workflows

------------------------------------------------------------------------

# Screen Layout

    --------------------------------------------------
    Emergency Header
    --------------------------------------------------
    SOS Button
    --------------------------------------------------
    Emergency Contacts
    --------------------------------------------------
    Nearest Medical Facilities
    --------------------------------------------------
    Travel Documents
    --------------------------------------------------
    Safety Advisories
    --------------------------------------------------
    Emergency Phrasebook
    --------------------------------------------------
    Bottom Navigation
    --------------------------------------------------

------------------------------------------------------------------------

# Header

Displays:

-   Current location
-   Country
-   Current trip
-   Offline/Online status

------------------------------------------------------------------------

# SOS Section

Large primary button:

-   SOS

Actions:

-   Call local emergency number
-   Show nearest hospital
-   Share live location (optional)
-   Notify family members (optional)

Confirmation required before initiating external actions.

------------------------------------------------------------------------

# Emergency Contacts

Displays:

-   Police
-   Ambulance
-   Fire
-   Tourist Police
-   Embassy / Consulate
-   Hotel Reception

Tap to:

-   Call
-   Copy number
-   Navigate

------------------------------------------------------------------------

# Medical Assistance

Shows:

-   Nearby hospitals
-   Pharmacies
-   Clinics
-   24-hour medical facilities

Displays:

-   Distance
-   Opening status
-   Navigation shortcut

------------------------------------------------------------------------

# Travel Documents

Quick access to:

-   Passport
-   Visa
-   Insurance
-   Flight tickets
-   Hotel bookings

Protected using device authentication where supported.

------------------------------------------------------------------------

# Safety Advisories

Displays:

-   Weather alerts
-   Health advisories
-   Local safety notices
-   Transportation disruptions

Clearly indicates whether advisories are live or cached.

------------------------------------------------------------------------

# Emergency Phrasebook

Common translated phrases:

-   I need help.
-   Call an ambulance.
-   Where is the hospital?
-   I lost my passport.
-   I need a doctor.

Supports text display and text-to-speech when available.

------------------------------------------------------------------------

# Offline Behaviour

Available offline:

-   Emergency contacts
-   Downloaded documents
-   Phrasebook
-   Cached medical facilities
-   Destination safety guidance

------------------------------------------------------------------------

# Flutter Widgets

Suggested widgets:

-   SliverAppBar
-   FilledButton
-   Card
-   ListTile
-   ExpansionTile
-   GridView
-   BottomSheet

------------------------------------------------------------------------

# Acceptance Criteria

-   Safety screen opens in under 1 second.
-   SOS action reachable within one tap.
-   Emergency information accessible offline.
-   Travel documents protected by biometric/device authentication.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -------------------
  1.0       Initial Safety UX
