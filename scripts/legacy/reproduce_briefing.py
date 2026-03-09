
import asyncio
import os
import sys
from typing import List, Dict, Any

# Add project root to path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from boons_text_to_sql_agent.config import load_settings
from boons_text_to_sql_agent.domain import Question, Scope, Role, SqlQuery
from boons_text_to_sql_agent.infrastructure.llm.langchain_text_to_sql import LangChainTextToSqlAdapter
from boons_text_to_sql_agent.infrastructure.db.mysql_executor import MySqlExecutor
from boons_text_to_sql_agent.infrastructure.security.simple_sql_validator import SimpleSqlValidator
from boons_text_to_sql_agent.infrastructure.llm.summarizer import LlmSummarizer
from boons_text_to_sql_agent.infrastructure.llm.watcher_agent import LlmWatcherAgent
from boons_text_to_sql_agent.application.services import GenerateAndExecuteQueryService

class MockSchemaProvider:
    def get_schema_manifest(self, scope):
        # Just return something or use real if easy
        from boons_text_to_sql_agent.infrastructure.schema.static_schema_provider import StaticSchemaProvider
        return StaticSchemaProvider().get_schema_manifest(scope)

async def main():
    settings = load_settings()
    
    # 1. Setup real components for deep trace
    schema_provider = MockSchemaProvider()
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
        text="Can you tell me a funny joke about restaurants?",
        scope=Scope(role=Role.INTERNAL, merchant_ids=[])
    )
    
    print("\n--- Running Intent Guarding Verification ---")
    try:
        result = await service.handle(question)
        print("\n[AI RESPONSE]")
        print(f"'{result.summary}'")
        
        if result.sql is None:
            print("\nSUCCESS: Agent correctly identified this as non-SQL/out-of-scope.")
        else:
            print("\nFAILURE: Agent attempted to generate SQL for a joke!")
            
    except Exception as e:
        print(f"\nERROR: {e}")
        
    except Exception as e:
        print(f"\nERROR: {e}")

if __name__ == "__main__":
    asyncio.run(main())
