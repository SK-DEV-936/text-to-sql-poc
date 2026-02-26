from __future__ import annotations

from typing import Any, Mapping, Dict

from boons_text_to_sql_agent.application.ports import SchemaProviderPort
from boons_text_to_sql_agent.domain import Scope, Role


class StaticSchemaProvider(SchemaProviderPort):
    """Temporary hardcoded schema manifest for the POC."""

    def get_schema_manifest(self, scope: Scope) -> Mapping[str, Any]:
        base_schema: Dict[str, Any] = {
            "tables": {
                "merchants": {
                    "description": "Merchants / restaurants",
                    "columns": ["id", "name", "city", "created_at", "status"],
                },
                "orders": {
                    "description": "Orders placed in the system",
                    "columns": [
                        "id",
                        "merchant_id",
                        "customer_id",
                        "order_status",
                        "total_amount",
                        "created_at",
                    ],
                },
                "order_items": {
                    "description": "Line items per order",
                    "columns": ["id", "order_id", "menu_item_id", "quantity", "item_price"],
                },
                "customers": {
                    "description": "Customers (minimal fields, no PII)",
                    "columns": ["id", "created_at", "customer_segment"],
                },
            },
            "relationships": [
                {"from": "orders.merchant_id", "to": "merchants.id"},
                {"from": "orders.customer_id", "to": "customers.id"},
                {"from": "order_items.order_id", "to": "orders.id"},
            ],
        }

        if scope.role == Role.MERCHANT:
            base_schema["role"] = "merchant"
        else:
            base_schema["role"] = "internal"

        return base_schema

