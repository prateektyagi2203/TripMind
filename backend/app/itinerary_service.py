"""Day-by-day itinerary generation, retrieval and saving.

- ``generate_itinerary`` builds a *draft* plan (not persisted) using GPT-4o,
  seeded with real nearby POIs from ``places_service``. The Flutter planner
  lets the user edit the draft before saving it back via ``save_itinerary``.
- ``get_itinerary`` / ``save_itinerary`` read & replace the persisted plan.
- All operations are gated to trip members (collaborative editing).

Degrades gracefully: without an OpenAI key it returns a dated scaffold seeded
with any available POIs; without a places key it falls back to AI-only.
"""
from __future__ import annotations

import json
import uuid
from datetime import date, timedelta

from fastapi import HTTPException, status
from sqlmodel import Session, select

from . import places_service
from .concierge_service import _get_client, _model
from .db_models import (
    Destination,
    ItineraryActivity,
    ItineraryDay,
    Journey,
    Trip,
    TripMember,
    User,
)
from .itinerary_schemas import (
    ActivityOut,
    ItineraryDayIn,
    ItineraryDayOut,
    ItineraryPlanOut,
    NearbyPlace,
    NearbyResponse,
    PlanPreferences,
)


# ---- Membership ----------------------------------------------------------
def _require_member(trip_id: str, user: User, session: Session) -> Trip:
    membership = session.exec(
        select(TripMember).where(
            TripMember.trip_id == trip_id, TripMember.user_id == user.id
        )
    ).first()
    trip = session.get(Trip, trip_id)
    if membership is None or trip is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found."
        )
    return trip


# ---- Date helpers --------------------------------------------------------
def _date_range(start: str, end: str) -> list[str]:
    try:
        d0 = date.fromisoformat(start[:10])
        d1 = date.fromisoformat(end[:10])
    except ValueError:
        return []
    if d1 < d0:
        d1 = d0
    days = (d1 - d0).days
    days = min(days, 60)  # safety cap
    return [(d0 + timedelta(days=i)).isoformat() for i in range(days + 1)]


def _dest_for_date(day_iso: str, dests: list[Destination]) -> Destination | None:
    if not dests:
        return None
    for d in dests:
        ci = (d.checkin or "")[:10]
        co = (d.checkout or "")[:10]
        if ci and co and ci <= day_iso <= co:
            return d
        if ci and not co and ci <= day_iso:
            return d
    return dests[-1]


# ---- Persistence ---------------------------------------------------------
def _load_plan(trip_id: str, session: Session) -> ItineraryPlanOut:
    days = session.exec(
        select(ItineraryDay)
        .where(ItineraryDay.trip_id == trip_id)
        .order_by(ItineraryDay.day_index)
    ).all()
    day_outs: list[ItineraryDayOut] = []
    for d in days:
        acts = session.exec(
            select(ItineraryActivity)
            .where(ItineraryActivity.day_id == d.id)
            .order_by(ItineraryActivity.order_index)
        ).all()
        day_outs.append(
            ItineraryDayOut(
                id=d.id,
                day_index=d.day_index,
                date=d.date,
                title=d.title,
                area=d.area,
                summary=d.summary,
                is_light=d.is_light,
                activities=[
                    ActivityOut(
                        id=a.id,
                        order_index=a.order_index,
                        time=a.time,
                        title=a.title,
                        description=a.description,
                        category=a.category,
                        location_name=a.location_name,
                        location_address=a.location_address,
                        lat=a.lat,
                        lng=a.lng,
                        source=a.source,
                        rating=a.rating,
                        link=a.link,
                        image_url=a.image_url,
                    )
                    for a in acts
                ],
            )
        )
    return ItineraryPlanOut(trip_id=trip_id, days=day_outs)


def get_itinerary(trip_id: str, user: User, session: Session) -> ItineraryPlanOut:
    _require_member(trip_id, user, session)
    return _load_plan(trip_id, session)


def save_itinerary(
    trip_id: str, days: list[ItineraryDayIn], user: User, session: Session
) -> ItineraryPlanOut:
    _require_member(trip_id, user, session)
    # Full replace: delete existing days + their activities, then re-insert.
    existing = session.exec(
        select(ItineraryDay).where(ItineraryDay.trip_id == trip_id)
    ).all()
    for d in existing:
        for a in session.exec(
            select(ItineraryActivity).where(ItineraryActivity.day_id == d.id)
        ).all():
            session.delete(a)
        session.delete(d)
    session.flush()

    for di, day in enumerate(days):
        row = ItineraryDay(
            trip_id=trip_id,
            day_index=day.day_index if day.day_index else di,
            date=day.date,
            title=day.title,
            area=day.area,
            summary=day.summary,
            is_light=day.is_light,
        )
        session.add(row)
        session.flush()
        for ai, act in enumerate(day.activities):
            session.add(
                ItineraryActivity(
                    day_id=row.id,
                    order_index=ai,
                    time=act.time,
                    title=act.title,
                    description=act.description,
                    category=act.category,
                    location_name=act.location_name,
                    location_address=act.location_address,
                    lat=act.lat,
                    lng=act.lng,
                    source=act.source,
                    rating=act.rating,
                    link=act.link,
                    image_url=act.image_url,
                )
            )
    session.commit()
    return _load_plan(trip_id, session)


# ---- Nearby (browse) -----------------------------------------------------
async def _ai_nearby(
    city: str,
    hotel_name: str,
    hotel_address: str,
    category: str,
    query: str,
    limit: int = 12,
) -> list[dict]:
    """AI-generated nearby suggestions used when TripAdvisor is unavailable or
    when the traveller types a free-text search (e.g. 'Indian food')."""
    client = _get_client()
    if client is None:
        return []
    cat_hint = (
        "" if category in ("", "all") else f" Only include the '{category}' category."
    )
    q_hint = f' The traveller is specifically searching for: "{query}".' if query else ""
    near = hotel_name or hotel_address or "the traveller's hotel"
    prompt = (
        f"Suggest up to {limit} real, well-rated places to visit near {near} "
        f"in {city or 'the destination'}.{q_hint}{cat_hint} "
        "Use real, specific place names and an approximate street address or area. "
        "Category must be one of: food, sightseeing, nature, culture, relax, "
        "shopping, nightlife, other. "
        'Respond as JSON only: {"places": [{"name": "...", "address": "...", '
        '"category": "...", "rating": "4.5"}]}.'
    )
    try:
        res = await client.chat.completions.create(
            model=_model(),
            messages=[{"role": "user", "content": prompt}],
            temperature=0.4,
            max_tokens=1000,
            response_format={"type": "json_object"},
        )
        data = json.loads(res.choices[0].message.content or "{}")
    except Exception:
        return []
    out: list[dict] = []
    for p in (data.get("places") or [])[:limit] if isinstance(data, dict) else []:
        if not isinstance(p, dict):
            continue
        name = str(p.get("name", "") or "").strip()
        if not name:
            continue
        out.append(
            {
                "name": name,
                "address": str(p.get("address", "") or "").strip(),
                "lat": "",
                "lng": "",
                "rating": str(p.get("rating", "") or "").strip(),
                "link": "",
                "image_url": "",
                "category": str(p.get("category", "other") or "other").strip().lower(),
            }
        )
    return out


async def nearby_for_trip(
    trip_id: str, category: str, user: User, session: Session, query: str = ""
) -> NearbyResponse:
    _require_member(trip_id, user, session)
    dests = session.exec(
        select(Destination)
        .where(Destination.trip_id == trip_id)
        .order_by(Destination.order_index)
    ).all()
    results: list[NearbyPlace] = []
    seen: set[str] = set()
    source = "fallback"

    def _add(items: list[dict]) -> None:
        for p in items:
            if category and category != "all" and p.get("category") != category:
                continue
            key = p["name"].lower()
            if key in seen:
                continue
            seen.add(key)
            results.append(NearbyPlace(**p))

    # A free-text search goes straight to the AI suggester. Otherwise try the
    # real places API first, then fall back to AI when it returns nothing.
    if not query:
        for d in dests:
            _add(await places_service.nearby_places(d.hotel_name, d.hotel_address, d.city))
        if results:
            source = "tripadvisor"

    if not results:
        for d in dests:
            _add(
                await _ai_nearby(
                    d.city, d.hotel_name, d.hotel_address, category, query
                )
            )
            if len(results) >= 24:
                break
        if results:
            source = "ai"

    return NearbyResponse(source=source, results=results[:30])


# ---- Generation ----------------------------------------------------------
def _hhmm_minus(hhmm: str, minutes: int) -> str:
    """Return HH:MM that is ``minutes`` before the given HH:MM (clamped to 00:00)."""
    try:
        h, m = (int(x) for x in hhmm.split(":")[:2])
    except (ValueError, AttributeError):
        return ""
    total = h * 60 + m - minutes
    if total < 0:
        total = 0
    return f"{total // 60:02d}:{total % 60:02d}"


def _departure_flight(trip_id: str, session: Session) -> dict | None:
    """The flight home for a trip: prefers a journey flagged to 'Home', else any
    flight that carries a departure time. Returns date/time/from/flight info."""
    journeys = session.exec(
        select(Journey).where(
            Journey.trip_id == trip_id, Journey.mode == "flight"
        )
    ).all()
    home = [j for j in journeys if (j.to_city or "").strip().lower() == "home"]
    cand = home[0] if home else next(
        (j for j in journeys if "T" in (j.depart or "")), None
    )
    if cand is None:
        return None
    dep = (cand.depart or "").strip()
    time = ""
    if "T" in dep:
        time = dep.split("T", 1)[1][:5]
    return {
        "date": dep[:10],
        "time": time,
        "from_city": (cand.from_city or "").strip(),
        "flight_number": (cand.flight_number or "").strip(),
        "airline": (cand.airline or "").strip(),
    }


def _acts_per_day(pace: str, is_light: bool) -> int:
    if is_light:
        return 2
    return {"light": 2, "balanced": 4, "packed": 6}.get(pace, 4)


def _build_prompt(
    trip: Trip,
    dates: list[str],
    dests: list[Destination],
    pois_by_city: dict[str, list[dict]],
    prefs: PlanPreferences,
    dep_flight: dict | None = None,
) -> str:
    lines: list[str] = []
    lines.append(
        f'Plan a day-by-day itinerary for the trip "{trip.name}" '
        f"from {dates[0]} to {dates[-1]} ({len(dates)} days)."
    )
    lines.append("\nStays / hotels:")
    for d in dests:
        lines.append(
            f"- {d.city}: hotel {d.hotel_name or 'TBD'}"
            + (f" ({d.hotel_address})" if d.hotel_address else "")
            + (f", check-in {d.checkin}" if d.checkin else "")
            + (f", check-out {d.checkout}" if d.checkout else "")
        )
    for city, pois in pois_by_city.items():
        if not pois:
            continue
        lines.append(f"\nReal nearby places in {city} (prefer these, use exact names):")
        for p in pois[:18]:
            rating = f" rating {p['rating']}" if p.get("rating") else ""
            lines.append(f"- [{p['category']}] {p['name']}{rating} — {p.get('address', '')}")
    lines.append("\nTraveler preferences:")
    lines.append(f"- Pace: {prefs.pace}")
    if prefs.interests:
        lines.append(f"- Interests: {', '.join(prefs.interests)}")
    if prefs.travelers:
        lines.append(f"- Travelers: {prefs.travelers}")
    if prefs.notes:
        lines.append(f"- Notes: {prefs.notes}")

    # Departure-flight aware rule for the last day.
    dep_rule = ""
    if dep_flight and dep_flight.get("time"):
        ftime = dep_flight["time"]
        leave_by = _hhmm_minus(ftime, 180)  # ~3h before; AI adjusts for transfer
        fno = dep_flight.get("flight_number") or "the flight home"
        fcity = dep_flight.get("from_city") or "the city"
        lines.append(
            f"\nDeparture flight home: {fno} departs at {ftime} local on "
            f"{dep_flight.get('date', dates[-1])} from {fcity}."
        )
        dep_rule = (
            f"- The LAST day is the departure day. Its FIRST activity MUST be "
            f"'Leave hotel by HH:MM' so the traveller catches the {ftime} flight: "
            f"be at the airport ~3 hours before for an international flight, PLUS "
            f"realistic hotel->airport transfer time (a rough starting point is "
            f"~{leave_by}, but adjust for the actual transfer). Use category "
            f"'transit'. After that only a quick breakfast / check-out - nothing "
            f"far from the hotel.\n"
        )

    lines.append(
        "\nRules:\n"
        + ("- Keep the FIRST day light (arrival): few, relaxed, near the hotel.\n"
           if prefs.keep_first_day_light else "")
        + (dep_rule or "- Make the LAST day light (departure / flight home): "
           "nothing far, end near the hotel.\n")
        + "- Order activities sensibly through the day with meals; include a time for each.\n"
        "- Keep each description to one short sentence (max 12 words).\n"
        "- Prefer the real nearby places listed above; copy their exact name and address.\n"
        "- Category must be one of: food, sightseeing, nature, culture, relax, shopping, transit, nightlife, other.\n"
    )
    lines.append(
        '\nRespond as compact JSON only: {"days": [{"date": "YYYY-MM-DD", '
        '"title": "<short day title>", "area": "<city/neighbourhood>", '
        '"is_light": <bool>, "activities": [{"time": "09:30", "title": "...", '
        '"description": "...", "category": "...", "location_name": "...", '
        '"location_address": "..."}]}]}. '
        f"Provide exactly {len(dates)} day objects in date order."
    )
    return "\n".join(lines)


def _enrich(act: dict, lookup: dict[str, dict]) -> dict:
    """Fill lat/lng/link/image/rating + source from a matched POI candidate."""
    name = str(act.get("location_name") or act.get("title") or "").strip()
    poi = lookup.get(name.lower())
    if poi:
        return {
            "lat": poi.get("lat", ""),
            "lng": poi.get("lng", ""),
            "link": poi.get("link", ""),
            "image_url": poi.get("image_url", ""),
            "rating": poi.get("rating", ""),
            "address": poi.get("address", ""),
            "source": "places",
        }
    return {"lat": "", "lng": "", "link": "", "image_url": "", "rating": "", "address": "", "source": "ai"}


def _scaffold(
    dates: list[str], dests: list[Destination], pois_by_city: dict[str, list[dict]],
    prefs: PlanPreferences,
) -> ItineraryPlanOut:
    """No-AI fallback: dated days seeded with a few real POIs each."""
    day_outs: list[ItineraryDayOut] = []
    used: set[str] = set()
    for i, day_iso in enumerate(dates):
        dest = _dest_for_date(day_iso, dests)
        city = dest.city if dest else ""
        is_light = (i == 0 and prefs.keep_first_day_light) or i == len(dates) - 1
        acts: list[ActivityOut] = []
        pool = [p for p in pois_by_city.get(city, []) if p["name"].lower() not in used]
        for j, p in enumerate(pool[: _acts_per_day(prefs.pace, is_light)]):
            used.add(p["name"].lower())
            acts.append(
                ActivityOut(
                    id=uuid.uuid4().hex,
                    order_index=j,
                    time="",
                    title=p["name"],
                    description="",
                    category=p.get("category", "other"),
                    location_name=p["name"],
                    location_address=p.get("address", ""),
                    lat=p.get("lat", ""),
                    lng=p.get("lng", ""),
                    source="places",
                    rating=p.get("rating", ""),
                    link=p.get("link", ""),
                    image_url=p.get("image_url", ""),
                )
            )
        title = "Arrival & settle in" if i == 0 else (
            "Departure day" if i == len(dates) - 1 else f"Day {i + 1} in {city}".strip()
        )
        day_outs.append(
            ItineraryDayOut(
                id=uuid.uuid4().hex,
                day_index=i,
                date=day_iso,
                title=title,
                area=city,
                summary="",
                is_light=is_light,
                activities=acts,
            )
        )
    return ItineraryPlanOut(trip_id=dests[0].trip_id if dests else "", days=day_outs)


def _parse_days_lenient(content: str) -> list:
    """Parse the model's JSON, recovering complete day objects even if the
    response was truncated by the token limit (drops the final partial day)."""
    content = content or "{}"
    try:
        data = json.loads(content)
        if isinstance(data, dict):
            return data.get("days", []) or []
        return []
    except Exception:
        pass
    # Salvage: walk the "days" array and collect each fully-closed object.
    idx = content.find('"days"')
    start = content.find("[", idx) if idx != -1 else -1
    if start == -1:
        return []
    days: list = []
    depth = 0
    obj_start: int | None = None
    in_str = False
    esc = False
    for k in range(start + 1, len(content)):
        ch = content[k]
        if in_str:
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == '"':
                in_str = False
            continue
        if ch == '"':
            in_str = True
        elif ch == "{":
            if depth == 0:
                obj_start = k
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0 and obj_start is not None:
                try:
                    days.append(json.loads(content[obj_start : k + 1]))
                except Exception:
                    pass
                obj_start = None
        elif ch == "]" and depth == 0:
            break
    return days


def _scaffold_day(
    i: int, day_iso: str, dests: list[Destination],
    pois_by_city: dict[str, list[dict]], prefs: PlanPreferences, used: set[str],
    last_index: int,
) -> ItineraryDayOut:
    """Build a single dated scaffold day (used to fill gaps the AI didn't cover)."""
    dest = _dest_for_date(day_iso, dests)
    city = dest.city if dest else ""
    is_light = (i == 0 and prefs.keep_first_day_light) or i == last_index
    acts: list[ActivityOut] = []
    pool = [p for p in pois_by_city.get(city, []) if p["name"].lower() not in used]
    for j, p in enumerate(pool[: _acts_per_day(prefs.pace, is_light)]):
        used.add(p["name"].lower())
        acts.append(
            ActivityOut(
                id=uuid.uuid4().hex,
                order_index=j,
                time="",
                title=p["name"],
                description="",
                category=p.get("category", "other"),
                location_name=p["name"],
                location_address=p.get("address", ""),
                lat=p.get("lat", ""),
                lng=p.get("lng", ""),
                source="places",
                rating=p.get("rating", ""),
                link=p.get("link", ""),
                image_url=p.get("image_url", ""),
            )
        )
    title = "Arrival & settle in" if i == 0 else (
        "Departure day" if i == last_index else f"Day {i + 1} in {city}".strip()
    )
    return ItineraryDayOut(
        id=uuid.uuid4().hex,
        day_index=i,
        date=day_iso,
        title=title,
        area=city,
        summary="",
        is_light=is_light,
        activities=acts,
    )


async def generate_itinerary(
    trip_id: str, prefs: PlanPreferences, user: User, session: Session
) -> ItineraryPlanOut:
    trip = _require_member(trip_id, user, session)
    dests = session.exec(
        select(Destination)
        .where(Destination.trip_id == trip_id)
        .order_by(Destination.order_index)
    ).all()
    dates = _date_range(trip.start_date, trip.end_date)
    if not dates:
        return ItineraryPlanOut(trip_id=trip_id, days=[])

    # Seed real nearby places per city.
    pois_by_city: dict[str, list[dict]] = {}
    for d in dests:
        if d.city and d.city not in pois_by_city:
            pois_by_city[d.city] = await places_service.nearby_places(
                d.hotel_name, d.hotel_address, d.city
            )
    lookup: dict[str, dict] = {}
    for pois in pois_by_city.values():
        for p in pois:
            lookup[p["name"].lower()] = p

    client = _get_client()
    if client is None:
        return _scaffold(dates, list(dests), pois_by_city, prefs)

    dep_flight = _departure_flight(trip_id, session)
    prompt = _build_prompt(trip, dates, list(dests), pois_by_city, prefs, dep_flight)
    # Budget output tokens for the trip length; capped to stay within the
    # model's output limit. Roughly ~480 tokens per day of activities.
    max_out = min(16000, max(2600, len(dates) * 480 + 600))
    try:
        res = await client.chat.completions.create(
            model=_model(),
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            max_tokens=max_out,
            response_format={"type": "json_object"},
        )
        raw_days = _parse_days_lenient(res.choices[0].message.content or "{}")
    except Exception:
        return _scaffold(dates, list(dests), pois_by_city, prefs)

    day_outs: list[ItineraryDayOut] = []
    for i, raw in enumerate(raw_days):
        if not isinstance(raw, dict):
            continue
        day_iso = str(raw.get("date", "") or "").strip() or (
            dates[i] if i < len(dates) else ""
        )
        acts_raw = raw.get("activities", []) or []
        acts: list[ActivityOut] = []
        for j, a in enumerate(acts_raw):
            if not isinstance(a, dict):
                continue
            title = str(a.get("title", "") or "").strip()
            if not title:
                continue
            enriched = _enrich(a, lookup)
            address = str(a.get("location_address", "") or "").strip() or enriched["address"]
            acts.append(
                ActivityOut(
                    id=uuid.uuid4().hex,
                    order_index=j,
                    time=str(a.get("time", "") or "").strip(),
                    title=title,
                    description=str(a.get("description", "") or "").strip(),
                    category=str(a.get("category", "other") or "other").strip().lower(),
                    location_name=str(a.get("location_name", "") or "").strip(),
                    location_address=address,
                    lat=enriched["lat"],
                    lng=enriched["lng"],
                    source=enriched["source"],
                    rating=enriched["rating"],
                    link=enriched["link"],
                    image_url=enriched["image_url"],
                )
            )
        day_outs.append(
            ItineraryDayOut(
                id=uuid.uuid4().hex,
                day_index=i,
                date=day_iso,
                title=str(raw.get("title", "") or "").strip(),
                area=str(raw.get("area", "") or "").strip(),
                summary=str(raw.get("summary", "") or "").strip(),
                is_light=bool(raw.get("is_light", False)),
                activities=acts,
            )
        )

    if not day_outs:
        return _scaffold(dates, list(dests), pois_by_city, prefs)

    # If the model returned fewer days than the trip span (e.g. truncation or
    # a long trip), fill the remaining dates with dated scaffold days so the
    # user always gets the full trip to edit.
    if len(day_outs) < len(dates):
        used: set[str] = set()
        for d in day_outs:
            for a in d.activities:
                if a.location_name:
                    used.add(a.location_name.lower())
        last_index = len(dates) - 1
        for i in range(len(day_outs), len(dates)):
            day_outs.append(
                _scaffold_day(
                    i, dates[i], list(dests), pois_by_city, prefs, used, last_index
                )
            )
    return ItineraryPlanOut(trip_id=trip_id, days=day_outs)
