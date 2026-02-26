from __future__ import annotations

from typing import Any, Mapping, Sequence, List, Dict

from boons_text_to_sql_agent.application.ports import SqlExecutorPort
from boons_text_to_sql_agent.domain import SqlQuery


class InMemoryDemoExecutor(SqlExecutorPort):
    """Temporary executor that returns fake rows instead of hitting MySQL.

    This keeps the POC self-contained; we can replace it with a real async
    MySQL implementation once the schema is ready.
    """

    async def execute(self, sql_query: SqlQuery) -> Sequence[Mapping[str, Any]]:
        # Demo-only fake data; mirrors a subset of `merchants` columns.
        rows: List[Dict[str, Any]] = [
            {"id": 1, "name": "Demo Merchant A", "city": "San Francisco", "created_at": "2025-01-01", "status": "active"},
            {"id": 2, "name": "Demo Merchant B", "city": "New York", "created_at": "2025-02-15", "status": "active"},
        ]
        return rows

