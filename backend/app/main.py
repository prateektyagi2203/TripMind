"""TripMind AI Concierge API (FastAPI).

Run locally:
    cd backend
    python -m venv .venv && .venv\\Scripts\\activate   (Windows)
    pip install -r requirements.txt
    copy .env.example .env   # then add your OPENAI_API_KEY
    uvicorn app.main:app --reload --port 8000
"""
from __future__ import annotations

import asyncio
import os
from typing import Optional

from dotenv import load_dotenv
from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import Session

load_dotenv()

from .concierge_service import generate_briefing, handle_chat  # noqa: E402
from .expenses import add_expense, budget_snapshot, list_expenses  # noqa: E402
from .auth import get_current_user, login_or_create  # noqa: E402
from .db import get_session, init_db  # noqa: E402
from .db_models import User  # noqa: E402
from .models import (  # noqa: E402
    BriefingCard,
    ChatRequest,
    ChatResponse,
    ExpenseList,
    ExpenseRequest,
    ExpenseResponse,
    TranslateRequest,
    TranslateResponse,
    TripDay,
)
from .tools_service import translate  # noqa: E402
from .trip_context import get_trip_context  # noqa: E402
from .trip_day import build_trip_day  # noqa: E402
from .trip_schemas import (  # noqa: E402
    AirportTransferOut,
    FlightLookupRequest,
    FlightLookupResponse,
    FlightStatusOut,
    HotelResolveRequest,
    HotelResolveResponse,
    HotelSearchResponse,
    JoinRequest,
    LoginRequest,
    LoginResponse,
    TripCreate,
    TripOut,
    UserOut,
)
from .trips_service import (  # noqa: E402
    create_trip,
    get_trip,
    join_trip,
    list_trips,
    resolve_hotel,
    search_hotels,
    update_trip,
)
from .itinerary_schemas import (  # noqa: E402
    DayRouteOut,
    GenerateItineraryRequest,
    ItineraryPlanOut,
    NearbyResponse,
    SaveItineraryRequest,
)
from .itinerary_service import (  # noqa: E402
    generate_itinerary,
    get_itinerary,
    nearby_for_trip,
    save_itinerary,
)
from . import flight_service  # noqa: E402
from .day_route_service import build_day_route  # noqa: E402
from .transport_service import day1_airport_transfer  # noqa: E402

app = FastAPI(title="TripMind Concierge API", version="0.1.0")

_scheduler_task: asyncio.Task | None = None


async def _flight_refresh_loop() -> None:
    """Periodically refresh status for flights within the 24h window."""
    interval = max(1, int(os.getenv("FLIGHT_REFRESH_HOURS", "3"))) * 3600
    from sqlmodel import Session  # local import

    from .db import engine

    while True:
        try:
            with Session(engine) as session:
                await flight_service.refresh_due_flights(session)
        except Exception:
            pass
        await asyncio.sleep(interval)


@app.on_event("startup")
async def _startup() -> None:
    init_db()
    global _scheduler_task
    _scheduler_task = asyncio.create_task(_flight_refresh_loop())


@app.on_event("shutdown")
async def _shutdown() -> None:
    if _scheduler_task is not None:
        _scheduler_task.cancel()



_origins = [
    o.strip()
    for o in os.getenv(
        "CORS_ORIGINS",
        "http://localhost,http://localhost:8080,http://127.0.0.1:8080",
    ).split(",")
    if o.strip()
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=_origins,
    # flutter run -d chrome binds a new random localhost port each launch, so
    # match any localhost/127.0.0.1 port instead of pinning one in _origins.
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/api/health")
async def health() -> dict[str, object]:
    return {"status": "ok", "ai_enabled": bool(os.getenv("OPENAI_API_KEY", "").strip())}


@app.get("/api/trip-context")
async def trip_context() -> dict[str, object]:
    """Expose the mock TripContext so the Flutter app can render context pills."""
    return get_trip_context()


@app.post("/api/concierge/chat", response_model=ChatResponse)
async def concierge_chat(req: ChatRequest) -> ChatResponse:
    return await handle_chat(req.message, req.history)


@app.get("/api/concierge/briefing", response_model=BriefingCard)
async def concierge_briefing() -> BriefingCard:
    return await generate_briefing()


@app.get("/api/trips/today", response_model=TripDay)
async def trip_today() -> TripDay:
    """Structured day plan (itinerary + budget + stay + flight) for the active trip."""
    return build_trip_day()


@app.get("/api/trips/expenses", response_model=ExpenseList)
async def expenses_list() -> ExpenseList:
    return ExpenseList(expenses=list_expenses(), budget=budget_snapshot())


@app.post("/api/trips/expenses", response_model=ExpenseResponse)
async def expenses_add(req: ExpenseRequest) -> ExpenseResponse:
    """Log an expense and return the new entry plus the recomputed budget."""
    expense = add_expense(req.amount, req.category, req.note)
    return ExpenseResponse(expense=expense, budget=budget_snapshot())


@app.post("/api/tools/translate", response_model=TranslateResponse)
async def tools_translate(req: TranslateRequest) -> TranslateResponse:
    """Translate text via GPT-4o (falls back to a small phrasebook without a key)."""
    return await translate(req.text, req.target_lang)


# ----- Auth ---------------------------------------------------------------
@app.post("/api/auth/login", response_model=LoginResponse)
def auth_login(
    req: LoginRequest, session: Session = Depends(get_session)
) -> LoginResponse:
    """Dev login: upsert a user by email; token is the user id."""
    user = login_or_create(req, session)
    return LoginResponse(
        token=user.id,
        user=UserOut(
            id=user.id, email=user.email, name=user.name, photo_url=user.photo_url
        ),
    )


@app.get("/api/auth/me", response_model=UserOut)
def auth_me(user: User = Depends(get_current_user)) -> UserOut:
    return UserOut(id=user.id, email=user.email, name=user.name, photo_url=user.photo_url)


# ----- Trips (multi-user, persisted) --------------------------------------
@app.post("/api/trips", response_model=TripOut)
def trips_create(
    payload: TripCreate,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> TripOut:
    return create_trip(payload, user, session)


@app.get("/api/trips", response_model=list[TripOut])
def trips_list(
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> list[TripOut]:
    return list_trips(user, session)


@app.get("/api/trips/{trip_id}", response_model=TripOut)
def trips_get(
    trip_id: str,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> TripOut:
    return get_trip(trip_id, user, session)


@app.put("/api/trips/{trip_id}", response_model=TripOut)
def trips_update(
    trip_id: str,
    payload: TripCreate,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> TripOut:
    return update_trip(trip_id, payload, user, session)


@app.post("/api/trips/join", response_model=TripOut)
def trips_join(
    req: JoinRequest,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> TripOut:
    return join_trip(req.code, user, session)


@app.post("/api/hotels/resolve", response_model=HotelResolveResponse)
async def hotels_resolve(
    req: HotelResolveRequest,
    user: User = Depends(get_current_user),
) -> HotelResolveResponse:
    return await resolve_hotel(req.query, req.city)


@app.post("/api/hotels/search", response_model=HotelSearchResponse)
async def hotels_search(
    req: HotelResolveRequest,
    user: User = Depends(get_current_user),
) -> HotelSearchResponse:
    return await search_hotels(req.query, req.city)


# ----- Flight status ------------------------------------------------------
@app.post("/api/trips/{trip_id}/flights/refresh", response_model=list[FlightStatusOut])
async def flights_refresh(
    trip_id: str,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> list[FlightStatusOut]:
    """Refresh + return live status for this trip's flights within the 24h window."""
    trip = get_trip(trip_id, user, session)  # member-gated
    from .db_models import Journey  # local import to avoid cycle at module load
    from sqlmodel import select

    journeys = session.exec(
        select(Journey).where(Journey.trip_id == trip.id, Journey.mode == "flight")
    ).all()
    out: list[FlightStatusOut] = []
    for j in journeys:
        if j.flight_number.strip():
            await flight_service.refresh_journey(j, session)
            session.refresh(j)
            out.append(
                FlightStatusOut(
                    journey_id=j.id,
                    flight_number=j.flight_number,
                    airline=j.airline,
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
            )
    return out


# ----- Itinerary (day-by-day planner) -------------------------------------
@app.post(
    "/api/trips/{trip_id}/itinerary/generate", response_model=ItineraryPlanOut
)
async def itinerary_generate(
    trip_id: str,
    req: GenerateItineraryRequest,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> ItineraryPlanOut:
    """Build a draft AI plan (not saved) seeded with real nearby places."""
    return await generate_itinerary(trip_id, req.preferences, user, session)


@app.get("/api/trips/{trip_id}/itinerary", response_model=ItineraryPlanOut)
def itinerary_get(
    trip_id: str,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> ItineraryPlanOut:
    return get_itinerary(trip_id, user, session)


@app.put("/api/trips/{trip_id}/itinerary", response_model=ItineraryPlanOut)
def itinerary_save(
    trip_id: str,
    req: SaveItineraryRequest,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> ItineraryPlanOut:
    return save_itinerary(trip_id, req.days, user, session)


@app.get("/api/trips/{trip_id}/places/nearby", response_model=NearbyResponse)
async def places_nearby(
    trip_id: str,
    category: str = "all",
    q: str = "",
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> NearbyResponse:
    return await nearby_for_trip(trip_id, category, user, session, query=q)


@app.get(
    "/api/trips/{trip_id}/itinerary/day/{day_index}/route",
    response_model=DayRouteOut,
)
async def itinerary_day_route(
    trip_id: str,
    day_index: int,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> DayRouteOut:
    """Ordered stops + leg-by-leg distance/duration for one day's plan, for
    the Day map view. Activities without saved coordinates are skipped."""
    return await build_day_route(trip_id, day_index, user, session)


@app.get(
    "/api/trips/{trip_id}/day1/airport-transfer",
    response_model=Optional[AirportTransferOut],
)
async def trip_day1_airport_transfer(
    trip_id: str,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> Optional[AirportTransferOut]:
    """Grab/Bolt/inDrive/taxi options + approx cost & ETA from the arrival
    airport to the Day 1 hotel. None when the trip has no recognised
    Thailand arrival airport (feature is Thailand-specific for now)."""
    return await day1_airport_transfer(trip_id, user, session)


@app.post("/api/flights/lookup", response_model=FlightLookupResponse)
async def flights_lookup(
    req: FlightLookupRequest,
    user: User = Depends(get_current_user),
) -> FlightLookupResponse:
    """Look up a flight's local departure time by number + date for the wizard."""
    data = await flight_service.lookup_flight(req.flight_number, req.date)
    if not data:
        return FlightLookupResponse(found=False, flight_number=req.flight_number)
    return FlightLookupResponse(found=True, **data)

