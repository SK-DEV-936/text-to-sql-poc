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
    - `StaticSchemaProvider`: hardcoded subset of tables (`orders`, `order_details`, `catering_orders`, `catering_order_details`, `order_history`) and relationships.
  - **LLM**
    - `LangChainTextToSqlAdapter`: A real LangChain + LLM implementation that generates MySQL queries based on the schema and few-shot examples.
    - `LlmSummarizer`: Uses an LLM to generate natural language summaries of the data results.
  - **DB**
    - `MySqlExecutor`: The primary executor, used for both local development (via Docker) and AWS RDS. It utilizes asynchronous `aiomysql`.
    - `InMemoryDemoExecutor`: A legacy/fallback SQLite executor for no-DB local runs. No longer the default path.

- **Interface / delivery (`interface/api/`)**
  - `routes.py`:
    - FastAPI router with `POST /text-to-sql/`.
    - Request: `role`, `merchant_ids`, `question`.
    - Response: `final_sql`, `rows`, optional `summary`, `warnings`.
    - Converts HTTP JSON ↔ domain models and calls `GenerateAndExecuteQueryService`.

- **Composition root (`main.py`)**
  - Creates FastAPI app.
  - Loads settings from environment via `load_settings()`.
  - Instantiates:
    - `StaticSchemaProvider`
    - `LangChainTextToSqlAdapter`
    - `SimpleSqlValidator`
    - `MySqlExecutor` (default, points to Docker locally or RDS in AWS).
    - `LlmSummarizer`
  - Wires them into `GenerateAndExecuteQueryService` and mounts the `POST /text-to-sql` router.

### Current behavior (POC)

- The service is fully wired and can be started via:

```bash
./run_demo.sh
```

- When calling `POST /text-to-sql/`:
  - The LLM adapter generates a relevant MySQL query (e.g., `SELECT COUNT(*) FROM orders`).
  - The validator enforces safety, Row-Level Security (for merchants), and a 1000-row limit.
  - The executor returns real data from the local MySQL Docker instance.
  - The summarizer provides a human-friendly text response.

This ensures the POC provides a **high-fidelity simulation** of the final production environment.

