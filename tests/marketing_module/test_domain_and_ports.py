import pytest
import asyncio
from boons_text_to_sql_agent.marketing_module.domain.models import CampaignStrategy, SMSVariation, CampaignOnePager
from boons_text_to_sql_agent.marketing_module.infrastructure.db.marketing_schema_provider import StaticMarketingSchemaProvider

def test_domain_model_serialization():
    # Arrange
    strategy = CampaignStrategy(
        campaign_name="Lapsed User Promo",
        rationale="20% drop in Friday sales",
        target_segment_logic="Users with no orders in 3 weeks",
        offer_type="Discount",
        estimated_conversion_rate=3.5
    )
    sms = SMSVariation(
        variation_type="Urgent",
        copy_text="Come back to Friday Pizza! 20% off today.",
        mms_image_url="http://image.url"
    )
    
    # Act
    one_pager = CampaignOnePager(
        restaurant_id=101,
        strategy=strategy,
        target_audience_size=500,
        sms_variations=[sms],
        estimated_cost_usd=10.0
    )
    
    # Assert
    assert one_pager.restaurant_id == 101
    assert one_pager.strategy.campaign_name == "Lapsed User Promo"
    assert len(one_pager.sms_variations) == 1
    
    # Test JSON dump
    payload = one_pager.model_dump()
    assert payload["strategy"]["offer_type"] == "Discount"

@pytest.mark.asyncio
async def test_schema_provider():
    provider = StaticMarketingSchemaProvider()
    schema_str = await provider.get_db_schema_context()
    
    # Assert critical columns and security are present in prompt context
    assert "__RLS_MERCHANTS__" in schema_str
    assert "users" in schema_str
    
    assets = await provider.get_merchant_assets(999)
    assert assets["website"] == "https://restaurant999-demo.com"
