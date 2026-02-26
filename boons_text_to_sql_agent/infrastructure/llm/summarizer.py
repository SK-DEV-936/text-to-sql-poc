from __future__ import annotations

from typing import Any, Mapping, Sequence

from boons_text_to_sql_agent.application.ports import ResultSummarizerPort
from boons_text_to_sql_agent.domain import Question


class NoopSummarizer(ResultSummarizerPort):
    """Initial summarizer implementation: returns no summary.

    This keeps behavior simple; we can plug in an LLM-based summarizer later.
    """

    async def summarize(self, question: Question, rows: Sequence[Mapping[str, Any]]) -> str | None:
        return None

