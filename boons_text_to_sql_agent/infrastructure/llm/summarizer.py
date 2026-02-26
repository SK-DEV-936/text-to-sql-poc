import json
from typing import Any, Mapping, Sequence

from langchain_core.prompts import ChatPromptTemplate

from boons_text_to_sql_agent.application.ports import ResultSummarizerPort
from boons_text_to_sql_agent.config import Settings
from boons_text_to_sql_agent.domain import Question


class NoopSummarizer(ResultSummarizerPort):
    """Initial summarizer implementation: returns no summary.

    This keeps behavior simple; we can plug in an LLM-based summarizer later.
    """

    async def summarize(self, question: Question, rows: Sequence[Mapping[str, Any]]) -> str | None:
        return None


class LlmSummarizer(ResultSummarizerPort):
    """Real LLM summarizer using LangChain to generate natural language responses."""

    def __init__(self, settings: Settings):
        self._settings = settings
        self._llm = self._init_llm()

    def _init_llm(self) -> Any:
        if self._settings.is_aws_environment:
            from langchain_aws import ChatBedrock
            return ChatBedrock(
                model_id=self._settings.bedrock_model_id,
                region_name=self._settings.aws_region,
            )
        else:
            from langchain_openai import ChatOpenAI
            return ChatOpenAI(
                model=self._settings.llm_model,
                api_key=self._settings.llm_api_key,
                temperature=0.7
            )

    async def summarize(self, question: Question, rows: Sequence[Mapping[str, Any]]) -> str | None:
        if not rows:
            return "No data found matching your query."

        prompt = ChatPromptTemplate.from_messages([
            ("system", "{summarization_prompt}"),
            ("human", "Question: {question}\n\nData Results (JSON):\n{data_json}")
        ])

        chain = prompt | self._llm
        
        summarization_prompt = self._settings.prompts.summarization_prompt if self._settings.prompts else ""
        
        response = await chain.ainvoke({
            "summarization_prompt": summarization_prompt,
            "user_role": question.scope.role.value,
            "question": question.text,
            "data_json": json.dumps(list(rows)[:20], indent=2, default=str) # Limit context and handle datetimes
        })

        return str(response.content)

