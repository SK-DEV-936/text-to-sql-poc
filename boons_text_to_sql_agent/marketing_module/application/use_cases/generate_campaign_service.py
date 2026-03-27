from boons_text_to_sql_agent.marketing_module.domain.models import CampaignOnePager
from boons_text_to_sql_agent.marketing_module.application.ports import MarketingSchemaPort
from boons_text_to_sql_agent.marketing_module.infrastructure.llm.growth_manager import LangchainGrowthManager
from boons_text_to_sql_agent.marketing_module.infrastructure.llm.data_segmenter import LangchainDataSegmenter
from boons_text_to_sql_agent.marketing_module.infrastructure.llm.copywriter import LangchainCopywriterAgent
from boons_text_to_sql_agent.marketing_module.infrastructure.llm.campaign_validator import LangchainCampaignValidator

class GenerateCampaignService:
    def __init__(self, schema_port: MarketingSchemaPort):
        self.schema_port = schema_port
        self.strategist = LangchainGrowthManager()
        self.segmenter = LangchainDataSegmenter()
        self.copywriter = LangchainCopywriterAgent()
        self.validator = LangchainCampaignValidator()

    async def execute(self, restaurant_id: int) -> CampaignOnePager:
        # 1. Fetch Schema context & Assets
        schema_context = await self.schema_port.get_db_schema_context()
        assets = await self.schema_port.get_merchant_assets(restaurant_id)
        
        # We mock 'merchant_data_stats' for MVP. In prod, we execute raw analytics SQL.
        merchant_stats = {
            "restaurant_id": restaurant_id,
            "orders_dropped_recent_weeks": True,
            "top_item": "Spicy Tuna Roll"
        }
        
        # 2. Strategy phase (Growth Manager)
        strategy = await self.strategist.generate_strategy({
            "merchant_data_stats": merchant_stats,
            "external_context": "Weekend approaching"
        })
        
        # 3. SQL Segmentation phase (Data Analyst)
        safe_sql = await self.segmenter.generate_sql_segment(
            target_segment_logic=strategy.target_segment_logic,
            schema_context=schema_context
        )
        
        # In prod, we execute `safe_sql` to count. Mocking size:
        audience_size = 350
        
        # 4. Copywriter phase
        copy_output = await self.copywriter.generate_copy(
            strategy=strategy,
            website_context=assets.get("website", "Generic brand"),
            gallery_json=str(assets.get("gallery_json", "[]"))
        )
        
        # 5. Assemble One-Pager Document
        # Cost config: $0.0079 per SMS
        cost_estimate = audience_size * 0.0079
        
        one_pager = CampaignOnePager(
            restaurant_id=restaurant_id,
            strategy=strategy,
            target_audience_size=audience_size,
            sms_variations=copy_output.sms_variations,
            estimated_cost_usd=round(cost_estimate, 2)
        )
        
        # 6. Safety Verification phase (The Watcher)
        validation = await self.validator.validate(one_pager)
        one_pager.is_safe = validation.is_safe
        one_pager.validation_feedback = validation.feedback_reason
        
        return one_pager
