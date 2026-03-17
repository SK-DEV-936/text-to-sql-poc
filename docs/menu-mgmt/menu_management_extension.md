# Architecture Note: Leveraging Boons as a Menu Management Engine

You can effectively leverage the current Text-to-SQL engine as a foundation for your **Menu Management AI**. Gemini 2.5 Pro’s multimodal strength is a perfect fit for this.

## 1. Multimodal Input Evolution
The current engine processes text. Gemini 2.5 Pro can handle **Vision (Images)** and **PDFs**.
- **Expansion**: Extend the `Question` domain object to accept `media_bytes`.
- **Implementation**: The `LangChainTextToSqlAdapter` can be updated to include image/file context in the prompt, allowing it to "Look at this menu photo and generate the SQL to update our database."

## 2. Reusing the SQL Generation Core
The pattern of **Natural Language → SQL → Execution** remains identical, but shifts from `SELECT` to `UPDATE/INSERT`.
- **Service Layer**: Create a `MenuMutationService` that mirrors the `GenerateAndExecuteQueryService`.
- **Dynamic Schema**: Reuse the `StaticSchemaProvider` so the LLM knows the exact structure of your `menu_items`, `prices`, and `categories` tables.

## 3. Extending Security (The "Mutation Guard")
The current `SimpleSqlValidator` is "Read-Only". For menu updates:
- **Table-Level ACLs**: Allow `UPDATE` and `INSERT` specifically for the `menu_items` table while still blocking `DROP` or `DELETE` on core system tables.
- **Human-in-the-Loop (Recommended)**: Instead of auto-executing, the API can return the "Proposed Change" (JSON) to your Chat UI. The merchant clicks "Approve" before the `MySqlExecutor` commits it.

## 4. Multi-Tenant Integrity
The current `Scope` and `merchant_ids` logic is critical.
- **RLS**: Ensure every generated `UPDATE` statement includes a `WHERE merchant_id = X` clause, preventing one merchant from accidentally updating another's menu.

---
> [!TIP]
> **Gemini's Advantage**: Unlike the current text-only flow, you can pass a photo of a handwritten receipt or a new printed menu directly into the chain. The LLM acts as the OCR + Logic + SQL generator all at once.
