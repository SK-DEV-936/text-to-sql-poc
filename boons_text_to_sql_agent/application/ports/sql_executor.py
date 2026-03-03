from __future__ import annotations

from typing import Any, Mapping, Protocol, Sequence

from boons_text_to_sql_agent.domain import SqlQuery


class SqlExecutorPort(Protocol):
    async def execute(self, sql_query: SqlQuery) -> Sequence[Mapping[str, Any]]:
        """Execute a validated SQL query and return rows."""
        raise NotImplementedError

    async def get_active_merchant_ids(self) -> list[int]:
        """Fetch a list of active merchant IDs for testing/routing."""
        raise NotImplementedError

