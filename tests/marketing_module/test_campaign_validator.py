import pytest
from unittest.mock import AsyncMock, patch
from boons_text_to_sql_agent.marketing_module.infrastructure.llm.campaign_validator import LangchainCampaignValidator
from boons_text_to_sql_agent.marketing_module.domain.models import ValidationResult, CampaignOnePager, CampaignStrategy, SMSVariation

@pytest.mark.asyncio
@patch("boons_text_to_sql_agent.marketing_module.infrastructure.llm.campaign_validator.ChatOpenAI")
async def test_campaign_validator(mock_chat_openai):
    mock_llm = AsyncMock()
    mock_chat_openai.return_value = mock_llm
    
    mock_chain_invoke = AsyncMock()
    mock_chain_invoke.ainvoke.return_value = ValidationResult(
        is_safe=False,
        feedback_reason="Spammy AI behavior detected."
    )
    
    validator = LangchainCampaignValidator()
    validator.prompt = AsyncMock()
    validator.structured_llm = AsyncMock()
    
    strategy = CampaignStrategy(campaign_name="Test", rationale="Test", target_segment_logic="Test", offer_type="Discount", estimated_conversion_rate=5.0)
    one_pager = CampaignOnePager(
        restaurant_id=1,
        strategy=strategy,
        target_audience_size=100,
        sms_variations=[SMSVariation(variation_type="Direct", copy_text="Spam", mms_image_url=None)],
        estimated_cost_usd=1.0
    )
    
    with patch.object(validator.prompt, '__or__', return_value=mock_chain_invoke):
        result = await validator.validate(one_pager)
        
        assert result.is_safe is False
        assert "Spammy" in result.feedback_reason
