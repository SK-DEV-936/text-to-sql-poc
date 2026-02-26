## Next steps and project status

This file captures **where the POC is today** and a suggested sequence of next steps so a future engineer/agent can continue smoothly.

### Current status (implemented)

- Clean architecture skeleton in place:
  - Domain models (`Question`, `Scope`, `SqlQuery`, `QueryResult`, `Role`).
  - Single use case: `GenerateAndExecuteQueryService`.
  - Ports for schema, text-to-SQL, validation, execution, summarization.
  - Infrastructure adapters that are **safe stubs** (no real DB or LLM yet).
  - FastAPI `POST /text-to-sql` endpoint wired end-to-end.
- POC is runnable entirely locally with:

```bash
uvicorn boons_text_to_sql_agent.main:app --reload
```

### Short-term next steps (minimal POC to “real” agent)

1. **Wire a real local MySQL / Docker DB**
   - Status: **largely done**.
   - Code and assets now include:
     - `MySqlExecutor` (async executor using a read-only MySQL user) in `infrastructure/db/mysql_executor.py`.
     - `main.py` can switch between `InMemoryDemoExecutor` (default) and `MySqlExecutor` using the `USE_IN_MEMORY_EXECUTOR` env var.
     - `config.py` exposes `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`.
     - A Dockerized MySQL setup under `db/`:
       - `db/docker-compose.yml`
       - `db/init/01-schema.sql` (DDL for `merchants`, `orders`, `order_items`, `customers` + read-only user).
       - `db/init/02-seed.sql` (simple synthetic seed data).
   - Still TODO:
     - Confirm parameter binding patterns once LLM output and validator behavior are finalized.

2. **Implement real LLM-based Text-to-SQL**
   - Replace the placeholder in `LangChainTextToSqlAdapter` with:
     - A proper prompt (system rules + schema manifest).
     - Few-shot examples from the PDF spec.
   - Use environment variables for API key and model.
   - Keep all LLM calls behind the `TextToSqlPort` interface.

3. **Strengthen SQL validation & RLS**
   - Extend `SimpleSqlValidator` to:
     - Enforce `merchant_id IN (:merchant_ids)` for merchant-scoped tables.
     - Optionally wrap queries in an outer `SELECT` to inject predicates and LIMIT.
   - Add unit tests for:
     - Allowed vs disallowed patterns.
     - Correct limit clamping.
     - Correct behavior when scope is missing (reject vs rewrite).

4. **Basic logging & observability**
   - Add a small logging module (or use Python `logging`) to record:
     - Role & scope (non-sensitive).
     - Question text.
     - LLM-generated SQL.
     - Final executed SQL.
     - Row count and errors.

### Medium-term enhancements (toward the PDF spec)

- Support:
  - Role `internal` with broader access (still read-only).
  - Additional views (e.g. `merchant_orders_view`) to simplify prompts.
- Add:
  - LLM-based summarizer implementation.
  - More detailed error handling and user-facing messages in the API.
- Prepare:
  - Config structure that can flip from local DB to AWS RDS using env vars only.

### How a future agent should continue

1. Read:
   - `README.md` at project root.
   - `docs/architecture.md` (this gives the mental model).
   - This `docs/next-steps.md` file.
2. Decide which of the **short-term next steps** to implement first (recommended order: DB → validator → LLM → logging).
3. Keep changes behind the existing ports/interfaces to preserve the clean architecture boundaries.

