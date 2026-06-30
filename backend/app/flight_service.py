"""Live flight status via AeroDataBox (RapidAPI).

Looks up a flight by its IATA/ICAO flight number + date, normalizes the
response, and updates the stored Journey snapshot. Designed to be called for
flights within ~24h of departure (on app open and by a periodic scheduler).

Configuration (backend/.env):
    RAPIDAPI_KEY=<your AeroDataBox RapidAPI key>
    # optional override:
    AERODATABOX_HOST=aerodatabox.p.rapidapi.com

Without a key the service degrades gracefully (no-op refresh).
"""
from __future__ import annotations

import os
from datetime import date, datetime, timezone

import httpx
from sqlmodel import Session, select

from .db_models import Journey

_HOST = os.getenv("AERODATABOX_HOST", "aerodatabox.p.rapidapi.com")

# How many days ahead we start polling a flight's status.
_WINDOW_DAYS = 1


def _api_key() -> str | None:
    key = os.getenv("RAPIDAPI_KEY", "").strip()
    return key or None


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def _flight_date(journey: Journey) -> str:
    """Best-effort YYYY-MM-DD for the flight, from depart (falls back today)."""
    raw = (journey.depart or "").strip()
    if len(raw) >= 10:
        return raw[:10]
    return date.today().isoformat()


def _within_window(journey: Journey) -> bool:
    fd = _flight_date(journey)
    try:
        d = date.fromisoformat(fd)
    except ValueError:
        return False
    delta = (d - date.today()).days
    return 0 <= delta <= _WINDOW_DAYS


def _norm_status(raw: str) -> str:
    s = (raw or "").strip().lower()
    mapping = {
        "scheduled": "scheduled",
        "expected": "scheduled",
        "checkin": "scheduled",
        "check-in": "scheduled",
        "boarding": "active",
        "gateclosed": "active",
        "gate closed": "active",
        "approaching": "active",
        "enroute": "active",
        "en route": "active",
        "active": "active",
        "departed": "active",
        "arrived": "landed",
        "landed": "landed",
        "delayed": "delayed",
        "cancelled": "cancelled",
        "canceled": "cancelled",
        "canceleduncertain": "cancelled",
        "diverted": "diverted",
    }
    return mapping.get(s, s or "unknown")


def _pick_time(block: dict, *keys: str) -> str:
    """Pull a local time string from an AeroDataBox time sub-object."""
    for k in keys:
        v = block.get(k)
        if isinstance(v, dict):
            t = v.get("local") or v.get("utc")
            if t:
                return str(t)
    return ""


def _normalize(flight: dict) -> dict:
    dep = flight.get("departure") or {}
    arr = flight.get("arrival") or {}
    status = _norm_status(str(flight.get("status", "")))

    sched_dep = _pick_time(dep, "scheduledTime")
    est_dep = _pick_time(dep, "revisedTime", "predictedTime", "actualTime")
    sched_arr = _pick_time(arr, "scheduledTime")
    est_arr = _pick_time(arr, "revisedTime", "predictedTime", "actualTime")

    note = ""
    if status == "cancelled":
        note = "Flight cancelled"
    elif status == "diverted":
        note = "Flight diverted"
    elif est_dep and sched_dep and est_dep != sched_dep:
        note = "Departure time changed"
        status = "delayed" if status in ("scheduled", "unknown") else status

    return {
        "status": status,
        "status_note": note,
        "departure_terminal": str(dep.get("terminal", "") or ""),
        "departure_gate": str(dep.get("gate", "") or ""),
        "arrival_terminal": str(arr.get("terminal", "") or ""),
        "arrival_gate": str(arr.get("gate", "") or ""),
        "scheduled_departure": sched_dep,
        "estimated_departure": est_dep,
        "scheduled_arrival": sched_arr,
        "estimated_arrival": est_arr,
    }


async def fetch_flight_status(flight_number: str, date_iso: str) -> dict | None:
    """Call AeroDataBox for a flight number + date. Returns normalized dict or None."""
    key = _api_key()
    fn = (flight_number or "").strip().upper().replace(" ", "")
    if not key or not fn:
        return None

    url = f"https://{_HOST}/flights/number/{fn}/{date_iso}"
    headers = {"X-RapidAPI-Key": key, "X-RapidAPI-Host": _HOST}
    params = {
        "withAircraftImage": "false",
        "withLocation": "false",
    }
    try:
        async with httpx.AsyncClient(timeout=12.0) as client:
            res = await client.get(url, headers=headers, params=params)
        if res.status_code != 200:
            return None
        body = res.json()
        flights = body if isinstance(body, list) else body.get("departures") or []
        if not flights:
            return None
        return _normalize(flights[0])
    except Exception:
        return None


def _local_hhmm(raw: str) -> str:
    """Extract a local HH:MM time from an AeroDataBox local time string."""
    import re

    m = re.search(r"(\d{1,2}):(\d{2})", raw or "")
    if not m:
        return ""
    return f"{int(m.group(1)):02d}:{m.group(2)}"


async def lookup_flight(flight_number: str, date_iso: str) -> dict | None:
    """Look up a flight's schedule by number + date for the create wizard.

    Returns airline, local departure time (HH:MM) and airports, or None when
    no key is configured / the flight can't be found (caller degrades to manual).
    """
    key = _api_key()
    fn = (flight_number or "").strip().upper().replace(" ", "")
    if not key or not fn:
        return None
    di = (date_iso or "").strip()[:10] or date.today().isoformat()
    url = f"https://{_HOST}/flights/number/{fn}/{di}"
    headers = {"X-RapidAPI-Key": key, "X-RapidAPI-Host": _HOST}
    params = {"withAircraftImage": "false", "withLocation": "false"}
    try:
        async with httpx.AsyncClient(timeout=12.0) as client:
            res = await client.get(url, headers=headers, params=params)
        if res.status_code != 200:
            return None
        body = res.json()
        flights = body if isinstance(body, list) else body.get("departures") or []
        if not flights:
            return None
        f = flights[0]
        dep = f.get("departure") or {}
        arr = f.get("arrival") or {}
        airline = f.get("airline") or {}
        dep_airport = dep.get("airport") or {}
        sched_dep = _pick_time(dep, "scheduledTime")
        sched_arr = _pick_time(arr, "scheduledTime")
        return {
            "flight_number": fn,
            "airline": str(airline.get("name", "") or ""),
            "departure_time": _local_hhmm(sched_dep),
            "departure_airport": str(
                dep_airport.get("name", "") or dep_airport.get("iata", "") or ""
            ),
            "arrival_time": _local_hhmm(sched_arr),
            "scheduled_departure": sched_dep,
        }
    except Exception:
        return None


def _changes(journey: Journey, snap: dict) -> list[str]:
    """Human-readable alerts comparing the previous snapshot to the new one."""
    alerts: list[str] = []
    if journey.status and snap["status"] != journey.status:
        if snap["status"] == "delayed":
            alerts.append(f"{journey.flight_number} is delayed")
        elif snap["status"] == "cancelled":
            alerts.append(f"{journey.flight_number} is cancelled")
        elif snap["status"] == "diverted":
            alerts.append(f"{journey.flight_number} has been diverted")
    if (
        journey.departure_terminal
        and snap["departure_terminal"]
        and snap["departure_terminal"] != journey.departure_terminal
    ):
        alerts.append(
            f"{journey.flight_number} departure terminal changed to "
            f"{snap['departure_terminal']}"
        )
    return alerts


async def refresh_journey(journey: Journey, session: Session, force: bool = False) -> list[str]:
    """Refresh one flight Journey if it's due. Returns any new alerts."""
    if journey.mode != "flight" or not journey.flight_number.strip():
        return []
    if not force and not _within_window(journey):
        return []

    snap = await fetch_flight_status(journey.flight_number, _flight_date(journey))
    if snap is None:
        return []

    alerts = _changes(journey, snap)
    for field, value in snap.items():
        setattr(journey, field, value)
    journey.status_checked_at = _now_iso()
    session.add(journey)
    session.commit()
    return alerts


async def refresh_due_flights(session: Session) -> list[str]:
    """Refresh all flight journeys within the polling window. Returns alerts."""
    if _api_key() is None:
        return []
    journeys = session.exec(select(Journey).where(Journey.mode == "flight")).all()
    all_alerts: list[str] = []
    for j in journeys:
        if j.flight_number.strip() and _within_window(j):
            all_alerts.extend(await refresh_journey(j, session, force=True))
    return all_alerts
