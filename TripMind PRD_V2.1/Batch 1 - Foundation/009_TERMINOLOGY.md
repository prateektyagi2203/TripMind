# 009_TERMINOLOGY.md

# TripMind Terminology

Version: 1.0

Status: Foundation

------------------------------------------------------------------------

# Purpose

This glossary standardizes terminology across product, engineering, AI,
UX and documentation.

------------------------------------------------------------------------

# Core Terms

## Trip

The primary business object. Every flight, hotel, expense, photo,
booking, document and itinerary belongs to a Trip.

------------------------------------------------------------------------

## Trip Context

A live object maintained by the TripMind Brain containing current
information about the traveler and journey.

Includes: - User - Family - Destination - Flights - Hotel - Weather -
Budget - Current Location - Current Activity - Preferences - Destination
Pack

------------------------------------------------------------------------

## TripMind Brain

The central intelligence layer responsible for reasoning,
recommendations and context management.

------------------------------------------------------------------------

## Destination Pack

A downloadable offline content package for a country or region.

Typical contents: - Attractions - Restaurants - Hospitals - Emergency
contacts - Common phrases - Suggested itineraries - Offline metadata

------------------------------------------------------------------------

## Engine

A self-contained business capability.

Examples: - Flight Engine - Hotel Engine - Taxi Engine - Expense
Engine - Translator Engine - Camera Engine

------------------------------------------------------------------------

## Module

A functional area composed of one or more engines and user interfaces.

------------------------------------------------------------------------

## Family

A collaborative group sharing a trip.

Each member has configurable permissions.

------------------------------------------------------------------------

## Journey

The timeline of activities within a trip.

------------------------------------------------------------------------

## Memory

A searchable travel artifact generated from photos, videos, locations,
expenses and journals.

------------------------------------------------------------------------

## AI Concierge

The conversational assistant that uses Trip Context to proactively
assist the traveler.

------------------------------------------------------------------------

## CabHub

TripMind's ride comparison capability integrating providers such as
Grab, Bolt and inDrive.

------------------------------------------------------------------------

## Offline First

Design principle requiring essential travel features to function without
network connectivity whenever practical.

------------------------------------------------------------------------

## Smart Expense

Automatically detected expense from SMS, email, receipt OCR or
integrated providers.

------------------------------------------------------------------------

## Camera Intelligence

AI features that recognize attractions, scan documents, organize photos
and generate memories.

------------------------------------------------------------------------

## Plugin

An installable capability such as Destination Packs or future provider
integrations.

------------------------------------------------------------------------

# Naming Conventions

Business objects: - Trip - Flight - Hotel - Activity - Booking -
Expense - Memory

Technical objects: - Engine - Service - Repository - Provider -
Adapter - Plugin

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ---------------------
  1.0       Initial Terminology
