# TripMind AI Engineering Handbook
## Version 2.0 — Concrete Implementation Spec
### Model: GPT-4o · Stack: FastAPI + Flutter

---

## 1. Overview & Philosophy

TripMind uses GPT-4o as its single LLM provider for MVP. Every AI call
is mediated through a **TripContext object** — the AI is never called
without context. The concierge does not search the web; it reasons over
structured data that TripMind already owns.

**Core rule:** AI fills the gap between what the user typed and what the
app's engines know. If the app already has the answer deterministically,
don't call the AI.

---

## 2. The TripContext Object

This JSON object is constructed by the Trip Context Engine and injected
into every LLM system prompt. It is the single source of truth.

```json
{
  "user": {
    "name": "Prateek",
    "language": "en",
    "currency": "THB",
    "home_currency": "INR",
    "dietary": ["vegetarian"],
    "family_size": 4,
    "children_ages": [6, 9]
  },
  "trip": {
    "id": "trip_phuket_dec26",
    "destination": "Phuket, Thailand",
    "current_day": 2,
    "total_days": 5,
    "start_date": "2026-12-02",
    "end_date": "2026-12-06"
  },
  "hotel": {
    "name": "Kata Rocks Resort",
    "address": "186/22 Kok Tanode Road, Kata, Phuket",
    "checkin": "2026-12-02",
    "checkout": "2026-12-06",
    "phone": "+66-76-370-777"
  },
  "flight": {
    "return_flight": "AI-318",
    "departure": "HKT",
    "arrival": "DEL",
    "departure_time": "2026-12-06T09:15:00+07:00",
    "terminal": "T1",
    "gate": "B12",
    "status": "on_time"
  },
  "budget": {
    "total_thb": 28500,
    "spent_thb": 16530,
    "remaining_thb": 11970,
    "today_spent_thb": 2840,
    "daily_avg_thb": 4132
  },
  "itinerary_today": [
    { "time": "09:00", "activity": "Big Buddha Temple", "status": "current" },
    { "time": "13:00", "activity": "Kata Beach Lunch", "status": "upcoming" },
    { "time": "16:00", "activity": "Patong Beach", "status": "upcoming" },
    { "time": "19:30", "activity": "Dinner at Savoey", "status": "upcoming" }
  ],
  "environment": {
    "local_time": "2026-12-03T09:05:00+07:00",
    "weather": { "temp_c": 32, "condition": "partly_cloudy", "rain_prob_pct": 15, "uv_index": 8 },
    "gps": { "lat": 7.8951, "lng": 98.3004, "area": "Chalong, Phuket" },
    "connectivity": "online"
  }
}
```

**Size budget:** Keep TripContext under 1,500 tokens. Omit nulls and
historical data. Refresh every 5 minutes or on any state change.

---

## 3. The System Prompt — Base Template

This is injected for every AI Concierge conversation turn.

```
You are TripMind AI, a travel companion for {{user.name}}'s family trip
to {{trip.destination}}. You are on Day {{trip.current_day}} of
{{trip.total_days}}.

CURRENT CONTEXT:
- Local time: {{environment.local_time}}
- Weather: {{environment.weather.temp_c}}°C, {{environment.weather.condition}}
- Budget remaining: ฿{{budget.remaining_thb}} (spent ฿{{budget.spent_thb}} of ฿{{budget.total_thb}})
- Family: {{user.family_size}} people including children aged {{user.children_ages | join(", ")}}
- Current location: {{environment.gps.area}}
- Active itinerary: {{itinerary_today | format_timeline}}
- Hotel: {{hotel.name}}
- Dietary: {{user.dietary | join(", ")}}

RULES:
1. Be concise — 3 sentences max unless the user asks for detail.
2. Always consider children when recommending activities, food, or transport.
3. For transport: always compare Grab, Bolt, inDrive and recommend by value.
4. For food: always filter by dietary restrictions first, then price, then rating.
5. Always state the budget impact of any recommendation (e.g. "this leaves ฿X for the rest of the day").
6. If you don't know something, say so. Never invent prices, times, or bookings.
7. For emergencies: immediately provide hotel phone, nearest hospital, and local police (191).
8. Distinguish clearly: "I know this from your trip data" vs "I'm suggesting based on general knowledge."

PERSONALITY: Warm, practical, family-aware. You know their itinerary
so you never ask for information TripMind already has.
```

**Token cost estimate:** ~350 tokens per call (system + context).
At ₹1.5 per 1K tokens (GPT-4o input pricing), each conversation turn
costs ~₹0.53. 50 turns/day/user = ~₹26/day/user. Budget accordingly.

---

## 4. Morning Briefing Prompt

Triggered once daily at 7:30am local time. Runs as a background job.
Output cached and displayed on Home Dashboard.

```python
MORNING_BRIEFING_PROMPT = """
Based on the following trip context, generate a morning briefing for a
family of {family_size} (children aged {children_ages}).

Trip context:
{trip_context_json}

Generate a morning briefing with EXACTLY this structure (JSON output only):
{
  "headline": "Day 2 in Phuket 🌴",
  "weather_line": "32°C, partly cloudy. Rain unlikely before 4pm.",
  "first_activity": {
    "time": "09:00",
    "name": "Big Buddha Temple",
    "departure_tip": "Leave by 8:40 — Grab ~฿180, 22 min."
  },
  "budget_line": "฿11,970 remaining. Daily target ฿4,000.",
  "ai_tip": "One family-specific tip for the day in 1 sentence.",
  "alerts": []  // any flight changes, weather warnings, etc.
}

Rules:
- Use only data from the trip context provided.
- Do not invent prices. Use context budget data only.
- Keep every field under 80 characters.
- For children, flag any age-inappropriate activities.
"""
```

**Backend call:**
```python
async def generate_morning_briefing(trip_context: TripContext) -> BriefingCard:
    response = await openai_client.chat.completions.create(
        model="gpt-4o",
        temperature=0.4,  # Low temp — factual output
        response_format={"type": "json_object"},
        messages=[
            {"role": "system", "content": MORNING_BRIEFING_PROMPT.format(**trip_context.dict())},
            {"role": "user", "content": "Generate today's briefing."}
        ],
        max_tokens=400
    )
    return BriefingCard.model_validate_json(response.choices[0].message.content)
```

---

## 5. AI Concierge — Conversation Handler

Multi-turn conversation. History is maintained client-side and sent with
each request (max last 10 turns to control token cost).

### 5.1 Intent Router (cheapest call first)

Before hitting GPT-4o, classify intent with a fast regex + keyword
router. Only complex intents need the LLM.

```python
DETERMINISTIC_INTENTS = {
    "budget_check": ["how much", "spent", "remaining", "budget"],
    "weather": ["weather", "rain", "temperature", "hot"],
    "flight_status": ["flight", "gate", "terminal", "boarding"],
    "hotel_info": ["hotel", "check-in", "check out", "reception"],
    "itinerary_view": ["plan", "schedule", "today", "what's next"],
}

def route_intent(user_message: str) -> str:
    msg = user_message.lower()
    for intent, keywords in DETERMINISTIC_INTENTS.items():
        if any(kw in msg for kw in keywords):
            return intent
    return "llm_required"
```

Deterministic responses never call the API — they pull directly from
TripContext. This reduces AI API cost by ~40%.

### 5.2 LLM Conversation Call

```python
async def concierge_chat(
    user_message: str,
    history: list[dict],
    trip_context: TripContext
) -> ConciergeResponse:

    system = build_system_prompt(trip_context)  # Base prompt + context
    messages = [{"role": "system", "content": system}]
    messages += history[-10:]  # Last 10 turns only
    messages.append({"role": "user", "content": user_message})

    response = await openai_client.chat.completions.create(
        model="gpt-4o",
        temperature=0.6,
        max_tokens=500,
        messages=messages,
        tools=CONCIERGE_TOOLS  # See Section 6
    )

    return parse_concierge_response(response)
```

### 5.3 Response Format

AI always returns structured JSON so Flutter can render rich cards.

```json
{
  "text": "Great! Here are cab options for 4 people to Big Buddha.",
  "card_type": "cab_comparison",
  "card_data": {
    "destination": "Big Buddha Temple",
    "pax": 4,
    "options": [
      { "provider": "Grab", "price_thb": 180, "eta_min": 22, "recommended": true },
      { "provider": "Bolt", "price_thb": 165, "eta_min": 28, "recommended": false },
      { "provider": "inDrive", "price_thb": 150, "eta_min": 18, "recommended": false, "note": "negotiate fare" }
    ]
  },
  "actions": [
    { "label": "Open Grab", "deep_link": "grab://destination?lat=7.8276&lng=98.3009" },
    { "label": "Open Bolt", "deep_link": "bolt://..." }
  ],
  "follow_up_chips": ["Log as expense", "Add to itinerary", "What to see there?"]
}
```

---

## 6. Tool Definitions (Function Calling)

GPT-4o can invoke these tools. Each maps to a TripMind engine.

```python
CONCIERGE_TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "get_cab_options",
            "description": "Compare Grab, Bolt, inDrive for a destination. Always use this when user asks about taxi, cab, or transport.",
            "parameters": {
                "type": "object",
                "properties": {
                    "destination_name": {"type": "string"},
                    "destination_lat": {"type": "number"},
                    "destination_lng": {"type": "number"},
                    "pax": {"type": "integer"}
                },
                "required": ["destination_name", "pax"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "search_restaurants",
            "description": "Find restaurants near current location. Use dietary prefs from TripContext automatically.",
            "parameters": {
                "type": "object",
                "properties": {
                    "cuisine": {"type": "string", "description": "e.g. Thai, Indian, Vegetarian"},
                    "max_price_thb": {"type": "number"},
                    "radius_km": {"type": "number", "default": 2.0},
                    "suitable_for_children": {"type": "boolean", "default": true}
                }
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "translate_text",
            "description": "Translate any text to/from Thai. Use when user pastes or describes foreign text.",
            "parameters": {
                "type": "object",
                "properties": {
                    "text": {"type": "string"},
                    "target_language": {"type": "string", "default": "en"}
                },
                "required": ["text"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "log_expense",
            "description": "Log a travel expense. Use when user mentions spending money.",
            "parameters": {
                "type": "object",
                "properties": {
                    "amount_thb": {"type": "number"},
                    "category": {"type": "string", "enum": ["food", "transport", "activity", "shopping", "hotel", "other"]},
                    "description": {"type": "string"},
                    "pax_split": {"type": "integer", "description": "Number of people sharing this expense"}
                },
                "required": ["amount_thb", "category", "description"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "get_weather_detail",
            "description": "Get hourly forecast for activity planning.",
            "parameters": {
                "type": "object",
                "properties": {
                    "hours_ahead": {"type": "integer", "default": 24}
                }
            }
        }
    }
]
```

---

## 7. Image / Camera Routing

When user sends an image via chat, route it before LLM call.

```python
async def route_camera_input(image_b64: str, user_hint: str = "") -> CameraIntent:
    """
    Fast classification of what the image is.
    Use GPT-4o vision — cheaper than full conversation.
    """
    response = await openai_client.chat.completions.create(
        model="gpt-4o",
        max_tokens=50,
        messages=[{
            "role": "user",
            "content": [
                {
                    "type": "image_url",
                    "image_url": {"url": f"data:image/jpeg;base64,{image_b64}", "detail": "low"}
                },
                {
                    "type": "text",
                    "text": "Classify this image as exactly one of: receipt, boarding_pass, menu, signboard, landmark, hotel_booking, other. Reply with only the category word."
                }
            ]
        }]
    )
    intent = response.choices[0].message.content.strip()
    return CameraIntent(type=intent)

# Route to correct engine:
CAMERA_ROUTE_MAP = {
    "receipt": handle_receipt_ocr,       # Expense Engine
    "boarding_pass": handle_boarding_pass, # Flight Engine
    "menu": handle_menu_translation,      # Translator Engine
    "signboard": handle_signboard_translation,
    "landmark": handle_landmark_recognition,
    "hotel_booking": handle_hotel_import,
}
```

---

## 8. Offline AI Behaviour

When `connectivity == "offline"`:

1. Skip all LLM calls.
2. Serve from `offline_cache`:
   - Last generated morning briefing (stored as JSON in Isar DB)
   - Last 20 conversation turns
   - Destination Pack knowledge base (local JSON)
3. For deterministic intents: still answer from TripContext in local DB.
4. Display offline banner: *"AI reasoning unavailable. Showing cached
   trip data."*
5. Queue any tool calls (e.g. expense logging) for sync on reconnect.

**Never show an empty state.** The app always has useful trip data
available offline.

---

## 9. Prompt Versioning

Every prompt is versioned. Breaking changes require a new version.

```python
PROMPT_REGISTRY = {
    "morning_briefing": {"version": "1.0", "model": "gpt-4o", "temp": 0.4},
    "concierge_base": {"version": "1.0", "model": "gpt-4o", "temp": 0.6},
    "camera_classify": {"version": "1.0", "model": "gpt-4o", "temp": 0.0},
    "translation": {"version": "1.0", "model": "gpt-4o", "temp": 0.2},
}
```

Log `prompt_version` and `model` with every API response in telemetry.

---

## 10. Cost Control

| Call Type            | Model    | Max Tokens | Est. Cost/Call |
|----------------------|----------|------------|----------------|
| Morning briefing     | gpt-4o   | 400 out    | ~₹0.80        |
| Concierge turn       | gpt-4o   | 500 out    | ~₹1.00        |
| Camera classify      | gpt-4o   | 50 out     | ~₹0.40        |
| Translation          | gpt-4o   | 300 out    | ~₹0.60        |
| Deterministic intent | no call  | —          | ₹0            |

**Cost guardrails:**
- Rate limit: 30 LLM calls/user/day
- Deterministic routing prevents ~40% of calls
- Morning briefing is cached (1 call/day, not per-view)
- Camera classify uses `detail: "low"` (3x cheaper than high)

---

## 11. Safety & Hallucination Rules

1. **Never invent prices.** All prices come from CabHub API or
   user-provided data. If unavailable, say "prices vary — open Grab to
   check."
2. **Never create itinerary items.** Only suggest; user must confirm.
3. **Emergency responses** bypass LLM entirely — hardcoded response
   with hotel phone, police (191), tourist police (1155), hospital.
4. **Budget advice:** Never recommend spending that would leave <฿500
   remaining without explicit user confirmation.
5. **Child safety:** Flag any activity not suitable for ages in
   `children_ages`. Never recommend adult entertainment venues.

---

## 12. Telemetry (Minimal MVP)

Log per LLM call to your FastAPI logs (no external tool needed for MVP):

```python
@dataclass
class AICallLog:
    timestamp: datetime
    user_id: str
    trip_id: str
    prompt_version: str
    intent: str          # e.g. "cab_comparison", "morning_briefing"
    input_tokens: int
    output_tokens: int
    latency_ms: int
    tool_called: str | None
    success: bool
    error: str | None
```

Review weekly. Target: p95 latency < 3 seconds, success rate > 97%.

---

## 13. MVP Scope vs Future

| Feature                  | MVP v1.0 | v1.1 | v2.0 |
|--------------------------|----------|------|------|
| Morning briefing         | ✅       |      |      |
| Concierge chat           | ✅       |      |      |
| Tool calling (5 tools)   | ✅       |      |      |
| Camera routing           | ✅       |      |      |
| Offline cached responses | ✅       |      |      |
| Travel DNA / preferences |          | ✅   |      |
| Multi-trip memory        |          |      | ✅   |
| Voice (Whisper)          |          | ✅   |      |
| Autonomous replanning    |          |      | ✅   |
| Multi-agent orchestration|          |      | ✅   |

---

*Version 2.0 — Replaces all 16 versions of Batch14_AI_Engineering_Handbook*
*Owner: TripMind Product · Model: GPT-4o · Last updated: June 2026*
