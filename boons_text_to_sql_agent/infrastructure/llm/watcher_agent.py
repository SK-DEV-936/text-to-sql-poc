from typing import Any, Mapping, Sequence
from datetime import datetime

from pydantic import BaseModel, Field

from boons_text_to_sql_agent.application.ports.result_summarizer import ResultSummarizerPort
from boons_text_to_sql_agent.config import Settings
from boons_text_to_sql_agent.domain import Question


class _WatcherResponse(BaseModel):
    is_safe: bool = Field(
        description="True if the text is factually accurate, professional, and follows all rules. False if it fails."
    )
    corrected_text: str | None = Field(
        default=None,
        description="If is_safe is False, provide the corrected text here. If True, this can be null."
    )
    reasoning: str | None = Field(
        default=None,
        description="Internal thoughts on why the text was deemed unsafe or incorrect."
    )


class LlmWatcherAgent:
    """An AI Watcher Agent that grades the output of the LlmSummarizer.
    
    It acts as a final safety check, ensuring the summary text:
    1. Accurately reflects the raw database JSON result.
    2. Does not mention SQL, tables, columns, or internal logic.
    3. Maintains a professional tone appropriate for the user's role.
    4. Adheres to legal and social norms (no offensive language, bias, or data bleeding).
    """

    def __init__(self, settings: Settings):
        self._settings = settings
        self._llm = self._init_llm()

    def _init_llm(self) -> Any:
        if self._settings.is_aws_environment and not self._settings.force_local_rag:
            from langchain_aws import ChatBedrock
            return ChatBedrock(
                model_id=self._settings.bedrock_model_id,
                region_name=self._settings.aws_region,
                temperature=0.0 # Watcher should be deterministic
            )
        else:
            from langchain_openai import ChatOpenAI
            return ChatOpenAI(
                model=self._settings.llm_model,
                api_key=self._settings.llm_api_key,
                temperature=0.0 # Watcher should be deterministic
            )

    async def review_and_correct(
        self, 
        question: Question, 
        raw_rows: Sequence[Mapping[str, Any]], 
        draft_summary: str
    ) -> str:
        """Review the draft summary and return either the original or a corrected version."""
        
        from langchain_core.prompts import ChatPromptTemplate
        import json
        
        # We limit the rows to avoid blowing up the context window
        limited_rows = list(raw_rows)[:50] if raw_rows else []
        data_json = json.dumps({
            "total_rows_in_result_set": len(raw_rows),
            "sample_rows": limited_rows
        }, indent=2, default=str)

        prompt = ChatPromptTemplate.from_messages([
            ("system", 
             "You are a strict QA Compliance Agent for a restaurant analytics AI.\n"
             "Your job is to review the Draft Response written by another AI and guarantee it meets all criteria:\n"
             "1. Factual Accuracy: The response MUST accurately reflect the Raw Data JSON. Do not hallucinate numbers.\n"
             "2. No Tech Jargon: The response MUST NOT mention SQL, queries, databases, row-level security, or table names.\n"
             "3. Social/Legal Safety: The response MUST be polite, professional, and free of any harmful, biased, or restricted content.\n"
             "4. Role Accuracy: The response must address the user correctly (Role: {user_role}).\n\n"
             "If the Draft Response passes all checks, set `is_safe` to true.\n"
             "If the Draft Response fails any check, set `is_safe` to false and write the `corrected_text`.\n"
             "CRITICAL: The `corrected_text` MUST ONLY contain the final natural language response for the user.\n"
             "CRITICAL: DO NOT include phrases like 'However, the correct text is...', 'Correction:', or 'Revised summary:'. Just the response itself.\n"
             "CRITICAL: Use standard ASCII characters and maintain perfect spacing. No smushed text.\n"
             "CRITICAL: ALWAYS put a space before and after markdown emphasis (e.g., ' **$1,234.56** ').\n"
             "CRITICAL: ONLY use standard '*' for markdown. NEVER use '∗'." 
            ),
            ("human", 
             "User Question: {question}\n"
             "Raw Data JSON: {data_json}\n\n"
             "Draft Response to Review: {draft_summary}"
            )
        ])

        chain = prompt | self._llm.with_structured_output(_WatcherResponse)
        
        try:
            response: _WatcherResponse = await chain.ainvoke({
                "user_role": question.scope.role.value,
                "question": question.text,
                "data_json": data_json,
                "draft_summary": draft_summary
            })
            
            if not response.is_safe:
                import logging
                logger = logging.getLogger(__name__)
                logger.warning(f"Watcher Agent intercepted unsafe response. Reason: {response.reasoning}")
                
                if response.corrected_text:
                    # Strip any common LLM conversational prefixes that violate instructions
                    cleaned_text = response.corrected_text
                    prefixes_to_strip = [
                        "the corrected text is:",
                        "correction:",
                        "revised summary:",
                        "here is the fixed text:",
                        "here is the corrected text:"
                    ]
                    lower_text = cleaned_text.lower()
                    for prefix in prefixes_to_strip:
                        if lower_text.startswith(prefix):
                            cleaned_text = cleaned_text[len(prefix):].strip()
                    
                    if cleaned_text:
                        return cleaned_text
                
                # If the Watcher Agent flagged it but failed to provide safe corrected text
                logger.error("Watcher Agent failed to provide a safe corrected response. Falling back to generic safety message.")
                return "I apologize, but I am unable to summarize that specific data due to security or formatting constraints. Please try rephrasing your request."
                
            return draft_summary
            
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Watcher Agent failed during evaluation: {e}. Falling back to draft summary.")
            return draft_summary
