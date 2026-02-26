from __future__ import annotations

from typing import Any, Mapping, Protocol

from boons_text_to_sql_agent.domain import Scope


class SchemaProviderPort(Protocol):
    def get_schema_manifest(self, scope: Scope) -> Mapping[str, Any]:
        """Return a schema manifest tailored to the given scope/role."""
        raise NotImplementedError

