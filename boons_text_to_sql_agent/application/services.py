from __future__ import annotations

from dataclasses import dataclass

from boons_text_to_sql_agent.domain import Question, QueryResult
from boons_text_to_sql_agent.application.ports import (
    SchemaProviderPort,
    TextToSqlPort,
    SqlValidatorPort,
    SqlExecutorPort,
    ResultSummarizerPort,
)


@dataclass
class GenerateAndExecuteQueryService:
    schema_provider: SchemaProviderPort
    text_to_sql: TextToSqlPort
    sql_validator: SqlValidatorPort
    sql_executor: SqlExecutorPort
    result_summarizer: ResultSummarizerPort

    async def handle(self, question: Question) -> QueryResult:
        schema_manifest = self.schema_provider.get_schema_manifest(question.scope)
        raw_sql = await self.text_to_sql.generate_sql(question, schema_manifest)
        validated_sql = self.sql_validator.validate_and_enforce(question.scope, raw_sql)
        rows = await self.sql_executor.execute(validated_sql)
        summary = await self.result_summarizer.summarize(question, rows)

        return QueryResult(sql=validated_sql, rows=rows, summary=summary, warnings=None)

