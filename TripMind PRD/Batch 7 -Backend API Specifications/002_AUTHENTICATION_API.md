# 002_AUTHENTICATION_API.md

# Authentication API

Version: 1.0

Status: Backend API Specification

------------------------------------------------------------------------

# Purpose

Define authentication and session management APIs for TripMind.

------------------------------------------------------------------------

# Endpoints

## POST /auth/register

Creates a new account.

Request

``` json
{
  "name":"John Doe",
  "email":"john@example.com",
  "password":"********"
}
```

Response

``` json
{
  "success": true,
  "data": {
    "user_id":"uuid",
    "access_token":"jwt",
    "refresh_token":"jwt"
  }
}
```

------------------------------------------------------------------------

## POST /auth/login

Authenticate with email and password.

------------------------------------------------------------------------

## POST /auth/google

Authenticate using Google Sign-In.

------------------------------------------------------------------------

## POST /auth/apple

Authenticate using Apple Sign-In.

------------------------------------------------------------------------

## POST /auth/refresh

Refresh an expired access token.

------------------------------------------------------------------------

## POST /auth/logout

Invalidate current session.

------------------------------------------------------------------------

## GET /auth/me

Return authenticated user profile.

------------------------------------------------------------------------

# Error Codes

-   INVALID_CREDENTIALS
-   ACCOUNT_EXISTS
-   ACCOUNT_NOT_FOUND
-   TOKEN_EXPIRED
-   TOKEN_INVALID
-   ACCOUNT_DISABLED

------------------------------------------------------------------------

# Security

-   HTTPS only
-   JWT access tokens
-   Refresh token rotation
-   Rate limiting
-   Password hashing (Argon2id/Bcrypt)

------------------------------------------------------------------------

# Acceptance Criteria

-   Login \<2 seconds
-   Token refresh without re-login
-   Multiple device sessions supported
-   OpenAPI documented

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ----------------------------
  1.0       Initial Authentication API
