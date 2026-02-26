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

### Row-Level Security (RLS)
- **Mathematical Scoping:** When a Merchant submits a query, the system mathematically scopes the final SQL string by wrapping it in an outer constraint. Even if the AI hallucinated a query fetching data for "Restaurant 123" when the user is "Restaurant 45", the system intercepts it and forcefully overrides the filter to strictly enforce `WHERE restaurant_id IN (45)`.
- **Limit Enforcement:** All queries are automatically clamped to a maximum row limit to prevent database overload (default: 1000 rows).

### Regex Blocklists
To prevent malicious prompts from slipping through, the system scans the final AI-generated SQL using configurable regex patterns:
- **Blocked Operations:** The system scans for and instantly blocks any query containing commands like `INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE`, `GRANT`, or `REVOKE`.
- **Blocked Tables:** The system maintains a blocklist of tables that no text-to-SQL query can ever access (e.g., `users_passwords`, `internal_audit_logs`).

*These guardrails and blocklists are fully configurable in `config/guardrails.yaml`.*
