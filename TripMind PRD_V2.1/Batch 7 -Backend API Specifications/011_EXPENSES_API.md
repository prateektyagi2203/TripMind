# 011_EXPENSES_API.md

# Expenses API

Version: 1.0

Status: Backend API Specification

------------------------------------------------------------------------

# Purpose

Defines REST endpoints for travel expense management, receipt
processing, SMS-imported expenses and budget summaries.

------------------------------------------------------------------------

# Resource

`/expenses`

------------------------------------------------------------------------

## GET /expenses

Returns expenses for the authenticated user.

### Query Parameters

-   trip_id
-   category
-   currency
-   page
-   page_size

------------------------------------------------------------------------

## POST /expenses

Creates a manual expense.

### Request

``` json
{
  "trip_id":"uuid",
  "category":"Food",
  "amount":850,
  "currency":"THB",
  "merchant":"Indian Delight",
  "payment_method":"Card"
}
```

------------------------------------------------------------------------

## POST /expenses/receipt

Processes a receipt image and returns an editable expense draft.

------------------------------------------------------------------------

## POST /expenses/sms-import

Imports an expense extracted from Android SMS.

------------------------------------------------------------------------

## PATCH /expenses/{expenseId}

Updates an expense.

------------------------------------------------------------------------

## DELETE /expenses/{expenseId}

Soft deletes an expense.

------------------------------------------------------------------------

## GET /expenses/summary

Returns:

-   Total spent
-   Remaining budget
-   Daily average
-   Category totals
-   Family split

------------------------------------------------------------------------

## GET /expenses/categories

Returns supported expense categories.

------------------------------------------------------------------------

# Response Schema

``` json
{
  "success": true,
  "data": {
    "expense_id":"uuid",
    "budget_remaining":76250
  }
}
```

------------------------------------------------------------------------

# Validation

-   Amount must be greater than zero.
-   Currency required.
-   Trip must exist.
-   Category must be valid.

------------------------------------------------------------------------

# Events

-   ExpenseCreated
-   ExpenseUpdated
-   ReceiptProcessed
-   SMSImported
-   BudgetThresholdExceeded

------------------------------------------------------------------------

# Security

-   JWT authentication required.
-   Users can access only their own or shared-trip expenses.
-   Receipt images processed securely.

------------------------------------------------------------------------

# Acceptance Criteria

-   Manual expense creation \<1 second.
-   Receipt draft generated in under 5 seconds.
-   Budget summary reflects latest changes.
-   OpenAPI documentation generated.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ----------------------
  1.0       Initial Expenses API
