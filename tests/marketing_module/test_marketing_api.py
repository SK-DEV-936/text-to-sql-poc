import pytest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient
from fastapi import FastAPI
from boons_text_to_sql_agent.marketing_module.interface.api.marketing_routes import router

app = FastAPI()
app.include_router(router)
client = TestClient(app)

@patch("boons_text_to_sql_agent.marketing_module.application.use_cases.generate_campaign_service.GenerateCampaignService.execute", new_callable=AsyncMock)
def test_generate_campaign_api(mock_execute):
    from boons_text_to_sql_agent.marketing_module.domain.models import CampaignOnePager, CampaignStrategy, SMSVariation
    # Arrange
    strategy = CampaignStrategy(
        campaign_name="Test Promo",
        rationale="Testing integration",
        target_segment_logic="All users",
        offer_type="Discount",
        estimated_conversion_rate=5.0
    )
    one_pager = CampaignOnePager(
        restaurant_id=1,
        strategy=strategy,
        target_audience_size=100,
        sms_variations=[SMSVariation(variation_type="Direct", copy_text="Hey there", mms_image_url=None)],
        estimated_cost_usd=1.0
    )
    mock_execute.return_value = one_pager
    
    # Act
    # TestClient works synchronously even over async routes
    response = client.post("/api/marketing/generate-campaign?restaurant_id=1")
    
    # Assert
    assert response.status_code == 200
    assert response.json()["restaurant_id"] == 1
    assert response.json()["strategy"]["campaign_name"] == "Test Promo"
