# 004_BACKEND_ARCHITECTURE.md

# Backend Architecture

Version: 1.0

Status: Architecture

------------------------------------------------------------------------

# Purpose

Define the backend architecture, services and responsibilities for
TripMind.

------------------------------------------------------------------------

# Technology Stack

Framework: FastAPI

Language: Python 3.12+

Database: PostgreSQL

Cache: Redis

ORM: SQLAlchemy

Validation: Pydantic

Authentication: JWT + OAuth

Background Jobs: Celery (future) / FastAPI Background Tasks (MVP)

Storage: S3 Compatible Object Storage

------------------------------------------------------------------------

# Service Architecture

                     FastAPI

            API Gateway / Routers

       -------------------------------

       Auth Service

       User Service

       Trip Service

       Family Service

       Flight Service

       Hotel Service

       Itinerary Service

       Restaurant Service

       Taxi Service

       Translator Service

       Expense Service

       Camera Service

       AI Service

       Notification Service

       Sync Service

       Destination Pack Service

------------------------------------------------------------------------

# Responsibilities

## Authentication

-   Login
-   Apple Sign-In
-   Google Sign-In
-   Refresh Tokens
-   Session Management

------------------------------------------------------------------------

## Trip Service

-   Create Trip
-   Update Trip
-   Archive Trip
-   Share Trip

------------------------------------------------------------------------

## Family Service

-   Invite Members
-   Permissions
-   Shared Trips

------------------------------------------------------------------------

## Flight Service

-   Flight metadata
-   Live status provider integration
-   Boarding reminders

------------------------------------------------------------------------

## Hotel Service

-   Hotel enrichment
-   Nearby places
-   Check-in reminders

------------------------------------------------------------------------

## AI Service

Coordinates requests to:

-   Trip Context Engine
-   Recommendation Engine
-   Planner
-   Memory Engine

------------------------------------------------------------------------

## Notification Service

Supports:

-   Push Notifications
-   Scheduled reminders
-   Morning Briefing
-   Flight alerts

------------------------------------------------------------------------

# API Principles

-   REST-first
-   JSON only
-   Versioned endpoints (/v1)
-   Idempotent writes where possible
-   OpenAPI documentation

------------------------------------------------------------------------

# Security

-   JWT authentication
-   OAuth providers
-   HTTPS only
-   Input validation
-   Rate limiting
-   Audit logging

------------------------------------------------------------------------

# Scalability

Backend must support:

-   Horizontal scaling
-   Stateless API servers
-   Redis caching
-   Async endpoints
-   Future microservice extraction

------------------------------------------------------------------------

# Repository Structure

    backend/
      app/
        api/
        core/
        models/
        schemas/
        services/
        repositories/
        integrations/
        ai/
        workers/

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ------------------------------
  1.0       Initial Backend Architecture
