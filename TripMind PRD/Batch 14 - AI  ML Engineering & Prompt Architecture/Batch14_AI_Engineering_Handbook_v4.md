# TripMind AI Engineering Handbook

## Batch 14 -- AI / ML Engineering & Prompt Architecture

### Version 4.0

------------------------------------------------------------------------

# Part III --- AI Orchestrator

The AI Orchestrator is the control plane of TripMind's intelligence
platform. It is responsible for converting a user's natural-language
request into an executable workflow, coordinating agents, invoking
deterministic tools, assembling context, and returning a validated
response.

## Responsibilities

-   Intent classification
-   Context assembly
-   Agent selection
-   Model routing
-   Tool orchestration
-   Memory retrieval
-   RAG integration
-   Streaming responses
-   Retry & fallback
-   Telemetry

------------------------------------------------------------------------

## High-Level Flow

``` mermaid
flowchart TD
User-->Gateway
Gateway-->Orchestrator
Orchestrator-->Intent
Intent-->Planner
Planner-->Memory
Planner-->RAG
Planner-->ModelRouter
Planner-->AgentPool
AgentPool-->Tools
Tools-->Planner
Planner-->Validator
Validator-->Streamer
Streamer-->User
```

------------------------------------------------------------------------

## Request State Machine

``` mermaid
stateDiagram-v2
[*] --> Received
Received --> Authenticated
Authenticated --> Planned
Planned --> Executing
Executing --> WaitingForTool
WaitingForTool --> Executing
Executing --> Validating
Validating --> Streaming
Streaming --> Completed
Executing --> Failed
Failed --> Retry
Retry --> Executing
Retry --> Escalated
Escalated --> Completed
```

------------------------------------------------------------------------

## Planner Responsibilities

The Planner does not answer the question. It decomposes work into
executable tasks.

Example:

User request:

> "Plan a 5-day Phuket family trip in December under ₹2 lakh including
> flights."

Execution plan:

1.  Extract constraints.
2.  Retrieve user preferences.
3.  Search destination knowledge.
4.  Invoke Flight Agent.
5.  Invoke Hotel Agent.
6.  Invoke Budget Agent.
7.  Merge recommendations.
8.  Validate against budget.
9.  Produce itinerary.

------------------------------------------------------------------------

## Agent Execution Modes

### Sequential

Used when later tasks depend on earlier outputs.

Example:

Visa → Flights → Hotels

### Parallel

Used when tasks are independent.

``` mermaid
flowchart LR
Planner-->FlightAgent
Planner-->HotelAgent
Planner-->WeatherAgent

FlightAgent-->Merge
HotelAgent-->Merge
WeatherAgent-->Merge
```

Parallel execution minimizes latency.

------------------------------------------------------------------------

## Context Assembly

The orchestrator builds a prompt context from multiple sources:

-   Current conversation
-   User profile
-   Active trip
-   Long-term memory
-   Retrieved documents
-   Tool results
-   Business rules

Priority order:

1.  Safety rules
2.  System instructions
3.  Current request
4.  Retrieved evidence
5.  Memory
6.  Tool output

------------------------------------------------------------------------

## Model Router

Selection criteria:

  Requirement      Preferred Model
  ---------------- -------------------------
  Lowest latency   Small model
  Deep reasoning   Premium reasoning model
  Large context    Long-context model
  Cost sensitive   Budget model
  OCR              Vision-capable model

Routing decisions are logged for auditability.

------------------------------------------------------------------------

## Failure Handling

Common failures:

-   Provider timeout
-   Tool unavailable
-   Rate limiting
-   Invalid JSON
-   Hallucination detection
-   Retrieval failure

Mitigation:

-   Retry with exponential backoff
-   Switch provider
-   Reduce context
-   Disable optional tools
-   Return graceful degradation

------------------------------------------------------------------------

## FastAPI Reference Skeleton

``` python
class AIOrchestrator:

    async def handle(self, request):
        plan = self.plan(request)
        context = self.build_context(plan)
        result = await self.execute(plan, context)
        return self.validate(result)
```

------------------------------------------------------------------------

## Telemetry

Every request records:

-   request_id
-   trace_id
-   session_id
-   prompt_version
-   model
-   latency_ms
-   token_usage
-   tool_calls
-   retrieval_hits
-   cache_status
-   cost_estimate

------------------------------------------------------------------------

## Operational Guidelines

-   Keep orchestration deterministic.
-   Avoid embedding business rules inside prompts.
-   Prefer tool execution over model guessing.
-   Stream partial responses when possible.
-   Record every routing decision.

------------------------------------------------------------------------

## Architecture Decision Record

**ADR-004:** The orchestrator owns workflow execution; individual agents
must remain stateless and independently testable.

**ADR-005:** Every external dependency (LLM, tool, vector database) must
be abstracted behind interfaces to enable provider replacement without
application changes.
