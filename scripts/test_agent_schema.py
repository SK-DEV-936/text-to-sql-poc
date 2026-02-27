import asyncio
import json
from boons_text_to_sql_agent.config import load_settings
from boons_text_to_sql_agent.domain import Question, Scope, Role
from boons_text_to_sql_agent.infrastructure.llm.langchain_text_to_sql import LangChainTextToSqlAdapter
from boons_text_to_sql_agent.infrastructure.schema.static_schema_provider import StaticSchemaProvider

async def main():
    settings = load_settings()
    llm_agent = LangChainTextToSqlAdapter(settings)
    schema_provider = StaticSchemaProvider()

    # Create a mock scope
    scope = Scope(role=Role.MERCHANT, merchant_ids=[123], max_rows=100)
    
    # We will test a few questions
    questions = [
        "How many regular orders do I have today?",
        "What is the total revenue from catering orders?",
        "Show me the top 5 most popular menu items from regular orders."
    ]

    schema_manifest = {
        "tables": {
            "orders": {
                "description": "Regular food orders placed in the system",
                "columns": ["id", "code", "customer_id", "total_menu_price", "grand_total", "order_status", "created_date"]
            },
            "order_details": {
                "description": "Line items for regular food orders",
                "columns": ["id", "order_code", "menu_name", "quantity", "restaurant_id", "total"]
            },
            "catering_orders": {
                "description": "Catering food orders placed in the system",
                "columns": ["id", "code", "customer_id", "total_menu_price", "grand_total", "order_status", "created_date"]
            },
            "catering_order_details": {
                "description": "Line items for catering food orders",
                "columns": ["id", "order_code", "menu_name", "quantity", "restaurant_id", "total"]
            }
        },
        "relationships": [
            {"from": "order_details.order_code", "to": "orders.code"},
            {"from": "catering_order_details.order_code", "to": "catering_orders.code"}
        ],
        "role": "merchant"
    }

    print("--- Evaluating Agent with New Schema ---")
    for q_text in questions:
        print(f"\nQuestion: {q_text}")
        question = Question(text=q_text, scope=scope)
        try:
            sql_query = await llm_agent.generate_sql(question, schema_manifest)
            print(f"Generated SQL:\n{sql_query.text}")
        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    asyncio.run(main())
