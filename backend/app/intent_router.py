"""Deterministic intent router (PRD AI_ENGINEERING_HANDBOOK_v2.md section 5.1).

Answers common questions from TripContext WITHOUT calling the LLM. This is the
core cost-control mechanism: if the app already knows the answer, don't pay for
a GPT-4o call.
"""
from __future__ import annotations

from typing import Any, Optional

from .models import ChatResponse, RichCard

DETERMINISTIC_INTENTS: dict[str, list[str]] = {
    "budget_check": ["how much", "spent", "remaining", "budget", "left"],
    "weather": ["weather", "rain", "temperature", "hot", "forecast"],
    "flight_status": ["flight", "gate", "terminal", "boarding"],
    "hotel_info": ["hotel", "check-in", "check out", "checkout", "reception"],
    "itinerary_view": ["plan", "schedule", "today", "what's next", "whats next", "itinerary"],
}

# Cab/taxi triggers produce a rich comparison card (still deterministic-ish demo data).
CAB_KEYWORDS = ["cab", "taxi", "grab", "bolt", "indrive", "ride", "how do i get"]


def route_intent(message: str) -> Optional[str]:
    msg = message.lower()
    for intent, keywords in DETERMINISTIC_INTENTS.items():
        if any(k in msg for k in keywords):
            return intent
    return None


def is_cab_query(message: str) -> bool:
    msg = message.lower()
    return any(k in msg for k in CAB_KEYWORDS)


def answer_deterministic(intent: str, ctx: dict[str, Any]) -> ChatResponse:
    budget = ctx["budget"]
    weather = ctx["environment"]["weather"]
    flight = ctx["flight"]
    hotel = ctx["hotel"]
    itinerary = ctx["itinerary_today"]

    if intent == "budget_check":
        text = (
            f"You've spent THB {budget['spent_thb']:,} of THB {budget['total_thb']:,}. "
            f"That leaves THB {budget['remaining_thb']:,} "
            f"(THB {budget['today_spent_thb']:,} spent today)."
        )
        card = RichCard(
            type="budget_summary",
            data={
                "total_thb": budget["total_thb"],
                "spent_thb": budget["spent_thb"],
                "remaining_thb": budget["remaining_thb"],
                "today_spent_thb": budget["today_spent_thb"],
                "daily_avg_thb": budget["daily_avg_thb"],
            },
        )
        return ChatResponse(text=text, source="deterministic", rich_card=card)

    if intent == "weather":
        text = (
            f"It's {weather['temp_c']}C and {weather['condition'].replace('_', ' ')} "
            f"in {ctx['environment']['gps']['area']}. "
            f"Rain chance {weather['rain_prob_pct']}%, UV index {weather['uv_index']}."
        )
        return ChatResponse(text=text, source="deterministic")

    if intent == "flight_status":
        text = (
            f"Flight {flight['return_flight']} {flight['departure']}->{flight['arrival']} "
            f"departs {flight['departure_time'][11:16]}, terminal {flight['terminal']}, "
            f"gate {flight['gate']}. Status: {flight['status'].replace('_', ' ')}."
        )
        return ChatResponse(text=text, source="deterministic")

    if intent == "hotel_info":
        text = (
            f"You're staying at {hotel['name']}, {hotel['address']}. "
            f"Reception: {hotel['phone']}. Checkout {hotel['checkout']}."
        )
        return ChatResponse(text=text, source="deterministic")

    if intent == "itinerary_view":
        lines = ", ".join(f"{i['time']} {i['activity']}" for i in itinerary)
        text = f"Today's plan: {lines}."
        return ChatResponse(text=text, source="deterministic")

    return ChatResponse(text="Let me look into that.", source="deterministic")


def cab_comparison_card() -> RichCard:
    """Mock CabHub comparison rendered as a rich card (proves the card pattern)."""
    return RichCard(
        type="cab_comparison",
        data={
            "destination": "Big Buddha Temple",
            "providers": [
                {"name": "Grab", "price_thb": 180, "eta_min": 4, "best_value": True},
                {"name": "Bolt", "price_thb": 165, "eta_min": 7, "best_value": False},
                {"name": "inDrive", "price_thb": 150, "eta_min": 11, "best_value": False},
            ],
        },
    )
