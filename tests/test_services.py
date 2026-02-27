import pytest
from unittest.mock import AsyncMock, MagicMock

from boons_text_to_sql_agent.application.services import GenerateAndExecuteQueryService
from boons_text_to_sql_agent.domain import Question, SqlQuery, Scope, Role, QueryResult


@pytest.fixture
def base_question():
    return Question(
        text="What is my revenue?",
        scope=Scope(role=Role.MERCHANT, merchant_ids=[123], max_rows=100)
    )


@pytest.fixture
def mock_dependencies():
    return {
        "schema_provider": MagicMock(),
        "text_to_sql": AsyncMock(),
        "sql_validator": MagicMock(),
        "sql_executor": AsyncMock(),
        "result_summarizer": AsyncMock(),
        "watcher_agent": AsyncMock()
    }


@pytest.fixture
def service(mock_dependencies):
    return GenerateAndExecuteQueryService(**mock_dependencies)


@pytest.mark.asyncio
async def test_service_happy_path(service, mock_dependencies, base_question):
    # Setup happy path
    sql_query = SqlQuery(text="SELECT sum(amount) FROM orders", parameters={})
    mock_dependencies["text_to_sql"].generate_sql.return_value = sql_query
    
    validated_sql = SqlQuery(text="SELECT sum(amount) FROM orders WHERE rls=123", parameters={"rls":123})
    mock_dependencies["sql_validator"].validate_and_enforce.return_value = validated_sql
    
    db_rows = [{"sum(amount)": 500}]
    mock_dependencies["sql_executor"].execute.return_value = db_rows
    
    mock_dependencies["result_summarizer"].summarize.return_value = ("Draft sum: 500", {"type": "bar"})
    mock_dependencies["watcher_agent"].review_and_correct.return_value = "Final sum: 500"
    
    # Execute
    result = await service.handle(base_question)
    
    # Assert
    assert result.sql == validated_sql
    assert result.rows == db_rows
    assert result.summary == "Final sum: 500"
    assert result.chart_spec == {"type": "bar"}
    assert result.warnings is None


@pytest.mark.asyncio
async def test_service_conversational_reply(service, mock_dependencies, base_question):
    # Setup Text-to-SQL returning conversational refusal
    mock_dependencies["text_to_sql"].generate_sql.return_value = "I cannot answer that, I am just an analytics agent."
    
    # Execute
    result = await service.handle(base_question)
    
    # Assert
    assert result.sql is None
    assert result.rows is None
    assert "cannot answer that" in result.summary
    
    # Pipeline should have aborted before DB/Watchers
    mock_dependencies["sql_executor"].execute.assert_not_called()


@pytest.mark.asyncio
async def test_service_self_correction_loop(service, mock_dependencies, base_question):
    # Setup initial fail
    first_sql = SqlQuery(text="SELECT * FROM missing_table", parameters={})
    mock_dependencies["text_to_sql"].generate_sql.return_value = first_sql
    mock_dependencies["sql_validator"].validate_and_enforce.return_value = first_sql
    
    # DB throws an error on first execute, succeeds on second
    second_sql = SqlQuery(text="SELECT * FROM good_table", parameters={})
    mock_dependencies["text_to_sql"].fix_sql.return_value = second_sql
    mock_dependencies["sql_validator"].validate_and_enforce.side_effect = [first_sql, second_sql]
    
    mock_dependencies["sql_executor"].execute.side_effect = [
        Exception("Table missing_table doesn't exist"),
        [{"id": 1}]
    ]
    
    mock_dependencies["result_summarizer"].summarize.return_value = ("Success", None)
    mock_dependencies["watcher_agent"].review_and_correct.return_value = "Success"
    
    # Execute
    result = await service.handle(base_question)
    
    # Assert fix_sql was called once
    mock_dependencies["text_to_sql"].fix_sql.assert_called_once()
    assert result.sql == second_sql
    assert result.summary == "Success"


@pytest.mark.asyncio
async def test_service_fatal_failure(service, mock_dependencies, base_question):
    # Setup persistent failure
    bad_sql = SqlQuery(text="SELECT syntax error", parameters={})
    mock_dependencies["text_to_sql"].generate_sql.return_value = bad_sql
    mock_dependencies["sql_validator"].validate_and_enforce.return_value = bad_sql
    mock_dependencies["text_to_sql"].fix_sql.return_value = bad_sql
    
    # DB fails 3 times
    mock_dependencies["sql_executor"].execute.side_effect = Exception("Persistent DB error")
    
    # Execute
    result = await service.handle(base_question)
    
    # Assert
    assert result.rows is None
    assert "unable to process that request" in result.summary
    assert "Max retries exceeded" in result.warnings
