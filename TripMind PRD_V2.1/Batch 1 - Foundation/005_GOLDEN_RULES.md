# 005_GOLDEN_RULES.md

# TripMind Golden Rules

Version: 1.0

Status: Foundation

------------------------------------------------------------------------

# Purpose

The Golden Rules are non-negotiable product and engineering rules. Every
feature, screen, API and AI workflow must comply with these principles.

------------------------------------------------------------------------

# Rule 1 --- Never Ask Twice

TripMind must never ask the user for information it already knows or can
infer.

Examples: - Hotel - Flight - Current trip - Family members - Dietary
preferences - Preferred currency

------------------------------------------------------------------------

# Rule 2 --- The Trip Is the Center

Everything belongs to a Trip.

Examples: - Flights - Hotels - Expenses - Photos - Translator history -
Taxi rides - Restaurant visits - Documents

------------------------------------------------------------------------

# Rule 3 --- AI Must Add Value

AI should: - Anticipate - Recommend - Explain - Simplify

AI should never exist just because AI is available.

------------------------------------------------------------------------

# Rule 4 --- Offline Is a Requirement

Critical features should continue functioning without internet.

Minimum offline support: - Itinerary - Flights - Hotels - Destination
Pack - Translation - Emergency - Documents - Expenses

------------------------------------------------------------------------

# Rule 5 --- Family First

Family collaboration is a core capability.

Support: - Shared itinerary - Shared bookings - Shared expenses - Shared
memories - Optional live location

------------------------------------------------------------------------

# Rule 6 --- Privacy First

Sensitive information remains under user control.

Requirements: - Explicit permissions - Local processing where
practical - Encryption - Granular sharing - Easy data deletion

------------------------------------------------------------------------

# Rule 7 --- Integrate Instead of Rebuild

TripMind should orchestrate trusted services instead of replacing them.

Examples: - Google Maps - Grab - Bolt - inDrive - Klook

------------------------------------------------------------------------

# Rule 8 --- Explain Recommendations

Every recommendation should include a concise reason.

Example: "Leave 20 minutes earlier because traffic is increasing."

------------------------------------------------------------------------

# Rule 9 --- Capture Once, Reuse Everywhere

Information captured once should automatically populate all relevant
modules.

Example: A scanned boarding pass updates: - Flight - Timeline -
Notifications - Airport reminders

------------------------------------------------------------------------

# Rule 10 --- Build for the Next Country

Every design decision must support future destination packs without
architectural changes.

------------------------------------------------------------------------

# Product Acceptance Checklist

Every feature must satisfy:

-   Reduces user effort
-   Uses Trip Context
-   Works offline where practical
-   Supports Android and iPhone
-   Respects privacy
-   Fits into Trip-centric architecture
-   Can scale internationally

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ----------------------
  1.0       Initial Golden Rules
