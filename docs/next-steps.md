## Next steps and project status

This file captures **where the POC is today** and a suggested sequence of next steps so a future engineer/agent can continue smoothly.

- Clean architecture skeleton in place.
- **Real local MySQL / Docker DB** (High-fidelity RDS simulation):
  - `MySqlExecutor` (async) is the default.
  - Dockerized MySQL under `db/` with 5,000+ seed records.
  - Environment-aware config (`local`, `aws-dev`, `aws-prod`).
- FastAPI `POST /text-to-sql` endpoint wired end-to-end.
- POC is runnable locally via `./run_demo.sh`.

### Short-term next steps (minimal POC to “real” agent)

1. **Implement real LLM-based Text-to-SQL**
   - Replace the placeholder in `LangChainTextToSqlAdapter` with:
     - A proper prompt (system rules + schema manifest).
     - Few-shot examples from the PDF spec.
   - Use environment variables for API key and model.
   - Keep all LLM calls behind the `TextToSqlPort` interface.
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

