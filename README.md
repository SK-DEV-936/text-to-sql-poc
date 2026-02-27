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

### Running locally (API only)

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

### Local MySQL via Docker (optional but recommended)

This project includes a self-contained **MySQL + schema + seed data** setup so other developers can run the same database locally without extra setup.

1. Start MySQL using Docker:

```bash
cd db
docker compose up -d
```

This starts a MySQL 8.0 instance with:

- Database: `boons`
- Admin user: `boons_admin` / `adminpass`
- Read-only agent user: `boons_readonly` / `change-me`

2. Ensure the API is configured to talk to this DB (these are the defaults in `config.py`):

```bash
export DB_HOST=localhost
export DB_PORT=3306
export DB_USER=boons_readonly
export DB_PASSWORD=change-me
export DB_NAME=boons
export USE_IN_MEMORY_EXECUTOR=false
```

3. Start the API as usual:

```bash
uvicorn boons_text_to_sql_agent.main:app --reload
```

### Running the Full Demo (UI + API)

For the easiest experience, use the provided demo script which starts both the backend and the Streamlit frontend:

1. Ensure the virtual environment `venv` exists and dependencies are installed.
2. Run the demo script from the project root:

```bash
./run_demo.sh
```

This script automatically handles:
- Port cleanup (killing previous instances on 8000/8501).
- Starting the FastAPI backend.
- Launching the Streamlit Chat UI.
- Shutting down everything when you Ctrl+C.

