# 012_FAMILY_API.md

# Family API

Version: 1.0

Status: Backend API Specification

------------------------------------------------------------------------

# Purpose

Defines REST endpoints for managing family members, trip sharing,
permissions and shared travel data.

------------------------------------------------------------------------

# Resource

`/family`

------------------------------------------------------------------------

## GET /family/members

Returns members for a trip.

### Query Parameters

-   trip_id

------------------------------------------------------------------------

## POST /family/invite

Invites one or more members.

### Request

``` json
{
  "trip_id":"uuid",
  "emails":[
    "wife@example.com",
    "child@example.com"
  ]
}
```

------------------------------------------------------------------------

## GET /family/member/{memberId}

Returns member details and permissions.

------------------------------------------------------------------------

## PATCH /family/member/{memberId}

Updates:

-   Role
-   Permissions
-   Sharing preferences

------------------------------------------------------------------------

## DELETE /family/member/{memberId}

Removes a member from the trip.

------------------------------------------------------------------------

## POST /family/location

Updates optional live location.

### Request

``` json
{
  "trip_id":"uuid",
  "latitude":7.8804,
  "longitude":98.3923
}
```

------------------------------------------------------------------------

## GET /family/activity

Returns recent family activity:

-   Joined members
-   Shared expenses
-   Itinerary updates
-   Memory uploads

------------------------------------------------------------------------

# Response Schema

``` json
{
  "success": true,
  "data": {
    "member_id":"uuid",
    "role":"adult"
  }
}
```

------------------------------------------------------------------------

# Validation

-   Only trip owner may invite or remove members.
-   Duplicate invitations rejected.
-   Location sharing is opt-in.
-   Permission changes require owner role.

------------------------------------------------------------------------

# Events

-   FamilyMemberInvited
-   FamilyMemberJoined
-   FamilyMemberRemoved
-   PermissionsUpdated
-   LocationUpdated

------------------------------------------------------------------------

# Security

-   JWT authentication required.
-   Role-based authorization enforced.
-   Shared data scoped to trip membership.

------------------------------------------------------------------------

# Acceptance Criteria

-   Invitations processed in under 2 seconds.
-   Permission updates propagate after sync.
-   Optional location sharing supported.
-   OpenAPI documentation generated.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- --------------------
  1.0       Initial Family API
