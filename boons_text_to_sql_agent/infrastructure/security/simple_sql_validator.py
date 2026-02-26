from __future__ import annotations

import re

from boons_text_to_sql_agent.application.ports import SqlValidatorPort
from boons_text_to_sql_agent.config import Settings
from boons_text_to_sql_agent.domain import Scope, SqlQuery


class SimpleSqlValidator(SqlValidatorPort):
    """Very minimal SQL validator/rewriter for the POC.

    - Enforces single-statement SELECT-only.
    - Ensures a LIMIT exists and is <= scope.max_rows (adds or clamps).
    - Does NOT yet parse full SQL or enforce merchant_id filters.
    """

    def __init__(self, settings: Settings):
        self._settings = settings
        guardrails = settings.guardrails
        if not guardrails:
            raise RuntimeError("Guardrails configuration is missing.")
            
        patterns = "|".join(guardrails.dangerous_regex_patterns)
        self._dangerous_pattern = re.compile(f"({patterns})", flags=re.IGNORECASE)
        self._blocked_tables = guardrails.blocked_tables

    def validate_and_enforce(self, scope: Scope, sql_query: SqlQuery) -> SqlQuery:
        # Remove trailing whitespace and semicolon
        text = sql_query.text.strip().rstrip(";")

        if not text.lower().startswith("select"):
            raise ValueError("Only SELECT statements are allowed.")

        if self._dangerous_pattern.search(text):
            raise ValueError("Dangerous SQL pattern detected.")
            
        lower_text = text.lower()
        for table in self._blocked_tables:
            # Basic check for table name mention
            if re.search(rf"\b{table}\b", lower_text):
                raise ValueError(f"Access to blocked table '{table}' is forbidden.")

        parameters = dict(sql_query.parameters)

        # Basic RLS enforcement using an outer wrapper query
        # This assumes the inner query returns a `merchant_id` column if it's merchant scoped.
        from boons_text_to_sql_agent.domain import Role
        
        if scope.role == Role.MERCHANT:
            if not scope.merchant_ids:
                raise ValueError("Merchant role requires at least one merchant_id in scope.")
            
            # Create parameterized placeholders
            placeholders = []
            for i, m_id in enumerate(scope.merchant_ids):
                param_key = f"rls_merchant_id_{i}"
                placeholders.append(f"%({param_key})s")
                parameters[param_key] = m_id
            
            in_clause = ", ".join(placeholders)
            
            # Wrap the entire query to easily enforce both RLS and LIMIT
            # without complex AST parsing.
            text = (
                f"SELECT * FROM ({text}) AS _rls_wrapper "
                f"WHERE merchant_id IN ({in_clause}) "
                f"LIMIT {scope.max_rows}"
            )
        else:
            # For internal roles, just enforce the limit
            lower = text.lower()
            if " limit " not in lower:
                text = f"{text} LIMIT {scope.max_rows}"
            else:
                def _replace_limit(match: re.Match) -> str:
                    prefix = match.group(1)
                    current_limit = int(match.group(2))
                    new_limit = min(current_limit, scope.max_rows)
                    return f"{prefix}{new_limit}"

                text = re.sub(r"(limit\s+)(\d+)", _replace_limit, text, flags=re.IGNORECASE)

        return SqlQuery(text=text, parameters=parameters)

