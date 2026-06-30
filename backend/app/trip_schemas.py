"""Pydantic request/response schemas for auth + trip creation & sharing."""
from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field

TransportMode = Literal["cab", "self_drive", "flight", "ferry", "bus", "train"]


# ---- Auth ----------------------------------------------------------------
class LoginRequest(BaseModel):
    """Dev login: pick an identity. Swappable for a Google ID token later."""

    email: str = Field(..., min_length=3, max_length=120)
    name: str = Field("", max_length=80)
    photo_url: str = Field("", max_length=400)


class UserOut(BaseModel):
    id: str
    email: str
    name: str
    photo_url: str = ""


class LoginResponse(BaseModel):
    token: str
    user: UserOut


# ---- Trip creation -------------------------------------------------------
class DestinationIn(BaseModel):
    city: str = Field(..., min_length=1, max_length=80)
    hotel_name: str = Field("", max_length=160)
    hotel_address: str = Field("", max_length=300)
    checkin: str = Field("", max_length=30)
    checkout: str = Field("", max_length=30)


class JourneyIn(BaseModel):
    mode: TransportMode = "flight"
    from_city: str = Field("", max_length=80)
    to_city: str = Field("", max_length=80)
    pnr: str = Field("", max_length=20)
    flight_number: str = Field("", max_length=12)
    airline: str = Field("", max_length=80)
    route: str = Field("", max_length=80)
    depart: str = Field("", max_length=30)
    arrive: str = Field("", max_length=30)


class TravellerIn(BaseModel):
    name: str = Field("", max_length=80)
    age: int = Field(0, ge=0, le=120)
    sex: str = Field("", max_length=10)
    is_me: bool = False


class TripCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=120)
    start_date: str = Field(..., max_length=30)
    end_date: str = Field(..., max_length=30)
    currency: str = Field("INR", max_length=8)
    cover_gradient: Literal["sunset", "ocean"] = "sunset"
    destinations: list[DestinationIn] = Field(default_factory=list)
    journeys: list[JourneyIn] = Field(default_factory=list)
    travellers: list[TravellerIn] = Field(default_factory=list)


# ---- Trip output ---------------------------------------------------------
class DestinationOut(DestinationIn):
    id: str
    order_index: int


class JourneyOut(JourneyIn):
    id: str
    order_index: int
    # Live status snapshot (empty until the flight is within range / checked)
    status: str = ""
    status_note: str = ""
    departure_terminal: str = ""
    departure_gate: str = ""
    arrival_terminal: str = ""
    arrival_gate: str = ""
    scheduled_departure: str = ""
    estimated_departure: str = ""
    scheduled_arrival: str = ""
    estimated_arrival: str = ""
    status_checked_at: str = ""


class TripMemberOut(BaseModel):
    user_id: str
    name: str
    role: str


class TravellerOut(TravellerIn):
    id: str
    order_index: int


class TripOut(BaseModel):
    id: str
    name: str
    start_date: str
    end_date: str
    currency: str
    cover_gradient: str
    invite_code: str
    status: Literal["Upcoming", "Ongoing", "Completed"]
    role: Literal["owner", "member"]
    owner_name: str
    members: list[TripMemberOut]
    destinations: list[DestinationOut]
    journeys: list[JourneyOut]
    travellers: list[TravellerOut] = Field(default_factory=list)


# ---- Join & hotel resolve ------------------------------------------------
class JoinRequest(BaseModel):
    code: str = Field(..., min_length=4, max_length=12)


class HotelResolveRequest(BaseModel):
    query: str = Field(..., min_length=1, max_length=120)
    city: str = Field("", max_length=80)


class HotelResolveResponse(BaseModel):
    name: str
    address: str
    source: Literal["ai", "fallback"] = "fallback"
    suggestions: list[str] = Field(default_factory=list)


class HotelSuggestion(BaseModel):
    name: str
    address: str = ""


class HotelSearchResponse(BaseModel):
    source: Literal["ai", "fallback"] = "fallback"
    results: list[HotelSuggestion] = Field(default_factory=list)


# ---- Flight status -------------------------------------------------------
class FlightStatusOut(BaseModel):
    journey_id: str
    flight_number: str
    airline: str = ""
    status: str = ""
    status_note: str = ""
    departure_terminal: str = ""
    departure_gate: str = ""
    arrival_terminal: str = ""
    arrival_gate: str = ""
    scheduled_departure: str = ""
    estimated_departure: str = ""
    scheduled_arrival: str = ""
    estimated_arrival: str = ""
    status_checked_at: str = ""


class FlightLookupRequest(BaseModel):
    flight_number: str
    date: str = ""


class FlightLookupResponse(BaseModel):
    found: bool = False
    flight_number: str = ""
    airline: str = ""
    departure_time: str = ""  # local HH:MM
    departure_airport: str = ""
    arrival_time: str = ""
    scheduled_departure: str = ""  # raw local datetime, if available
