from __future__ import annotations

from typing import Protocol

from boons_text_to_sql_agent.domain import Scope, SqlQuery


class SqlValidatorPort(Protocol):
    def validate_and_enforce(self, scope: Scope, sql_query: SqlQuery) -> SqlQuery:
        """Validate SQL safety and enforce scope (RLS, limits). Raise on irreparable queries."""
        raise NotImplementedError

