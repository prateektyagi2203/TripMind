# 009_EXPENSE_ENGINE.md

# Expense Engine

Version: 1.0

Status: Module Specification

------------------------------------------------------------------------

# Purpose

The Expense Engine automatically captures, categorizes, analyzes and
summarizes travel expenses throughout a trip. It minimizes manual data
entry by extracting expenses from multiple sources and presenting
real-time budget insights.

------------------------------------------------------------------------

# Responsibilities

-   Automatically detect travel expenses
-   Categorize spending
-   Track trip budget
-   Convert currencies
-   Generate daily and trip summaries
-   Share expenses with family members
-   Publish budget updates to Trip Context

------------------------------------------------------------------------

# Business Rules

-   Every expense belongs to exactly one Trip.
-   Expenses may belong to an individual or the whole family.
-   Users can edit or reject automatically detected expenses.
-   Manual expenses always override AI-generated drafts.

------------------------------------------------------------------------

# Expense Sources

## Automatic

-   Android SMS
-   Email confirmations (optional)
-   Grab/Bolt ride receipts
-   Klook bookings
-   Hotel invoices
-   Restaurant receipts
-   Camera OCR
-   Credit card notifications (future)

## Manual

-   Cash payment
-   Notes
-   Split expenses

------------------------------------------------------------------------

# Categories

Transportation

Accommodation

Food & Drinks

Shopping

Entertainment

Activities

Medical

Emergency

Miscellaneous

------------------------------------------------------------------------

# Core Features

## Smart SMS Parsing

Automatically detects:

-   Merchant
-   Amount
-   Currency
-   Date
-   Payment method

Creates a pending expense for review.

------------------------------------------------------------------------

## Receipt OCR

Extracts:

-   Merchant
-   Items (future)
-   Tax
-   Total
-   Currency

------------------------------------------------------------------------

## Budget Dashboard

Displays:

-   Total spent
-   Remaining budget
-   Daily average
-   Category breakdown
-   Family contribution
-   Currency conversion

------------------------------------------------------------------------

## Currency Conversion

Features:

-   Live exchange rates (online)
-   Cached rates (offline)
-   Base currency selection
-   Multi-currency reporting

------------------------------------------------------------------------

## Family Expenses

Supports:

-   Shared expenses
-   Split equally
-   Custom split
-   Paid by tracking

------------------------------------------------------------------------

# APIs

-   POST /expenses
-   GET /expenses
-   PATCH /expenses/{id}
-   DELETE /expenses/{id}
-   GET /expenses/summary
-   POST /expenses/receipt

------------------------------------------------------------------------

# Database Tables

-   expenses
-   expense_categories
-   expense_receipts
-   exchange_rates
-   expense_splits

------------------------------------------------------------------------

# Events

Publishes:

-   ExpenseCreated
-   ExpenseUpdated
-   BudgetExceeded
-   ReceiptProcessed
-   DailyBudgetUpdated

------------------------------------------------------------------------

# Offline Behaviour

Available offline:

-   Manual expenses
-   Budget dashboard
-   Receipt drafts
-   Cached exchange rates
-   Expense history

Synchronization occurs automatically when internet becomes available.

------------------------------------------------------------------------

# Dependencies

-   Camera Engine
-   Trip Context Engine
-   Family Engine
-   Sync Engine
-   Memory Engine

------------------------------------------------------------------------

# Acceptance Criteria

-   SMS parsing accuracy \>95% for supported formats.
-   OCR receipt extraction completes in under 5 seconds.
-   Budget updates immediately after expense creation.
-   Family expense synchronization functions correctly.

------------------------------------------------------------------------

# Future Enhancements

-   Bank integrations
-   Credit card feeds
-   AI spending insights
-   Tax refund tracking
-   Expense export (PDF/Excel)

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ------------------------
  1.0       Initial Expense Engine
