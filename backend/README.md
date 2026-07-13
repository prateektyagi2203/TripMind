# TripMind Concierge API

Minimal FastAPI backend for the AI Concierge vertical slice. Powers the Flutter
app's live chat and morning briefing using GPT-4o, with a deterministic intent
router that answers common questions from `TripContext` without an LLM call.

## Run locally (Windows PowerShell)

```powershell
cd backend
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env   # then edit .env and add OPENAI_API_KEY
uvicorn app.main:app --reload --port 8000
```

The server runs at http://127.0.0.1:8000 (interactive docs at `/docs`).

> Works **without** an OpenAI key too: deterministic intents still answer, and
> open-ended questions return a clearly-labelled fallback message. Add
> `OPENAI_API_KEY` to `.env` to enable full GPT-4o replies.

## Endpoints

| Method | Path                       | Purpose                                   |
|--------|----------------------------|-------------------------------------------|
| GET    | `/api/health`              | Liveness + whether AI is enabled          |
| GET    | `/api/trip-context`        | Mock TripContext (drives the context strip)|
| POST   | `/api/concierge/chat`      | Chat turn -> deterministic or GPT-4o reply |
| GET    | `/api/concierge/briefing`  | Daily morning briefing card               |

### Cost control

`app/intent_router.py` answers budget / weather / flight / hotel / itinerary
questions directly from `TripContext` (`source: "deterministic"`), so those
never hit GPT-4o. Only open-ended reasoning reaches the model (`source: "ai"`).
