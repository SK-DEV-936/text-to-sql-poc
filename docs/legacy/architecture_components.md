# Boons Text-to-SQL Architecture Components

This document breaks down the components of the Boons Text-to-SQL architecture (as visualized in the main architecture diagram) and details the specific frameworks and libraries that power each step of the pipeline.

## 1. The Frontend & Entry Points

*   **User (Merchant/Internal):** The person asking the question (e.g., "What was my revenue yesterday?"). The system treats them differently based on their role (Internal staff see all data, Merchants only see their own).
*   **Streamlit UI / Chat Interface:** The visual frontend where the user types their question and sees the final chat response and data tables.
    *   **Framework:** `streamlit` (Rapid Python web app framework for data applications).
*   **FastAPI POST /text-to-sql:** The backend API endpoint. It receives the user's question from Streamlit and kicks off the processing pipeline.
    *   **Framework:** `fastapi` (High-performance async web framework).
    *   **Validation:** `pydantic` (Data parsing and validation for API requests).

## 2. The Orchestrator

*   **GenerateAndExecuteQueryService:** This is the "brain" or traffic controller of the application. It doesn't actually do the heavy lifting itself; instead, it calls all the other specialized services in the correct order to get the job done.
    *   **Pattern:** Hexagonal / Clean Architecture (Dependency Injection).
*   **Payload (chat_history & RLS Context):** The package of data moving through the system. It contains the user's question, past chat history (so the AI remembers context), and their Row-Level Security (RLS) details (like their `restaurant_id`).
    *   **Framework:** `langchain_core.messages` (Standardized message formats for LLM context).

## 3. Context gathering (Teaching the AI)

*   **StaticSchemaProvider:** Contains the hardcoded dictionary of your database structure (table names, column descriptions, and how tables join together). It gives the AI the blueprint of your data.
*   **FAISS / Bedrock Vector DB:** The Retrieval-Augmented Generation (RAG) knowledge base. When a user asks about "dinner", this database is searched to find the SQL definition of "dinner" (e.g., `HOUR > 17`).
    *   **Framework (Local):** `faiss-cpu` (Facebook AI Similarity Search for fast local vector lookups) and `langchain_community.vectorstores`.
    *   **Framework (AWS Bedrock):** Amazon OpenSearch Serverless (managed vector store).
    *   **Embeddings:** `langchain_openai.OpenAIEmbeddings` or `langchain_aws.BedrockEmbeddings`.

## 4. Query Generation & Validation

*   **LLM: Text-to-SQL Generator:** The first AI agent. It takes the Schema, the Vector DB synonyms, and the User's question, and attempts to write a raw MySQL query.
    *   **Framework:** `langchain` (Chaining prompts, RAG context, and LLM calls).
    *   **Models:** `langchain_openai.ChatOpenAI` (Local/Testing) or `langchain_aws.ChatBedrock` (AWS Production).
    *   **Structured Output:** `pydantic` (Forcing the LLM to return strictly structured JSON containing the SQL).
*   **SimpleSqlValidator (sqlglot AST):** The security bouncer. Before any query touches the real database, the validator parses the SQL into an Abstract Syntax Tree (AST). It blocks dangerous commands like `DROP` or `DELETE`, and injects the mandatory `__RLS_MERCHANTS__` security token to guarantee a merchant can't query another merchant's data.
    *   **Framework:** `sqlglot` (A pure Python SQL parser and transpiler. It converts the SQL string into a programmatic tree that can be heavily inspected and modified securely).

## 5. Execution & Self-Correction

*   **MySQL / AWS RDS Database:** The actual relational database where your order data lives.
    *   **Driver:** `aiomysql` (Asynchronous MySQL driver to ensure database calls don't block the FastAPI server).
*   **LLM: SQL Fixer:** If the generated SQL crashes when it hits the MySQL database (e.g., a missing parenthesis or bad column name), the error is caught and sent to this specialized "Fixer" AI. The Fixer rewrites the query and tries again (up to 2 retry loops) without bothering the user.
    *   **Framework:** `langchain` (Error handling and prompt templating).

## 6. Formatting & Final Review

*   **LLM: Result Summarizer:** Once the MySQL database returns raw data rows, this AI reads the rows and converts them into a polite, professional English response (e.g., "Your restaurant had 15 orders yesterday.").
    *   **Framework:** `langchain` (Forcing the LLM to output a structured JSON response containing both the introductory text and raw data).
*   **LLM: Watcher Agent:** The final QA inspector. It reviews the Summarizer's draft response to ensure it didn't use confusing technical jargon (like mentioning "SQL" or "rows") and confirms the tone is appropriate before the final message is sent back to the Streamlit UI.
    *   **Framework:** `langchain` (Final pass validation chain).
