## Architecture overview

This POC follows a **Clean / Hexagonal Architecture** for a local-first, AWS-compatible text-to-SQL analytics agent.

### Layers and modules

- **Domain (`domain/`)**
  - Pure business concepts, no framework/SDK imports.
  - Key models:
    - `Role` enum: `merchant`, `internal`.
    - `Scope`: role, merchant_ids, optional customer_id, max_rows, default_time_window_days.
    - `Question`: natural-language question + `Scope`.
    - `SqlQuery`: SQL text + parameters.
    - `QueryResult`: final SQL + rows + optional summary/warnings.

- **Application (`application/`)**
  - **Use case**
    - `GenerateAndExecuteQueryService`:
      - Input: `Question`.
      - Flow: schema provider → text-to-SQL LLM → SQL validator (safety + limits) → SQL executor → summarizer.
      - Output: `QueryResult`.
  - **Ports/interfaces (`application/ports/`)**
    - `SchemaProviderPort`: returns schema manifest for a given `Scope`.
    - `TextToSqlPort`: generates `SqlQuery` from `Question` + schema manifest.
    - `SqlValidatorPort`: validates/enforces safety and scope; returns corrected `SqlQuery` or raises.
    - `SqlExecutorPort`: executes validated `SqlQuery` and returns rows.
    - `ResultSummarizerPort`: optionally summarizes results.

- **Infrastructure (`infrastructure/`)**
  - **Schema**
    - `StaticSchemaProvider`: hardcoded subset of tables (`merchants`, `orders`, `order_items`, `customers`) and relationships.
  - **LLM**
    - `LangChainTextToSqlAdapter`: currently a **placeholder** that always returns a safe demo `SELECT ... FROM merchants LIMIT 10`. Will be replaced with a real LangChain + LLM implementation.
    - `NoopSummarizer`: returns no summary; stub for future LLM summarization.
  - **DB**
    - `InMemoryDemoExecutor`: returns fake merchant rows instead of talking to a real MySQL instance. Will later be replaced with an async MySQL executor using the real schema.
  - **Security / guardrails**
    - `SimpleSqlValidator`:
      - Enforces **SELECT-only**.
      - Rejects obviously dangerous tokens (INSERT/UPDATE/DELETE/DROP/ALTER/TRUNCATE, `;`).
      - Ensures a `LIMIT` exists and clamps it to `scope.max_rows`.
      - Does **not yet** enforce row-level `merchant_id` predicates (RLS) – that’s a planned enhancement.

- **Interface / delivery (`interface/api/`)**
  - `routes.py`:
    - FastAPI router with `POST /text-to-sql`.
    - Request: `role`, `merchant_ids`, `question`.
    - Response: `final_sql`, `rows`, optional `summary`, `warnings`.
    - Converts HTTP JSON ↔ domain models and calls `GenerateAndExecuteQueryService`.

- **Composition root (`main.py`)**
  - Creates FastAPI app.
  - Instantiates:
    - `StaticSchemaProvider`
    - `LangChainTextToSqlAdapter` (placeholder)
    - `SimpleSqlValidator`
    - `InMemoryDemoExecutor`
    - `NoopSummarizer`
  - Wires them into `GenerateAndExecuteQueryService` and mounts the `POST /text-to-sql` router.

### Current behavior (POC)

- The service is fully wired and can be started via:

```bash
uvicorn boons_text_to_sql_agent.main:app --reload
```

- When calling `POST /text-to-sql`:
  - The LLM adapter returns a fixed `SELECT ... FROM merchants LIMIT 10`.
  - The validator enforces safety and limit.
  - The executor returns in-memory demo merchant rows.
  - The summarizer returns no summary.

This keeps the POC **runnable without any external dependencies** (no DB, no LLM) while preserving the clean architecture boundaries for later extension.

