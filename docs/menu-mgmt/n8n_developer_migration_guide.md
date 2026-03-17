# Developer Guide: Migrating n8n Workflows to the Python Core Engine

This guide is for **n8n developers** who are transitioning from visual, node-based workflows to the Python-based **Boons Core Engine**.

---

## 1. Technical Shift: Visual Nodes to Python Logic

| If you did this in n8n... | Do this in the Core Engine... |
| :--- | :--- |
| **HTTP Request Node** (to Gemini) | Use `ChatGoogleGenerativeAI` in the `Vision Agent`. |
| **Wait for Approval Node** | Use the `pending_mutations` table + `Approval UI`. |
| **MySQL Node** (Read/Write) | Use the `MySqlExecutor` class in the `Infrastructure Layer`. |
| **Workflow Trigger** (Webhook) | Use the `/api/v1/menu-mgmt/upload` endpoint. |
| **IF/Switch Nodes** | Use **Python logic** or **LangGraph nodes** for routing. |

---

## 2. Preparing your Migration: 4-Step Checklist

### Step 1: Export & Document current n8n Logic
Before switching, map out your current n8n prompts.
*   **Action**: Export your n8n workflows as JSON.
*   **Action**: Identify where you are using `OCR` vs. `Prompt Engineering`.

### Step 2: Implement the "Vision Agent" Prompt
The Core Engine uses Gemini 2.5 Pro natively. 
*   **Action**: Copy your n8n prompt into the Python `MenuVisionAgent`.
*   **Action**: Add the `media_bytes` parameter to handle direct image uploads without base64-encoding nodes.

### Step 3: Implement Mutation Security
n8n often lacks strict SQL validation.
*   **Action**: Ensure that any logic that previously generated SQL now routes through the `SecurityAuditorAgent`.
*   **Action**: **Never** manually concatenate strings into SQL. Use the engine's built-in parameterization.

### Step 4: Shadow Mode Testing
Do not delete your n8n workflow immediately.
*   **Action**: Configure n8n to send a copy of every request to the Core Engine's `/shadow-test` endpoint.
*   **Action**: Compare the structured JSON output from n8n vs. the Core Engine.

---

## 3. Interaction API for n8n Developers

Once the Core Engine is deployed, your frontend (or even n8n for notifications) will interact with it like this:

### Triggering an Extraction
```bash
# Upload a menu image for processing
curl -X POST "http://core-engine/api/v1/menu-mgmt/upload" \
     -F "file=@menu_photo.jpg" \
     -F "merchant_id=123"
```

### Approving a Mutation
```bash
# Approve the proposed SQL change after review
curl -X POST "http://core-engine/api/v1/menu-mgmt/approve/998" \
     -H "Authorization: Bearer <your-key>"
```

---

## 4. Key Reusable Files in this Project
*   `boons_text_to_sql_agent/config.py`: Central place for your API keys.
*   `tests/test_gemini_api.py`: Use this to verify your Gemini connection before coding logic.
*   `infrastructure/llm/langchain_text_to_sql.py`: Template for how to structure a specialized agent.
