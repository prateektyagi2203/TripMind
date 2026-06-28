# 006_AI_AGENT_ORCHESTRATOR.md

# AI Agent Orchestrator

Version: 1.0

Status: AI Architecture

------------------------------------------------------------------------

# Purpose

The AI Agent Orchestrator coordinates all specialized AI engines inside
TripMind. Instead of one monolithic assistant, TripMind delegates
requests to domain-specific agents while maintaining a single
conversational experience.

------------------------------------------------------------------------

# Goals

-   Route requests to the correct agent
-   Share Trip Context across agents
-   Prevent duplicated reasoning
-   Support future agents without changing the core architecture

------------------------------------------------------------------------

# Core Agents

## Concierge Agent

General travel conversation and planning.

## Trip Planner Agent

Creates and optimizes itineraries.

## Flight Agent

Flight status, airport guidance and reminders.

## Hotel Agent

Hotel information, nearby services and check-in assistance.

## Restaurant Agent

Cuisine recommendations, dietary filtering and reservations (future).

## CabHub Agent

Compares Grab, Bolt, inDrive and hotel taxis.

## Translator Agent

OCR, speech and conversation translation.

## Expense Agent

Budget analysis and expense categorization.

## Camera Agent

Photo understanding, OCR and attraction recognition.

## Memory Agent

Travel journals, albums and timelines.

------------------------------------------------------------------------

# Request Flow

    User Request
          │
    AI Concierge
          │
    Agent Orchestrator
          │
    Select Agent(s)
          │
    Retrieve Trip Context
          │
    Execute Tools
          │
    Merge Responses
          │
    Return Final Answer

------------------------------------------------------------------------

# Routing Rules

Examples:

-   "Book a taxi" → CabHub Agent
-   "Translate this menu" → Translator Agent
-   "What have we spent?" → Expense Agent
-   "Rearrange tomorrow" → Trip Planner Agent

Complex requests may invoke multiple agents.

------------------------------------------------------------------------

# Shared Context

Every agent receives:

-   User Context
-   Trip Context
-   Family Context
-   Location
-   Weather
-   Budget
-   Destination Pack
-   Travel DNA

------------------------------------------------------------------------

# Safety Rules

-   Never fabricate bookings or reservations.
-   Clearly distinguish facts from recommendations.
-   Require confirmation before destructive actions.
-   Respect privacy permissions.

------------------------------------------------------------------------

# Offline Behaviour

When offline:

-   Use cached Trip Context
-   Use Destination Packs
-   Disable cloud-only capabilities gracefully
-   Explain unavailable live data

------------------------------------------------------------------------

# Future Agents

-   Shopping Agent
-   Visa Agent
-   Insurance Agent
-   Sustainability Agent
-   Health & Wellness Agent

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -------------------------------
  1.0       Initial AI Agent Orchestrator
