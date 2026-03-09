import asyncio
import logging
import json
from boons_text_to_sql_agent.domain import Question, Scope, Role
from boons_text_to_sql_agent.application.services import GenerateAndExecuteQueryService
from boons_text_to_sql_agent.config import load_settings
from boons_text_to_sql_agent.infrastructure.db.mysql_executor import MySqlExecutor
from boons_text_to_sql_agent.infrastructure.llm.langchain_text_to_sql import LangChainTextToSqlAdapter
from boons_text_to_sql_agent.infrastructure.llm.summarizer import LlmSummarizer
from boons_text_to_sql_agent.infrastructure.llm.watcher_agent import LlmWatcherAgent
from boons_text_to_sql_agent.infrastructure.schema.static_schema_provider import StaticSchemaProvider
from boons_text_to_sql_agent.infrastructure.security.simple_sql_validator import SimpleSqlValidator

async def reproduce():
    # Setup logging to see everything
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)

    settings = load_settings()
    schema_provider = StaticSchemaProvider()
    text_to_sql = LangChainTextToSqlAdapter(settings)
    sql_validator = SimpleSqlValidator(settings)
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

    # Case 5: Number of cancelled orders this month (Merchant role, ID 1)
    question_text = "Number of cancelled orders this month"
    scope = Scope(role=Role.MERCHANT, merchant_ids=[1])
    question = Question(text=question_text, scope=scope, chat_history=[])
    
    print(f"\n--- REPRODUCING CASE 5 ---")
    try:
        res = await service.handle(question)
        print(f"\nSUCCESS")
        print(f"SQL Generated: {res.sql.text if res.sql else 'None'}")
        print(f"SQL Params:    {res.sql.parameters if res.sql else 'None'}")
        print(f"Summary:       {res.summary}")
    except Exception as e:
        print(f"\nFAILED with exception: {str(e)}")

if __name__ == "__main__":
    asyncio.run(reproduce())
