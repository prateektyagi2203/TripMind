# TripMind AI Engineering Handbook

## Batch 14 -- AI / ML Engineering & Prompt Architecture

### Version 6.0

------------------------------------------------------------------------

# Part V --- Memory Architecture

## Philosophy

Memory enables TripMind to deliver personalized assistance across
conversations and trips without repeatedly asking users for the same
information.

Design goals:

-   Persistent personalization
-   Privacy by design
-   High retrieval accuracy
-   Low latency
-   Explicit lifecycle management

------------------------------------------------------------------------

## Memory Types

  Memory Type         Examples                          TTL
  ------------------- --------------------------------- -----------
  Working Memory      Current conversation              Session
  Episodic Memory     Previous trips                    Long-term
  Semantic Memory     "User prefers window seat"        Long-term
  Preference Memory   Vegetarian meals, family travel   Long-term
  Procedural Memory   Completed onboarding              Long-term

``` mermaid
flowchart TD
Conversation-->WorkingMemory
WorkingMemory-->Consolidation
Trips-->EpisodicMemory
Preferences-->SemanticMemory
SemanticMemory-->Retriever
EpisodicMemory-->Retriever
Retriever-->Agents
```

------------------------------------------------------------------------

## Memory Lifecycle

``` mermaid
stateDiagram-v2
[*] --> Capture
Capture --> Classify
Classify --> Embed
Embed --> Store
Store --> Retrieve
Retrieve --> Score
Score --> Use
Use --> Update
Update --> Archive
Archive --> [*]
```

### Capture

Potential memories originate from:

-   Explicit user preferences
-   Travel bookings
-   Frequently repeated choices
-   Accepted AI recommendations

Do **not** automatically store transient or sensitive conversational
details unless required for product functionality and user expectations.

------------------------------------------------------------------------

## Storage Model

Suggested logical schema:

### memory_item

-   memory_id
-   user_id
-   category
-   summary
-   embedding_id
-   confidence
-   source
-   created_at
-   updated_at
-   expires_at

### memory_embedding

-   embedding_id
-   vector
-   model
-   dimensions

------------------------------------------------------------------------

## Retrieval Pipeline

1.  Encode user request
2.  Search vector index
3.  Filter by category
4.  Rank by semantic similarity
5.  Apply recency boost
6.  Apply confidence weighting
7.  Return top-k memories

------------------------------------------------------------------------

## Relevance Scoring

Example scoring formula:

Final Score =

-   50% semantic similarity
-   20% recency
-   20% confidence
-   10% frequency of reuse

Business rules may further boost active-trip memories.

------------------------------------------------------------------------

## Memory Consolidation

Repeated observations become stronger memories.

Example:

Conversation 1: "I prefer aisle seats."

Conversation 4: "Always book aisle."

Conversation 9: "I dislike middle seats."

→ Consolidated preference: Preferred seat = Aisle

------------------------------------------------------------------------

## Conflict Resolution

When memories conflict:

1.  Prefer explicit user statements.
2.  Prefer recent confirmations.
3.  Reduce confidence of stale memories.
4.  Surface ambiguity when confidence is low.

------------------------------------------------------------------------

## Privacy Controls

Memory categories should support:

-   View
-   Export
-   Delete
-   Forget specific memories
-   Disable future storage

Sensitive documents should not be embedded unless explicitly enabled.

------------------------------------------------------------------------

## Retrieval Sequence

``` mermaid
sequenceDiagram
User->>Planner: New request
Planner->>Memory: Retrieve context
Memory->>VectorDB: Similarity search
VectorDB-->>Memory: Candidate memories
Memory-->>Planner: Ranked context
Planner->>Agent: Execute with memory
```

------------------------------------------------------------------------

## FastAPI Reference

``` python
class MemoryService:

    async def retrieve(self, user_id, query):
        ...

    async def store(self, memory):
        ...

    async def consolidate(self):
        ...
```

------------------------------------------------------------------------

## Evaluation Metrics

Track:

-   Retrieval precision
-   Retrieval recall
-   Memory hit rate
-   Irrelevant memory rate
-   Average retrieval latency
-   User correction rate

------------------------------------------------------------------------

## Operational Best Practices

-   Keep memories concise.
-   Store facts, not speculation.
-   Periodically prune obsolete memories.
-   Separate product state from conversational memory.
-   Audit memory writes for quality.

------------------------------------------------------------------------

## Architecture Decision Records

ADR-008: Memories are immutable events; updates create new versions
rather than overwriting history where auditability is required.

ADR-009: Retrieval uses hybrid ranking combining vector similarity with
business metadata.
