# 001_UI_UX_OVERVIEW.md

# UI/UX Overview

Version: 1.0

Status: UI/UX Specification

------------------------------------------------------------------------

# Purpose

This document defines the overall user experience philosophy, navigation
model and design language for TripMind. It serves as the foundation for
every Flutter screen.

------------------------------------------------------------------------

# Design Goals

-   Reduce travel stress
-   Minimize taps
-   Surface information before users ask
-   Support one-handed use
-   Work equally well on Android and iPhone
-   Offline-first

------------------------------------------------------------------------

# UX Principles

## Trip First

Every screen is tied to the active trip.

## Context First

Use Trip Context to avoid repetitive input.

## AI First

AI proactively recommends actions instead of waiting for commands.

## Family First

Shared trips and collaborative features are available throughout the
app.

------------------------------------------------------------------------

# Navigation Structure

    Splash
      ↓
    Authentication
      ↓
    Home Dashboard
      ├── Trips
      ├── AI Concierge
      ├── Explore
      ├── Expenses
      └── Profile

Bottom navigation contains:

-   Home
-   Explore
-   AI
-   Expenses
-   Profile

------------------------------------------------------------------------

# Home Dashboard Widgets

-   Greeting
-   Countdown to trip
-   Today's itinerary
-   Weather
-   Flight card
-   Hotel card
-   Budget summary
-   Quick actions
-   AI briefing

------------------------------------------------------------------------

# Design Language

-   Rounded cards
-   Large touch targets
-   Bottom sheets
-   Floating action button for AI
-   Consistent iconography
-   Material 3 with platform adaptations

------------------------------------------------------------------------

# Accessibility

-   Dynamic text sizing
-   Screen reader support
-   High contrast mode
-   Voice interactions
-   Large tap targets

------------------------------------------------------------------------

# Themes

-   Light
-   Dark
-   Auto (system)

Accent colors vary by destination pack in future releases.

------------------------------------------------------------------------

# Screen Categories

-   Authentication
-   Trip Management
-   Travel Dashboard
-   AI
-   Explore
-   Maps
-   Restaurants
-   CabHub
-   Translator
-   Camera
-   Expenses
-   Family
-   Memories
-   Safety
-   Settings

------------------------------------------------------------------------

# Flutter Guidelines

-   Responsive layouts
-   Reusable widgets
-   Riverpod state management
-   GoRouter navigation
-   Platform-specific animations where appropriate

------------------------------------------------------------------------

# Related Documents

-   Flutter Architecture
-   Product Principles
-   Design System (upcoming)

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ------------------------
  1.0       Initial UI/UX Overview
