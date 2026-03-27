import asyncio
import os
import json
from dotenv import load_dotenv

# Load user's live OPENAI_API_KEY
load_dotenv()

from boons_text_to_sql_agent.marketing_module.infrastructure.db.marketing_schema_provider import StaticMarketingSchemaProvider
from boons_text_to_sql_agent.marketing_module.application.use_cases.generate_campaign_service import GenerateCampaignService

async def test_live_agent():
    if not os.getenv("OPENAI_API_KEY"):
        print("ERROR: OPENAI_API_KEY is not set. Cannot run live model.")
        return
        
    print("🚀 Booting Boons Marketing Agents...")
    print("1. Schema Provider Initialized")
    
    schema_port = StaticMarketingSchemaProvider()
    service = GenerateCampaignService(schema_port=schema_port)
    
    print("2. Firing GenerateCampaignService (restaurant_id=1)...")
    print("   -> Growth Manager analyzing stats...")
    print("   -> Data Analyst segmenting via SQL...")
    print("   -> Copywriter scanning assets and writing SMS...")
    print("   -> Watcher Agent verifying brand safety...")
    
    try:
        result = await service.execute(restaurant_id=1)
        print("\n✅ ======== C A M P A I G N   P R O P O S A L ========")
        print(json.dumps(result.model_dump(), indent=2))
    except Exception as e:
        print(f"\n❌ FAILED: {str(e)}")

if __name__ == "__main__":
    asyncio.run(test_live_agent())
