"""In-memory expense store for the active trip.

Logging an expense mutates the mock TripContext budget so the change is
reflected everywhere (Trip Detail budget ring + the Concierge's deterministic
budget card). In production this would be a database write + Trip Context
Engine recompute; here it is a process-local list so the vertical slice runs
without a DB.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timezone

from .models import BudgetSnapshot, Expense
from .trip_context import get_trip_context

_EXPENSES: list[Expense] = []


def budget_snapshot() -> BudgetSnapshot:
    ctx = get_trip_context()
    budget = ctx["budget"]
    return BudgetSnapshot(
        currency=ctx["user"]["currency"],
        total=budget["total_thb"],
        spent=budget["spent_thb"],
        remaining=budget["remaining_thb"],
        today_spent=budget["today_spent_thb"],
        daily_avg=budget["daily_avg_thb"],
    )


def add_expense(amount: int, category: str, note: str) -> Expense:
    """Record an expense and update the running budget totals."""
    budget = get_trip_context()["budget"]
    budget["spent_thb"] += amount
    budget["remaining_thb"] -= amount
    budget["today_spent_thb"] += amount

    expense = Expense(
        id=uuid.uuid4().hex[:8],
        amount=amount,
        category=category,
        note=note,
        created_at=datetime.now(timezone.utc).isoformat(timespec="seconds"),
    )
    _EXPENSES.insert(0, expense)  # newest first
    return expense


def list_expenses() -> list[Expense]:
    return list(_EXPENSES)
