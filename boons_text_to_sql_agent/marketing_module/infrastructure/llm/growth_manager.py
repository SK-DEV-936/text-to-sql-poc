from typing import Dict, Any
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from boons_text_to_sql_agent.marketing_module.application.ports import MarketingAiPort
from boons_text_to_sql_agent.marketing_module.domain.models import CampaignStrategy

class LangchainGrowthManager(MarketingAiPort):
    def __init__(self, llm_model: str = "gpt-4o"):
        self.llm = ChatOpenAI(model=llm_model, temperature=0.7)
        self.structured_llm = self.llm.with_structured_output(CampaignStrategy)
        
        self.prompt = ChatPromptTemplate.from_messages([
            ("system", """You are an elite, data-driven Restaurant Growth Hacker working for the Boons Analytics Platform. 
Your objective is to ingest raw database statistics and external context (like weather or holidays) to formulate ONE highly profitable, targeted SMS marketing campaign.

You must ignore generic, spammy marketing tactics. Instead, look for hidden data correlations (e.g., "30% of users who order pasta haven't ordered in 3 weeks" or "It will rain this Friday, let's push delivery comfort food").

**INPUT CONTEXT:**
- Merchant Data: {merchant_data_stats}
- External Events/Weather: {external_context}

**CONSTRAINTS:**
1. The campaign goal must be highly specific and tied directly to the data.
2. The `target_segment_logic` must be described in clear, technical terms so a Data Engineer can write a SQL query to target those exact users.
3. You must output STRICTLY IN JSON format matching the schema properties."""),
            ("user", "Analyze this data and give me the best campaign: {merchant_data_stats}")
        ])

    async def generate_strategy(self, merchant_data: Dict[str, Any]) -> CampaignStrategy:
        chain = self.prompt | self.structured_llm
        
        context = merchant_data.get("external_context", "Normal trading conditions")
        stats = str(merchant_data.get("merchant_data_stats", merchant_data))
        
        response = await chain.ainvoke({
            "merchant_data_stats": stats,
            "external_context": context
        })
        
        return response
