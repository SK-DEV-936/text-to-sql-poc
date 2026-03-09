# Database Engineer Guidelines: Schema Design for LLMs

When adding new tables or columns to the `StaticSchemaProvider` for the Text-to-SQL AI Agent, **mathematical precision is not enough**. The AI relies heavily on the semantic descriptions you provide to understand *business intent*.

Before executing `scripts/ingest_schema.py` or manually modifying the dictionary, you must adhere to the following rules to prevent AI hallucinations and devastating query errors.

---

## 1. High-Value Column Descriptions
Never leave a column description blank, and never state the obvious. Tell the AI exactly **how the business uses the column**.

*   ❌ **Bad:** `status`: "The status of the order."
*   ✅ **Good:** `status`: "The stage of the order lifecycle. Valid values are strictly: 'completed', 'cancelled', 'in_progress', 'refunded'. ALWAYS filter by `status = 'completed'` when calculating net sales or revenue."

## 2. Flag "Danger" Columns Explicitly
If a column contains financial numbers but is *not* revenue (e.g., discounts, taxes, fees), the AI will accidentally sum it up. You must explicitly warn the AI.

*   ✅ **Good:** `discount_total`: "The total amount discounted off the bill. CAUTION: Do NOT add this to revenue calculations. To find net revenue, subtract this from grand_total."
*   ✅ **Good:** `is_test_order`: "Boolean flag (1=true, 0=false). IMPORTANT: Always filter out `is_test_order=1` when the user asks for real financial metrics."

## 3. Explicit Foreign Key Mapping
LLMs are terrible at guessing how to `JOIN` tables if the column names don't perfectly match (e.g., `merchants.id` joining to `orders.merchant_uid`). You must explicitly map the exact joining pipeline in the `relationships` array.

*   ✅ **Good:** Provide the exact alias paths: `{"from": "orders.merchant_uid", "to": "merchants.id"}` so the LLM doesn't have to guess.

## 4. Hide "Noise" Tables
Do not give the AI irrelevant tables. Every table in the schema slows down the prompt processing and increases the chance of confusion. 
*   **Action:** Exclude `password_reset_tokens`, `audit_logs`, `django_migrations`, etc.

---

## The Pre-Flight Checklist
Before finalizing a schema addition, ask yourself:
1. *"What are the top 5 questions the business will ask about this specific table?"*
2. *"Are there any edge cases (like catered events, test accounts, or internal employee orders) that will corrupt the numbers?"* (If yes, explicitly define the EXCLUSION logic in the column description).
3. *"Did I define what 'Revenue' means for this specific table?"*
