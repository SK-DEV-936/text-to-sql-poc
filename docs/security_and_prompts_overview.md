# Security & Prompts Overview

This document provides a non-technical summary of how the Text-to-SQL AI Agent enforces security and dynamically alters its behavior based on user roles (e.g., Merchant vs. Internal).

## 1. LLM Prompt Guidelines

The agent uses a two-part instruction set for the AI model:

### Base Instructions
All requests to the AI follow these fundamental, unchangeable rules:
- **Strictly Read-Only:** The AI is instructed that it may *only* generate SQL `SELECT` statements. It is explicitly forbidden from generating any destructive actions like `INSERT`, `UPDATE`, `DELETE`, or `DROP`.
- **Targeted Output:** The AI must only output the final SQL string without conversational filler.

### Role-Specific Context
The AI dynamically adjusting its context based on the user interacting with the system:
- **MERCHANTS:** When a merchant asks a question, the AI is instructed to focus exclusively on their specific `orders` and `order_items`. The AI is told to ignore data belonging to other merchants.
- **INTERNAL ADMINS:** When an internal user asks a question, the AI is granted broader context to write queries joining more complex, system-wide tables for analytics.

*These prompts are fully configurable in `config/prompts.yaml`.*

## 2. Guardrails & Security Boundaries

Beyond instructing the AI, the system enforces hard security constraints on the final SQL before execution. If a query violates a guardrail, it is rejected immediately.

### Schema Ingestion Filtering (Sensitive Data Protection)
To ensure the LLM never hallucinates queries against highly sensitive data (like PIC names, phone numbers, internal metrics, or passwords), the system employs **Schema Sanitization during Ingestion**.
- **Security by Obscurity**: Before the database schema is ingested into the agent's RAG knowledge base or prompt block, any columns tagged as `-- SENSITIVE` by the Database Engineer are completely stripped from the schema definitions.
- **Zero-Trust**: Because the LLM does not even know the sensitive columns physically exist in the database tables, it is incapable of writing SQL queries to retrieve them. If a user asks for them, the LLM will simply state the data is unavailable.

### Row-Level Security (RLS) via Mandatory Tokens
- **The Magic Token (`__RLS_MERCHANTS__`)**: To prevent the AI from "guessing" IDs or hallucinating data, we use a proactive placeholder model. The AI is strictly instructed to use the string `__RLS_MERCHANTS__` in its SQL queries instead of actual numbers.
- **Mandatory Validation**: Before the database sees any SQL, our security validator scans the text. If the token is missing, the query is instantly killed with a Security Violation error. 
- **Secure ID Substitution**: Only *after* the token is found does the system swap it for the user's actual, verified IDs (e.g., `IN (1, 2)`). This ensures the AI never actually "knows" what data it is filtering, creating a hard security boundary between the conversational layer and the data layer.
- **Limit Enforcement**: All queries are automatically clamped to a maximum row limit to prevent database overload (default: 1000 rows).

### Regex Blocklists
To prevent malicious prompts from slipping through, the system scans the final AI-generated SQL using configurable regex patterns:
- **Blocked Operations:** The system scans for and instantly blocks any query containing commands like `INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE`, `GRANT`, or `REVOKE`.
- **Blocked Tables:** The system maintains a blocklist of tables that no text-to-SQL query can ever access (e.g., `users_passwords`, `internal_audit_logs`).

*These guardrails and blocklists are fully configurable in `config/guardrails.yaml`.*
