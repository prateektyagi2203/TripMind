"""SQLModel table definitions for TripMind.

A Trip has many Destinations (city + hotel + stay dates) and many Journeys
(transport legs between cities; a flight leg carries the PNR/airline). Members
link users to trips so family/friends who join see the same shared trip.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlmodel import Field, SQLModel


def _uuid() -> str:
    return uuid.uuid4().hex


def _now() -> datetime:
    return datetime.now(timezone.utc)


class User(SQLModel, table=True):
    __tablename__ = "users"

    id: str = Field(default_factory=_uuid, primary_key=True)
    email: str = Field(index=True, unique=True)
    name: str = ""
    photo_url: str = ""
    created_at: datetime = Field(default_factory=_now)


class Trip(SQLModel, table=True):
    __tablename__ = "trips"

    id: str = Field(default_factory=_uuid, primary_key=True)
    name: str
    owner_id: str = Field(index=True, foreign_key="users.id")
    start_date: str  # ISO date (YYYY-MM-DD)
    end_date: str
    currency: str = "INR"
    invite_code: str = Field(index=True, unique=True)
    cover_gradient: str = "sunset"  # sunset | ocean
    created_at: datetime = Field(default_factory=_now)


class TripMember(SQLModel, table=True):
    __tablename__ = "trip_members"

    id: str = Field(default_factory=_uuid, primary_key=True)
    trip_id: str = Field(index=True, foreign_key="trips.id")
    user_id: str = Field(index=True, foreign_key="users.id")
    role: str = "member"  # owner | member
    joined_at: datetime = Field(default_factory=_now)


class Destination(SQLModel, table=True):
    __tablename__ = "destinations"

    id: str = Field(default_factory=_uuid, primary_key=True)
    trip_id: str = Field(index=True, foreign_key="trips.id")
    order_index: int = 0
    city: str = ""
    hotel_name: str = ""
    hotel_address: str = ""
    checkin: str = ""  # ISO date
    checkout: str = ""


class Traveller(SQLModel, table=True):
    """A person on the trip (the owner + their family/companions)."""

    __tablename__ = "travellers"

    id: str = Field(default_factory=_uuid, primary_key=True)
    trip_id: str = Field(index=True, foreign_key="trips.id")
    order_index: int = 0
    name: str = ""
    age: int = 0  # 0 when unknown
    sex: str = ""  # male | female | other | ""
    is_me: bool = False  # the trip owner / primary traveller


class Journey(SQLModel, table=True):
    __tablename__ = "journeys"

    id: str = Field(default_factory=_uuid, primary_key=True)
    trip_id: str = Field(index=True, foreign_key="trips.id")
    order_index: int = 0
    mode: str = "flight"  # cab | self_drive | flight | ferry | bus | train
    from_city: str = ""  # "" / "Home" for the inbound leg
    to_city: str = ""
    # Flight-specific (only populated when mode == "flight")
    pnr: str = ""  # legacy / optional booking reference
    flight_number: str = ""  # e.g. "AI302" — used for live status tracking
    airline: str = ""
    route: str = ""  # e.g. "DEL → HKT"
    depart: str = ""  # ISO date/datetime
    arrive: str = ""
    # Live status snapshot (refreshed by flight_service within 24h of travel)
    status: str = ""  # scheduled | active | landed | delayed | cancelled | diverted | unknown
    status_note: str = ""  # human readable, e.g. "Delayed 35 min"
    departure_terminal: str = ""
    departure_gate: str = ""
    arrival_terminal: str = ""
    arrival_gate: str = ""
    scheduled_departure: str = ""  # ISO datetime from provider
    estimated_departure: str = ""
    scheduled_arrival: str = ""
    estimated_arrival: str = ""
    status_checked_at: str = ""  # ISO datetime of last successful check


class ItineraryDay(SQLModel, table=True):
    """One planned day of a trip. Owns an ordered list of ItineraryActivity."""

    __tablename__ = "itinerary_days"

    id: str = Field(default_factory=_uuid, primary_key=True)
    trip_id: str = Field(index=True, foreign_key="trips.id")
    day_index: int = 0  # 0-based position within the trip
    date: str = ""  # ISO date (YYYY-MM-DD)
    title: str = ""  # e.g. "Arrival & easy evening"
    area: str = ""  # city / neighbourhood the day is centred on
    summary: str = ""
    is_light: bool = False  # arrival / departure / rest day
    created_at: datetime = Field(default_factory=_now)


class ItineraryActivity(SQLModel, table=True):
    """A single activity within an ItineraryDay (AI-suggested or user-entered)."""

    __tablename__ = "itinerary_activities"

    id: str = Field(default_factory=_uuid, primary_key=True)
    day_id: str = Field(index=True, foreign_key="itinerary_days.id")
    order_index: int = 0
    time: str = ""  # free-form, e.g. "09:30" or "Morning"
    title: str = ""
    description: str = ""
    category: str = "other"  # food | sightseeing | nature | culture | relax | shopping | transit | nightlife | other
    location_name: str = ""
    location_address: str = ""
    lat: str = ""
    lng: str = ""
    source: str = "ai"  # ai | user | places
    rating: str = ""  # provider rating when sourced from a places API
    link: str = ""  # maps / TripAdvisor url
    image_url: str = ""

