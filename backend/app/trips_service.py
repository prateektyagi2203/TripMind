"""Trip creation, listing, joining, and hotel resolution."""
from __future__ import annotations

import json
import secrets
from datetime import date

from fastapi import HTTPException, status
from sqlmodel import Session, select

from .concierge_service import _get_client, _model
from .db_models import Destination, Journey, Trip, TripMember, User
from .trip_schemas import (
    DestinationOut,
    HotelResolveResponse,
    HotelSearchResponse,
    HotelSuggestion,
    JourneyOut,
    TripCreate,
    TripMemberOut,
    TripOut,
)

_CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"  # no ambiguous chars


def _gen_code(session: Session) -> str:
    for _ in range(20):
        code = "".join(secrets.choice(_CODE_ALPHABET) for _ in range(6))
        if session.exec(select(Trip).where(Trip.invite_code == code)).first() is None:
            return code
    raise HTTPException(status_code=500, detail="Could not allocate invite code.")


def _status(start: str, end: str) -> str:
    today = date.today().isoformat()
    if today < start:
        return "Upcoming"
    if today > end:
        return "Completed"
    return "Ongoing"


def create_trip(payload: TripCreate, owner: User, session: Session) -> TripOut:
    trip = Trip(
        name=payload.name.strip(),
        owner_id=owner.id,
        start_date=payload.start_date,
        end_date=payload.end_date,
        currency=payload.currency,
        cover_gradient=payload.cover_gradient,
        invite_code=_gen_code(session),
    )
    session.add(trip)
    session.flush()  # assign trip.id without committing yet

    session.add(TripMember(trip_id=trip.id, user_id=owner.id, role="owner"))

    for i, d in enumerate(payload.destinations):
        session.add(
            Destination(
                trip_id=trip.id,
                order_index=i,
                city=d.city.strip(),
                hotel_name=d.hotel_name.strip(),
                hotel_address=d.hotel_address.strip(),
                checkin=d.checkin,
                checkout=d.checkout,
            )
        )
    for i, j in enumerate(payload.journeys):
        session.add(
            Journey(
                trip_id=trip.id,
                order_index=i,
                mode=j.mode,
                from_city=j.from_city.strip(),
                to_city=j.to_city.strip(),
                pnr=j.pnr.strip(),
                flight_number=j.flight_number.strip().upper().replace(" ", ""),
                airline=j.airline.strip(),
                route=j.route.strip(),
                depart=j.depart,
                arrive=j.arrive,
            )
        )

    session.commit()
    session.refresh(trip)
    return _to_out(trip, owner, session)


def update_trip(
    trip_id: str, payload: TripCreate, user: User, session: Session
) -> TripOut:
    """Replace a trip's editable fields, destinations and journeys.

    Only the trip owner may edit. Live flight-status snapshots are carried over
    for journeys whose flight number is unchanged, so editing other details
    doesn't wipe a flight's current status.
    """
    trip = session.get(Trip, trip_id)
    if trip is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found."
        )
    membership = session.exec(
        select(TripMember).where(
            TripMember.trip_id == trip_id, TripMember.user_id == user.id
        )
    ).first()
    if membership is None or membership.role != "owner":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the trip owner can edit this trip.",
        )

    trip.name = payload.name.strip()
    trip.start_date = payload.start_date
    trip.end_date = payload.end_date
    trip.currency = payload.currency
    trip.cover_gradient = payload.cover_gradient
    session.add(trip)

    # Snapshot existing flight status keyed by flight number, to preserve it.
    old_journeys = session.exec(
        select(Journey).where(Journey.trip_id == trip_id)
    ).all()
    status_by_flight: dict[str, Journey] = {
        j.flight_number: j for j in old_journeys if j.flight_number
    }

    # Replace destinations.
    for d in session.exec(
        select(Destination).where(Destination.trip_id == trip_id)
    ).all():
        session.delete(d)
    for j in old_journeys:
        session.delete(j)
    session.flush()

    for i, d in enumerate(payload.destinations):
        session.add(
            Destination(
                trip_id=trip.id,
                order_index=i,
                city=d.city.strip(),
                hotel_name=d.hotel_name.strip(),
                hotel_address=d.hotel_address.strip(),
                checkin=d.checkin,
                checkout=d.checkout,
            )
        )
    for i, j in enumerate(payload.journeys):
        fn = j.flight_number.strip().upper().replace(" ", "")
        prev = status_by_flight.get(fn)
        session.add(
            Journey(
                trip_id=trip.id,
                order_index=i,
                mode=j.mode,
                from_city=j.from_city.strip(),
                to_city=j.to_city.strip(),
                pnr=j.pnr.strip(),
                flight_number=fn,
                airline=j.airline.strip(),
                route=j.route.strip(),
                depart=j.depart,
                arrive=j.arrive,
                status=prev.status if prev else "",
                status_note=prev.status_note if prev else "",
                departure_terminal=prev.departure_terminal if prev else "",
                departure_gate=prev.departure_gate if prev else "",
                arrival_terminal=prev.arrival_terminal if prev else "",
                arrival_gate=prev.arrival_gate if prev else "",
                scheduled_departure=prev.scheduled_departure if prev else "",
                estimated_departure=prev.estimated_departure if prev else "",
                scheduled_arrival=prev.scheduled_arrival if prev else "",
                estimated_arrival=prev.estimated_arrival if prev else "",
                status_checked_at=prev.status_checked_at if prev else "",
            )
        )

    session.commit()
    session.refresh(trip)
    return _to_out(trip, user, session)


def _to_out(trip: Trip, viewer: User, session: Session) -> TripOut:
    members = session.exec(
        select(TripMember).where(TripMember.trip_id == trip.id)
    ).all()
    member_outs: list[TripMemberOut] = []
    owner_name = ""
    role = "member"
    for m in members:
        u = session.get(User, m.user_id)
        name = u.name if u else "Traveler"
        if m.role == "owner":
            owner_name = name
        if m.user_id == viewer.id:
            role = m.role
        member_outs.append(
            TripMemberOut(user_id=m.user_id, name=name, role=m.role)
        )

    dests = session.exec(
        select(Destination)
        .where(Destination.trip_id == trip.id)
        .order_by(Destination.order_index)
    ).all()
    journeys = session.exec(
        select(Journey)
        .where(Journey.trip_id == trip.id)
        .order_by(Journey.order_index)
    ).all()

    return TripOut(
        id=trip.id,
        name=trip.name,
        start_date=trip.start_date,
        end_date=trip.end_date,
        currency=trip.currency,
        cover_gradient=trip.cover_gradient,
        invite_code=trip.invite_code,
        status=_status(trip.start_date, trip.end_date),
        role=role,
        owner_name=owner_name,
        members=member_outs,
        destinations=[
            DestinationOut(
                id=d.id,
                order_index=d.order_index,
                city=d.city,
                hotel_name=d.hotel_name,
                hotel_address=d.hotel_address,
                checkin=d.checkin,
                checkout=d.checkout,
            )
            for d in dests
        ],
        journeys=[
            JourneyOut(
                id=j.id,
                order_index=j.order_index,
                mode=j.mode,
                from_city=j.from_city,
                to_city=j.to_city,
                pnr=j.pnr,
                flight_number=j.flight_number,
                airline=j.airline,
                route=j.route,
                depart=j.depart,
                arrive=j.arrive,
                status=j.status,
                status_note=j.status_note,
                departure_terminal=j.departure_terminal,
                departure_gate=j.departure_gate,
                arrival_terminal=j.arrival_terminal,
                arrival_gate=j.arrival_gate,
                scheduled_departure=j.scheduled_departure,
                estimated_departure=j.estimated_departure,
                scheduled_arrival=j.scheduled_arrival,
                estimated_arrival=j.estimated_arrival,
                status_checked_at=j.status_checked_at,
            )
            for j in journeys
        ],
    )


def list_trips(user: User, session: Session) -> list[TripOut]:
    memberships = session.exec(
        select(TripMember).where(TripMember.user_id == user.id)
    ).all()
    trips: list[TripOut] = []
    for m in memberships:
        trip = session.get(Trip, m.trip_id)
        if trip is not None:
            trips.append(_to_out(trip, user, session))
    # Ongoing first, then Upcoming, then Completed; newest start date within group.
    order = {"Ongoing": 0, "Upcoming": 1, "Completed": 2}
    trips.sort(key=lambda t: (order.get(t.status, 3), t.start_date))
    return trips


def get_trip(trip_id: str, user: User, session: Session) -> TripOut:
    membership = session.exec(
        select(TripMember).where(
            TripMember.trip_id == trip_id, TripMember.user_id == user.id
        )
    ).first()
    if membership is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found."
        )
    trip = session.get(Trip, trip_id)
    if trip is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found."
        )
    return _to_out(trip, user, session)


def join_trip(code: str, user: User, session: Session) -> TripOut:
    norm = code.strip().upper()
    trip = session.exec(select(Trip).where(Trip.invite_code == norm)).first()
    if trip is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No trip found for that invite code.",
        )
    existing = session.exec(
        select(TripMember).where(
            TripMember.trip_id == trip.id, TripMember.user_id == user.id
        )
    ).first()
    if existing is None:
        session.add(TripMember(trip_id=trip.id, user_id=user.id, role="member"))
        session.commit()
    return _to_out(trip, user, session)


async def resolve_hotel(query: str, city: str) -> HotelResolveResponse:
    """Resolve a fuzzy hotel query into an exact name + address using GPT-4o.

    Falls back to echoing the query when no OpenAI key is configured.
    """
    client = _get_client()
    if client is None:
        return HotelResolveResponse(
            name=query.strip().title(),
            address=city.strip(),
            source="fallback",
        )

    where = f" in {city.strip()}" if city.strip() else ""
    prompt = (
        f"A traveler typed a hotel name: \"{query.strip()}\"{where}.\n"
        "Identify the most likely real hotel. Respond as compact JSON with keys: "
        '"name" (official hotel name), "address" (full street address with city/country), '
        'and "suggestions" (array of up to 3 alternative official hotel names that '
        "could also match). If unsure, make your best guess. JSON only."
    )
    try:
        res = await client.chat.completions.create(
            model=_model(),
            messages=[{"role": "user", "content": prompt}],
            temperature=0.2,
            max_tokens=220,
            response_format={"type": "json_object"},
        )
        data = json.loads(res.choices[0].message.content or "{}")
        return HotelResolveResponse(
            name=str(data.get("name", query)).strip() or query,
            address=str(data.get("address", "")).strip(),
            source="ai",
            suggestions=[str(s).strip() for s in data.get("suggestions", [])][:3],
        )
    except Exception:
        return HotelResolveResponse(
            name=query.strip().title(), address=city.strip(), source="fallback"
        )


async def search_hotels(query: str, city: str) -> HotelSearchResponse:
    """Return an exhaustive list of real hotels matching the query.

    When the query is a chain/brand (e.g. "Novotel"), list every property of that
    brand in/near the city. Each result has an official name and full address.
    Falls back to a single echoed result when no OpenAI key is configured.
    """
    q = query.strip()
    if not q:
        return HotelSearchResponse(source="fallback", results=[])

    client = _get_client()
    if client is None:
        return HotelSearchResponse(
            source="fallback",
            results=[HotelSuggestion(name=q.title(), address=city.strip())],
        )

    where = f" in or near {city.strip()}" if city.strip() else ""
    prompt = (
        f'A traveler is searching for a hotel: "{q}"{where}.\n'
        "List EVERY real hotel that matches. If the query is a hotel brand or chain "
        '(e.g. "Novotel", "Marriott", "Taj"), include ALL of that brand\'s '
        "properties in and around the city (different sub-brands like Novotel, "
        "Novotel Suites, ibis count if they share the brand the user typed). "
        "Be exhaustive — aim for 8 to 20 results when they exist. "
        'Respond as compact JSON: {"results": [{"name": "<official hotel name>", '
        '"address": "<full street address with area, city, country>"}]}. '
        "Only include hotels you are confident are real. JSON only."
    )
    try:
        res = await client.chat.completions.create(
            model=_model(),
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            max_tokens=900,
            response_format={"type": "json_object"},
        )
        data = json.loads(res.choices[0].message.content or "{}")
        raw = data.get("results", [])
        results: list[HotelSuggestion] = []
        seen: set[str] = set()
        for item in raw:
            if not isinstance(item, dict):
                continue
            name = str(item.get("name", "")).strip()
            if not name or name.lower() in seen:
                continue
            seen.add(name.lower())
            results.append(
                HotelSuggestion(name=name, address=str(item.get("address", "")).strip())
            )
        if not results:
            results = [HotelSuggestion(name=q.title(), address=city.strip())]
        return HotelSearchResponse(source="ai", results=results[:25])
    except Exception:
        return HotelSearchResponse(
            source="fallback",
            results=[HotelSuggestion(name=q.title(), address=city.strip())],
        )
