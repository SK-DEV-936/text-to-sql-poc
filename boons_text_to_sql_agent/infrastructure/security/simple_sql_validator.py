import sqlglot
from sqlglot import exp, parse_one

from boons_text_to_sql_agent.application.ports import SqlValidatorPort
from boons_text_to_sql_agent.config import Settings
from boons_text_to_sql_agent.domain import Role, Scope, SqlQuery


class SimpleSqlValidator(SqlValidatorPort):
    """AST-based SQL validator/rewriter using sqlglot.

    - Enforces single-statement SELECT-only.
    - Ensures a LIMIT exists and is <= scope.max_rows.
    - Injects Row-Level Security (RLS) filters for merchant roles.
    """

    def __init__(self, settings: Settings):
        self._settings = settings
        guardrails = settings.guardrails
        if not guardrails:
            raise RuntimeError("Guardrails configuration is missing.")
        self._blocked_tables = guardrails.blocked_tables

    def validate_and_enforce(self, scope: Scope, sql_query: SqlQuery) -> SqlQuery:
        try:
            # Parse the SQL into an AST
            expression = parse_one(sql_query.text, read="mysql")
        except Exception as e:
            raise ValueError(f"Invalid SQL syntax: {str(e)}")

        # 1. Enforce SELECT/Query only
        if not isinstance(expression, (exp.Select, exp.Union, exp.Intersect, exp.Except)):
            raise ValueError("Only SELECT statements are allowed.")

        # 2. Block forbidden tables
        for table in expression.find_all(exp.Table):
            table_name = table.name.lower()
            if table_name in self._blocked_tables:
                raise ValueError(f"Access to blocked table '{table_name}' is forbidden.")

        parameters = dict(sql_query.parameters)

        # 3. Handle Merchant RLS
        if scope.role == Role.MERCHANT:
            if not scope.merchant_ids:
                raise ValueError("Merchant role requires at least one merchant_id in scope.")

            # Create parameterized placeholders
            placeholders = []
            for i, m_id in enumerate(scope.merchant_ids):
                param_key = f"rls_restaurant_id_{i}"
                placeholders.append(f"%({param_key})s")
                parameters[param_key] = m_id

            import re
            pattern = re.compile(r"__RLS_MERCHANTS__", re.IGNORECASE)
            if not pattern.search(sql_query.text):
                import logging
                logger = logging.getLogger(__name__)
                logger.error(f"SECURITY VIOLATION: Mandatory token missing in LLM output. SQL: {sql_query.text}")
                raise ValueError("CRITICAL SECURITY ERROR: Missing mandatory `__RLS_MERCHANTS__` token in the WHERE clause.")
            
        # 4. Enforce LIMIT
        limit_clause = expression.find(exp.Limit)
        if limit_clause:
            current_limit = int(limit_clause.expression.this)
            new_limit = min(current_limit, scope.max_rows)
            limit_clause.set("expression", exp.Literal.number(new_limit))
        else:
            expression = expression.limit(scope.max_rows)

        sql_text = expression.sql(dialect="mysql")

        if scope.role == Role.MERCHANT:
            # Reconstruct the parameterized list and inject it
            rls_string = ", ".join(placeholders)
            
            # Robust replacement: handle backticks, casing, and spaces
            import re
            # Matches __RLS_MERCHANTS__ potentially wrapped in ` or ' or "
            pattern = re.compile(r"[`'\" ]*__RLS_MERCHANTS__[`'\" ]*", re.IGNORECASE)
            sql_text = pattern.sub(rls_string, sql_text)

            import logging
            logger = logging.getLogger(__name__)
            logger.info(f"RLS Injected. Final SQL: {sql_text}")

        return SqlQuery(text=sql_text, parameters=parameters)

