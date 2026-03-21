# Project Architecture Overview: Boons Text-to-SQL

This document provides a deep dive into the technical architecture, design patterns, and data flow of the `boons-text-to-sql-agent` project.

---

## 1. Architectural Philosophy
The project follows **Clean Architecture** (Hexagonal Architecture) principles to ensure the business logic is decoupled from external frameworks, databases, and AI models.

### Layers:
1.  **Domain Layer (`/domain`)**: Contains pure business models (`Question`, `Scope`, `Role`, `SqlQuery`, `QueryResult`). It has zero dependencies on external libraries (no FastAPI, Pydantic, or LangChain).
2.  **Application Layer (`/application`)**: Defines the use cases (e.g., `GenerateAndExecuteQueryService`) and **Ports** (interfaces like `TextToSqlPort`, `SqlExecutorPort`).
3.  **Infrastructure Layer (`/infrastructure`)**: Implements the Ports with concrete **Adapters**. This is where MySQL, Bedrock, Gemini, and FAISS are integrated.
4.  **Interface Layer (`/interface`)**: The entry point. It contains the FastAPI routes that map HTTP requests to domain models and invoke application services.

---

## 2. Core Data Flow
When a user asks a question (e.g., *"What were my sales yesterday?"*), the system follows this journey:

1.  **API Entry**: FastAPI receives the JSON packet and validates it using Pydantic.
2.  **Service Orchestration**: `GenerateAndExecuteQueryService` starts the pipeline.
3.  **Schema Retrieval**: `SchemaProviderPort` provides the relevant table metadata based on the user's role.
4.  **SQL Generation (LLM)**: `TextToSqlPort` sends the question, schema, and RAG context to the LLM (Gemini or Bedrock) to generate a MySQL query.
5.  **Security Validation (AST)**: The `SqlValidatorPort` parses the generated SQL into an **Abstract Syntax Tree (AST)** using `sqlglot`.
    - **RLS Injection**: If the user is a `MERCHANT`, it injects mandatory `merchant_id` filters into the `WHERE` clause.
    - **Guardrails**: It blocks `DROP`/`DELETE` and restricts table access.
6.  **SQL Execution**: `SqlExecutorPort` runs the validated SQL against the RDS (or local MySQL) and returns raw rows.
7.  **Summarization & Charting**: `ResultSummarizerPort` takes the rows and generates a natural language answer and a **Vega-Lite** chart specification.
8.  **The Watcher Agent**: A final `WatcherAgentPort` reviews the summary for factual accuracy and safety before returning it to the user.

---

## 3. Key Security & Safety Features
- **Row-Level Security (RLS)**: Mandatory `__RLS_MERCHANTS__` token injection ensures data tenancy is enforced at the AST level, not just the prompt level.
- **SQL Sanitization**: All incoming schema definitions are scrubbed of "SENSITIVE" commented columns before being shown to the LLM.
- **Self-Correction Loop**: If a generated SQL query fails execution, the application layer captures the error and asks the LLM to fix it (one retry allowed).
- **Watcher Agent**: A separate LLM pass that acts as a "Human-in-the-loop" equivalent for automated QA, ensuring no technical jargon (like "SQL") leaks to the end user.

---

## 4. Technology Stack
- **Framework**: FastAPI (Async)
- **AI/ML**: LangChain, Google Gemini (Primary LLM), AWS Bedrock (Platform)
- **Database**: MySQL (Production), SQLite (Demo/Mock)
- **SQL Analysis**: `sqlglot` (Python SQL Parser and Transpiler)
- **Visualization**: Vega-Lite (Charts)
- **RAG**: Local FAISS (In-Docker, current), with future path to Amazon Bedrock Knowledge Bases (for managed scale).
- **LLM**: Google Gemini (Primary), with future path to AWS Bedrock (for Claude 3.5 redundancy and **Guardrails for Safety**).
- **Security Role**: Bedrock acts as the "Security and Scale Bridge"—it isn't strictly required for logic but is essential for SOC2 compliance, managed RAG storage, and global model fallback.
- **Configuration**: Pydantic Settings, YAML
