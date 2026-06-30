"""Mock TripContext — the single source of truth injected into every LLM call.

Mirrors the structure defined in PRD AI_ENGINEERING_HANDBOOK_v2.md section 2.
In production this is built by the Trip Context Engine; here it is static mock
data so the Concierge vertical slice can run end-to-end without a backend DB.
"""
from __future__ import annotations

from typing import Any

TRIP_CONTEXT: dict[str, Any] = {
    "user": {
        "name": "Prateek",
        "language": "en",
        "currency": "THB",
        "home_currency": "INR",
        "dietary": ["vegetarian"],
        "family_size": 4,
        "children_ages": [6, 9],
    },
    "trip": {
        "id": "trip_phuket_dec26",
        "destination": "Phuket, Thailand",
        "current_day": 2,
        "total_days": 5,
        "start_date": "2026-12-02",
        "end_date": "2026-12-06",
    },
    "hotel": {
        "name": "Kata Rocks Resort",
        "address": "186/22 Kok Tanode Road, Kata, Phuket",
        "checkin": "2026-12-02",
        "checkout": "2026-12-06",
        "phone": "+66-76-370-777",
    },
    "flight": {
        "return_flight": "AI-318",
        "departure": "HKT",
        "arrival": "DEL",
        "departure_time": "2026-12-06T09:15:00+07:00",
        "terminal": "T1",
        "gate": "B12",
        "status": "on_time",
    },
    "budget": {
        "total_thb": 28500,
        "spent_thb": 16530,
        "remaining_thb": 11970,
        "today_spent_thb": 2840,
        "daily_avg_thb": 4132,
    },
    "itinerary_today": [
        {"time": "09:00", "activity": "Big Buddha Temple", "status": "current"},
        {"time": "13:00", "activity": "Kata Beach Lunch", "status": "upcoming"},
        {"time": "16:00", "activity": "Patong Beach", "status": "upcoming"},
        {"time": "19:30", "activity": "Dinner at Savoey", "status": "upcoming"},
    ],
    "environment": {
        "local_time": "2026-12-03T09:05:00+07:00",
        "weather": {
            "temp_c": 32,
            "condition": "partly_cloudy",
            "rain_prob_pct": 15,
            "uv_index": 8,
        },
        "gps": {"lat": 7.8951, "lng": 98.3004, "area": "Chalong, Phuket"},
        "connectivity": "online",
    },
}


def get_trip_context() -> dict[str, Any]:
    """Return the active TripContext. Single accessor so it is easy to swap
    for a real Trip Context Engine later."""
    return TRIP_CONTEXT
