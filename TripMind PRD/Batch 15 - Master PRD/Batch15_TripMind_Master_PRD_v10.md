# TripMind Product Specification (Master PRD)

## Batch 15 -- Version 10.0

------------------------------------------------------------------------

# Part X --- Family Management & Collaboration

## Purpose

Family Management enables a single TripMind account to organize and
coordinate travel for multiple travellers while preserving privacy,
role-based permissions and personalized AI recommendations.

------------------------------------------------------------------------

## Product Scope

### MVP

-   Create family
-   Invite members
-   Assign traveller roles
-   Shared trips
-   Shared documents (role-based)

### Phase 2

-   Collaborative itinerary editing
-   Shared expense settlement
-   Live activity updates

### Future

-   Family calendar sync
-   Child travel profiles
-   Emergency contact network

------------------------------------------------------------------------

## Personas

-   Parent managing children's travel
-   Couple planning vacations
-   Friends travelling together
-   Corporate travel coordinator

------------------------------------------------------------------------

## Functional Requirements

### FR-001 -- Create Family

Owner can: - Create a family workspace - Name the family - Upload an
optional photo

### FR-002 -- Invite Members

Invitation methods: - Email - QR code (future) - Shareable link (future)

Invitation states: Pending → Accepted → Active Pending → Expired Pending
→ Revoked

### FR-003 -- Traveller Profiles

Each traveller profile stores: - Full name - Date of birth -
Relationship - Passport reference - Dietary preferences - Accessibility
requirements - Emergency contact

### FR-004 -- Role Management

Supported roles:

  Role     Permissions
  -------- ------------------------
  Owner    Full control
  Admin    Manage trips & members
  Editor   Edit shared content
  Viewer   Read-only

### FR-005 -- Shared Trips

Users may: - Invite family members - Assign travellers to bookings -
Share itineraries - Share documents - Share expenses

------------------------------------------------------------------------

## Collaboration Workflow

``` mermaid
flowchart LR
CreateFamily-->InviteMember
InviteMember-->AcceptInvite
AcceptInvite-->AssignTrip
AssignTrip-->SharedPlanning
SharedPlanning-->Travel
Travel-->Archive
```

------------------------------------------------------------------------

## Business Rules

BR-001: Every family has exactly one Owner.

BR-002: Children cannot be Owners.

BR-003: Removing a member never deletes historical trip data.

BR-004: Personal passports remain visible only to authorized users.

BR-005: AI recommendations consider traveller ages and accessibility
requirements.

------------------------------------------------------------------------

## Permission Matrix

  Action            Owner   Admin   Editor   Viewer
  ---------------- ------- ------- -------- --------
  Invite member       ✓       ✓       ✗        ✗
  Remove member       ✓       ✓       ✗        ✗
  Edit itinerary      ✓       ✓       ✓        ✗
  View itinerary      ✓       ✓       ✓        ✓
  Manage roles        ✓       ✗       ✗        ✗

------------------------------------------------------------------------

## UI Specifications

### Family Dashboard

Widgets: - Upcoming trips - Members - Shared expenses - Visa readiness -
Passport status - Notifications

### Member Profile

Displays: - Personal details - Assigned trips - Documents -
Preferences - Emergency information

------------------------------------------------------------------------

## Offline Behaviour

Available: - View family members - View shared trips - Edit draft notes

Deferred: - Invitations - Permission updates - Cloud synchronization

------------------------------------------------------------------------

## Error Catalogue

-   Invitation expired
-   Duplicate invitation
-   Role conflict
-   Member already assigned
-   Sync conflict
-   Permission denied

------------------------------------------------------------------------

## Analytics Events

-   family_created
-   member_invited
-   invitation_accepted
-   role_changed
-   shared_trip_created
-   family_member_removed

------------------------------------------------------------------------

## Acceptance Criteria

AC-001: Owner can create a family in under two minutes.

AC-002: Invited members receive access only after acceptance.

AC-003: Permission rules are consistently enforced.

AC-004: Family dashboard aggregates trip readiness correctly.

------------------------------------------------------------------------

## Risks

-   Accidental permission escalation
-   Shared document privacy
-   Concurrent edits

Mitigation: - Role-based authorization - Audit logging - Conflict
resolution strategy

------------------------------------------------------------------------

## Future Enhancements

-   Live collaborative planning
-   Group voting for activities
-   Shared travel timeline
-   Family AI assistant
-   Automatic expense settlement
