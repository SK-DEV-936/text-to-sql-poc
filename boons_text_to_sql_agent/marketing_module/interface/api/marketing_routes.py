from fastapi import APIRouter, HTTPException
from boons_text_to_sql_agent.marketing_module.domain.models import CampaignOnePager
from boons_text_to_sql_agent.marketing_module.application.use_cases.generate_campaign_service import GenerateCampaignService
from boons_text_to_sql_agent.marketing_module.infrastructure.db.marketing_schema_provider import StaticMarketingSchemaProvider

router = APIRouter(prefix="/api/marketing", tags=["Marketing Module"])

@router.post("/generate-campaign", response_model=CampaignOnePager)
async def generate_campaign(restaurant_id: int):
    try:
        # Instantiate schema dependencies
        schema_provider = StaticMarketingSchemaProvider()
        
        # Inject dependencies into the core Application Use Case
        service = GenerateCampaignService(schema_port=schema_provider)
        
        # Execute orchestration
        result = await service.execute(restaurant_id)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
