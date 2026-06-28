# 002_AUTHENTICATION_SECURITY

## Purpose

Authentication and session security standards.

### Identity

-   Email/password
-   Google OAuth
-   Apple Sign In

### Tokens

-   JWT access token
-   Refresh token rotation
-   Token expiration
-   Device-bound sessions

### Passwords

-   Argon2id preferred
-   bcrypt fallback
-   Password reset tokens
-   Email verification

### Session Security

-   Logout all devices
-   Session revocation
-   Idle timeout
-   Refresh token blacklist

### Acceptance

-   MFA-ready architecture
-   JWT validation on every protected API
