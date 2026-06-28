# 011_EXPENSES_UX.md

# Expenses UX Specification

Version: 1.0

Status: UI/UX Specification

------------------------------------------------------------------------

# Purpose

The Expenses screen gives travelers a real-time understanding of
spending throughout a trip. It automatically aggregates expenses from
SMS (Android), receipts, bookings and manual entries while providing
clear budget insights.

------------------------------------------------------------------------

# UX Goals

-   Budget visible at a glance
-   Minimize manual entry
-   One-tap receipt scanning
-   Clear family expense tracking
-   Offline capable

------------------------------------------------------------------------

# Screen Layout

    --------------------------------------------------
    Trip Budget Summary
    --------------------------------------------------
    Today's Spending
    --------------------------------------------------
    Category Breakdown
    --------------------------------------------------
    Recent Expenses
    --------------------------------------------------
    Quick Actions
    --------------------------------------------------
    Insights
    --------------------------------------------------
    Bottom Navigation
    --------------------------------------------------

------------------------------------------------------------------------

# Budget Summary

Displays:

-   Total Budget
-   Total Spent
-   Remaining Budget
-   Daily Average
-   Projected Spend

------------------------------------------------------------------------

# Charts

-   Category pie chart
-   Daily spending trend
-   Budget progress bar

------------------------------------------------------------------------

# Expense List

Each expense shows:

-   Merchant
-   Category
-   Amount
-   Currency
-   Date & Time
-   Source (SMS, OCR, Manual)

Actions:

-   Edit
-   Delete
-   Attach receipt
-   Split expense

------------------------------------------------------------------------

# Quick Actions

-   Add Expense
-   Scan Receipt
-   Import SMS
-   Convert Currency

------------------------------------------------------------------------

# Family Expenses

Displays:

-   Paid by
-   Shared amount
-   Split details
-   Settlement suggestions

------------------------------------------------------------------------

# AI Insights

Examples:

-   Spending ahead of budget
-   Biggest category
-   Restaurant spend
-   Taxi spend
-   Savings opportunities

------------------------------------------------------------------------

# Offline Behaviour

Available offline:

-   View expenses
-   Add/edit expenses
-   Receipt drafts
-   Cached exchange rates

Synchronization occurs automatically when online.

------------------------------------------------------------------------

# Flutter Widgets

-   CustomScrollView
-   Card
-   ListTile
-   DataTable
-   FloatingActionButton
-   LinearProgressIndicator
-   Pie chart widget
-   Line chart widget

------------------------------------------------------------------------

# Acceptance Criteria

-   Dashboard loads in under 1 second.
-   Manual expense entry in under 15 seconds.
-   Receipt scan creates editable draft.
-   Family expenses sync correctly.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ---------------------
  1.0       Initial Expenses UX
