from __future__ import annotations

import logging
import time

from fastapi import FastAPI, Request

from boons_text_to_sql_agent.application import GenerateAndExecuteQueryService
from boons_text_to_sql_agent.config import load_settings
from boons_text_to_sql_agent.infrastructure.db.mysql_executor import (
    InMemoryDemoExecutor,
    MySqlExecutor,
)
from boons_text_to_sql_agent.infrastructure.llm.langchain_text_to_sql import LangChainTextToSqlAdapter
from boons_text_to_sql_agent.infrastructure.llm.summarizer import LlmSummarizer
from boons_text_to_sql_agent.infrastructure.llm.watcher_agent import LlmWatcherAgent
from boons_text_to_sql_agent.infrastructure.schema.static_schema_provider import StaticSchemaProvider
from boons_text_to_sql_agent.infrastructure.security.simple_sql_validator import SimpleSqlValidator
from boons_text_to_sql_agent.interface.api.routes import create_router

# Configure global logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


def create_app() -> FastAPI:
    app = FastAPI(title="Boons Text-to-SQL Agent API")

    settings = load_settings()
    logger.info(f"Starting application in environment: {settings.environment}")

    schema_provider = StaticSchemaProvider()
    text_to_sql = LangChainTextToSqlAdapter(settings)
    sql_validator = SimpleSqlValidator(settings)
    
    if settings.use_in_memory_executor:
        logger.info("Using InMemoryDemoExecutor (SQLite fallback)")
        sql_executor = InMemoryDemoExecutor()
    else:
        logger.info("Using Python MySqlExecutor (Docker MySQL or AWS RDS)")
        sql_executor = MySqlExecutor(
            host=settings.db_host,
            port=settings.db_port,
            user=settings.db_user,
            password=settings.db_password,
            db_name=settings.db_name,
        )
        
    result_summarizer = LlmSummarizer(settings)
    watcher_agent = LlmWatcherAgent(settings)

    service = GenerateAndExecuteQueryService(
        schema_provider=schema_provider,
        text_to_sql=text_to_sql,
        sql_validator=sql_validator,
        sql_executor=sql_executor,
        result_summarizer=result_summarizer,
        watcher_agent=watcher_agent,
    )

    router = create_router(service)
    app.include_router(router)
    app.include_router(marketing_router)

    # Middleware for Production Observability
    @app.middleware("http")
    async def log_requests(request: Request, call_next):
        start_time = time.time()
        response = await call_next(request)
        process_time = time.time() - start_time
        logger.info(
            f"Method: {request.method} Path: {request.url.path} "
            f"Status: {response.status_code} Latency: {process_time:.2f}s"
        )
        return response

    @app.get("/health")
    async def health_check():
        logger.info(f"Health check triggered in {settings.environment} environment")
        return {
            "status": "healthy",
            "environment": settings.environment,
            "version": "1.0.1"
        }

    return app

app = create_app()
