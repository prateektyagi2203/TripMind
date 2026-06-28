# TripMind AI Engineering Handbook

## Batch 14 -- AI / ML Engineering & Prompt Architecture

### Version 5.0

------------------------------------------------------------------------

# Part IV --- Multi-Agent Framework

## Overview

TripMind follows an **agentic architecture** in which each agent owns a
single business capability. Agents are orchestrated by the Planner and
never communicate directly with the UI.

``` mermaid
flowchart TD
User-->Gateway
Gateway-->Orchestrator
Orchestrator-->Planner
Planner-->FlightAgent
Planner-->HotelAgent
Planner-->ExpenseAgent
Planner-->VisaAgent
Planner-->WeatherAgent
Planner-->RecommendationAgent
Planner-->MemoryAgent
```

## Agent Design Principles

-   Single responsibility
-   Stateless execution
-   Deterministic inputs/outputs
-   Tool-first reasoning
-   Structured JSON responses
-   Independently testable

------------------------------------------------------------------------

## Standard Agent Contract

Every agent implements:

-   Metadata
-   Supported intents
-   Input schema
-   Output schema
-   Prompt template
-   Tool registry
-   Validation rules
-   Retry policy
-   Evaluation dataset

``` python
class BaseAgent:
    name: str

    async def execute(self, context):
        ...

    async def validate(self, result):
        ...
```

------------------------------------------------------------------------

## Agent Lifecycle

``` mermaid
stateDiagram-v2
[*] --> Registered
Registered --> Selected
Selected --> ContextLoaded
ContextLoaded --> Executing
Executing --> ToolCalling
ToolCalling --> Reasoning
Reasoning --> Validation
Validation --> Completed
Validation --> Retry
Retry --> Executing
```

------------------------------------------------------------------------

# Planner Agent

Purpose: - Decompose user goals into executable tasks. - Select
agents. - Decide parallel vs sequential execution. - Merge outputs.

Input: - User request - Session context - Memory - Retrieved knowledge

Output: - Execution graph - Agent assignments - Success criteria

------------------------------------------------------------------------

# Flight Agent

Responsibilities:

-   Flight search
-   Fare comparison
-   Cabin recommendations
-   Airline policy awareness
-   Baggage guidance

Tools: - Flight search API - Airline policy RAG - Currency conversion

Failure handling: - Retry transient provider failures. - Fallback to
alternate provider. - Return partial results if inventory is
unavailable.

------------------------------------------------------------------------

# Hotel Agent

Responsibilities:

-   Hotel discovery
-   Budget optimization
-   Family suitability
-   Amenity comparison
-   Distance analysis

------------------------------------------------------------------------

# Expense Agent

Responsibilities:

-   OCR receipt parsing
-   Expense categorization
-   Currency normalization
-   Budget forecasting
-   Spending summaries

------------------------------------------------------------------------

# Visa Agent

Responsibilities:

-   Destination visa requirements
-   Required documents
-   Validity checks
-   Processing timelines

All answers must be grounded using the RAG knowledge base.

------------------------------------------------------------------------

# Weather Agent

Responsibilities:

-   Forecast retrieval
-   Packing recommendations
-   Activity suitability
-   Severe weather alerts

------------------------------------------------------------------------

# Recommendation Agent

Combines:

-   User preferences
-   Family profile
-   Budget
-   Seasonality
-   Ratings
-   Previous trips

Produces ranked recommendations with confidence scores.

------------------------------------------------------------------------

# Memory Agent

Responsibilities:

-   Retrieve long-term preferences
-   Persist new memories
-   Score relevance
-   Remove obsolete memories
-   Resolve conflicts

------------------------------------------------------------------------

# Inter-Agent Communication

Agents exchange structured payloads only.

``` mermaid
sequenceDiagram
Planner->>FlightAgent: Search flights
Planner->>HotelAgent: Search hotels
FlightAgent-->>Planner: Flight options
HotelAgent-->>Planner: Hotel shortlist
Planner->>RecommendationAgent: Rank combinations
RecommendationAgent-->>Planner: Final itinerary
```

------------------------------------------------------------------------

# Shared Context

Common context object contains:

-   user_id
-   session_id
-   active_trip
-   preferences
-   retrieved_documents
-   memory_items
-   tool_results

Agents may read but never mutate shared state directly.

------------------------------------------------------------------------

# Testing Strategy

Each agent requires:

-   Unit tests
-   Prompt regression tests
-   Tool mocks
-   Golden datasets
-   Latency benchmarks
-   Hallucination evaluation

------------------------------------------------------------------------

# Performance Guidelines

-   Parallelize independent agents.
-   Cache deterministic tool responses.
-   Limit prompt context.
-   Stream long-running responses.
-   Prefer retrieval over generation for factual answers.

------------------------------------------------------------------------

# Architecture Decision Records

ADR-006: Agents remain stateless; persistence belongs to the Memory
service.

ADR-007: Agents return typed JSON objects, never free-form text, to
simplify orchestration and validation.
