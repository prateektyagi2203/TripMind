# TripMind AI Engineering Handbook

## Batch 14 -- AI / ML Engineering & Prompt Architecture

### Version 8.0

------------------------------------------------------------------------

# Part VII --- Prompt Engineering & Prompt Management

## Philosophy

Prompts are production assets. They must be versioned, tested, reviewed
and deployed with the same discipline as application code.

Objectives:

-   Consistent behavior
-   Predictable outputs
-   Easy experimentation
-   Safe evolution
-   Regression prevention

------------------------------------------------------------------------

## Prompt Hierarchy

``` mermaid
flowchart TD
System[System Prompt]
Developer[Developer Prompt]
User[User Prompt]
Memory[Memory Context]
RAG[RAG Context]
Tools[Tool Results]
Output[Validated Response]

System-->Output
Developer-->Output
User-->Output
Memory-->Output
RAG-->Output
Tools-->Output
```

Priority order:

1.  Safety rules
2.  System instructions
3.  Developer instructions
4.  User request
5.  Retrieved knowledge
6.  Memory
7.  Tool outputs

------------------------------------------------------------------------

## Prompt Components

Every production prompt consists of:

-   Objective
-   Constraints
-   Available tools
-   Output schema
-   Context
-   Examples (optional)
-   Failure guidance

Template:

``` text
ROLE:
OBJECTIVE:
CONSTRAINTS:
AVAILABLE TOOLS:
CONTEXT:
OUTPUT FORMAT:
```

------------------------------------------------------------------------

## Prompt Lifecycle

``` mermaid
stateDiagram-v2
[*] --> Draft
Draft --> Review
Review --> Approved
Approved --> Testing
Testing --> Staging
Staging --> Production
Production --> Monitoring
Monitoring --> Revision
Revision --> Draft
```

------------------------------------------------------------------------

## Dynamic Prompt Assembly

The Prompt Manager builds prompts at runtime.

Inputs:

-   User intent
-   Active agent
-   Retrieved documents
-   Memory items
-   Feature flags
-   Prompt version

Only relevant context is injected to minimize token usage.

------------------------------------------------------------------------

## Prompt Versioning

Recommended format:

-   travel-planner:v1.0.0
-   expense-agent:v2.3.1
-   visa-agent:v1.4.0

Each request records:

-   prompt_version
-   model_version
-   agent_name
-   request_id

This enables regression analysis.

------------------------------------------------------------------------

## JSON Schema Enforcement

LLMs should return structured outputs.

Example:

``` json
{
  "destination": "",
  "budget": 0,
  "recommendations": [],
  "confidence": 0.0
}
```

Validation occurs before responses reach the UI.

------------------------------------------------------------------------

## Prompt Injection Defenses

Protect against:

-   Instruction override
-   Data exfiltration
-   Tool abuse
-   Hidden document prompts

Controls:

-   Delimit retrieved context
-   Treat retrieved text as data, not instructions
-   Validate tool requests
-   Strip unsupported directives

------------------------------------------------------------------------

## Prompt Testing

Every prompt requires:

-   Golden test cases
-   Adversarial prompts
-   JSON validation
-   Hallucination checks
-   Latency measurement
-   Cost analysis

Automated regression tests run before deployment.

------------------------------------------------------------------------

## Prompt Library

Suggested structure:

``` text
/prompts
    system/
    planner/
    flight/
    hotel/
    expense/
    visa/
    recommendation/
    shared/
```

Each prompt contains metadata:

-   owner
-   version
-   last_updated
-   supported_models
-   expected_schema

------------------------------------------------------------------------

## FastAPI Prompt Manager

``` python
class PromptManager:

    def load(self, name, version):
        ...

    def build(self, template, context):
        ...

    def validate(self, output):
        ...
```

------------------------------------------------------------------------

## Operational Metrics

Track:

-   Prompt success rate
-   JSON validation failures
-   Hallucination rate
-   Average tokens
-   Prompt cost
-   Latency
-   User feedback

------------------------------------------------------------------------

## Best Practices

-   Keep prompts modular.
-   Avoid embedding business rules.
-   Prefer retrieval over long instructions.
-   Version every production prompt.
-   Test prompts continuously.

------------------------------------------------------------------------

## Architecture Decision Records

ADR-013: Prompts are stored separately from application code where
practical and version-controlled.

ADR-014: Prompt changes require automated regression testing before
production rollout.

ADR-015: Structured output validation is mandatory for all
business-critical AI workflows.
