"""Nearby points-of-interest discovery via TripAdvisor (Travel Advisor on RapidAPI).

Geocodes a hotel to lat/long, then lists nearby attractions and restaurants.
Reuses the same ``RAPIDAPI_KEY`` as ``flight_service``. Degrades gracefully
(returns an empty list) when no key is configured or the upstream call fails,
so the planner can fall back to AI-only suggestions.

Configuration (backend/.env):
    RAPIDAPI_KEY=<your RapidAPI key, subscribed to Travel Advisor>
    # optional override:
    TRIPADVISOR_HOST=travel-advisor.p.rapidapi.com
"""
from __future__ import annotations

import os
from typing import Any

import httpx

_HOST = os.getenv("TRIPADVISOR_HOST", "travel-advisor.p.rapidapi.com")


def _api_key() -> str | None:
    key = os.getenv("RAPIDAPI_KEY", "").strip()
    return key or None


def _headers() -> dict[str, str]:
    return {"X-RapidAPI-Key": _api_key() or "", "X-RapidAPI-Host": _HOST}


async def _get(client: httpx.AsyncClient, path: str, params: dict[str, str]) -> Any:
    res = await client.get(f"https://{_HOST}{path}", headers=_headers(), params=params)
    if res.status_code != 200:
        return None
    return res.json()


def _extract_latlng(geo: Any) -> tuple[str, str] | None:
    if not isinstance(geo, dict):
        return None
    for entry in geo.get("data", []) or []:
        obj = entry.get("result_object") if isinstance(entry, dict) else None
        if not isinstance(obj, dict):
            continue
        lat = str(obj.get("latitude", "") or "").strip()
        lng = str(obj.get("longitude", "") or "").strip()
        if lat and lng:
            return lat, lng
    return None


def _norm_item(it: Any, category: str) -> dict[str, str] | None:
    if not isinstance(it, dict):
        return None
    name = str(it.get("name", "") or "").strip()
    if not name:
        return None
    photo = it.get("photo")
    image_url = ""
    if isinstance(photo, dict):
        images = photo.get("images")
        if isinstance(images, dict):
            large = images.get("large")
            if isinstance(large, dict):
                image_url = str(large.get("url", "") or "")
    return {
        "name": name,
        "address": str(it.get("address", "") or "").strip(),
        "lat": str(it.get("latitude", "") or ""),
        "lng": str(it.get("longitude", "") or ""),
        "rating": str(it.get("rating", "") or ""),
        "link": str(it.get("web_url", "") or ""),
        "image_url": image_url,
        "category": category,
    }


async def geocode(query: str) -> tuple[str, str] | None:
    """Resolve a free-text place query to (lat, lng). None on any failure."""
    if not _api_key() or not query.strip():
        return None
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            geo = await _get(
                client,
                "/locations/search",
                {"query": query, "limit": "1", "lang": "en_US"},
            )
        return _extract_latlng(geo)
    except Exception:
        return None


async def nearby_places(
    hotel_name: str, hotel_address: str, city: str, limit: int = 20
) -> list[dict[str, str]]:
    """Return nearby attractions + restaurants for a hotel. Empty on any failure."""
    if not _api_key():
        return []
    query = ", ".join(p.strip() for p in (hotel_name, city) if p.strip())
    query = query or hotel_address.strip() or city.strip()
    if not query:
        return []
    try:
        async with httpx.AsyncClient(timeout=12.0) as client:
            geo = await _get(
                client,
                "/locations/search",
                {"query": query, "limit": "1", "lang": "en_US"},
            )
            latlng = _extract_latlng(geo)
            if latlng is None:
                return []
            lat, lng = latlng
            out: list[dict[str, str]] = []
            seen: set[str] = set()
            for path, cat in (
                ("/attractions/list-by-latlng", "sightseeing"),
                ("/restaurants/list-by-latlng", "food"),
            ):
                data = await _get(
                    client,
                    path,
                    {
                        "latitude": lat,
                        "longitude": lng,
                        "limit": str(limit),
                        "lang": "en_US",
                    },
                )
                items = (data or {}).get("data", []) if isinstance(data, dict) else []
                for it in items:
                    norm = _norm_item(it, cat)
                    if norm and norm["name"].lower() not in seen:
                        seen.add(norm["name"].lower())
                        out.append(norm)
            return out
    except Exception:
        return []
