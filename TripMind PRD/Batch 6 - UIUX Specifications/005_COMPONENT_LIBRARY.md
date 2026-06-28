# 005_COMPONENT_LIBRARY.md

# Component Library

Version: 1.0

Status: UI/UX Specification

------------------------------------------------------------------------

# Purpose

This document defines the reusable UI components that make up the
TripMind design system. Every screen should be composed from these
standardized widgets to ensure consistency, maintainability and faster
Flutter development.

------------------------------------------------------------------------

# Design Principles

-   Reusable over custom
-   Stateless where possible
-   Accessible by default
-   Responsive layouts
-   Theme aware (Light/Dark)
-   Platform adaptive

------------------------------------------------------------------------

# App Shell Components

## App Bar

Supports: - Title - Back button - Search - Notifications - Profile
avatar

## Bottom Navigation Bar

Tabs: - Home - Explore - AI Concierge - Expenses - Profile

## Floating AI Button

Persistent shortcut to AI Concierge.

------------------------------------------------------------------------

# Cards

## Flight Card

Displays: - Airline - Flight number - Departure time - Gate - Status

## Hotel Card

Displays: - Hotel name - Check-in/out - Distance - Quick actions

## Weather Card

Displays: - Temperature - Forecast - Sunrise - Sunset

## Budget Card

Displays: - Budget - Spent - Remaining - Daily average

## Restaurant Card

Displays: - Image - Cuisine - Rating - Distance - AI recommendation

## Attraction Card

Displays: - Image - Opening hours - Visit duration - Distance

## Memory Card

Displays: - Photo - Title - Date - Trip

## AI Insight Card

Displays: - Recommendation - Reason - Action button

------------------------------------------------------------------------

# Buttons

-   Primary Filled
-   Secondary Outlined
-   Text Button
-   Icon Button
-   Floating Action Button

------------------------------------------------------------------------

# Input Components

-   Search Bar
-   Text Field
-   Date Picker
-   Time Picker
-   Dropdown
-   Currency Field
-   Voice Input
-   Camera Input

------------------------------------------------------------------------

# Lists

-   Trip List
-   Expense List
-   Restaurant List
-   Attraction List
-   Notification List
-   Family Member List

------------------------------------------------------------------------

# Feedback Components

-   Snackbar
-   Toast
-   Loading Spinner
-   Skeleton Loader
-   Empty State
-   Error State
-   Offline Banner

------------------------------------------------------------------------

# Dialogs

-   Confirmation Dialog
-   Delete Dialog
-   Permission Dialog
-   Sync Conflict Dialog
-   AI Suggestion Dialog

------------------------------------------------------------------------

# Maps Components

-   Current Location Marker
-   Hotel Marker
-   Attraction Marker
-   Restaurant Marker
-   Route Overlay

------------------------------------------------------------------------

# Flutter Mapping

Each component should have:

-   Stateless implementation where possible
-   Theme support
-   Accessibility labels
-   Widget tests
-   Storybook/demo screen (future)

Suggested structure:

lib/shared/widgets/ - cards/ - buttons/ - inputs/ - dialogs/ - lists/ -
maps/ - feedback/

------------------------------------------------------------------------

# Acceptance Criteria

-   Components are reusable across all screens.
-   No duplicate UI implementations.
-   Theme switching requires no component changes.
-   Components meet accessibility guidelines.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ---------------------------
  1.0       Initial Component Library
