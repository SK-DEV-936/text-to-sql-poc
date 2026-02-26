from __future__ import annotations

from typing import Any, Mapping, Protocol, Sequence

from boons_text_to_sql_agent.domain import Question


class ResultSummarizerPort(Protocol):
    async def summarize(self, question: Question, rows: Sequence[Mapping[str, Any]]) -> tuple[str | None, dict | None]:
        """Optionally summarize the result rows and generate a Vega-Lite chart spec."""
        raise NotImplementedError
