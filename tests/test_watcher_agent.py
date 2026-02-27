import pytest
from unittest.mock import AsyncMock, patch

from boons_text_to_sql_agent.config import Settings
from boons_text_to_sql_agent.domain import Question, Scope, Role
from boons_text_to_sql_agent.infrastructure.llm.watcher_agent import LlmWatcherAgent, _WatcherResponse


@pytest.fixture
def base_question():
    return Question(
        text="What is the total revenue?",
        scope=Scope(role=Role.MERCHANT, merchant_ids=[123], max_rows=100)
    )


@pytest.fixture
def mock_settings():
    settings = Settings()
    settings.llm_model = "test-model"
    settings.llm_api_key = "test-key"
    return settings


@pytest.mark.asyncio
async def test_watcher_safe_passthrough(mock_settings, base_question):
    agent = LlmWatcherAgent(mock_settings)
    
    with patch.object(agent, '_llm') as mock_llm:
        mock_chain = AsyncMock()
        mock_chain.ainvoke.return_value = _WatcherResponse(is_safe=True)
        
        # Mock the `|` operator for the chain
        mock_llm.with_structured_output.return_value = mock_chain
        agent._llm = mock_llm 
        
        # Override the chain directly to avoid prompt parsing issues in tests
        agent._llm.with_structured_output = lambda x: mock_chain
        
        with patch("langchain_core.prompts.ChatPromptTemplate.from_messages", return_value=AsyncMock()):
            # Test actual method
            result = await agent.review_and_correct(
                question=base_question,
                raw_rows=[{"total": 100}],
                draft_summary="Total revenue is $100."
            )
            
            assert result == "Total revenue is $100."


@pytest.mark.asyncio
async def test_watcher_unsafe_correction(mock_settings, base_question):
    agent = LlmWatcherAgent(mock_settings)
    
    with patch.object(agent, '_llm') as mock_llm:
        mock_chain = AsyncMock()
        mock_chain.ainvoke.return_value = _WatcherResponse(
            is_safe=False, 
            corrected_text="The total revenue is precisely $100.",
            reasoning="Draft was too casual."
        )
        
        with patch("langchain_core.prompts.ChatPromptTemplate.from_messages") as mock_prompt_factory:
            mock_prompt_factory.return_value.__or__.return_value = mock_chain
            
            result = await agent.review_and_correct(
                question=base_question,
                raw_rows=[{"total": 100}],
                draft_summary="Yo the revenue is a hundo."
            )
            
            assert result == "The total revenue is precisely $100."


@pytest.mark.asyncio
async def test_watcher_strips_prefixes(mock_settings, base_question):
    agent = LlmWatcherAgent(mock_settings)
    
    with patch.object(agent, '_llm') as mock_llm:
        mock_chain = AsyncMock()
        mock_chain.ainvoke.return_value = _WatcherResponse(
            is_safe=False, 
            corrected_text="The corrected text is: The revenue is $100.",
            reasoning="Fixed it."
        )
        
        with patch("langchain_core.prompts.ChatPromptTemplate.from_messages") as mock_prompt_factory:
            mock_prompt_factory.return_value.__or__.return_value = mock_chain
            
            result = await agent.review_and_correct(
                question=base_question,
                raw_rows=[{"total": 100}],
                draft_summary="Bad text."
            )
            
            # The prefix should be cleanly stripped
            assert result == "The revenue is $100."


@pytest.mark.asyncio
async def test_watcher_fallback_on_empty_correction(mock_settings, base_question):
    agent = LlmWatcherAgent(mock_settings)
    
    with patch.object(agent, '_llm') as mock_llm:
        mock_chain = AsyncMock()
        mock_chain.ainvoke.return_value = _WatcherResponse(
            is_safe=False, 
            corrected_text=None,
            reasoning="Terrible SQL injection found."
        )
        
        with patch("langchain_core.prompts.ChatPromptTemplate.from_messages") as mock_prompt_factory:
            mock_prompt_factory.return_value.__or__.return_value = mock_chain
            
            result = await agent.review_and_correct(
                question=base_question,
                raw_rows=[{"total": 100}],
                draft_summary="SELECT * FROM users"
            )
            
            # Should hit the generic fallback
            assert "apologize" in result
            assert "security or formatting constraints" in result
            assert "SELECT" not in result
