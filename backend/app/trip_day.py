"""Builds the TripDay payload for the Trip Detail screen from TripContext.

Pure transformation of the mock TripContext into the structured shape the
Flutter Trip Detail screen consumes. No LLM involved — this is deterministic
trip data, kept separate from the Concierge service.
"""
from __future__ import annotations

from .expenses import budget_snapshot
from .models import (
    FlightInfo,
    ItineraryItem,
    StayInfo,
    TripDay,
)
from .trip_context import get_trip_context


def build_trip_day() -> TripDay:
    ctx = get_trip_context()
    trip = ctx["trip"]
    hotel = ctx["hotel"]
    flight = ctx["flight"]
    env = ctx["environment"]
    weather = env["weather"]
    gps = env["gps"]

    condition = str(weather["condition"]).replace("_", " ")
    weather_line = f"{weather['temp_c']}°C · {condition} · {weather['rain_prob_pct']}% rain"

    items = [
        ItineraryItem(
            time=row["time"],
            activity=row["activity"],
            status=row.get("status", "upcoming"),
        )
        for row in ctx["itinerary_today"]
    ]

    return TripDay(
        destination=trip["destination"],
        day_number=trip["current_day"],
        total_days=trip["total_days"],
        date=env["local_time"][:10],
        weather_line=weather_line,
        area=gps["area"],
        items=items,
        budget=budget_snapshot(),
        stay=StayInfo(
            name=hotel["name"],
            address=hotel["address"],
            checkout=hotel["checkout"],
            phone=hotel["phone"],
        ),
        flight=FlightInfo(
            flight_no=flight["return_flight"],
            route=f"{flight['departure']} → {flight['arrival']}",
            departure_time=flight["departure_time"],
            terminal=flight["terminal"],
            gate=flight["gate"],
            status=str(flight["status"]).replace("_", " "),
        ),
    )
