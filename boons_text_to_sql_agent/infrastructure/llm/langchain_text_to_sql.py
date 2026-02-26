from __future__ import annotations

from typing import Any, Mapping

from boons_text_to_sql_agent.application.ports import TextToSqlPort
from boons_text_to_sql_agent.domain import Question, SqlQuery


class LangChainTextToSqlAdapter(TextToSqlPort):
    """Placeholder LLM adapter; currently returns a fixed safe SQL template.

    This keeps the POC runnable without requiring LLM credentials; we can wire
    real LangChain + OpenAI/Anthropic later.
    """

    async def generate_sql(self, question: Question, schema_manifest: Mapping[str, Any]) -> SqlQuery:
        # Very small, obviously safe placeholder query.
        sql = "SELECT id, name, city, created_at, status FROM merchants LIMIT 10"
        return SqlQuery(text=sql, parameters={})

