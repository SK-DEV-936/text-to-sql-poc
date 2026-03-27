from typing import List
from pydantic import BaseModel
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from boons_text_to_sql_agent.marketing_module.domain.models import SMSVariation, CampaignStrategy

class CopywriterOutput(BaseModel):
    sms_variations: List[SMSVariation]
    strategic_rationale_markdown: str

class LangchainCopywriterAgent:
    def __init__(self, llm_model: str = "gpt-4o"):
        self.llm = ChatOpenAI(model=llm_model, temperature=0.7)
        self.structured_llm = self.llm.with_structured_output(CopywriterOutput)
        
        self.prompt = ChatPromptTemplate.from_messages([
            ("system", """You are a premier Brand Communications Expert specializing in luxury hospitality and high-conversion SMS marketing.
You are fundamentally opposed to "spammy", generic marketing. Every message you craft must feel like a warm, exclusive, highly personalized VIP invitation.

STRATEGY: {campaign_strategy}
RESTAURANT BRAND CONTEXT: {website_context}
AVAILABLE IMAGES: {merchant_gallery_images}

YOUR TASK:
1. Analyze the context to match the restaurant's tone.
2. Write 3 distinct variations of the SMS copy (Strictly under 160 characters per variation):
   - Direct & Action-Oriented.
   - Warm & Relational (The "Owner's Note").
   - Scarcity/Urgency driven.
   *CRITICAL RULE*: Every SMS MUST end with an actionable "Order Now" link using the provided RESTAURANT BRAND CONTEXT URL (e.g. https://[website]/order).
3. Select the best image URL from the images to attach as an MMS flyer.
4. Output strict JSON matching the requested schema."""),
            ("user", "Draft the SMS variations.")
        ])

    async def generate_copy(self, strategy: CampaignStrategy, website_context: str, gallery_json: str) -> CopywriterOutput:
        chain = self.prompt | self.structured_llm
        
        response = await chain.ainvoke({
            "campaign_strategy": strategy.model_dump_json(),
            "website_context": website_context,
            "merchant_gallery_images": gallery_json
        })
        return response
