# Project Architecture Review (March 2026)

## 1. High-Level Architecture
The project follows **Clean Architecture** (Hexagonal Architecture) principles, ensuring that business logic is decoupled from external dependencies.

### Layers:
- **`domain/`**: Contains core multi-tenant business models (`Question`, `Scope`, `Role`, `SqlQuery`, `QueryResult`).
- **`application/`**: Orchestrates the text-to-SQL pipeline via the `GenerateAndExecuteQueryService`. It defines **Ports** (interfaces) for LLM, DB, and Security.
- **`infrastructure/`**: Implements the **Adapters**.
    - **LLM**: `LangChainTextToSqlAdapter` (using Gemini/Claude), `LlmSummarizer`, `LlmWatcherAgent`.
    - **Retreival**: `LocalFaissProvider` and `AwsBedrockKbProvider` for RAG.
    - **Security**: `SimpleSqlValidator` using `sqlglot` for AST-based SQL sanitization and RLS injection.
    - **DB**: `MySqlExecutor` and `InMemoryDemoExecutor`.
- **`interface/`**: FastAPI implementation providing the REST API layer.

---

## 2. Core Data Flow (The Text-to-SQL Journey)

1.  **Gatekeeper (Intent Classification)**: The LLM first checks if the user's intent is analytics-related. Non-analytics queries are blocked immediately to save RAG/Schema processing costs.
2.  **Context Retrieval (RAG)**: Relevant business rules and synonyms are retrieved from the FAISS (local) or Bedrock (AWS) vector stores.
3.  **Schema Injection**: The structured JSON representation of the database (`StaticSchemaProvider`) is injected into the LLM system prompt.
4.  **SQL Generation**: The LLM generates a MySQL statement using the provided context and schema.
5.  **AST Validation & RLS**:
    - The `SimpleSqlValidator` parses the SQL using `sqlglot`.
    - It enforces SELECT-only and blocks forbidden tables.
    - It ensures the `__RLS_MERCHANTS__` token is present for merchant roles and replaces it with secure parameterized merchant IDs.
6.  **Execution**: The validated SQL is executed against the database.
7.  **Self-Correction**: If execution fails, the system attempts to fix the SQL via an LLM retry loop.
8.  **Summarization & Charting**: Results are converted to natural language and a **Vega-Lite** chart specification.
9.  **Watcher Agent**: A final QA pass ensures the output is safe, technical jargon-free, and factually accurate.

---

## 3. Automation & Ingestion Pipeline
The project features a "self-modifying" ingestion pipeline:
- **`ingest_schema.py`**: Reads `.sql` DDL files, uses an LLM to generate descriptions, and then dynamically updates `static_schema_provider.py` and `build_knowledge_base.py` via regex-based source code modification.
- **`build_knowledge_base.py`**: Generates a local `faiss_index/` using Google Generative AI Embeddings.

---

## 4. Security Guardrails
- **AST Sanitization**: Prevents destructive operations (`DROP`, `DELETE`, etc.) at the parser level.
- **Row-Level Security (RLS)**: Mandatory token injection ensures multi-tenancy is enforced even if the LLM makes errors.
- **Column Scrubbing**: The ingestion script physically removes columns tagged with `-- SENSITIVE` from the schema before it ever reaches the LLM.
- **Read-Only Database User**: Recommended for local and production use.
