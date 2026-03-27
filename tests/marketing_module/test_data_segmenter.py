import pytest
from unittest.mock import AsyncMock, patch
from boons_text_to_sql_agent.marketing_module.infrastructure.llm.data_segmenter import LangchainDataSegmenter, SecurityValidationError

@patch("boons_text_to_sql_agent.marketing_module.infrastructure.llm.data_segmenter.ChatOpenAI")
def test_sql_validation_success(mock_chat_openai):
    segmenter = LangchainDataSegmenter()
    valid_sql = "SELECT u.phone FROM users u WHERE u.role_id = 1 AND u.restaurant_id = __RLS_MERCHANTS__"
    
    clean_sql = segmenter.validate_sql_security(valid_sql)
    assert "SELECT" in clean_sql
    assert "__RLS_MERCHANTS__" in clean_sql

@patch("boons_text_to_sql_agent.marketing_module.infrastructure.llm.data_segmenter.ChatOpenAI")
def test_sql_validation_fails_on_delete(mock_chat_openai):
    segmenter = LangchainDataSegmenter()
    malicious_sql = "DELETE FROM users WHERE restaurant_id = __RLS_MERCHANTS__"
    
    with pytest.raises(SecurityValidationError) as exc:
        segmenter.validate_sql_security(malicious_sql)
    assert "not a SELECT statement" in str(exc.value)

@patch("boons_text_to_sql_agent.marketing_module.infrastructure.llm.data_segmenter.ChatOpenAI")
def test_sql_validation_fails_on_missing_rls(mock_chat_openai):
    segmenter = LangchainDataSegmenter()
    invalid_sql = "SELECT phone FROM users WHERE role_id = 1"
    
    with pytest.raises(SecurityValidationError) as exc:
        segmenter.validate_sql_security(invalid_sql)
    assert "Missing mandatory __RLS_MERCHANTS__" in str(exc.value)

@pytest.mark.asyncio
@patch("boons_text_to_sql_agent.marketing_module.infrastructure.llm.data_segmenter.ChatOpenAI")
async def test_segmenter_full_generation(mock_chat_openai):
    mock_llm = AsyncMock()
    # Mocking the text response of the LLM content
    mock_response = AsyncMock()
    mock_response.content = "```sql\nSELECT u.phone FROM users u WHERE u.restaurant_id = __RLS_MERCHANTS__;\n```"
    
    # Mock chain
    mock_chain = AsyncMock()
    mock_chain.ainvoke.return_value = mock_response
    
    segmenter = LangchainDataSegmenter()
    segmenter.prompt = AsyncMock()
    segmenter.llm = AsyncMock()
    
    with patch.object(segmenter.prompt, '__or__', return_value=mock_chain):
        result = await segmenter.generate_sql_segment(
            target_segment_logic="Get users",
            schema_context="schema"
        )
        
        assert isinstance(result, str)
        assert "__RLS_MERCHANTS__" in result
        assert "```sql" not in result # Check cleaning works
