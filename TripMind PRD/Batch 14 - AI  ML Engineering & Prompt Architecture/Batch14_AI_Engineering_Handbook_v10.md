# TripMind AI Engineering Handbook

## Batch 14 -- AI / ML Engineering & Prompt Architecture

### Version 10.0

------------------------------------------------------------------------

# Part IX --- AI Tool Calling & MCP Integration

## Purpose

Large Language Models reason effectively but cannot reliably interact
with external systems on their own. Tool Calling bridges reasoning with
deterministic execution. TripMind standardizes this through a Tool
Registry and a Model Context Protocol (MCP)-inspired architecture.

------------------------------------------------------------------------

## Architecture

``` mermaid
flowchart LR
Agent-->ToolRouter
ToolRouter-->Registry
Registry-->FlightAPI
Registry-->HotelAPI
Registry-->WeatherAPI
Registry-->OCR
Registry-->Calendar
Registry-->Maps
Registry-->Notifications
Registry-->ExpenseParser
```

------------------------------------------------------------------------

## Design Principles

-   Tools perform deterministic work.
-   LLMs decide *when* to call tools.
-   Every tool has a typed schema.
-   Tool execution is observable.
-   Tools are idempotent whenever practical.

------------------------------------------------------------------------

## Tool Lifecycle

``` mermaid
sequenceDiagram
participant Agent
participant Router
participant Registry
participant Tool

Agent->>Router: Tool request
Router->>Registry: Validate tool
Registry-->>Router: Schema
Router->>Tool: Execute
Tool-->>Router: Result
Router-->>Agent: Structured output
```

------------------------------------------------------------------------

## Tool Categories

  Category       Examples
  -------------- ---------------------------
  Travel         Flights, Hotels, Maps
  Finance        Currency, Expense Parsing
  Documents      OCR, Passport Reader
  Productivity   Calendar, Notifications
  Intelligence   Search, RAG Retrieval
  Platform       Memory, Preferences

------------------------------------------------------------------------

## Tool Schema

Each tool defines:

-   Tool ID
-   Version
-   Description
-   JSON input schema
-   JSON output schema
-   Timeout
-   Authentication requirements
-   Retry policy

Example:

``` json
{
  "tool":"weather.lookup",
  "version":"1.0",
  "input":{
    "city":"Phuket",
    "date":"2026-12-03"
  }
}
```

------------------------------------------------------------------------

## Tool Registry

Responsibilities:

-   Discovery
-   Versioning
-   Capability lookup
-   Access control
-   Deprecation tracking
-   Health monitoring

The registry is the single source of truth for available tools.

------------------------------------------------------------------------

## MCP-inspired Design

TripMind adopts MCP concepts:

-   Standard tool interface
-   Context exchange
-   Capability negotiation
-   Typed resources
-   Structured responses

Internal services can expose MCP-compatible endpoints in the future
without changing agent logic.

------------------------------------------------------------------------

## Security

Controls include:

-   Allow-listed tools
-   Role-based permissions
-   Input validation
-   Output sanitization
-   Rate limiting
-   Audit logging
-   Secret isolation

Agents never receive raw credentials.

------------------------------------------------------------------------

## Error Handling

Failure categories:

-   Validation error
-   Authentication failure
-   Timeout
-   Dependency unavailable
-   Partial response
-   Rate limit exceeded

Recovery:

1.  Retry
2.  Fallback tool
3.  Cached response
4.  Graceful degradation

------------------------------------------------------------------------

## FastAPI Reference

``` python
class ToolRouter:

    async def execute(self, tool_name, payload):
        ...

class ToolRegistry:

    def resolve(self, tool_name):
        ...
```

------------------------------------------------------------------------

## Observability

Capture:

-   tool_name
-   execution_ms
-   success
-   retries
-   caller_agent
-   request_id
-   payload_size
-   response_size

------------------------------------------------------------------------

## Testing

Each tool requires:

-   Contract tests
-   Mock integration tests
-   Load tests
-   Security tests
-   Schema validation
-   Backward compatibility tests

------------------------------------------------------------------------

## Operational Best Practices

-   Version tools independently.
-   Keep tool responses small.
-   Use strict JSON schemas.
-   Prefer deterministic APIs.
-   Monitor slow tools separately.

------------------------------------------------------------------------

## Architecture Decision Records

ADR-019: All tool invocations flow through the Tool Router.

ADR-020: Tool interfaces are schema-first and versioned.

ADR-021: Authentication is handled by the platform layer, never by
prompts or agents.
