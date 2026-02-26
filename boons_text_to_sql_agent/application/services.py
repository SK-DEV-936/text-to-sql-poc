from __future__ import annotations

import logging
from dataclasses import dataclass

from boons_text_to_sql_agent.application.ports import (
    ResultSummarizerPort,
    SchemaProviderPort,
    SqlExecutorPort,
    SqlValidatorPort,
    TextToSqlPort,
)
from boons_text_to_sql_agent.domain import QueryResult, Question

logger = logging.getLogger(__name__)


@dataclass
class GenerateAndExecuteQueryService:
    schema_provider: SchemaProviderPort
    text_to_sql: TextToSqlPort
    sql_validator: SqlValidatorPort
    sql_executor: SqlExecutorPort
    result_summarizer: ResultSummarizerPort

    async def handle(self, question: Question) -> QueryResult:
        logger.info(f"Received question: '{question.text}' for role '{question.scope.role.value}'")
        
        schema_manifest = self.schema_provider.get_schema_manifest(question.scope)
        logger.debug("Schema manifest retrieved successfully.")
        
        raw_sql_or_msg = await self.text_to_sql.generate_sql(question, schema_manifest)
        if isinstance(raw_sql_or_msg, str):
            logger.info(f"LLM replied with conversational message: {raw_sql_or_msg}")
            return QueryResult(sql=None, rows=None, summary=raw_sql_or_msg, warnings=None)
            
        raw_sql = raw_sql_or_msg
        logger.info(f"LLM Generated SQL: {raw_sql.text}")
        
        validated_sql = self.sql_validator.validate_and_enforce(question.scope, raw_sql)
        logger.info(f"Validated/Enforced SQL: {validated_sql.text}")
        
        rows = await self.sql_executor.execute(validated_sql)
        logger.info(f"Query executed successfully. Rows returned: {len(rows)}")
        
        summary = await self.result_summarizer.summarize(question, rows)

        return QueryResult(sql=validated_sql, rows=rows, summary=summary, warnings=None)

