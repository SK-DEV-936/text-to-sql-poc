from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from boons_text_to_sql_agent.marketing_module.domain.models import ValidationResult, CampaignOnePager

class LangchainCampaignValidator:
    def __init__(self, llm_model: str = "gpt-4o"):
        self.llm = ChatOpenAI(model=llm_model, temperature=0.0)
        self.structured_llm = self.llm.with_structured_output(ValidationResult)
        
        self.prompt = ChatPromptTemplate.from_messages([
            ("system", """You are the final Safety Watcher for a top-tier Restaurant Communications platform.
Your job is to review AI-generated SMS Marketing proposals before they are shown to the Merchant.

You must catch and reject:
1. Spammy, aggressive, or coercive language (e.g., "BUY NOW OR LOSE OUT!!!").
2. Brand-damaging offers that don't make financial sense or look like mistakes.
3. Offensive terms, hallucinations, or broken placeholder strings like {{name}}.

**PROPOSAL DATA TO REVIEW:**
{proposal}

**YOUR DIRECTIVE:**
Evaluate the proposal.
If it is safe, high-quality, and looks like a respectful invitation from a restaurant, return is_safe=true.
If it violates any safety, spam, or quality constraints, return is_safe=false and provide extremely concise feedback_reason explaining why it was flagged."""),
            ("user", "Validate this campaign.")
        ])

    async def validate(self, proposal: CampaignOnePager) -> ValidationResult:
        chain = self.prompt | self.structured_llm
        
        # We temporarily hide the validation fields from the payload dump 
        # so the LLM doesn't recursively read its own empty feedback
        payload = proposal.model_dump(exclude={"is_safe", "validation_feedback"})
        
        response = await chain.ainvoke({
            "proposal": str(payload)
        })
        
        return response
