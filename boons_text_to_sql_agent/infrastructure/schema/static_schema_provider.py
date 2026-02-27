from __future__ import annotations

from typing import Any, Dict, Mapping

from boons_text_to_sql_agent.application.ports import SchemaProviderPort
from boons_text_to_sql_agent.domain import Role, Scope


class StaticSchemaProvider(SchemaProviderPort):
    """Temporary hardcoded schema manifest for the POC."""

    def get_schema_manifest(self, scope: Scope) -> Mapping[str, Any]:
        base_schema: Dict[str, Any] = {
                    "tables": {
                                "users": {
                                            "description": "Table that stores user information.",
                                            "columns": {
                                                        "id": "Unique identifier for each user.",
                                                        "email": "Email address of the user, must be unique.",
                                                        "password_hash": "Hashed password for user authentication.",
                                                        "created_at": "Timestamp of when the user was created."
                                            }
                                },
                                "login_history": {
                                            "description": "Table that records login attempts by users.",
                                            "columns": {
                                                        "id": "Unique identifier for each login record.",
                                                        "user_id": "Identifier for the user who logged in, references the users table.",
                                                        "login_time": "Timestamp of when the user logged in.",
                                                        "ip_address": "IP address from which the user logged in."
                                            }
                                }
                    },
                    "relationships": [
                                {
                                            "from": "login_history.user_id",
                                            "to": "users.id"
                                }
                    ]
        }

        if scope.role == Role.MERCHANT:
            base_schema["role"] = "merchant"
        else:
            base_schema["role"] = "internal"

        return base_schema
