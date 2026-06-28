# 013_DESTINATION_PACKS_API.md

# Destination Packs API

Version: 1.0

Status: Backend API Specification

------------------------------------------------------------------------

# Purpose

Defines REST endpoints for downloading, updating and managing offline
Destination Packs.

------------------------------------------------------------------------

# Resource

`/destination-packs`

------------------------------------------------------------------------

## GET /destination-packs

Returns all available destination packs.

### Query Parameters

-   country
-   region
-   version
-   language

------------------------------------------------------------------------

## GET /destination-packs/installed

Returns packs installed for the authenticated user.

------------------------------------------------------------------------

## POST /destination-packs/download

Downloads a destination pack.

### Request

``` json
{
  "country":"Thailand",
  "language":"en"
}
```

------------------------------------------------------------------------

## GET /destination-packs/{packId}

Returns pack metadata.

Includes:

-   Version
-   Size
-   Supported languages
-   Last updated
-   Content summary

------------------------------------------------------------------------

## GET /destination-packs/{packId}/updates

Checks whether a newer version is available.

------------------------------------------------------------------------

## DELETE /destination-packs/{packId}

Removes an installed destination pack.

------------------------------------------------------------------------

## POST /destination-packs/sync

Synchronizes installed packs across user devices.

------------------------------------------------------------------------

# Response Schema

``` json
{
  "success": true,
  "data": {
    "pack_id":"uuid",
    "status":"downloaded",
    "version":"1.2.0"
  }
}
```

------------------------------------------------------------------------

# Validation

-   Country required.
-   Pack version must exist.
-   Downloads require authentication.
-   Installed pack integrity verified before activation.

------------------------------------------------------------------------

# Events

-   DestinationPackDownloaded
-   DestinationPackUpdated
-   DestinationPackRemoved
-   DestinationPackSynced

------------------------------------------------------------------------

# Security

-   JWT authentication required.
-   Pack signatures verified.
-   HTTPS downloads only.

------------------------------------------------------------------------

# Acceptance Criteria

-   Pack metadata loads in under 1 second.
-   Download resumes after interruption.
-   Updates preserve user data.
-   OpenAPI documentation generated.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -------------------------------
  1.0       Initial Destination Packs API
