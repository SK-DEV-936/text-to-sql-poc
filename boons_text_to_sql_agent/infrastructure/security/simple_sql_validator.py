from __future__ import annotations

import re

from boons_text_to_sql_agent.application.ports import SqlValidatorPort
from boons_text_to_sql_agent.domain import Scope, SqlQuery


class SimpleSqlValidator(SqlValidatorPort):
    """Very minimal SQL validator/rewriter for the POC.

    - Enforces single-statement SELECT-only.
    - Ensures a LIMIT exists and is <= scope.max_rows (adds or clamps).
    - Does NOT yet parse full SQL or enforce merchant_id filters.
    """

    _dangerous_pattern = re.compile(
        r";|\\b(INSERT|UPDATE|DELETE|DROP|ALTER|TRUNCATE|CREATE|GRANT|REVOKE)\\b",
        flags=re.IGNORECASE,
    )

    def validate_and_enforce(self, scope: Scope, sql_query: SqlQuery) -> SqlQuery:
        text = sql_query.text.strip()

        if not text.lower().startswith("select"):
            raise ValueError("Only SELECT statements are allowed.")

        if self._dangerous_pattern.search(text):
            raise ValueError("Dangerous SQL pattern detected.")

        # Very simple LIMIT enforcement; assumes no subqueries with LIMIT for now.
        lower = text.lower()
        if " limit " not in lower:
            text = f"{text} LIMIT {scope.max_rows}"
        else:
            # Clamp existing LIMIT to max_rows.
            def _replace_limit(match: re.Match[str]) -> str:
                prefix = match.group(1)
                current_limit = int(match.group(2))
                new_limit = min(current_limit, scope.max_rows)
                return f"{prefix}{new_limit}"

            text = re.sub(r"(limit\\s+)(\\d+)", _replace_limit, text, flags=re.IGNORECASE)

        return SqlQuery(text=text, parameters=sql_query.parameters)

