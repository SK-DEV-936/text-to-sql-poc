from __future__ import annotations

from typing import Any, Mapping, Protocol

from boons_text_to_sql_agent.domain import Question, SqlQuery


class TextToSqlPort(Protocol):
    async def generate_sql(
        self, question: Question, schema_manifest: Mapping[str, Any]
    ) -> SqlQuery | str:
        """Generate a SQL query or conversational reply from a natural-language question."""
        raise NotImplementedError

    async def fix_sql(
        self,
        question: Question,
        schema_manifest: Mapping[str, Any],
        failing_sql: SqlQuery,
        error_msg: str,
    ) -> SqlQuery | str:
        """Attempt to fix a failing SQL query based on the error message."""
        raise NotImplementedError

