from __future__ import annotations

from typing import Protocol, Mapping, Any

from boons_text_to_sql_agent.domain import Question, SqlQuery


class TextToSqlPort(Protocol):
    async def generate_sql(self, question: Question, schema_manifest: Mapping[str, Any]) -> SqlQuery:
        """Generate a SQL query from a natural-language question and schema manifest."""
        raise NotImplementedError

