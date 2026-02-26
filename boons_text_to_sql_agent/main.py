from __future__ import annotations

from fastapi import FastAPI

from boons_text_to_sql_agent.application import GenerateAndExecuteQueryService
from boons_text_to_sql_agent.infrastructure.schema.static_schema_provider import StaticSchemaProvider
from boons_text_to_sql_agent.infrastructure.llm.langchain_text_to_sql import (
    LangChainTextToSqlAdapter,
)
from boons_text_to_sql_agent.infrastructure.security.simple_sql_validator import SimpleSqlValidator
from boons_text_to_sql_agent.infrastructure.db.mysql_executor import InMemoryDemoExecutor
from boons_text_to_sql_agent.infrastructure.llm.summarizer import NoopSummarizer
from boons_text_to_sql_agent.interface.api.routes import create_router


def create_app() -> FastAPI:
    app = FastAPI(title="Boons Text-to-SQL Agent (POC)")

    # Infrastructure adapters
    schema_provider = StaticSchemaProvider()
    text_to_sql = LangChainTextToSqlAdapter()
    sql_validator = SimpleSqlValidator()
    sql_executor = InMemoryDemoExecutor()
    summarizer = NoopSummarizer()

    # Application service
    service = GenerateAndExecuteQueryService(
        schema_provider=schema_provider,
        text_to_sql=text_to_sql,
        sql_validator=sql_validator,
        sql_executor=sql_executor,
        result_summarizer=summarizer,
    )

    # API layer
    router = create_router(service)
    app.include_router(router)

    return app


app = create_app()

