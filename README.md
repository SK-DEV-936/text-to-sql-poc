## Boons Text-to-SQL Agent (POC)

Minimal, clean-architecture Python POC for a local-first, AWS-compatible text-to-SQL analytics agent for a food-ordering system.

### Tech stack

- **Language**: Python 3.10+
- **Web framework**: FastAPI
- **DB**: MySQL (local / Docker) via async driver
- **LLM**: Pluggable via LangChain + OpenAI (can be swapped later)

### High-level architecture

- **domain/**: Pure business models (`Question`, `Scope`, `SqlQuery`, `QueryResult`, `Role`, etc.). No FastAPI, DB, or LLM imports.
- **application/**: Use cases and ports. Main use case: `GenerateAndExecuteQueryService`.
- **infrastructure/**: Adapters that implement ports (LLM, DB, validator, schema provider, summarizer).
- **interface/api/**: FastAPI routes mapping HTTP JSON ↔ domain models and calling the use case.
- **main.py**: Composition root that wires everything together.

### Running locally

1. Create and activate a virtualenv.
2. Install dependencies:

```bash
pip install -e ".[dev]"
```

3. Start the API:

```bash
uvicorn boons_text_to_sql_agent.main:app --reload
```

4. Open the interactive docs at:

```text
http://localhost:8000/docs
```

You will see a minimal `POST /text-to-sql` endpoint wired through the clean architecture layers. The initial version uses stubbed implementations and is meant as a foundation for iterative hardening.

