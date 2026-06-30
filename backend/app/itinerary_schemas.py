"""Pydantic schemas for the day-by-day itinerary planner."""
from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field

ActivityCategory = Literal[
    "food",
    "sightseeing",
    "nature",
    "culture",
    "relax",
    "shopping",
    "transit",
    "nightlife",
    "other",
]


# ---- Activities & days ---------------------------------------------------
class ActivityIn(BaseModel):
    time: str = Field("", max_length=20)
    title: str = Field(..., min_length=1, max_length=160)
    description: str = Field("", max_length=600)
    category: str = Field("other", max_length=20)
    location_name: str = Field("", max_length=160)
    location_address: str = Field("", max_length=300)
    lat: str = Field("", max_length=30)
    lng: str = Field("", max_length=30)
    source: str = Field("user", max_length=12)
    rating: str = Field("", max_length=10)
    link: str = Field("", max_length=400)
    image_url: str = Field("", max_length=500)


class ActivityOut(ActivityIn):
    id: str
    order_index: int


class ItineraryDayIn(BaseModel):
    day_index: int = 0
    date: str = Field("", max_length=30)
    title: str = Field("", max_length=160)
    area: str = Field("", max_length=120)
    summary: str = Field("", max_length=600)
    is_light: bool = False
    activities: list[ActivityIn] = Field(default_factory=list)


class ItineraryDayOut(ItineraryDayIn):
    id: str
    activities: list[ActivityOut] = Field(default_factory=list)


class ItineraryPlanOut(BaseModel):
    trip_id: str
    days: list[ItineraryDayOut] = Field(default_factory=list)


# ---- Preferences & requests ----------------------------------------------
class PlanPreferences(BaseModel):
    pace: Literal["light", "balanced", "packed"] = "balanced"
    interests: list[str] = Field(default_factory=list)
    keep_first_day_light: bool = True
    travelers: str = Field("", max_length=120)
    notes: str = Field("", max_length=400)


class GenerateItineraryRequest(BaseModel):
    preferences: PlanPreferences = Field(default_factory=PlanPreferences)


class SaveItineraryRequest(BaseModel):
    days: list[ItineraryDayIn] = Field(default_factory=list)


# ---- Nearby places -------------------------------------------------------
class NearbyPlace(BaseModel):
    name: str
    address: str = ""
    lat: str = ""
    lng: str = ""
    rating: str = ""
    link: str = ""
    image_url: str = ""
    category: str = "other"


class NearbyResponse(BaseModel):
    source: Literal["tripadvisor", "ai", "fallback"] = "fallback"
    results: list[NearbyPlace] = Field(default_factory=list)
