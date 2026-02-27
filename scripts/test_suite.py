import asyncio
import logging
import json
from dataclasses import dataclass
from typing import List, Dict, Any, Optional

from boons_text_to_sql_agent.domain import Question, Scope, Role
from boons_text_to_sql_agent.application.services import GenerateAndExecuteQueryService
from boons_text_to_sql_agent.config import load_settings
from boons_text_to_sql_agent.infrastructure.db.mysql_executor import MySqlExecutor
from boons_text_to_sql_agent.infrastructure.llm.langchain_text_to_sql import LangChainTextToSqlAdapter
from boons_text_to_sql_agent.infrastructure.llm.summarizer import LlmSummarizer
from boons_text_to_sql_agent.infrastructure.llm.watcher_agent import LlmWatcherAgent
from boons_text_to_sql_agent.infrastructure.schema.static_schema_provider import StaticSchemaProvider
from boons_text_to_sql_agent.infrastructure.security.simple_sql_validator import SimpleSqlValidator

@dataclass
class TestCase:
    question: str
    role: Role
    merchant_ids: List[int]
    expected_to_be_sql: bool = True
    should_pass: bool = True

TEST_CASES = [
    TestCase("How many times has user with email 'merchant@example.com' logged in?", Role.MERCHANT, [1]),
    TestCase("What is the login frequency for all users in the last month?", Role.INTERNAL, []),
    TestCase("Can you show me the login history for user with ID 1?", Role.MERCHANT, [1]),
    TestCase("What are the security measures in place for user authentication?", Role.INTERNAL, [], expected_to_be_sql=False),
    TestCase("How can I reset my password?", Role.MERCHANT, [1], expected_to_be_sql=False),
    TestCase("What is the average number of logins per user?", Role.INTERNAL, []),
    TestCase("What IP addresses have been used to log in by user with ID 1?", Role.MERCHANT, [1]),
    TestCase("What happens if I enter the wrong password multiple times?", Role.MERCHANT, [1], expected_to_be_sql=False),
    TestCase("How do I know if my account has been compromised?", Role.INTERNAL, [], expected_to_be_sql=False),
    TestCase("List all login attempts for the last week for all users.", Role.INTERNAL, []),
]

async def run_test_suite():
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

    results = []
    passed_count = 0

    print(f"Starting Test Suite: {len(TEST_CASES)} cases...")
    print("-" * 50)

    for i, tc in enumerate(TEST_CASES):
        print(f"[{i+1}/{len(TEST_CASES)}] Question: '{tc.question}' (Role: {tc.role.value})")
        
        scope = Scope(role=tc.role, merchant_ids=tc.merchant_ids)
        question = Question(text=tc.question, scope=scope, chat_history=[])
        
        try:
            res = await service.handle(question)
            
            is_success = True
            failure_reason = ""

            # Check if it was expected to be SQL and if it is
            is_sql = res.sql is not None
            if is_sql != tc.expected_to_be_sql:
                is_success = False
                failure_reason = f"Expected is_sql={tc.expected_to_be_sql}, got {is_sql}"
            
            # If it's SQL, ensure rows was populated or at least no explicit error
            if is_sql and res.rows is None:
                is_success = False
                failure_reason = "SQL generated but execution returned None/Error"

            if is_success:
                passed_count += 1
                status = "PASS"
            else:
                status = "FAIL"

            results.append({
                "id": i+1,
                "question": tc.question,
                "role": tc.role.value,
                "status": status,
                "reason": failure_reason,
                "sql": res.sql.text if res.sql else "N/A",
                "summary": res.summary[:100] + "..." if res.summary else "N/A"
            })
            print(f"  Result: {status} {'(' + failure_reason + ')' if failure_reason else ''}")

        except Exception as e:
            print(f"  Result: ERROR ({str(e)})")
            results.append({
                "id": i+1,
                "question": tc.question,
                "role": tc.role.value,
                "status": "ERROR",
                "reason": str(e)
            })

    print("-" * 50)
    print(f"Test Suite Finished. Passed: {passed_count}/{len(TEST_CASES)}")
    
    with open("test_results.json", "w") as f:
        json.dump(results, f, indent=2)
    print(f"Detailed results saved to test_results.json")

if __name__ == "__main__":
    logging.basicConfig(level=logging.WARNING) # Reduce noise
    asyncio.run(run_test_suite())
