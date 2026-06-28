# TripMind Product Specification (Master PRD)

## Batch 15 -- Version 7.0

------------------------------------------------------------------------

# Part VII --- Expense Management & Budget Tracking

## Purpose

The Expense Management module enables travellers to record, categorize,
analyze and optimize trip spending in real time. It supports manual
entry, OCR-based receipt capture, multiple currencies, family expense
sharing and AI-driven budget insights.

------------------------------------------------------------------------

# Functional Requirements

### FR-001 -- Create Expense

Users shall be able to create an expense manually by entering:

-   Amount
-   Currency
-   Category
-   Date & Time
-   Merchant
-   Payment Method
-   Notes
-   Receipt (optional)

------------------------------------------------------------------------

### FR-002 -- Capture Receipt

Users shall be able to:

-   Scan receipt using camera
-   Upload image
-   Upload PDF

OCR automatically extracts:

-   Merchant
-   Date
-   Amount
-   Currency
-   Taxes
-   Line Items (future)

Users must review extracted values before saving.

------------------------------------------------------------------------

### FR-003 -- Expense Categories

Default categories:

-   Flights
-   Hotels
-   Food
-   Shopping
-   Local Transport
-   Entertainment
-   Activities
-   Visa
-   Insurance
-   Miscellaneous

Categories may be customized per user.

------------------------------------------------------------------------

### FR-004 -- Multi-Currency Support

Every expense stores:

-   Original currency
-   Original amount
-   Exchange rate
-   Base currency amount

Historical exchange rates are preserved.

------------------------------------------------------------------------

### FR-005 -- Budget Monitoring

Display:

-   Total spent
-   Remaining budget
-   Category breakdown
-   Daily burn rate
-   Forecasted trip spend

AI highlights overspending risks.

------------------------------------------------------------------------

# User Journey

``` mermaid
flowchart LR
OpenTrip-->Expenses
Expenses-->AddExpense
AddExpense-->OCR
OCR-->Review
Review-->Save
Save-->BudgetUpdated
BudgetUpdated-->Insights
```

------------------------------------------------------------------------

# UI Components

## Expense List

Displays:

-   Merchant
-   Amount
-   Currency
-   Category
-   Date
-   Receipt indicator

Supports:

-   Search
-   Filter
-   Sort
-   Bulk selection

------------------------------------------------------------------------

## Expense Details

Contains:

-   Merchant
-   Receipt image
-   AI OCR confidence
-   Notes
-   Exchange rate
-   Budget impact
-   Audit history

------------------------------------------------------------------------

## Budget Dashboard

Widgets:

-   Budget consumed
-   Remaining amount
-   Category pie chart
-   Daily average
-   Spending trend
-   AI recommendations

------------------------------------------------------------------------

# Business Rules

BR-001: Expenses always belong to one trip.

BR-002: Negative expense amounts are prohibited.

BR-003: Deleted expenses remain recoverable for 30 days.

BR-004: Receipt edits require user confirmation if OCR confidence is
below threshold.

BR-005: Budget warnings appear at configurable thresholds (50%, 80%,
100%).

------------------------------------------------------------------------

# Non-Functional Requirements

NFR-001: Expense list loads within 2 seconds.

NFR-002: OCR result displayed within 5 seconds under normal network
conditions.

NFR-003: Expense synchronization retries automatically after
connectivity is restored.

------------------------------------------------------------------------

# Permission Matrix

  Role             View   Add   Edit   Delete
  --------------- ------ ----- ------ --------
  Owner             ✓      ✓     ✓       ✓
  Family Editor     ✓      ✓     ✓       ✗
  Viewer            ✓      ✗     ✗       ✗

------------------------------------------------------------------------

# Offline Behaviour

Supported offline:

-   Add expense
-   Edit draft
-   Capture receipt
-   Browse previous expenses

Deferred until online:

-   OCR processing
-   Currency updates
-   AI insights
-   Cloud backup

------------------------------------------------------------------------

# Error Catalogue

  Error                   User Action
  ----------------------- --------------------------------------
  Invalid amount          Correct input
  OCR failed              Manual entry
  Sync failed             Retry later
  Currency unavailable    Save locally and refresh rates later
  Receipt upload failed   Retry upload

------------------------------------------------------------------------

# Analytics Events

-   expense_created
-   expense_updated
-   expense_deleted
-   receipt_scanned
-   ocr_completed
-   budget_threshold_reached
-   ai_budget_tip_viewed

------------------------------------------------------------------------

# Acceptance Test Scenarios

Scenario 1: Manual expense creation succeeds with valid data.

Scenario 2: Receipt OCR extracts fields and allows correction.

Scenario 3: Offline expense synchronizes automatically when connectivity
returns.

Scenario 4: Budget dashboard updates immediately after saving an
expense.

------------------------------------------------------------------------

# Future Enhancements

-   Split expenses between travellers
-   Automatic credit-card import
-   Per-day budget optimization
-   AI anomaly detection
-   Tax refund estimation
-   Business expense reports
