# Developer Environment Guide & Architecture

This guide covers the local development environment for the Boons Text-to-SQL AI Agent. 
*(For AWS Deployment, refer exclusively to `aws-deploy/eks_deployment_guide.md`)*

## 1. Local Setup (Docker Compose & FAISS)

The local stack is powered by a Dockerize MySQL instance and a local FAISS vector database.

### Initializing the Database
The project contains massive seed data files (e.g. `db/init/generate_seed_data.py`).
1. Spin up the local database using Docker Compose (if applicable) or a local MySQL server.
2. Ensure `.env` is set to `ENVIRONMENT="local"` and `FORCE_LOCAL_RAG="1"`.

### Generating the Knowledge Base
To parse your `.sql` table configurations into the Python schema AST:
```bash
python scripts/ingest_schema.py --schema db/init/your-schema.sql
```
To compile the extracted semantic business rules into the live local vector search engine (FAISS):
```bash
python scripts/build_knowledge_base.py
```

### Running the Application
The fastest way to test your schema changes is via the Streamlit Chat interface:
```bash
./run_demo.sh
```
This boots the `demo_chat.py` UI and background FastAPI server.

---

## 2. Core Architecture Philosophy

The project uses **Clean Architecture** to map natural human language to secure, executable SQL.

### Execution Flow
1. **User asks a question** (e.g., "What was our net revenue yesterday?").
2. **Context Retrieval (RAG)**: The system vector-searches the FAISS Index (Local) or Bedrock Knowledge Base (AWS) to find the semantic definition of "Net Revenue" (e.g. `order_status = 'completed'`).
3. **Schema Injection**: The exact JSON mapping of the database structure (`static_schema_provider.py`) is gathered.
4. **LLM Generation**: The system prompt forces Claude/OpenAI to generate a pure `SELECT` statement using the RAG definition.
5. **AST Validation & Security Check**: `sqlglot` parses the generated SQL string to ensure no destructive operations (`DROP`) are present and forces the `__RLS_MERCHANTS__` security token dynamically.
6. **Execution**: The backend `aiomysql` queries the data without blocking.

Any execution error is fed back into a **Self-Correction Loop** where the LLM is given the MySQL error log and told to fix its own query up to 3 times before failing.
