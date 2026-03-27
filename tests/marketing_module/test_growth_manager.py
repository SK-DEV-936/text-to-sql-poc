import pytest
from unittest.mock import AsyncMock, patch
from boons_text_to_sql_agent.marketing_module.infrastructure.llm.growth_manager import LangchainGrowthManager
from boons_text_to_sql_agent.marketing_module.domain.models import CampaignStrategy

@pytest.mark.asyncio
@patch("boons_text_to_sql_agent.marketing_module.infrastructure.llm.growth_manager.ChatOpenAI")
async def test_growth_manager_strategy_generation(mock_chat_openai):
    # Arrange: Mock the structured LLM chain response
    mock_llm_instance = AsyncMock()
    mock_chat_openai.return_value = mock_llm_instance
    
    mock_chain_invoke = AsyncMock()
    mock_chain_invoke.ainvoke.return_value = CampaignStrategy(
        campaign_name="Test Promo",
        rationale="Testing framework",
        target_segment_logic="Select all test users",
        offer_type="Free Test",
        estimated_conversion_rate=5.0
    )
    
    # We patch the run pipeline to avoid actual API calls
    manager = LangchainGrowthManager()
    manager.prompt = AsyncMock()
    manager.structured_llm = AsyncMock()
    # Mocking the piped chain `self.prompt | self.structured_llm`
    with patch.object(manager.prompt, '__or__', return_value=mock_chain_invoke):
        
        # Act
        result = await manager.generate_strategy({
            "merchant_data_stats": {"orders_dropped": "yes"}
        })
        
        # Assert
        assert isinstance(result, CampaignStrategy)
        assert result.campaign_name == "Test Promo"
        mock_chain_invoke.ainvoke.assert_called_once()
