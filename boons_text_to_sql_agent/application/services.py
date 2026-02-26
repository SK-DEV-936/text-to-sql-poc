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
            
        current_sql = raw_sql_or_msg
        
        # Self-correction loop: allow one attempt to fix failing SQL
        max_retries = 1
        for attempt in range(max_retries + 1):
            try:
                logger.info(f"Execution attempt {attempt + 1}: {current_sql.text}")
                validated_sql = self.sql_validator.validate_and_enforce(question.scope, current_sql)
                
                rows = await self.sql_executor.execute(validated_sql)
                logger.info(f"Query executed successfully. Rows returned: {len(rows)}")
                
                summary = await self.result_summarizer.summarize(question, rows)
                return QueryResult(sql=validated_sql, rows=rows, summary=summary, warnings=None)
                
            except Exception as e:
                error_msg = str(e)
                logger.warning(f"SQL execution failed (attempt {attempt + 1}): {error_msg}")
                
                if attempt < max_retries:
                    logger.info("Attempting SQL self-correction...")
                    current_sql = await self.text_to_sql.fix_sql(
                        question, schema_manifest, current_sql, error_msg
                    )
                    # If fix_sql returned a string message instead of SQL
                    if isinstance(current_sql, str):
                        return QueryResult(sql=None, rows=None, summary=current_sql, warnings="Fixed failed")
                else:
                    logger.error(f"SQL execution failed after {max_retries} retries: {error_msg}")
                    return QueryResult(
                        sql=current_sql, 
                        rows=None, 
                        summary="I'm sorry, but I was unable to retrieve that information right now. Please try asking in a different way or check back later.",
                        warnings="Max retries exceeded"
                    )

