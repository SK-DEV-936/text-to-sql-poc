import asyncio
import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from boons_text_to_sql_agent.config import load_settings
from boons_text_to_sql_agent.domain import Question, Scope, Role
from boons_text_to_sql_agent.infrastructure.llm.langchain_text_to_sql import LangChainTextToSqlAdapter
from boons_text_to_sql_agent.infrastructure.db.mysql_executor import MySqlExecutor
from boons_text_to_sql_agent.infrastructure.security.simple_sql_validator import SimpleSqlValidator
from boons_text_to_sql_agent.infrastructure.llm.summarizer import LlmSummarizer
from boons_text_to_sql_agent.infrastructure.llm.watcher_agent import LlmWatcherAgent
from boons_text_to_sql_agent.application.services import GenerateAndExecuteQueryService
from boons_text_to_sql_agent.infrastructure.schema.static_schema_provider import StaticSchemaProvider

async def main():
    settings = load_settings()
    
    schema_provider = StaticSchemaProvider()
    text_to_sql = LangChainTextToSqlAdapter(settings)
    sql_validator = SimpleSqlValidator(settings)
    sql_executor = MySqlExecutor(
        host=settings.db_host,
        port=settings.db_port,
        user=settings.db_user,
        password=settings.db_password,
        db_name=settings.db_name
    )
    summarizer = LlmSummarizer(settings)
    watcher = LlmWatcherAgent(settings)
    
    service = GenerateAndExecuteQueryService(
        schema_provider=schema_provider,
        text_to_sql=text_to_sql,
        sql_validator=sql_validator,
        sql_executor=sql_executor,
        result_summarizer=summarizer,
        watcher_agent=watcher
    )

    question = Question(
        text="Show me all cancelled orders.",
        scope=Scope(role=Role.MERCHANT, merchant_ids=[1]) # Same as screenshot
    )
    
    print("\n--- Running Formatting Verification for Lists ---")
    try:
        result = await service.handle(question)
        print("\n[AI DRAFT RESPONSE]")
        print(result.summary)
        print("\n--- RAW REPRESENTATION ---")
        print(repr(result.summary))
        
    except Exception as e:
        print(f"\nERROR: {e}")

if __name__ == "__main__":
    asyncio.run(main())
