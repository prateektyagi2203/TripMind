# TripMind AI Engineering Handbook

## Batch 14 -- AI / ML Engineering & Prompt Architecture

### Version 3.0

------------------------------------------------------------------------

# Part II --- AI Platform Architecture

## 1. Architectural Goals

The AI platform is designed around five principles:

-   Modularity
-   Provider independence
-   Observability
-   Deterministic orchestration
-   Horizontal scalability

Unlike a chatbot architecture where every request is sent directly to an
LLM, TripMind uses an orchestration layer that decides whether AI is
required, which model to use, which tools to invoke, and whether
retrieval or memory should be consulted.

------------------------------------------------------------------------

## 2. Logical Architecture

``` mermaid
flowchart TD

UI[Flutter Application]

API[FastAPI API Gateway]

AUTH[Authentication]

ORCH[AI Orchestrator]

PLAN[Planner]

MEM[Memory Engine]

RAG[Knowledge Engine]

TOOLS[Tool Registry]

OPENAI[GPT Models]

CLAUDE[Claude Models]

GEMINI[Gemini Models]

RESULT[Structured Response]

UI-->API
API-->AUTH
AUTH-->ORCH

ORCH-->PLAN
PLAN-->MEM
PLAN-->RAG
PLAN-->TOOLS

PLAN-->OPENAI
PLAN-->CLAUDE
PLAN-->GEMINI

PLAN-->RESULT
RESULT-->API
API-->UI
```

------------------------------------------------------------------------

## 3. Layered Architecture

### Presentation Layer

Responsibilities:

-   User authentication
-   Streaming responses
-   Voice input (future)
-   Offline caching
-   Rich UI rendering

------------------------------------------------------------------------

### API Layer

Responsibilities:

-   Authentication
-   Rate limiting
-   Request validation
-   Session management
-   Streaming transport
-   Audit logging

------------------------------------------------------------------------

### AI Orchestrator

Responsibilities:

-   Understand intent
-   Select execution strategy
-   Choose agent(s)
-   Decide model
-   Invoke tools
-   Merge results
-   Handle failures

The orchestrator contains no travel-specific business logic. Its
responsibility is coordination.

------------------------------------------------------------------------

### Agent Layer

Each agent is responsible for a single business capability.

Examples:

-   Flight Agent
-   Hotel Agent
-   Expense Agent
-   Packing Agent
-   Visa Agent
-   Weather Agent
-   Recommendation Agent

Every agent exposes a common interface:

Input

↓

Reasoning

↓

Tool Calls

↓

Validation

↓

Structured Output

------------------------------------------------------------------------

### Tool Layer

Tools are deterministic integrations.

Examples:

-   Weather API
-   Maps
-   Currency
-   OCR
-   Calendar
-   Notifications
-   Flight Search
-   Hotel Search

LLMs reason.

Tools execute.

------------------------------------------------------------------------

### Knowledge Layer

Responsible for:

-   Document retrieval
-   Semantic search
-   User documents
-   Airline policies
-   Visa requirements

The LLM never answers policy questions without consulting this layer.

------------------------------------------------------------------------

### Memory Layer

Stores:

Short-term conversation

↓

Trip context

↓

User preferences

↓

Family preferences

↓

Long-term semantic memory

Memory retrieval is based on relevance rather than chronological order.

------------------------------------------------------------------------

## 4. Request Flow

``` mermaid
sequenceDiagram

participant U as User

participant G as API Gateway

participant O as Orchestrator

participant P as Planner

participant A as Agent

participant T as Tool

participant L as LLM

U->>G: Request

G->>O: Authenticated request

O->>P: Build execution plan

P->>A: Execute

A->>T: Call deterministic tools

T-->>A: Data

A->>L: Prompt with context

L-->>A: Structured reasoning

A-->>P: Response

P-->>O: Combined answer

O-->>G: Final response

G-->>U: Stream response
```

------------------------------------------------------------------------

## 5. Design Decisions (ADRs)

### ADR-001

Business logic must never reside inside prompts.

Instead:

Business Rules

↓

Python

↓

Prompt

↓

LLM

This allows deterministic testing.

### ADR-002

Every AI feature must support provider replacement.

No application component should depend directly on a single vendor SDK.

### ADR-003

Every AI request receives:

-   Request ID
-   Trace ID
-   Prompt Version
-   Model Version
-   Agent Name

These identifiers enable debugging and regression testing.

------------------------------------------------------------------------

## 6. Engineering Checklist

Before introducing a new AI capability:

-   Define success criteria
-   Create an agent contract
-   Write prompt template
-   Register tools
-   Add evaluation dataset
-   Add observability metrics
-   Define fallback behaviour
-   Document failure modes
-   Review cost impact

This checklist becomes mandatory for all future AI features.
