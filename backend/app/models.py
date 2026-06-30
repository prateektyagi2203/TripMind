"""Pydantic models for the TripMind AI Concierge API."""
from __future__ import annotations

from typing import Any, Literal, Optional

from pydantic import BaseModel, Field


class ChatMessage(BaseModel):
    role: Literal["user", "assistant"]
    content: str


class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1)
    # Client keeps history; we only use the last N turns to control token cost.
    history: list[ChatMessage] = Field(default_factory=list)


class RichCard(BaseModel):
    """A structured payload rendered as a card inside the chat stream."""

    type: Literal[
        "cab_comparison",
        "budget_summary",
        "weather_detail",
        "restaurant_list",
    ]
    data: dict[str, Any]


class ChatResponse(BaseModel):
    text: str
    # Where the answer came from — proves the deterministic router saved an LLM call.
    source: Literal["deterministic", "ai", "fallback"]
    rich_card: Optional[RichCard] = None


class BriefingCard(BaseModel):
    headline: str
    weather_line: str
    first_activity: dict[str, str]
    budget_line: str
    ai_tip: str
    alerts: list[str] = Field(default_factory=list)
    source: Literal["ai", "fallback"] = "fallback"


class ItineraryItem(BaseModel):
    time: str
    activity: str
    status: Literal["done", "current", "upcoming"]


class BudgetSnapshot(BaseModel):
    currency: str
    total: int
    spent: int
    remaining: int
    today_spent: int
    daily_avg: int


class StayInfo(BaseModel):
    name: str
    address: str
    checkout: str
    phone: str


class FlightInfo(BaseModel):
    flight_no: str
    route: str
    departure_time: str
    terminal: str
    gate: str
    status: str


class TripDay(BaseModel):
    """Everything the Trip Detail screen needs for the active day."""

    destination: str
    day_number: int
    total_days: int
    date: str
    weather_line: str
    area: str
    items: list[ItineraryItem]
    budget: BudgetSnapshot
    stay: StayInfo
    flight: FlightInfo


EXPENSE_CATEGORIES = ("food", "transport", "activities", "shopping", "other")


class ExpenseRequest(BaseModel):
    amount: int = Field(..., gt=0, description="Amount in trip currency (THB).")
    category: Literal["food", "transport", "activities", "shopping", "other"]
    note: str = Field("", max_length=120)


class Expense(BaseModel):
    id: str
    amount: int
    category: str
    note: str
    created_at: str


class ExpenseResponse(BaseModel):
    """Returned after logging an expense: the new entry + recomputed budget."""

    expense: Expense
    budget: BudgetSnapshot


class ExpenseList(BaseModel):
    expenses: list[Expense]
    budget: BudgetSnapshot


class TranslateRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=300)
    target_lang: str = Field("Thai", max_length=40)


class TranslateResponse(BaseModel):
    translated: str
    pronunciation: str = ""
    source: Literal["ai", "fallback"] = "fallback"
