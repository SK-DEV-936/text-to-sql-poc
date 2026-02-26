from __future__ import annotations

from typing import Protocol, Sequence, Mapping, Any

from boons_text_to_sql_agent.domain import Question


class ResultSummarizerPort(Protocol):
    async def summarize(self, question: Question, rows: Sequence[Mapping[str, Any]]) -> str | None:
        """Optionally summarize the result rows for the caller."""
        raise NotImplementedError

