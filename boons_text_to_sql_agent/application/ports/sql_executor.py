from __future__ import annotations

from typing import Protocol, Sequence, Mapping, Any

from boons_text_to_sql_agent.domain import SqlQuery


class SqlExecutorPort(Protocol):
    async def execute(self, sql_query: SqlQuery) -> Sequence[Mapping[str, Any]]:
        """Execute a validated SQL query and return rows."""
        raise NotImplementedError

