from __future__ import annotations

import logging

from fastapi import FastAPI

from boons_text_to_sql_agent.application import GenerateAndExecuteQueryService
from boons_text_to_sql_agent.config import load_settings
from boons_text_to_sql_agent.infrastructure.db.mysql_executor import (
    InMemoryDemoExecutor,
    MySqlExecutor,
)
from boons_text_to_sql_agent.infrastructure.llm.langchain_text_to_sql import (
    LangChainTextToSqlAdapter,
)
from boons_text_to_sql_agent.infrastructure.llm.summarizer import NoopSummarizer
from boons_text_to_sql_agent.infrastructure.schema.static_schema_provider import (
    StaticSchemaProvider,
)
from boons_text_to_sql_agent.infrastructure.security.simple_sql_validator import SimpleSqlValidator
from boons_text_to_sql_agent.interface.api.routes import create_router

# Configure global logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


def create_app() -> FastAPI:
    app = FastAPI(title="Boons Text-to-SQL Agent (POC)")

    settings = load_settings()
    logger.info(f"Starting application in environment: {settings.environment}")

    # Infrastructure adapters
    schema_provider = StaticSchemaProvider()
    text_to_sql = LangChainTextToSqlAdapter(settings=settings)
    sql_validator = SimpleSqlValidator(settings=settings)
    
    if settings.use_in_memory_executor:
        sql_executor = InMemoryDemoExecutor()
    else:
        sql_executor = MySqlExecutor(
            host=settings.db_host,
            port=settings.db_port,
            user=settings.db_user,
            password=settings.db_password,
            db_name=settings.db_name,
        )
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

