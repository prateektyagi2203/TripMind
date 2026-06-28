# TripMind AI Engineering Handbook

## Batch 14 -- AI / ML Engineering & Prompt Architecture

### Version 7.0

------------------------------------------------------------------------

# Part VI --- Retrieval-Augmented Generation (RAG) Engine

## Purpose

The RAG engine grounds AI responses in trusted knowledge rather than
relying solely on model parameters. It retrieves relevant enterprise and
user-specific information before generation, reducing hallucinations and
improving explainability.

------------------------------------------------------------------------

## High-Level Pipeline

``` mermaid
flowchart LR
Docs[Documents]
OCR[OCR]
Clean[Normalize]
Chunk[Chunking]
Meta[Metadata]
Embed[Embeddings]
Vector[(Vector DB)]
Retrieve[Retriever]
Rank[Re-ranker]
Context[Context Builder]
LLM[LLM]
Answer[Grounded Response]

Docs-->OCR-->Clean-->Chunk-->Meta-->Embed-->Vector
Vector-->Retrieve-->Rank-->Context-->LLM-->Answer
```

------------------------------------------------------------------------

## Knowledge Sources

### Enterprise Knowledge

-   Airline baggage policies
-   Visa regulations
-   Airport guides
-   Hotel policies
-   Travel insurance rules
-   Currency information

### User Knowledge

-   Passports
-   Previous itineraries
-   Expense receipts
-   Bookings
-   Family preferences
-   Saved places

Knowledge domains remain logically isolated using tenant and document
metadata.

------------------------------------------------------------------------

## Document Ingestion

Stages:

1.  Upload
2.  Malware scan
3.  OCR (if required)
4.  Text normalization
5.  Language detection
6.  Chunk generation
7.  Metadata extraction
8.  Embedding generation
9.  Index update
10. Verification

------------------------------------------------------------------------

## Chunking Strategy

  Strategy         Use Case
  ---------------- --------------------------
  Fixed token      Small structured docs
  Recursive        General documentation
  Semantic         Policies & manuals
  Heading-aware    Markdown/PDF
  Sliding window   Long narrative documents

Recommended chunk size:

-   400--800 tokens
-   15--20% overlap

------------------------------------------------------------------------

## Metadata Model

Each chunk should include:

-   document_id
-   tenant_id
-   source_type
-   language
-   title
-   section
-   tags
-   created_at
-   version
-   access_level

Metadata filtering is applied before vector similarity search.

------------------------------------------------------------------------

## Retrieval Workflow

``` mermaid
sequenceDiagram
participant User
participant Planner
participant Retriever
participant VectorDB
participant Reranker
participant LLM

User->>Planner: Ask question
Planner->>Retriever: Search request
Retriever->>VectorDB: Hybrid search
VectorDB-->>Retriever: Candidate chunks
Retriever->>Reranker: Score relevance
Reranker-->>Planner: Top ranked context
Planner->>LLM: Prompt + context
LLM-->>User: Grounded answer
```

------------------------------------------------------------------------

## Hybrid Retrieval

TripMind combines:

-   Dense vector search
-   Keyword/BM25 search
-   Metadata filtering
-   Business rule filtering

Benefits:

-   Better recall
-   Higher precision
-   Reduced irrelevant context

------------------------------------------------------------------------

## Context Builder

Context assembly order:

1.  System rules
2.  User query
3.  Retrieved passages
4.  User memory
5.  Tool results

Context budget should be enforced to prevent excessive token usage.

------------------------------------------------------------------------

## Hallucination Controls

-   Never answer policy questions without retrieved evidence.
-   Reject empty retrieval for factual requests.
-   Prefer "I don't have enough information" over speculation.
-   Surface source references internally for debugging.

------------------------------------------------------------------------

## Index Maintenance

-   Incremental indexing
-   Soft delete support
-   Version-aware indexing
-   Background re-embedding
-   Periodic integrity checks

------------------------------------------------------------------------

## Reference FastAPI Design

``` python
class RAGService:

    async def ingest(self, document):
        ...

    async def retrieve(self, query):
        ...

    async def rerank(self, chunks):
        ...

    async def build_context(self, query):
        ...
```

------------------------------------------------------------------------

## Evaluation Metrics

Measure:

-   Recall@K
-   Precision@K
-   MRR
-   nDCG
-   Retrieval latency
-   Context relevance
-   Hallucination rate
-   Citation coverage

------------------------------------------------------------------------

## Operational Guidelines

-   Re-embed documents when embedding models change.
-   Keep retrieval independent of LLM providers.
-   Monitor vector index growth.
-   Validate ingestion with checksum and sampling.
-   Archive obsolete documents rather than deleting immediately.

------------------------------------------------------------------------

## Architecture Decision Records

**ADR-010:** Retrieval must complete before generation for factual
queries.

**ADR-011:** Vector search is augmented with metadata filtering and
optional keyword retrieval to improve precision.

**ADR-012:** Knowledge ingestion is asynchronous and idempotent to
support large document collections.
