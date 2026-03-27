from typing import Dict, Any
from boons_text_to_sql_agent.marketing_module.application.ports import MarketingSchemaPort

class StaticMarketingSchemaProvider(MarketingSchemaPort):
    async def get_db_schema_context(self) -> str:
        return """
        Table: users (Alias u)
        Columns:
          - id (int)
          - phone (varchar) 
          - first_name (varchar)
          - last_name (varchar)
          - role_id (int) - MUST be filtered for customers only.
          
        Table: catering_orders (Alias co)
        Columns: 
          - id (int)
          - customer_id (int) - references users.id
          - order_placed_at (int) - Unix timestamp
          - restaurant_id (int) - MUST be filtered by __RLS_MERCHANTS__
        """
        
    async def get_merchant_assets(self, restaurant_id: int) -> Dict[str, Any]:
        # Minimal mock logic for the adapter tests. 
        # A real DB implementation will execute async queries against `restaurants` via aiomysql.
        return {
            "website": f"https://restaurant{restaurant_id}-demo.com",
            "gallery_json": '["https://example.com/asset1.jpg", "https://example.com/asset2.jpg"]'
        }
