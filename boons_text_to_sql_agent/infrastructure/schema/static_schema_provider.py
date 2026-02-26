from __future__ import annotations

from typing import Any, Dict, Mapping

from boons_text_to_sql_agent.application.ports import SchemaProviderPort
from boons_text_to_sql_agent.domain import Role, Scope


class StaticSchemaProvider(SchemaProviderPort):
    """Temporary hardcoded schema manifest for the POC."""

    def get_schema_manifest(self, scope: Scope) -> Mapping[str, Any]:
        base_schema: Dict[str, Any] = {
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
                },
                "order_history": {
                    "description": "Audit trails and lifecycle events of all types of orders.",
                    "columns": ["id", "order_id", "process_by", "particulars", "time_format", "created_data"]
                }
            },
            "relationships": [
                {"from": "order_details.order_code", "to": "orders.code"},
                {"from": "catering_order_details.order_code", "to": "catering_orders.code"},
                {"from": "order_history.order_id", "to": "orders.code"},
                {"from": "order_history.order_id", "to": "catering_orders.code"}
            ],
        }

        if scope.role == Role.MERCHANT:
            base_schema["role"] = "merchant"
        else:
            base_schema["role"] = "internal"

        return base_schema

