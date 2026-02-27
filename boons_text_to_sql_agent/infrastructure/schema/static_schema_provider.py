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
                    "columns": {
                        "id": "Primary key identifier",
                        "code": "Unique public order reference code",
                        "customer_id": "Identifier of the customer who placed the order",
                        "total_menu_price": "Total price of all food items in the order before taxes or fees",
                        "grand_total": "Final amount paid by customer including all fees, taxes, and tips",
                        "order_status": "Current logical state of the order (e.g., 'completed', 'canceled')",
                        "created_date": "Timestamp indicating when the order was placed"
                    }
                },
                "order_details": {
                    "description": "Line items for regular food orders",
                    "columns": {
                        "id": "Primary key identifier for the order detail line",
                        "order_code": "Foreign key linking to the parent order code",
                        "menu_name": "Name of the food item ordered",
                        "quantity": "Number of servings or items ordered",
                        "restaurant_id": "Identifier for the restaurant preparing the item",
                        "total": "Total calculated price for this specific line item"
                    }
                },
                "catering_orders": {
                    "description": "Catering food orders placed in the system",
                    "columns": {
                        "id": "Primary key identifier",
                        "code": "Unique public order reference code for catering",
                        "customer_id": "Identifier of the customer who placed the catering order",
                        "total_menu_price": "Total price of all catering food items",
                        "grand_total": "Final exact amount paid including catering fees and taxes",
                        "order_status": "Current logical state of the catering order",
                        "created_date": "Timestamp indicating when the catering order was placed"
                    }
                },
                "catering_order_details": {
                    "description": "Line items for catering food orders",
                    "columns": {
                        "id": "Primary key identifier for the catering order detail line",
                        "order_code": "Foreign key linking to the parent catering order code",
                        "menu_name": "Name of the catering food item or package ordered",
                        "quantity": "Number of catering item units ordered",
                        "restaurant_id": "Identifier for the restaurant preparing the catering item",
                        "total": "Total calculated price for this catering line item"
                    }
                },
                "order_history": {
                    "description": "Audit trails and lifecycle events of all types of orders.",
                    "columns": {
                        "id": "Primary key identifier for the history record",
                        "order_id": "Foreign key linking to the parent order code (regular or catering)",
                        "process_by": "Name or identifier of the user/system that processed the action",
                        "particulars": "Details or notes about the lifecycle event",
                        "time_format": "Unix timestamp representation of the event time",
                        "created_data": "Standard datetime timestamp when the event was recorded"
                    }
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

