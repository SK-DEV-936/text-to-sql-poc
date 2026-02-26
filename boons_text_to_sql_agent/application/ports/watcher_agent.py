from typing import Any, Mapping, Protocol, Sequence

from boons_text_to_sql_agent.domain import Question


class WatcherAgentPort(Protocol):
    """Port for reviewing and validating the final natural language summary."""

    async def review_and_correct(
        self, 
        question: Question, 
        raw_rows: Sequence[Mapping[str, Any]], 
        draft_summary: str
    ) -> str:
        """Review the draft summary and return either the original or a corrected version."""
        ...
