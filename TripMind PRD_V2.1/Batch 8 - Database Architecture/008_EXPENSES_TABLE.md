# 008_EXPENSES_TABLE.md

# Expenses Table Specification

Version: 1.0

Status: Database Specification

------------------------------------------------------------------------

# Purpose

Defines the canonical `expenses` table for storing all trip-related
spending captured manually or automatically from receipts, SMS, bookings
and partner integrations.

------------------------------------------------------------------------

# Table Name

`expenses`

------------------------------------------------------------------------

# Description

Stores normalized expense records linked to a Trip. Supports multiple
currencies, family sharing, receipt attachments and offline
synchronization.

------------------------------------------------------------------------

# Columns

  Column              Type            Required   Description
  ------------------- --------------- ---------- -------------------------------
  id                  UUID            Yes        Primary key
  trip_id             UUID            Yes        References trips.id
  created_by          UUID            Yes        References users.id
  category            VARCHAR(50)     Yes        Expense category
  merchant            VARCHAR(255)    No         Merchant name
  amount              NUMERIC(12,2)   Yes        Transaction amount
  currency            CHAR(3)         Yes        ISO currency
  exchange_rate       NUMERIC(12,6)   No         Conversion rate
  amount_base         NUMERIC(12,2)   No         Amount in trip currency
  payment_method      VARCHAR(50)     No         Cash, Card, UPI, etc.
  source              VARCHAR(30)     Yes        manual, receipt, sms, booking
  receipt_id          UUID            No         Linked receipt
  expense_date        TIMESTAMP       Yes        Expense timestamp
  notes               TEXT            No         User notes
  is_shared           BOOLEAN         Yes        Shared expense flag
  created_at          TIMESTAMP       Yes        Creation timestamp
  updated_at          TIMESTAMP       Yes        Last update
  deleted_at          TIMESTAMP       No         Soft delete
  sync_version        BIGINT          Yes        Sync version
  device_updated_at   TIMESTAMP       Yes        Client update time

------------------------------------------------------------------------

# Constraints

-   Primary Key: `id`
-   Foreign Key: `trip_id → trips.id`
-   Foreign Key: `created_by → users.id`
-   Amount must be greater than zero.
-   Currency must be ISO-4217 compliant.
-   Soft deletes only.

------------------------------------------------------------------------

# Indexes

-   PK(id)
-   INDEX(trip_id)
-   INDEX(created_by)
-   INDEX(category)
-   INDEX(expense_date)
-   INDEX(source)

------------------------------------------------------------------------

# Relationships

-   Many Expenses → One Trip
-   Many Expenses → One User
-   One Expense → One Receipt (optional)
-   One Expense → Many Split Records (future)

------------------------------------------------------------------------

# Synchronization

-   Offline creation and editing supported.
-   Sync based on `sync_version`.
-   Conflict resolution uses last-write-wins except split records.

------------------------------------------------------------------------

# Security

-   Visible only to authorized trip members.
-   Shared expenses respect permission model.
-   Financial metadata encrypted where required.

------------------------------------------------------------------------

# Acceptance Criteria

-   Expense lookup optimized by trip.
-   Multi-currency supported.
-   Offline synchronization supported.
-   Compatible with PostgreSQL and SQLite.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- --------------------------------------
  1.0       Initial Expenses Table Specification
