# 001_API_OVERVIEW.md

# API Overview

Version: 1.0

Status: Backend API Specification

------------------------------------------------------------------------

# Purpose

This document defines the API philosophy and standards for TripMind. All
client applications (Android, iPhone and future Web) communicate with
the backend through versioned REST APIs.

------------------------------------------------------------------------

# Design Principles

-   REST-first
-   JSON only
-   Versioned endpoints
-   Stateless requests
-   Idempotent operations where applicable
-   Offline sync friendly

------------------------------------------------------------------------

# Base URL

Production

    https://api.tripmind.app/v1

Development

    http://localhost:8000/api/v1

------------------------------------------------------------------------

# Authentication

Supported:

-   JWT Access Token
-   Refresh Token
-   Google Sign-In
-   Apple Sign-In

Authorization Header

    Authorization: Bearer <access_token>

------------------------------------------------------------------------

# Standard Response

Success

``` json
{
  "success": true,
  "data": {},
  "meta": {}
}
```

Error

``` json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request."
  }
}
```

------------------------------------------------------------------------

# Resource Groups

-   Authentication
-   Users
-   Trips
-   Flights
-   Hotels
-   Itinerary
-   Restaurants
-   CabHub
-   Translator
-   Camera
-   Expenses
-   Family
-   Memories
-   Notifications
-   Weather
-   Destination Packs

------------------------------------------------------------------------

# HTTP Methods

-   GET
-   POST
-   PATCH
-   DELETE

------------------------------------------------------------------------

# Pagination

Query Parameters

-   page
-   page_size
-   sort
-   order

------------------------------------------------------------------------

# Security

-   HTTPS only
-   JWT validation
-   Rate limiting
-   Input validation
-   Audit logging

------------------------------------------------------------------------

# Versioning

Current API version:

v1

Future breaking changes will use:

v2

------------------------------------------------------------------------

# Acceptance Criteria

-   OpenAPI documentation generated.
-   Consistent response schema.
-   Authentication required for protected endpoints.
-   Mobile clients compatible across Android and iPhone.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ----------------------
  1.0       Initial API Overview
