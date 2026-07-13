"""Point-to-point route for a single itinerary day, for the Day plan map.

Legs use real driving distance/duration from OpenRouteService when
``ORS_API_KEY`` is configured, falling back to a straight-line estimate
per-leg otherwise (marked accordingly — see ``DayRouteOut.source``).
"""
from __future__ import annotations

from sqlmodel import Session

from . import places_service
from .db_models import User
from .itinerary_schemas import DayRouteOut, RouteLegOut, RouteStopOut
from .itinerary_service import _load_plan, _require_member
from .routing_service import haversine_km, routed_distance_duration


def _parse_coord(raw: str) -> float | None:
    try:
        return float(raw)
    except (TypeError, ValueError):
        return None


async def build_day_route(
    trip_id: str, day_index: int, user: User, session: Session
) -> DayRouteOut:
    _require_member(trip_id, user, session)
    plan = _load_plan(trip_id, session)
    day = next((d for d in plan.days if d.day_index == day_index), None)
    if day is None:
        return DayRouteOut()

    stops: list[RouteStopOut] = []
    skipped = 0
    for act in day.activities:
        lat, lng = _parse_coord(act.lat), _parse_coord(act.lng)
        if lat is None or lng is None:
            # Many AI-suggested activities never matched a real places lookup
            # and were saved with empty coordinates. Try geocoding on the fly
            # rather than silently dropping them from the map.
            query = ", ".join(
                p.strip()
                for p in (act.location_name or act.title, day.area)
                if p and p.strip()
            )
            geo = await places_service.geocode(query) if query else None
            if geo is None:
                skipped += 1
                continue
            lat, lng = float(geo[0]), float(geo[1])
        stops.append(RouteStopOut(title=act.title, lat=lat, lng=lng))

    if len(stops) < 2:
        return DayRouteOut(stops=stops, skipped=skipped)

    legs: list[RouteLegOut] = []
    all_routed = True
    for a, b in zip(stops, stops[1:]):
        routed = await routed_distance_duration(a.lat, a.lng, b.lat, b.lng)
        if routed is not None:
            distance_km, duration_min = routed
        else:
            all_routed = False
            distance_km = round(haversine_km(a.lat, a.lng, b.lat, b.lng) * 1.35, 1)
            duration_min = round(distance_km / 30 * 60)  # ~30 km/h city driving guess
        legs.append(RouteLegOut(distance_km=distance_km, duration_min=duration_min))

    return DayRouteOut(
        source="routed" if all_routed else "approximate",
        stops=stops,
        legs=legs,
        total_distance_km=round(sum(leg.distance_km for leg in legs), 1),
        total_duration_min=round(sum(leg.duration_min for leg in legs)),
        skipped=skipped,
    )
