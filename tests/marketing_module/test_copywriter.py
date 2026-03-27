import pytest
from unittest.mock import AsyncMock, patch
from boons_text_to_sql_agent.marketing_module.domain.models import CampaignStrategy, SMSVariation
from boons_text_to_sql_agent.marketing_module.infrastructure.llm.copywriter import LangchainCopywriterAgent, CopywriterOutput

@pytest.mark.asyncio
@patch("boons_text_to_sql_agent.marketing_module.infrastructure.llm.copywriter.ChatOpenAI")
async def test_copywriter_generation(mock_chat_openai):
    mock_llm_instance = AsyncMock()
    mock_chat_openai.return_value = mock_llm_instance
    
    # Mocking the structured output response
    mock_chain_invoke = AsyncMock()
    mock_chain_invoke.ainvoke.return_value = CopywriterOutput(
        sms_variations=[
            SMSVariation(variation_type="Direct", copy_text="Get 20% off!", mms_image_url="http://img.com/1.jpg"),
            SMSVariation(variation_type="Warm", copy_text="We miss you so much.", mms_image_url="http://img.com/1.jpg"),
            SMSVariation(variation_type="Urgent", copy_text="Only 2 hours left!", mms_image_url="http://img.com/1.jpg")
        ],
        strategic_rationale_markdown="## Rationale\nTesting the tone mapping."
    )
    
    agent = LangchainCopywriterAgent()
    agent.prompt = AsyncMock()
    agent.structured_llm = AsyncMock()
    
    strategy = CampaignStrategy(
        campaign_name="Test",
        rationale="Test",
        target_segment_logic="Test",
        offer_type="Discount",
        estimated_conversion_rate=5.0
    )
    
    with patch.object(agent.prompt, '__or__', return_value=mock_chain_invoke):
        result = await agent.generate_copy(
            strategy=strategy,
            website_context="Fine Italian Dining",
            gallery_json='["http://img.com/1.jpg"]'
        )
        
        assert len(result.sms_variations) == 3
        assert result.sms_variations[0].mms_image_url == "http://img.com/1.jpg"
