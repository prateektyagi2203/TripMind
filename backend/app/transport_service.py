"""Day 1 airport -> hotel transfer estimate, built from real trip data.

Thailand-specific: estimates cost/ETA for the ride-hailing apps actually
operating there (Grab, Bolt, inDrive) plus the airport's public metered taxi
counter.

Distance & duration come from OpenRouteService's driving-car routing (real
road network, when ``ORS_API_KEY`` is configured) between the arrival
airport and the Day 1 hotel (geocoded via ``places_service``). Without a key,
or if either call fails, falls back to a straight-line estimate so the card
still renders something reasonable.

Prices are NOT live — no ride-hailing app exposes a public price-quote API.
They're a fare-formula estimate (flagfall + per-km + per-min) calibrated to
roughly match real Thailand pricing; the API response is marked accordingly
and the Flutter card must show it as an estimate, not a quote.
"""
from __future__ import annotations

from typing import Optional

from sqlmodel import Session, select

from . import places_service
from .db_models import Destination, User
from .itinerary_service import _arrival_flight, _require_member
from .routing_service import haversine_km, routed_distance_duration
from .trip_schemas import AirportTransferOut, TransferProviderOut

# Airports serving Thailand's common tourist routes: code, display name, lat/lng.
THAILAND_AIRPORTS: dict[str, dict[str, object]] = {
    "bangkok": {"code": "BKK", "name": "Suvarnabhumi Airport", "lat": 13.6900, "lng": 100.7501},
    "don mueang": {"code": "DMK", "name": "Don Mueang International Airport", "lat": 13.9126, "lng": 100.6067},
    "phuket": {"code": "HKT", "name": "Phuket International Airport", "lat": 8.1132, "lng": 98.3169},
    "krabi": {"code": "KBV", "name": "Krabi Airport", "lat": 8.0958, "lng": 98.9861},
    "koh samui": {"code": "USM", "name": "Samui Airport", "lat": 9.5478, "lng": 100.0623},
    "chiang mai": {"code": "CNX", "name": "Chiang Mai International Airport", "lat": 18.7669, "lng": 98.9626},
    "pattaya": {"code": "UTP", "name": "U-Tapao International Airport", "lat": 12.6799, "lng": 101.0050},
}

# City-centre coordinates, used only when hotel geocoding is unavailable.
CITY_FALLBACK_COORDS: dict[str, tuple[float, float]] = {
    "bangkok": (13.7563, 100.5018),
    "phuket": (7.8804, 98.3923),
    "krabi": (8.0863, 98.9063),
    "koh samui": (9.5120, 100.0136),
    "chiang mai": (18.7883, 98.9853),
    "pattaya": (12.9236, 100.8825),
}

_ORS_URL = "https://api.openrouteservice.org/v2/directions/driving-car"


def _match_city(city: str, table: dict) -> Optional[dict | tuple]:
    key = city.strip().lower()
    if not key:
        return None
    for name, value in table.items():
        if name in key or key in name:
            return value
    return None


def _providers_for_distance(distance_km: float, base_duration_min: Optional[float]) -> list[dict]:
    """Fare-formula estimate: flagfall + per-km + per-min. NOT live pricing —
    no ride-hailing app exposes a public price-quote API."""
    duration_min = (
        round(base_duration_min)
        if base_duration_min is not None
        else round(distance_km / 50 * 60) + 6  # ~50 km/h incl. airport exit + traffic
    )

    def cost(flagfall: float, per_km: float, per_min: float) -> int:
        return round(flagfall + per_km * distance_km + per_min * duration_min)

    providers = [
        {"name": "Grab", "price_thb": cost(35, 9.0, 2.0), "eta_min": duration_min + 4},
        {"name": "Bolt", "price_thb": cost(30, 8.0, 1.8), "eta_min": duration_min + 6},
        {"name": "inDrive", "price_thb": cost(25, 7.0, 1.5), "eta_min": duration_min + 8},
        {
            "name": "Airport Taxi Meter",
            "price_thb": cost(35, 6.5, 0) + 120,  # + airport surcharge & expressway tolls
            "eta_min": duration_min,
        },
    ]
    cheapest = min(p["price_thb"] for p in providers)
    for p in providers:
        p["best_value"] = p["price_thb"] == cheapest
    return providers


async def day1_airport_transfer(
    trip_id: str, user: User, session: Session
) -> Optional[AirportTransferOut]:
    """None when the trip has no recognisable Thailand arrival airport."""
    _require_member(trip_id, user, session)
    arrival = _arrival_flight(trip_id, session)
    if arrival is None:
        return None

    city = arrival["to_city"]
    airport = _match_city(city, THAILAND_AIRPORTS)
    if airport is None:
        return None

    destinations = session.exec(
        select(Destination)
        .where(Destination.trip_id == trip_id)
        .order_by(Destination.order_index)
    ).all()
    hotel = next(
        (d for d in destinations if d.city.strip().lower() == city.strip().lower()),
        destinations[0] if destinations else None,
    )
    if hotel is None:
        return None

    query = ", ".join(p.strip() for p in (hotel.hotel_name, hotel.city) if p.strip())
    query = query or hotel.hotel_address.strip()
    coords = await places_service.geocode(query) if query else None
    hotel_geocoded = coords is not None
    if coords is None:
        coords = _match_city(city, CITY_FALLBACK_COORDS)
        if coords is None:
            return None

    hotel_lat, hotel_lng = float(coords[0]), float(coords[1])
    airport_lat, airport_lng = float(airport["lat"]), float(airport["lng"])

    routed = await routed_distance_duration(airport_lat, airport_lng, hotel_lat, hotel_lng)
    if routed is not None:
        distance_km, duration_min = routed
        source = "routed"
    else:
        # Straight-line * fudge factor to approximate actual road distance.
        distance_km = round(haversine_km(airport_lat, airport_lng, hotel_lat, hotel_lng) * 1.35, 1)
        duration_min = None
        source = "geocoded" if hotel_geocoded else "approximate"

    return AirportTransferOut(
        airport_code=str(airport["code"]),
        airport_name=str(airport["name"]),
        hotel_name=hotel.hotel_name or "your hotel",
        distance_km=distance_km,
        source=source,
        airport_lat=airport_lat,
        airport_lng=airport_lng,
        hotel_lat=hotel_lat,
        hotel_lng=hotel_lng,
        providers=[
            TransferProviderOut(**p)
            for p in _providers_for_distance(distance_km, duration_min)
        ],
    )
