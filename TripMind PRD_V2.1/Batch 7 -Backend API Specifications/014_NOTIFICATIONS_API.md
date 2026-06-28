# 014_NOTIFICATIONS_API.md

# Notifications API

Version: 1.0

Status: Backend API Specification

------------------------------------------------------------------------

# Purpose

Defines REST endpoints for scheduling, delivering and managing
notifications across TripMind.

------------------------------------------------------------------------

# Resource

`/notifications`

------------------------------------------------------------------------

## GET /notifications

Returns notifications for the authenticated user.

### Query Parameters

-   unread
-   category
-   page
-   page_size

------------------------------------------------------------------------

## POST /notifications/schedule

Creates a scheduled notification.

### Request

``` json
{
  "trip_id":"uuid",
  "category":"flight",
  "title":"Leave for the airport",
  "scheduled_at":"2026-12-02T05:30:00Z"
}
```

------------------------------------------------------------------------

## GET /notifications/{notificationId}

Returns notification details.

------------------------------------------------------------------------

## PATCH /notifications/{notificationId}/read

Marks a notification as read.

------------------------------------------------------------------------

## DELETE /notifications/{notificationId}

Deletes a notification.

------------------------------------------------------------------------

## GET /notifications/preferences

Returns notification preferences.

------------------------------------------------------------------------

## PATCH /notifications/preferences

Updates categories, quiet hours and delivery preferences.

------------------------------------------------------------------------

# Categories

-   Flight
-   Hotel
-   Itinerary
-   Weather
-   Budget
-   Family
-   AI Concierge
-   Safety

------------------------------------------------------------------------

# Response Schema

``` json
{
  "success":true,
  "data":{
    "notification_id":"uuid",
    "status":"scheduled"
  }
}
```

------------------------------------------------------------------------

# Validation

-   Scheduled time required.
-   Category must be valid.
-   Quiet hours respected except critical alerts.

------------------------------------------------------------------------

# Events

-   NotificationScheduled
-   NotificationDelivered
-   NotificationRead
-   NotificationDeleted

------------------------------------------------------------------------

# Security

-   JWT authentication required.
-   Notifications scoped to authenticated user.
-   Critical alerts audited.

------------------------------------------------------------------------

# Acceptance Criteria

-   Local reminders synchronize across devices.
-   Preferences applied immediately.
-   Duplicate notifications suppressed.
-   OpenAPI documentation generated.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ---------------------------
  1.0       Initial Notifications API
