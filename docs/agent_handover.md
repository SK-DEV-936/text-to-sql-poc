# AI Agent Operations & Handover Guide

This document is specifically designed as the ultimate source of truth for any AI Assistant or autonomous Agent taking over the development of the Boons Text-to-SQL system.

---

## 1. Project Navigation & File Dictionary

The project enforces a strict separation between **Local FAISS Generation** and **AWS Bedrock / EKS Infrastructure**.

### The Core Engine (`boons_text_to_sql_agent/`)
* **`infrastructure/schema/static_schema_provider.py`**: The raw DB dictionary definition (columns, keys, data types). It is *automatically overwritten* by ingestion scripts and directly injected into the LLM system prompt as JSON text.
* **`infrastructure/llm/`**: Contains the orchestrators connecting to the Vector Databases (FAISS/Bedrock) and the raw LLMs.
* **`config.py`**: Global configuration router. Switching `ENVIRONMENT` from `local` to `aws-dev` instantly swaps databases and vector backends.

### The Local Environment (FAISS Native)
* **`scripts/ingest_schema.py`**: A local-only script. Reads `.sql` files, generates a JSON schema AST, and appends fuzzy business rules (e.g., "lunch equals 11:30-3:00") directly into the python code of `build_knowledge_base.py`.
* **`scripts/build_knowledge_base.py`**: Compiles native Python dictionary RAG rules into the `faiss_index/` vector database.
* **`run_demo.sh` & `demo_chat.py`**: The local Streamlit testing application.
* **`tests/test_suite.py`**: The integration test suite.

### The AWS Execution Workload (`aws-deploy/`)
* **`aws-deploy/docs/app_runner_deployment_guide.md`**: The sole source of truth for AWS App Runner deployment.
* **`aws-deploy/scripts/aws_ingest_schema.py`**: The isolated AWS Bedrock schema parser. It generates raw Markdown files instead of overwriting Python.
* **`aws-deploy/knowledge/*.md`**: The raw text rules (synced to the AWS S3 Bucket) that the Amazon Bedrock Knowledge Base automatically absorbs.
* **`aws-deploy/db/init/`**: Clean `orders-schema.sql` files for AWS RDS initialization.

---

## 2. Hard Security Guardrails

When modifying the codebase or schemas, you **MUST** adhere to the following security architectures:

1. **The Strict Read-Only Policy:** The Agent is strictly forbidden from generating `INSERT`, `UPDATE`, `DELETE`, or `DROP`. The application enforces Regex Blocklists against these operations.
2. **Schema Sanitization (`-- SENSITIVE`):** If a Database Engineer tags a column as `-- SENSITIVE` in the raw `.sql` schema, you must ensure the `ingest_schema.py` parser physically strips that column out before it ever reaches `static_schema_provider.py` or the LLM prompt. Security by obscurity is mandatory.
3. **Multi-Tenant Row-Level Security (RLS):** 
   - You must instruct the AI generation layer to use the placeholder `__RLS_MERCHANTS__` for user IDs. 
   - A query is *instantly killed* if this security token is missing. The backend validator securely swaps this token for the verified user IDs *after* the LLM completes generation.

---

## 3. Schema Engineering Rules (For RAG)

When adding or interpreting database schema for the Vector DB:
* **Precision Over Description:** Do not formulate generic descriptions. (`status`: "Valid values are strictly: 'completed', 'cancelled'. ALWAYS filter by `status = 'completed'` when calculating net sales").
* **Danger Columns:** Specifically warn the LLM about columns that look like revenue but are not (e.g. `discount_total`).
* **Explicit Foreign Keys:** Always provide exact alias paths in the schema JSON relationships (e.g., `orders.merchant_uid -> merchants.id`) to prevent hallucinated JOINs.
