"""Shared routing helpers: straight-line distance and real driving
distance/duration via OpenRouteService (free tier, ``ORS_API_KEY``).

Used by both the Day 1 airport transfer estimate and the Day map's
point-to-point leg distances.
"""
from __future__ import annotations

import math
import os
from typing import Optional

import httpx

_ORS_URL = "https://api.openrouteservice.org/v2/directions/driving-car"


def haversine_km(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    r = 6371.0
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dp = math.radians(lat2 - lat1)
    dl = math.radians(lng2 - lng1)
    a = math.sin(dp / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) ** 2
    return 2 * r * math.asin(math.sqrt(a))


async def routed_distance_duration(
    o_lat: float, o_lng: float, d_lat: float, d_lng: float
) -> Optional[tuple[float, float]]:
    """Real driving distance (km) + duration (min) from OpenRouteService.
    None without ``ORS_API_KEY`` or on any failure (rate limit, no route, etc)."""
    key = os.getenv("ORS_API_KEY", "").strip()
    if not key:
        return None
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            res = await client.get(
                _ORS_URL,
                params={
                    "api_key": key,
                    "start": f"{o_lng},{o_lat}",
                    "end": f"{d_lng},{d_lat}",
                },
            )
        if res.status_code != 200:
            return None
        summary = res.json()["features"][0]["properties"]["summary"]
        return round(summary["distance"] / 1000, 1), round(summary["duration"] / 60)
    except Exception:
        return None
