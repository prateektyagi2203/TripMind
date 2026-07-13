"""Concierge service: orchestrates intent routing -> GPT-4o, plus morning briefing.

Designed to run with OR without an OpenAI key:
- With a key: real GPT-4o calls.
- Without a key: deterministic / fallback replies so the vertical slice still
  works end-to-end during development.
"""
from __future__ import annotations

import json
import os
from typing import Any, Optional

from .intent_router import (
    answer_deterministic,
    cab_comparison_card,
    is_cab_query,
    route_intent,
)
from .models import BriefingCard, ChatMessage, ChatResponse
from .prompts import MORNING_BRIEFING_PROMPT, build_system_prompt
from .trip_context import get_trip_context

MAX_HISTORY_TURNS = 10

_client: Optional[Any] = None


def _get_client() -> Optional[Any]:
    """Lazily build an AsyncOpenAI client. Returns None if no key is configured."""
    global _client
    if _client is not None:
        return _client
    api_key = os.getenv("OPENAI_API_KEY", "").strip()
    if not api_key:
        return None
    try:
        from openai import AsyncOpenAI

        _client = AsyncOpenAI(api_key=api_key)
        return _client
    except Exception:
        return None


def _model() -> str:
    return os.getenv("OPENAI_MODEL", "gpt-4o").strip() or "gpt-4o"


async def handle_chat(message: str, history: list[ChatMessage]) -> ChatResponse:
    ctx = get_trip_context()

    # 1. Cheapest path: deterministic intent answered from TripContext (no LLM).
    intent = route_intent(message)
    if intent is not None:
        return answer_deterministic(intent, ctx)

    # 2. Cab/taxi queries return a rich comparison card.
    if is_cab_query(message):
        card = cab_comparison_card()
        cheapest = min(card.data["providers"], key=lambda p: p["price_thb"])
        best = next(p for p in card.data["providers"] if p["best_value"])
        text = (
            f"For {card.data['destination']}: {best['name']} is the best value at "
            f"THB {best['price_thb']} ({best['eta_min']} min). "
            f"{cheapest['name']} is cheapest at THB {cheapest['price_thb']}."
        )
        return ChatResponse(text=text, source="deterministic", rich_card=card)

    # 3. Everything else needs reasoning -> GPT-4o (or fallback if no key).
    client = _get_client()
    if client is None:
        return ChatResponse(
            text=(
                "I'm running without an AI key right now, so I can only answer "
                "from your trip data (budget, weather, flight, hotel, plan). "
                "Add an OPENAI_API_KEY to unlock full concierge replies."
            ),
            source="fallback",
        )

    messages = [{"role": "system", "content": build_system_prompt(ctx)}]
    for turn in history[-MAX_HISTORY_TURNS:]:
        messages.append({"role": turn.role, "content": turn.content})
    messages.append({"role": "user", "content": message})

    try:
        resp = await client.chat.completions.create(
            model=_model(),
            temperature=0.5,
            max_tokens=300,
            messages=messages,
        )
        text = (resp.choices[0].message.content or "").strip()
        return ChatResponse(text=text or "(no response)", source="ai")
    except Exception as exc:  # network / quota / auth failures
        return ChatResponse(
            text=f"I couldn't reach the AI service ({type(exc).__name__}). "
            "I can still answer from your trip data in the meantime.",
            source="fallback",
        )


def _fallback_briefing(ctx: dict[str, Any]) -> BriefingCard:
    trip = ctx["trip"]
    weather = ctx["environment"]["weather"]
    budget = ctx["budget"]
    first = ctx["itinerary_today"][0]
    return BriefingCard(
        headline=f"Day {trip['current_day']} in {trip['destination'].split(',')[0]}",
        weather_line=f"{weather['temp_c']}C, {weather['condition'].replace('_', ' ')}. "
        f"Rain {weather['rain_prob_pct']}%.",
        first_activity={
            "time": first["time"],
            "name": first["activity"],
            "departure_tip": "Leave ~20 min early. Grab ~THB 180.",
        },
        budget_line=f"THB {budget['remaining_thb']:,} remaining. "
        f"Daily target THB {budget['daily_avg_thb']:,}.",
        ai_tip="Carry water and hats - UV is high for the kids today.",
        alerts=[],
        source="fallback",
    )


async def generate_briefing() -> BriefingCard:
    ctx = get_trip_context()
    client = _get_client()
    if client is None:
        return _fallback_briefing(ctx)

    prompt = MORNING_BRIEFING_PROMPT.format(
        family_size=ctx["user"]["family_size"],
        children_ages=ctx["user"]["children_ages"],
        trip_context_json=json.dumps(ctx),
    )
    try:
        resp = await client.chat.completions.create(
            model=_model(),
            temperature=0.4,
            max_tokens=400,
            response_format={"type": "json_object"},
            messages=[
                {"role": "system", "content": prompt},
                {"role": "user", "content": "Generate today's briefing."},
            ],
        )
        data = json.loads(resp.choices[0].message.content or "{}")
        data["source"] = "ai"
        return BriefingCard.model_validate(data)
    except Exception:
        return _fallback_briefing(ctx)
