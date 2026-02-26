# Security Deep-Dive: Target Architecture and Vulnerability Analysis

This document explores the structural vulnerabilities discovered during a deep-dive analysis of the application's boundaries, specifically focusing on the `interface` (API endpoints) and the `application` (Ports & Services) layers. 

## 1. Interface Layer Vulnerabilities (`routes.py`)

### A. Missing Input Length Limits
- **Vulnerability**: The `QueryRequest` model does not enforce maximum lengths on the `question` field.
- **Impact**: A malicious user or bot could submit extremely large strings (e.g., megabytes of text) causing memory spikes and highly expensive token-consumption at the LLM level, leading to a Denial of Service (DoS) or unexpected billing costs.
- **Remediation**: Add `Field(max_length=500)` or similar constraints to the `question` field in `QueryRequest`.

### B. Unbounded `merchant_ids` Array
- **Vulnerability**: The `merchant_ids: List[int]` field does not have a bound on the list size. 
- **Impact**: Passing an array of 100,000 integers would cause a massive subquery expansion during validation: `WHERE merchant_id IN (?, ?, ?, ... 100,000x)`, likely crashing the SQL interpreter or exceeding parsing limits.
- **Remediation**: Add `max_items` validation to the `merchant_ids` list.

## 2. Application Layer Validation (`simple_sql_validator.py`)

### A. Trivial Regex Bypasses
- **Vulnerability**: The `SimpleSqlValidator` relies purely on regex string-matching to prevent malicious queries (`INSERT`, `DROP`, etc.). 
- **Impact**: Regex is notoriously poor at parsing SQL. A determined attacker could potentially use SQL comment injection or obscure syntax to trick the regex while still executing a malicious query (e.g., `SELECT /* INSERT */ 1`).
- **Remediation**: Replace string regex with an Abstract Syntax Tree (AST) SQL parser like `sqlglot` to structurally verify the query intent.

### B. `restaurant_id` Ambiguity & Shadowing
- **Vulnerability**: The RLS wrapper enforces security via: `SELECT * FROM ({text}) AS _rls_wrapper WHERE restaurant_id IN (...)`. 
- **Impact**: If the internal `{text}` query contains a self-join or pulls from multiple tables, multiple columns could be named `restaurant_id`, causing an ambiguous column alias error `Column 'restaurant_id' in where clause is ambiguous` and returning a 500 error instead of failing securely at the validation layer. Conversely, an attacker could artificially alias a harmless constant mathematically to `AS restaurant_id` to bypass the wrapper.
- **Remediation**: The validator should statically analyze the AST of the generated SQL to guarantee exactly one unambiguous `restaurant_id` output column exists before wrapping.

### C. `limit` Parsing Vulnerability
- **Vulnerability**: For `INTERNAL` roles, the validator manually alters the query string to append or rewrite the `LIMIT` clause using a regex: `re.sub(r"(limit\s+)(\d+)", ...)`.
- **Impact**: If the `LIMIT` keyword happens to appear inside a legitimate string literal within the query (e.g., `WHERE status = 'at the limit 100'`), the regex blindly overwrites the string literal, corrupting the query.
- **Remediation**: Again, AST parsing is required to safely modify limits on queries without destroying literals.

## 3. General Architecture Observations

- **Stack Traces**: Currently failing queries result in raw Python exception outputs in the logs. Ensuring we mask stack traces or DB errors from seeping into the API responses is critical. The current architecture successfully captures `Exception` and returns a generic `500 Internal server error` detail, which is a great structural defense against enumeration.
- **Role Enforcement at the Edge**: `routes.py` successfully stops unauthenticated payloads *before* they touch the domain (e.g., if a merchant tries to query without `merchant_ids`). This validates the clean architecture design.

---

**Summary:** The application is structurally well-designed. The API blocks malformed shapes and the service isolates concerns. However, the core weakness resides inside `SimpleSqlValidator` using naive Regex string-manipulation instead of robust AST structural parsing. Upgrading this single file will resolve the vast majority of execution and injection loopholes.
