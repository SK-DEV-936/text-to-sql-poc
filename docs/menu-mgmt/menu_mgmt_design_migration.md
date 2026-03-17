# Detailed Design: Menu Management Core Engine Migration

## 1. Executive Summary
This document outlines the architectural shift from the current **n8n-based** prototyping flow to a **Custom Python Core Engine** leveraging Gemini 2.5 Pro. The goal is to move from a visual workflow tool to a highly secure, scalable, and version-controlled microservice capable of multimodal menu data processing and safe database mutations.

---

## 2. n8n vs. Custom Core Engine: Why Migrate?

| Feature | n8n (Current) | Custom Core Engine (Target) |
| :--- | :--- | :--- |
| **Logic Control** | Visual nodes (limited complex logic) | Pure Python (LangGraph/LangChain) |
| **Security** | General API auth | Fine-grained Merchant Isolation & Security Guards |
| **Multimodal** | Basic integration | Native Gemini 2.5 Vision/PDF processing |
| **Maintenance** | Manual node updates | Git-based CI/CD and unit testing |
| **HITL** | Manual dashboarding | Integrated "Proposed Changes" workflow |

---

## 3. Detailed Architectural Design

### 3.1 The Multi-Agent Orchestration (LangGraph-based)
Instead of a linear n8n flow, we will use a **cyclic multi-agent graph**:

1.  **Input Receiver**: Accepts Image/PDF bytes + Merchant Metadata.
2.  **Vision Extraction Agent**: Gemini-powered OCR + Schema Mapping.
3.  **Conflict Resolver Agent**: Checks existing database entries to determine if a change is an `INSERT` or an `UPDATE`.
4.  **Security Auditor Agent**: Final validation of the SQL string for Merchant ID isolation (`WHERE merchant_id = ?`) and table ACLs.
5.  **Staging Layer**: Instead of direct commit, it outputs a "Change Manifest" for human review.

### 3.2 Security Guardrails (The "Air-Gap")
*   **Validator 1 (Syntax)**: Ensures the SQL is valid MySql.
*   **Validator 2 (Semantic)**: Ensures the merchant isn't trying to update a field labeled `system_admin`.
*   **Validator 3 (Tenant)**: Replaces any `merchant_id` in the prompt-generated SQL with the *authenticated* session ID.

---

## 4. User Stories

### Merchant Personas
*   **Story 1**: As a Merchant, I want to upload a photo of my handwritten "Daily Specials" so that my digital menu updates automatically without manual typing.
*   **Story 2**: As a Merchant, I want to see a preview of the price changes before they go live, so that I don't accidentally overcharge my customers.
*   **Story 3**: As a Merchant, I want to upload a PDF of my supplier's price list to bulk-update my inventory prices.

### Admin/DevOps Personas
*   **Story 4**: As a DevOps Engineer, I want the system to block any SQL query that doesn't include a `merchant_id` filter to prevent cross-tenant data leaks.
*   **Story 5**: As a Developer, I want to be able to unit test the OCR accuracy separate from the SQL generation logic.

---

## 5. Detailed Task & Sub-Task Breakdown

### Phase 1: Foundation & Data Modeling (Planning)
*   [ ] **Task 1.1: Database Schema Finalization**
    *   Sub-task: Define `menus`, `categories`, `menu_items`, and `price_history` tables in [SQL Data Model](./menu_mgmt_data_model.md).
    *   Sub-task: Implement MySQL row-level security (RLS) policies.
*   [ ] **Task 1.2: Multimodal Input Specification**
    *   Sub-task: Define standard JSON schema for a "Menu Item".
    *   Sub-task: Document API contract for multipart/form-data uploads.

### Phase 2: Core AI Agent Logic (Implementation)
*   [ ] **Task 2.1: Vision Extraction Agent Implementation**
    *   Sub-task: Prompt engineering for high-accuracy menu OCR.
    *   Sub-task: Handling multi-page PDF menus via Gemini context window.
*   [ ] **Task 2.2: The Mutation Generator**
    *   Sub-task: Map OCR JSON to `INSERT/UPDATE` SQL.
    *   Sub-task: Implement logic to detect existing items (Fuzzy matching on menu names).
*   [ ] **Task 2.3: Security Auditor (The Guardrail)**
    *   Sub-task: Regex-based SQL sanitizer.
    *   Sub-task: LLM-based "Intent Analysis" to detect malicious instructions.

### Phase 3: HITL & API Integration
*   [ ] **Task 3.1: Staging & Approval Service**
    *   Sub-task: Create a `staging_changes` table to hold pending approvals.
    *   Sub-task: Implement `POST /menu-mgmt/approve/{id}` endpoint.
*   [ ] **Task 3.2: Merchant UI Update**
    *   Sub-task: Build a side-by-side "Original Image vs. Extracted Data" review screen.

---

## 6. Migration Strategy (n8n → Core Engine)
1.  **Shadow Mode**: Run the Core Engine in parallel with n8n, logging results for comparison.
2.  **Read-Only Switch**: Move the extraction logic to the Core Engine but keep n8n for notifications/emails.
3.  **Full Cutover**: Decommission n8n workflows and route all traffic through the Python microservice. Take reference from the [n8n Migration Guide](./n8n_developer_migration_guide.md).

---

## 7. Reusable Components from Core Engine

The Menu Management Engine will leverage these existing project pillars to accelerate development:

### 7.1 Infrastructure & Adapters
*   **Gemini 2.5 Pro Core**: The configuration in `config.py` and the `ChatGoogleGenerativeAI` adapters are 100% reusable for the new Vision and Mutation agents.
*   **MySqlExecutor**: The database connection management is already verified with AWS RDS. We only need to toggle `read_only=False` for this flow.
*   **StaticSchemaProvider**: We will extend this to include the new `menu_items` and `categories` tables, ensuring the LLM always has the correct "ground truth" schema.

### 7.2 Security & Multi-Tenancy
*   **Scope & Role Domain Objects**: The existing logic for `merchant_ids` and `Role.MERCHANT` is the foundation for our mandatory `WHERE merchant_id = ?` security filter.
*   **SQL Validation Pattern**: The logic path used in `SimpleSqlValidator` will be evolved into the **Security Auditor Agent**, reusing the same "interceptor" pattern.

### 7.3 DevOps & Deployment
*   **AWS App Runner Pipeline**: The Dockerfile, CI/CD guides, and App Runner secrets configuration (`GEMINI_API_KEY`) remain identical.
*   **Secrets Manager Integration**: The pattern for fetching DB credentials and API keys is fully established.

### 7.4 UI Patterns
*   **Streamlit Chat Interface**: The session state management and chat history logic in `demo_chat.py` will serve as the template for the Menu Upload and Approval UI.
